//! The manifest at the start of every packet's encrypted stream.

use serde::{Deserialize, Serialize};

use crate::KltError;

/// The largest encoded manifest a reader accepts.
pub(crate) const MAX_MANIFEST_LEN: u32 = 64 * 1024;
const MAX_NAME_LEN: usize = 255;
const MAX_MIME_LEN: usize = 127;

/// The public keys of whoever made a signed packet.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct SignerKeys {
    /// Ed25519 verifying key.
    #[serde(with = "serde_bytes")]
    pub ed25519: Vec<u8>,
    /// ML-DSA-65 verification key.
    #[serde(with = "serde_bytes")]
    pub mldsa65: Vec<u8>,
}

/// What a packet holds. Everything here is encrypted.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Manifest {
    /// Format version, always 1.
    pub v: u8,
    /// The original file name, without any directory.
    pub name: String,
    /// The media type, such as `image/jpeg`.
    pub mime: String,
    /// The content length in bytes.
    pub size: u64,
    /// Who signed it, if anyone.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub signer: Option<SignerKeys>,
}

/// Whether a file name is a plain name that cannot point anywhere else.
fn name_is_safe(name: &str) -> bool {
    !name.is_empty()
        && name.len() <= MAX_NAME_LEN
        && name != "."
        && name != ".."
        && !name
            .chars()
            .any(|c| c == '/' || c == '\\' || c.is_control())
}

impl Manifest {
    pub(crate) fn validate(&self) -> Result<(), KltError> {
        if self.v != 1 {
            return Err(KltError::Malformed("unknown manifest version"));
        }
        if !name_is_safe(&self.name) {
            return Err(KltError::Malformed("unsafe file name"));
        }
        if self.mime.len() > MAX_MIME_LEN || self.mime.chars().any(char::is_control) {
            return Err(KltError::Malformed("bad media type"));
        }
        Ok(())
    }

    pub(crate) fn encode(&self) -> Result<Vec<u8>, KltError> {
        self.validate()?;
        let mut out = Vec::new();
        ciborium::into_writer(self, &mut out).map_err(|_| KltError::Malformed("manifest"))?;
        Ok(out)
    }

    pub(crate) fn decode(bytes: &[u8]) -> Result<Self, KltError> {
        let m: Self = ciborium::from_reader(bytes).map_err(|_| KltError::Malformed("manifest"))?;
        m.validate()?;
        Ok(m)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn names_that_escape_are_refused() {
        for bad in ["", ".", "..", "../x", "a/b", "a\\b", "x\ny"] {
            assert!(!name_is_safe(bad), "{bad:?} accepted");
        }
        for good in ["foto.jpg", "rapor 2026.pdf", "ç ğ ı ö ş ü.txt", "..gizli"] {
            assert!(name_is_safe(good), "{good:?} refused");
        }
    }
}
