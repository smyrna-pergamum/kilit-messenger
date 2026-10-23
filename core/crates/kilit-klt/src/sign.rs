//! Hybrid signatures: Ed25519 and ML-DSA-65, both must verify.

use ed25519_dalek::{Signature as EdSignature, VerifyingKey};
use libcrux_ml_dsa::ml_dsa_65::{self, MLDSA65Signature, MLDSA65VerificationKey};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha512};

use crate::{KltError, SignerKeys};

/// The ML-DSA context string for packet signatures.
pub(crate) const MLDSA_CONTEXT: &[u8] = b"kilit/klt1";
const DOMAIN: &[u8] = b"KLT1-sig-v1\0";
/// The largest encoded signature a reader accepts.
pub(crate) const MAX_SIGNATURE_LEN: u32 = 8 * 1024;
const ED25519_KEY_LEN: usize = 32;
const ED25519_SIG_LEN: usize = 64;
const MLDSA65_KEY_LEN: usize = 1952;
const MLDSA65_SIG_LEN: usize = 3309;

/// An Ed25519 signature and an ML-DSA-65 signature over the same message.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct HybridSignature {
    /// Ed25519 signature.
    #[serde(with = "serde_bytes")]
    pub ed25519: Vec<u8>,
    /// ML-DSA-65 signature.
    #[serde(with = "serde_bytes")]
    pub mldsa65: Vec<u8>,
}

/// Something that can sign packets. The vault implements it; the keys never
/// leave the vault.
pub trait PacketSigner {
    /// The public keys that verify this signer's signatures.
    fn signer_keys(&self) -> SignerKeys;
    /// Signs `message` with both algorithms, using `context` for ML-DSA.
    fn sign(&self, message: &[u8], context: &[u8]) -> Result<HybridSignature, KltError>;
}

/// The message a packet signature covers.
pub(crate) fn signed_message(manifest: &[u8], content_hash: &[u8]) -> Vec<u8> {
    let mut m = Vec::with_capacity(DOMAIN.len() + 128);
    m.extend_from_slice(DOMAIN);
    m.extend_from_slice(&Sha512::digest(manifest));
    m.extend_from_slice(content_hash);
    m
}

/// Checks both signatures over `message`. Fails if either one fails.
pub fn verify(
    keys: &SignerKeys,
    message: &[u8],
    context: &[u8],
    sig: &HybridSignature,
) -> Result<(), KltError> {
    let ed_key: &[u8; ED25519_KEY_LEN] = keys
        .ed25519
        .as_slice()
        .try_into()
        .map_err(|_| KltError::BadSignature)?;
    let ed_sig: &[u8; ED25519_SIG_LEN] = sig
        .ed25519
        .as_slice()
        .try_into()
        .map_err(|_| KltError::BadSignature)?;
    let ml_key: [u8; MLDSA65_KEY_LEN] = keys
        .mldsa65
        .as_slice()
        .try_into()
        .map_err(|_| KltError::BadSignature)?;
    let ml_sig: [u8; MLDSA65_SIG_LEN] = sig
        .mldsa65
        .as_slice()
        .try_into()
        .map_err(|_| KltError::BadSignature)?;

    VerifyingKey::from_bytes(ed_key)
        .map_err(|_| KltError::BadSignature)?
        .verify_strict(message, &EdSignature::from_bytes(ed_sig))
        .map_err(|_| KltError::BadSignature)?;
    ml_dsa_65::verify(
        &MLDSA65VerificationKey::new(ml_key),
        message,
        context,
        &MLDSA65Signature::new(ml_sig),
    )
    .map_err(|_| KltError::BadSignature)
}
