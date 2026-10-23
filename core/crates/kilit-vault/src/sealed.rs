//! The vault at rest: the master secret sealed under PIN, hardware key and
//! Argon2id.

use argon2::{Algorithm, Argon2, Params, Version};
use chacha20poly1305::aead::{Aead, Payload};
use chacha20poly1305::{KeyInit, XChaCha20Poly1305, XNonce};
use ed25519_dalek::Signer;
use kilit_klt::{HybridSignature, KdfParams, KltError, PacketSigner, SignerKeys, XWingIdentity};
use libcrux_ml_dsa::ml_dsa_65;
use secrecy::{ExposeSecret, SecretString};
use serde::{Deserialize, Serialize};
use zeroize::Zeroizing;

use crate::identity::{self, PublicIdentity};
use crate::{HardwareKey, VaultError};

const VERSION: u8 = 1;
const PIN_DOMAIN: &[u8] = b"kilit/v1/vault-pin\0";
const SALT_LABEL: &[u8] = b"kilit/v1/vault";
const AAD_LABEL: &[u8] = b"kilit-vault-v1";
const MIN_PIN_CHARS: usize = 6;

#[derive(Serialize, Deserialize)]
struct SealedV1 {
    v: u8,
    m_kib: u32,
    t: u32,
    p: u32,
    #[serde(with = "serde_bytes")]
    salt: Vec<u8>,
    #[serde(with = "serde_bytes")]
    nonce: Vec<u8>,
    #[serde(with = "serde_bytes")]
    ct: Vec<u8>,
}

impl SealedV1 {
    fn params(&self) -> KdfParams {
        KdfParams {
            m_kib: self.m_kib,
            t: self.t,
            p: self.p,
        }
    }

    /// The header fields are bound to the ciphertext, so none can be swapped.
    fn aad(&self) -> Vec<u8> {
        let mut a = AAD_LABEL.to_vec();
        for n in [self.m_kib, self.t, self.p] {
            a.extend_from_slice(&n.to_be_bytes());
        }
        a.extend_from_slice(&self.salt);
        a
    }
}

fn random<const N: usize>() -> Result<[u8; N], VaultError> {
    let mut b = [0u8; N];
    getrandom::fill(&mut b).map_err(|_| VaultError::Crypto)?;
    Ok(b)
}

/// The bytes a hardware key MACs for a PIN: a fixed domain label, then the
/// PIN in UTF-8. Platform code that computes the MAC itself (Android
/// Keystore, Windows TPM) must MAC exactly these bytes.
pub fn pin_mac_input(pin: &SecretString) -> Zeroizing<Vec<u8>> {
    let mut input = Zeroizing::new(PIN_DOMAIN.to_vec());
    input.extend_from_slice(pin.expose_secret().as_bytes());
    input
}

/// HMAC(hardware key, [`pin_mac_input`]): what Argon2id stretches. Made on
/// the device, either here through a [`HardwareKey`] or by platform code.
pub struct PinMac(Zeroizing<[u8; 32]>);

impl PinMac {
    /// MACs `pin` with `hw`, refusing PINs shorter than six characters.
    pub fn compute(pin: &SecretString, hw: &dyn HardwareKey) -> Result<Self, VaultError> {
        if pin.expose_secret().chars().count() < MIN_PIN_CHARS {
            return Err(VaultError::Rejected("PIN too short"));
        }
        Ok(Self(Zeroizing::new(hw.mac(&pin_mac_input(pin))?)))
    }

    /// A MAC computed by platform code. The caller has checked the PIN's
    /// length, since the PIN itself never reaches Rust on this path.
    pub fn from_bytes(mac: [u8; 32]) -> Self {
        Self(Zeroizing::new(mac))
    }

    /// The MAC's bytes.
    pub fn to_bytes(&self) -> [u8; 32] {
        *self.0
    }
}

fn kek(pre: &PinMac, salt: &[u8], params: KdfParams) -> Result<Zeroizing<[u8; 32]>, VaultError> {
    let pre = &pre.0;
    let p = Params::new(params.m_kib, params.t, params.p, Some(32))
        .map_err(|_| VaultError::Rejected("Argon2id parameters"))?;
    let mut full_salt = SALT_LABEL.to_vec();
    full_salt.extend_from_slice(salt);
    let mut key = Zeroizing::new([0u8; 32]);
    Argon2::new(Algorithm::Argon2id, Version::V0x13, p)
        .hash_password_into(pre.as_ref(), &full_salt, key.as_mut())
        .map_err(|_| VaultError::Crypto)?;
    Ok(key)
}

fn cipher(key: &[u8; 32]) -> Result<XChaCha20Poly1305, VaultError> {
    XChaCha20Poly1305::new_from_slice(key).map_err(|_| VaultError::Crypto)
}

/// An unlocked vault. Dropping it wipes the master secret.
pub struct Vault {
    master: Zeroizing<[u8; 32]>,
}

impl Vault {
    /// The master secret, for keys derived elsewhere in this crate.
    pub(crate) fn master(&self) -> &[u8; 32] {
        &self.master
    }
}

impl Vault {
    /// Makes a new identity and returns it with its sealed form, which the
    /// store keeps.
    pub fn create(
        pin: &SecretString,
        hw: &dyn HardwareKey,
        params: KdfParams,
    ) -> Result<(Self, Vec<u8>), VaultError> {
        Self::create_with_mac(&PinMac::compute(pin, hw)?, params)
    }

    /// [`Vault::create`] with a MAC made by platform code.
    pub fn create_with_mac(mac: &PinMac, params: KdfParams) -> Result<(Self, Vec<u8>), VaultError> {
        let vault = Self {
            master: Zeroizing::new(random::<32>()?),
        };
        let sealed = vault.seal_with_mac(mac, params)?;
        Ok((vault, sealed))
    }

