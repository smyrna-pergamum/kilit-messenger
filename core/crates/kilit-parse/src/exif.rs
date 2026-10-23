//! Just enough TIFF/EXIF to read two things and write one: the orientation
//! and whether there is a GPS block, and a minimal EXIF carrying only the
//! orientation. Every read is bounds-checked; a malformed block yields
//! "no orientation" and "no GPS", never a panic.

const ORIENTATION: u16 = 0x0112;
const GPS_IFD: u16 = 0x8825;
const SHORT: u16 = 3;

struct Tiff<'a> {
    d: &'a [u8],
    little: bool,
}

impl<'a> Tiff<'a> {
    fn new(d: &'a [u8]) -> Option<Self> {
        let little = match d.get(0..2)? {
            b"II" => true,
            b"MM" => false,
            _ => return None,
        };
        let t = Self { d, little };
        (t.u16(2)? == 42).then_some(t)
    }

    fn u16(&self, at: usize) -> Option<u16> {
        let b: [u8; 2] = self.d.get(at..at.checked_add(2)?)?.try_into().ok()?;
        Some(if self.little {
            u16::from_le_bytes(b)
        } else {
            u16::from_be_bytes(b)
        })
    }

    fn u32(&self, at: usize) -> Option<u32> {
        let b: [u8; 4] = self.d.get(at..at.checked_add(4)?)?.try_into().ok()?;
        Some(if self.little {
            u32::from_le_bytes(b)
        } else {
            u32::from_be_bytes(b)
        })
    }

    /// The entries of IFD0 as (tag, type, offset of the value field).
    fn ifd0(&self) -> Option<Vec<(u16, u16, usize)>> {
        let start = usize::try_from(self.u32(4)?).ok()?;
        let count = usize::from(self.u16(start)?).min(512);
        (0..count)
            .map(|i| {
                let e = start.checked_add(2 + i * 12)?;
                Some((self.u16(e)?, self.u16(e + 2)?, e + 8))
            })
            .collect()
    }
}

/// The EXIF orientation (1 to 8), if there is a valid one.
pub fn orientation(exif: &[u8]) -> Option<u16> {
    let t = Tiff::new(exif)?;
    let (_, ty, at) = t
        .ifd0()?
        .into_iter()
        .find(|(tag, _, _)| *tag == ORIENTATION)?;
    if ty != SHORT {
        return None;
    }
    t.u16(at).filter(|o| (1..=8).contains(o))
}

/// Whether the EXIF points to a GPS block.
pub fn has_gps(exif: &[u8]) -> bool {
    Tiff::new(exif)
        .and_then(|t| t.ifd0())
        .is_some_and(|e| e.iter().any(|(tag, _, _)| *tag == GPS_IFD))
}

/// A 26-byte big-endian EXIF whose only entry is the orientation.
pub fn minimal(orientation: u16) -> Vec<u8> {
    let mut v = Vec::with_capacity(26);
    v.extend_from_slice(b"MM\x00\x2a"); // big-endian TIFF
    v.extend_from_slice(&8u32.to_be_bytes()); // IFD0 right after the header
    v.extend_from_slice(&1u16.to_be_bytes()); // one entry
    v.extend_from_slice(&ORIENTATION.to_be_bytes());
    v.extend_from_slice(&SHORT.to_be_bytes());
    v.extend_from_slice(&1u32.to_be_bytes()); // one value
    v.extend_from_slice(&orientation.to_be_bytes());
    v.extend_from_slice(&[0, 0]); // value field padding
    v.extend_from_slice(&0u32.to_be_bytes()); // no next IFD
    v
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_minimal_exif_reads_back() {
        for o in 1..=8 {
            let m = minimal(o);
            assert_eq!(m.len(), 26);
            assert_eq!(orientation(&m), Some(o));
            assert!(!has_gps(&m));
        }
    }

    #[test]
    fn garbage_is_neither_oriented_nor_located() {
        for bad in [
            &b""[..],
            b"MM",
            b"MM\x00\x2a\xff\xff\xff\xff",
            b"II\x2a\x00\x08\x00\x00\x00\xff\xff",
        ] {
            assert_eq!(orientation(bad), None);
            assert!(!has_gps(bad));
        }
    }
}
