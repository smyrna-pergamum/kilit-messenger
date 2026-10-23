//! The KLT1 encrypted file format.
//!
//! A `.klt` file is the 4-byte magic `KLT1` followed by an age v1 payload
//! (see `spec/KLT1.md`). This crate only recognises the envelope for now;
//! sealing and opening land in Aşama 1.

/// The first four bytes of every `.klt` file.
pub const MAGIC: &[u8; 4] = b"KLT1";

/// The prefix of a text-armored packet pasted into another app.
pub const TEXT_PREFIX: &str = "KLT1:";

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
