//! `KLT1:<base64url>.` text armor for packets pasted into chat apps
//! (spec/KLT1.md, "Metin zırhı").

use base64::Engine;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;

use crate::{KltError, MAGIC, TEXT_PREFIX};

/// The largest packet that may be armored, in bytes. Its text is about
/// 60,000 characters, under WhatsApp's per-message limit.
pub const MAX_ARMORED: usize = 45_000;

/// Marks the end of an armored packet. Not in the base64url alphabet.
pub const TEXT_END: char = '.';

/// The most packets [`find_in_text`] looks for in one paste.
pub const MAX_FOUND: usize = 16;

const MAX_ENCODED: usize = MAX_ARMORED.div_ceil(3) * 4;

/// Encodes a packet as `KLT1:<base64url>.`.
pub fn to_text(packet: &[u8]) -> Result<String, KltError> {
    if !packet.starts_with(MAGIC) {
        return Err(KltError::NotKlt);
    }
    if packet.len() > MAX_ARMORED {
        return Err(KltError::Malformed("too large to send as text"));
    }
    Ok(format!(
        "{TEXT_PREFIX}{}{TEXT_END}",
        URL_SAFE_NO_PAD.encode(packet)
    ))
}

fn is_b64url(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '-' || c == '_'
}

/// Characters a chat app may slip into a long token without meaning to.
fn is_ignorable(c: char) -> bool {
    c.is_whitespace()
        || matches!(
            c,
            '\u{200B}' | '\u{200C}' | '\u{200D}' | '\u{2060}' | '\u{FEFF}' | '\u{00AD}'
        )
}

/// Reads one armored body starting right after the prefix. Returns the
/// decoded packet, or why it could not be read.
fn read_body(after_prefix: &str) -> Result<Vec<u8>, KltError> {
    let mut compact = String::new();
    for c in after_prefix.chars() {
        if c == TEXT_END {
            let packet = URL_SAFE_NO_PAD
                .decode(&compact)
                .map_err(|_| KltError::Malformed("bad text encoding"))?;
            if !packet.starts_with(MAGIC) {
                return Err(KltError::NotKlt);
            }
            return Ok(packet);
        }
        if is_b64url(c) {
            compact.push(c);
            if compact.len() > MAX_ENCODED {
                return Err(KltError::Malformed("too large to send as text"));
            }
        } else if !is_ignorable(c) {
            return Err(KltError::Malformed("unexpected character in the packet"));
        }
    }
    Err(KltError::Truncated)
}

/// Decodes exactly one armored packet, with nothing else around it but
/// whitespace.
pub fn from_text(text: &str) -> Result<Vec<u8>, KltError> {
    let text = text.trim_matches(is_ignorable);
    let body = text.strip_prefix(TEXT_PREFIX).ok_or(KltError::NotKlt)?;
    if !body.trim_end_matches(is_ignorable).ends_with(TEXT_END) {
        return Err(KltError::Truncated);
    }
    read_body(body)
}

/// Finds every armored packet in pasted text, in order, ignoring the text
/// around them. Each entry is the packet or why that one could not be read,
/// so the UI can say "this message was cut off" instead of staying silent.
pub fn find_in_text(text: &str) -> Vec<Result<Vec<u8>, KltError>> {
    text.match_indices(TEXT_PREFIX)
        .take(MAX_FOUND)
        .map(|(at, _)| read_body(&text[at + TEXT_PREFIX.len()..]))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn packet() -> Vec<u8> {
        b"KLT1 some sealed bytes \x00\xff".to_vec()
    }

    #[test]
    fn round_trip_survives_line_breaks_and_zero_width_spaces() {
        let text = to_text(&packet()).unwrap();
        let mangled = format!(
            "  {}\n{}\u{200B}{}  ",
            &text[..10],
            &text[10..20],
            &text[20..]
        );
        assert_eq!(from_text(&mangled).unwrap(), packet());
    }

    #[test]
    fn a_missing_end_marker_means_cut_off() {
        let text = to_text(&packet()).unwrap();
        let cut = &text[..text.len() - 1];
        assert!(matches!(from_text(cut), Err(KltError::Truncated)));
        assert!(matches!(from_text(&text[..12]), Err(KltError::Truncated)));
    }

    #[test]
    fn refuses_other_text() {
        assert!(matches!(from_text("VEIL1:abc."), Err(KltError::NotKlt)));
        assert!(matches!(
            from_text("KLT1:a!b."),
            Err(KltError::Malformed(_))
        ));
        assert!(matches!(from_text("KLT1:QUJD."), Err(KltError::NotKlt)));
    }

    #[test]
    fn finds_packets_inside_a_conversation() {
        let a = to_text(&packet()).unwrap();
        let mut other = packet();
        other.push(7);
        let b = to_text(&other).unwrap();
        let paste = format!("Merhaba, işte dosya:\n{a}\nve bir tane daha {b} görüşürüz.");
        let found = find_in_text(&paste);
        assert_eq!(found.len(), 2);
        assert_eq!(found[0].as_ref().unwrap(), &packet());
        assert_eq!(found[1].as_ref().unwrap(), &other);
    }

    #[test]
    fn a_cut_packet_in_a_paste_is_reported_not_skipped() {
        let a = to_text(&packet()).unwrap();
        let paste = format!("bak: {}", &a[..a.len() - 5]);
        let found = find_in_text(&paste);
        assert_eq!(found.len(), 1);
        assert!(matches!(found[0], Err(KltError::Truncated)));
    }

    #[test]
    fn text_without_packets_finds_nothing() {
        assert!(find_in_text("sadece sohbet, KLT1 ama iki nokta yok").is_empty());
    }

    #[test]
    fn looks_at_no_more_than_sixteen_packets() {
        let a = to_text(&packet()).unwrap();
        let paste = vec![a; 40].join(" ");
        assert_eq!(find_in_text(&paste).len(), MAX_FOUND);
    }
}
