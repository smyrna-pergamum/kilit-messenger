//! `KLT1:` text armor for small packets pasted into chat apps.

use base64::Engine;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;

use crate::{KltError, MAGIC, TEXT_PREFIX};

/// The largest packet that may be armored, in bytes.
pub const MAX_ARMORED: usize = 64 * 1024;

/// Encodes a packet as `KLT1:<base64url>`.
pub fn to_text(packet: &[u8]) -> Result<String, KltError> {
    if !packet.starts_with(MAGIC) {
        return Err(KltError::NotKlt);
    }
    if packet.len() > MAX_ARMORED {
        return Err(KltError::Malformed("too large to send as text"));
    }
    Ok(format!("{TEXT_PREFIX}{}", URL_SAFE_NO_PAD.encode(packet)))
}

/// Decodes text made by [`to_text`]. Surrounding whitespace, and line breaks
/// a chat app may have inserted, are ignored.
pub fn from_text(text: &str) -> Result<Vec<u8>, KltError> {
    let body = text
        .trim()
        .strip_prefix(TEXT_PREFIX)
        .ok_or(KltError::NotKlt)?;
    let compact: String = body.chars().filter(|c| !c.is_whitespace()).collect();
    if compact.len() > MAX_ARMORED.div_ceil(3) * 4 {
        return Err(KltError::Malformed("too large to send as text"));
    }
    let packet = URL_SAFE_NO_PAD
        .decode(compact)
        .map_err(|_| KltError::Malformed("bad text encoding"))?;
    if !packet.starts_with(MAGIC) {
        return Err(KltError::NotKlt);
    }
    Ok(packet)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn round_trip_survives_chat_line_breaks() {
        let packet = b"KLT1 some sealed bytes \x00\xff".to_vec();
        let text = to_text(&packet).unwrap_or_default();
        let wrapped = format!("  {}\n{}  ", &text[..10], &text[10..]);
        assert_eq!(from_text(&wrapped).ok(), Some(packet));
    }

    #[test]
    fn refuses_other_text() {
        assert!(matches!(from_text("VEIL1:abc"), Err(KltError::NotKlt)));
        assert!(matches!(from_text("KLT1:!!!"), Err(KltError::Malformed(_))));
    }
}
