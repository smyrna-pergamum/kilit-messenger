//! The `klt-xwing` recipient: HPKE (RFC 9180) with the X-Wing hybrid KEM
//! (ML-KEM-768 + X25519), backed by libcrux.

use std::collections::HashSet;

use age::secrecy::ExposeSecret;
use age::{DecryptError, EncryptError};
use age_core::format::{FileKey, Stanza};
use base64::Engine;
use base64::engine::general_purpose::STANDARD_NO_PAD;
use hpke_rs::{Hpke, HpkeKeyPair, HpkePrivateKey, HpkePublicKey, Mode};
use hpke_rs_crypto::types::{AeadAlgorithm, KdfAlgorithm, KemAlgorithm};
use hpke_rs_libcrux::HpkeLibcrux;
use zeroize::Zeroizing;

use crate::{KltError, PQ_LABEL};

pub(crate) const TAG: &str = "klt-xwing";
const INFO: &[u8] = b"kilit/klt1/xwing";
/// X-Wing public key length.
pub const PUBLIC_KEY_LEN: usize = 1216;
const ENC_LEN: usize = 1120;
const FILE_KEY_LEN: usize = 16;
const BODY_LEN: usize = FILE_KEY_LEN + 16;

fn hpke() -> Hpke<HpkeLibcrux> {
    Hpke::new(
        Mode::Base,
        KemAlgorithm::XWingDraft06,
        KdfAlgorithm::HkdfSha256,
        AeadAlgorithm::ChaCha20Poly1305,
    )
}

/// Someone a packet can be sealed to: a contact, or your own vault.
#[derive(Clone)]
pub struct XWingRecipient {
    public: HpkePublicKey,
}

impl XWingRecipient {
    /// Parses a 1216-byte X-Wing public key.
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, KltError> {
        if bytes.len() != PUBLIC_KEY_LEN {
            return Err(KltError::Key("an X-Wing public key is 1216 bytes"));
        }
        Ok(Self {
            public: HpkePublicKey::new(bytes.to_vec()),
        })
    }

    /// The raw public key.
    pub fn to_bytes(&self) -> Vec<u8> {
        self.public.as_slice().to_vec()
    }
}

impl age::Recipient for XWingRecipient {
    fn wrap_file_key(
        &self,
        file_key: &FileKey,
    ) -> Result<(Vec<Stanza>, HashSet<String>), EncryptError> {
        let (enc, body) = hpke()
            .seal(
                &self.public,
                INFO,
                b"",
                file_key.expose_secret(),
                None,
                None,
                None,
            )
            .map_err(|_| EncryptError::Io(std::io::Error::other("X-Wing encapsulation failed")))?;
        let stanza = Stanza {
            tag: TAG.to_owned(),
            args: vec![STANDARD_NO_PAD.encode(enc)],
            body,
        };
        Ok((vec![stanza], HashSet::from([PQ_LABEL.to_owned()])))
    }
}

/// The private half of an [`XWingRecipient`]. Lives only in the vault.
pub struct XWingIdentity {
    private: HpkePrivateKey,
    public: HpkePublicKey,
}

impl XWingIdentity {
    /// Derives the key pair from 32 bytes of secret seed material.
    pub fn from_seed(seed: &[u8; 32]) -> Result<Self, KltError> {
        let pair: HpkeKeyPair = hpke()
            .derive_key_pair(seed)
            .map_err(|_| KltError::Key("X-Wing key derivation failed"))?;
        let (private, public) = pair.into_keys();
        Ok(Self { private, public })
    }

    /// The recipient that seals to this identity.
    pub fn recipient(&self) -> XWingRecipient {
        XWingRecipient {
            public: self.public.clone(),
        }
    }
}

impl age::Identity for XWingIdentity {
    fn unwrap_stanza(&self, stanza: &Stanza) -> Option<Result<FileKey, DecryptError>> {
        if stanza.tag != TAG {
            return None;
        }
        let [enc] = stanza.args.as_slice() else {
            return Some(Err(DecryptError::InvalidHeader));
        };
        let Ok(enc) = STANDARD_NO_PAD.decode(enc) else {
            return Some(Err(DecryptError::InvalidHeader));
        };
        if enc.len() != ENC_LEN || stanza.body.len() != BODY_LEN {
            return Some(Err(DecryptError::InvalidHeader));
        }
        // a failed open means this stanza was sealed to someone else
        let plain = Zeroizing::new(
            hpke()
                .open(
                    &enc,
                    &self.private,
                    INFO,
                    b"",
                    &stanza.body,
                    None,
                    None,
                    None,
                )
                .ok()?,
        );
        let key: &[u8; FILE_KEY_LEN] = plain.as_slice().try_into().ok()?;
        Some(Ok(FileKey::new(Box::new(*key))))
    }
}
