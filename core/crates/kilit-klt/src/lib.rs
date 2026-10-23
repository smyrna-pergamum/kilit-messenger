//! The KLT1 encrypted file format.
//!
//! A `.klt` file is the 4-byte magic `KLT1` followed by an age v1 file whose
//! recipients are Kilit's own post-quantum stanza types. `spec/KLT1.md` is
//! the authoritative description; this crate follows it.

mod armor;
mod carrier;
mod error;
mod manifest;
mod packet;
mod padme;
mod passphrase;
mod sign;
mod xwing;

pub use armor::{MAX_ARMORED, MAX_FOUND, TEXT_END, find_in_text, from_text, to_text};
pub use carrier::{
    Carried, MAX_MESSAGE_BYTES, MESSAGE_MIME, MESSAGE_NAME, carrier_file_name, carry, open_message,
    seal_message,
};
pub use error::KltError;
pub use manifest::{Manifest, SignerKeys};
pub use packet::{Opened, Signature, open, seal};
pub use passphrase::{KdfParams, PassphraseIdentity, PassphraseRecipient};
pub use sign::{HybridSignature, PacketSigner, verify};
pub use xwing::{XWingIdentity, XWingRecipient};

/// The first four bytes of every `.klt` file.
pub const MAGIC: &[u8; 4] = b"KLT1";

/// The prefix of a text-armored packet pasted into another app.
pub const TEXT_PREFIX: &str = "KLT1:";

/// The age label every Kilit recipient carries, so they can only be mixed
/// with other post-quantum recipients.
pub(crate) const PQ_LABEL: &str = "postquantum";

/// Why some bytes are not a `.klt` file.
#[derive(Debug, PartialEq, Eq)]
pub enum EnvelopeError {
    /// Shorter than the magic.
    TooShort,
    /// The magic does not match.
    NotKlt,
}

/// Returns the payload after the magic, or why the bytes are not a `.klt` file.
pub fn payload(bytes: &[u8]) -> Result<&[u8], EnvelopeError> {
    let (magic, rest) = bytes
        .split_first_chunk::<4>()
        .ok_or(EnvelopeError::TooShort)?;
    if magic == MAGIC {
        Ok(rest)
    } else {
        Err(EnvelopeError::NotKlt)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn recognises_the_magic() {
        assert_eq!(payload(b"KLT1age"), Ok(&b"age"[..]));
    }

    #[test]
    fn refuses_other_bytes() {
        assert_eq!(payload(b"KLT"), Err(EnvelopeError::TooShort));
        assert_eq!(payload(b"VEIL1:x"), Err(EnvelopeError::NotKlt));
    }
}
