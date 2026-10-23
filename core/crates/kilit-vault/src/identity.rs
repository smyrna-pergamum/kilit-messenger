//! The keys that grow from the master secret, and the public half others see.

use ed25519_dalek::SigningKey;
use hkdf::Hkdf;
use libcrux_ml_dsa::ml_dsa_65::{self, MLDSA65KeyPair};
use sha2::{Digest, Sha256, Sha512};
use zeroize::{Zeroize, Zeroizing};

use crate::VaultError;

const ED25519_INFO: &[u8] = b"kilit/v1/ed25519";
const MLDSA65_INFO: &[u8] = b"kilit/v1/mldsa65";
const XWING_INFO: &[u8] = b"kilit/v1/xwing";
const FINGERPRINT_DOMAIN: &[u8] = b"kilit/v1/fingerprint\0";

/// Derives one 32-byte seed for one purpose from the master secret.
pub(crate) fn seed(master: &[u8; 32], info: &[u8]) -> Result<Zeroizing<[u8; 32]>, VaultError> {
    let mut out = Zeroizing::new([0u8; 32]);
    Hkdf::<Sha256>::new(None, master)
        .expand(info, out.as_mut())
        .map_err(|_| VaultError::Crypto)?;
    Ok(out)
}

pub(crate) fn ed25519(master: &[u8; 32]) -> Result<SigningKey, VaultError> {
    Ok(SigningKey::from_bytes(&*seed(master, ED25519_INFO)?))
}

/// An ML-DSA-65 key pair. The signing key is wiped when this drops, since
/// libcrux does not do it itself.
pub(crate) struct MlDsa(pub(crate) MLDSA65KeyPair);

impl Drop for MlDsa {
    fn drop(&mut self) {
        self.0.signing_key.as_mut_slice().zeroize();
    }
}

pub(crate) fn mldsa65(master: &[u8; 32]) -> Result<MlDsa, VaultError> {
    Ok(MlDsa(ml_dsa_65::generate_key_pair(*seed(
        master,
        MLDSA65_INFO,
    )?)))
}

pub(crate) fn xwing(master: &[u8; 32]) -> Result<kilit_klt::XWingIdentity, VaultError> {
    kilit_klt::XWingIdentity::from_seed(&*seed(master, XWING_INFO)?).map_err(|_| VaultError::Crypto)
}

/// Everything a contact needs to know about you: signature keys and the key
/// to seal packets to. Safe to share.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PublicIdentity {
    /// Ed25519 verifying key.
    pub ed25519: [u8; 32],
    /// ML-DSA-65 verification key.
    pub mldsa65: Vec<u8>,
    /// X-Wing public key for `.klt` packets.
    pub xwing: Vec<u8>,
}

impl PublicIdentity {
    /// A safety number to compare in person: 12 groups of 5 digits, the same
    /// on both phones only if both hold the same keys.
    pub fn fingerprint(&self) -> String {
        let mut h = Sha512::new();
        h.update(FINGERPRINT_DOMAIN);
        for part in [&self.ed25519[..], &self.mldsa65, &self.xwing] {
            h.update((part.len() as u32).to_be_bytes());
            h.update(part);
        }
        let digest = h.finalize();
        // as Signal's safety numbers: 5 hash bytes per group, reduced mod 10^5
        digest
            .as_chunks::<5>()
            .0
            .iter()
            .take(12)
            .map(|c| {
                let n = c.iter().fold(0u64, |acc, &b| acc << 8 | u64::from(b));
                format!("{:05}", n % 100_000)
            })
            .collect::<Vec<_>>()
            .join(" ")
    }
}