    /// Opens a sealed vault with the PIN.
    pub fn unlock(
        sealed: &[u8],
        pin: &SecretString,
        hw: &dyn HardwareKey,
    ) -> Result<Self, VaultError> {
        // a short PIN can never have sealed a vault; no need to MAC it
        let mac = PinMac::compute(pin, hw).map_err(|e| match e {
            VaultError::Rejected(_) => VaultError::Locked,
            e => e,
        })?;
        Self::unlock_with_mac(sealed, &mac)
    }

    /// [`Vault::unlock`] with a MAC made by platform code.
    pub fn unlock_with_mac(sealed: &[u8], mac: &PinMac) -> Result<Self, VaultError> {
        let s: SealedV1 = ciborium::from_reader(sealed).map_err(|_| VaultError::Locked)?;
        if s.v != VERSION {
            return Err(VaultError::Unsupported);
        }
        let params = s.params();
        if params.m_kib > KdfParams::MAXIMUM.m_kib
            || params.t > KdfParams::MAXIMUM.t
            || params.p > KdfParams::MAXIMUM.p
        {
            return Err(VaultError::Rejected("Argon2id parameters"));
        }
        let nonce: [u8; 24] = s
            .nonce
            .as_slice()
            .try_into()
            .map_err(|_| VaultError::Locked)?;
        let key = kek(mac, &s.salt, params)?;
        let plain = Zeroizing::new(
            cipher(&key)?
                .decrypt(
                    &XNonce::from(nonce),
                    Payload {
                        msg: &s.ct,
                        aad: &s.aad(),
                    },
                )
                .map_err(|_| VaultError::Locked)?,
        );
        let master: [u8; 32] = plain
            .as_slice()
            .try_into()
            .map_err(|_| VaultError::Locked)?;
        Ok(Self {
            master: Zeroizing::new(master),
        })
    }

    /// Seals this vault again, for a new PIN or new costs. The identity stays.
    pub fn seal(
        &self,
        pin: &SecretString,
        hw: &dyn HardwareKey,
        params: KdfParams,
    ) -> Result<Vec<u8>, VaultError> {
        self.seal_with_mac(&PinMac::compute(pin, hw)?, params)
    }

    /// [`Vault::seal`] with a MAC made by platform code: how a vault moves
    /// from the software key to a hardware one.
    pub fn seal_with_mac(&self, mac: &PinMac, params: KdfParams) -> Result<Vec<u8>, VaultError> {
        if params.m_kib < KdfParams::MINIMUM.m_kib
            || params.t < KdfParams::MINIMUM.t
            || params.p == 0
            || params.m_kib > KdfParams::MAXIMUM.m_kib
            || params.t > KdfParams::MAXIMUM.t
            || params.p > KdfParams::MAXIMUM.p
        {
            return Err(VaultError::Rejected("Argon2id parameters"));
        }
        let mut s = SealedV1 {
            v: VERSION,
            m_kib: params.m_kib,
            t: params.t,
            p: params.p,
            salt: random::<16>()?.to_vec(),
            nonce: random::<24>()?.to_vec(),
            ct: Vec::new(),
        };
        let key = kek(mac, &s.salt, params)?;
        let nonce: [u8; 24] = s
            .nonce
            .as_slice()
            .try_into()
            .map_err(|_| VaultError::Crypto)?;
        s.ct = cipher(&key)?
            .encrypt(
                &XNonce::from(nonce),
                Payload {
                    msg: self.master.as_ref(),
                    aad: &s.aad(),
                },
            )
            .map_err(|_| VaultError::Crypto)?;
        let mut out = Vec::new();
        ciborium::into_writer(&s, &mut out).map_err(|_| VaultError::Crypto)?;
        Ok(out)
    }

    /// The public keys to share with contacts.
    pub fn public_identity(&self) -> Result<PublicIdentity, VaultError> {
        Ok(PublicIdentity {
            ed25519: identity::ed25519(&self.master)?.verifying_key().to_bytes(),
            mldsa65: identity::mldsa65(&self.master)?
                .0
                .verification_key
                .as_slice()
                .to_vec(),
            xwing: identity::xwing(&self.master)?.recipient().to_bytes(),
        })
    }

    /// The identity that opens `.klt` packets sealed to this vault.
    pub fn klt_identity(&self) -> Result<XWingIdentity, VaultError> {
        identity::xwing(&self.master)
    }
}

impl PacketSigner for Vault {
    fn signer_keys(&self) -> SignerKeys {
        // the keys are derived deterministically; failure here means the
        // system ran out of memory, and an empty key then fails verification
        self.public_identity()
            .map(|p| SignerKeys {
                ed25519: p.ed25519.to_vec(),
                mldsa65: p.mldsa65,
            })
            .unwrap_or(SignerKeys {
                ed25519: Vec::new(),
                mldsa65: Vec::new(),
            })
    }

    fn sign(&self, message: &[u8], context: &[u8]) -> Result<HybridSignature, KltError> {
        let ed = identity::ed25519(&self.master).map_err(|_| KltError::Key("vault"))?;
        let ml = identity::mldsa65(&self.master).map_err(|_| KltError::Key("vault"))?;
        let rnd = random::<32>().map_err(|_| KltError::Key("no system randomness"))?;
        let ml_sig = ml_dsa_65::sign(&ml.0.signing_key, message, context, rnd)
            .map_err(|_| KltError::Key("ML-DSA signing failed"))?;
        Ok(HybridSignature {
            ed25519: ed.sign(message).to_bytes().to_vec(),
            mldsa65: ml_sig.as_slice().to_vec(),
        })
    }
}
