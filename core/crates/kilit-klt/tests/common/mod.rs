//! Fixed keys shared by the tests and the vector generator.

// each test binary uses a different part of this module
#![allow(dead_code, clippy::unwrap_used)]

use ed25519_dalek::{Signer, SigningKey};
use kilit_klt::{HybridSignature, KltError, PacketSigner, SignerKeys};
use libcrux_ml_dsa::ml_dsa_65::{self, MLDSA65KeyPair};

/// A signer made from fixed seeds. Test use only.
pub struct TestSigner {
    pub ed: SigningKey,
    pub ml: MLDSA65KeyPair,
    pub claimed: Option<SignerKeys>,
}

impl TestSigner {
    pub fn new(n: u8) -> Self {
        Self {
            ed: SigningKey::from_bytes(&[n; 32]),
            ml: ml_dsa_65::generate_key_pair([n; 32]),
            claimed: None,
        }
    }

    pub fn keys(&self) -> SignerKeys {
        SignerKeys {
            ed25519: self.ed.verifying_key().to_bytes().to_vec(),
            mldsa65: self.ml.verification_key.as_slice().to_vec(),
        }
    }
}

impl PacketSigner for TestSigner {
    fn signer_keys(&self) -> SignerKeys {
        self.claimed.clone().unwrap_or_else(|| self.keys())
    }

    fn sign(&self, message: &[u8], context: &[u8]) -> Result<HybridSignature, KltError> {
        let ml = ml_dsa_65::sign(&self.ml.signing_key, message, context, [9; 32])
            .map_err(|_| KltError::Key("sign"))?;
        Ok(HybridSignature {
            ed25519: self.ed.sign(message).to_bytes().to_vec(),
            mldsa65: ml.as_slice().to_vec(),
        })
    }
}

/// The X-Wing seed of the vector recipient.
pub const VECTOR_XWING_SEED: [u8; 32] = [0x42; 32];
/// The seed of the vector signer.
pub const VECTOR_SIGNER_SEED: u8 = 7;
/// The passphrase of the passphrase vector.
pub const VECTOR_PASSPHRASE: &str = "kilit test vektörü bir";
/// The content of every vector.
pub const VECTOR_CONTENT: &[u8] = "Kilit KLT1 test vektörü.\n".as_bytes();
