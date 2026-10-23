//! A JPEG segment walker that keeps only what draws the picture.
//!
//! An allow list, not a deny list: segments Kilit does not know are dropped.
//! The walk follows the entropy-coded data scan by scan (progressive JPEGs
//! have several) and stops at the first end-of-image marker, so pictures a
//! phone appended after the main one (depth maps, previews, motion photos,
//! each with its own EXIF and GPS) go too.

use crate::{CleanError, Removed, take_exif};

const SOI: u8 = 0xD8;
const EOI: u8 = 0xD9;
const SOS: u8 = 0xDA;
const APP0: u8 = 0xE0;
const APP1: u8 = 0xE1;
const APP2: u8 = 0xE2;
const APP13: u8 = 0xED;
const APP14: u8 = 0xEE;
const COM: u8 = 0xFE;

const EXIF: &[u8] = b"Exif\0\0";
const XMP: &[u8] = b"http://ns.adobe.com/xap/1.0/\0";
const XMP_EXT: &[u8] = b"http://ns.adobe.com/xmp/extension/\0";

fn is_rst(m: u8) -> bool {
    (0xD0..=0xD7).contains(&m)
}

/// Markers with no length and no payload.
fn standalone(m: u8) -> bool {
    m == 0x01 || is_rst(m) || m == SOI || m == EOI
}

/// What to do with one segment.
fn judge(
    marker: u8,
    payload: &[u8],
    removed: &mut Vec<Removed>,
    keep_exif: &mut Option<Vec<u8>>,
    damaged: &mut bool,
) -> bool {
    match marker {
        // JFIF is required by some readers; JFXX can carry a thumbnail
        APP0 => {
            if payload.starts_with(b"JFIF\0") {
                true
            } else {
                removed.push(Removed::Other);
                false
            }
        }
        APP1 => {
            if let Some(exif) = payload.strip_prefix(EXIF) {
                *keep_exif = take_exif(exif, removed);
            } else if payload.starts_with(XMP) || payload.starts_with(XMP_EXT) {
                removed.push(Removed::Xmp);
            } else {
                removed.push(Removed::Other);
            }
            false
        }
        // colour profiles stay; MPF (the index of appended pictures) and
        // FlashPix go
        APP2 => {
            if payload.starts_with(b"ICC_PROFILE\0") {
                true
            } else {
                removed.push(Removed::ExtraImages);
                false
            }
        }
        APP13 => {
            removed.push(Removed::Iptc);
            false
        }
        // Adobe's segment says how to read the colours of CMYK JPEGs
        APP14 => {
            if payload.starts_with(b"Adobe") {
                true
            } else {
                removed.push(Removed::Other);
                false
            }
        }
        0xE3..=0xEF => {
            removed.push(Removed::Other);
            false
        }
        COM => {
            removed.push(Removed::Comment);
            false
        }
        // tables, frame and scan headers: the picture itself, kept only
        // when their structure is what the standard says, so nothing can
        // ride along inside a block disguised as a table
        0xC4 | 0xCC | 0xDA..=0xDD | 0xC0..=0xC3 | 0xC5..=0xC7 | 0xC9..=0xCB | 0xCD..=0xCF => {
            if well_formed(marker, payload) {
                true
            } else {
                *damaged = true;
                false
            }
        }
        // anything else (JPG extensions, hierarchical markers, reserved
        // codes) does not draw a baseline or progressive picture
        _ => {
            removed.push(Removed::Other);
            false
        }
    }
}

/// Whether a table or header segment has exactly the layout ITU T.81 gives
/// it: no spare bytes anywhere.
fn well_formed(marker: u8, p: &[u8]) -> bool {
    match marker {
        // DQT: tables of 64 one-byte or 64 two-byte values
        0xDB => {
            let mut i = 0;
            while let Some(&pq) = p.get(i) {
                let size = match pq >> 4 {
                    0 => 64,
                    1 => 128,
                    _ => return false,
                };
                i += 1 + size;
            }
            !p.is_empty() && i == p.len()
        }
        // DHT: a class/id byte, 16 counts, then that many symbols
        0xC4 => {
            let mut i = 0;
            while i < p.len() {
                let Some(counts) = p.get(i + 1..i + 17) else {
                    return false;
                };
                let n: usize = counts.iter().map(|&c| usize::from(c)).sum();
                if n > 256 {
                    return false;
                }
                i += 17 + n;
            }
            !p.is_empty() && i == p.len()
        }
        // DAC: pairs
        0xCC => !p.is_empty() && p.len().is_multiple_of(2),
        // DRI, DNL: one 16-bit value
        0xDC | 0xDD => p.len() == 2,
        // SOS: component count, two bytes each, three more
        0xDA => p
            .first()
            .is_some_and(|&n| (1..=4).contains(&n) && p.len() == 1 + 2 * usize::from(n) + 3),
        // SOFn: precision, height, width, component count, three bytes each
        _ => p.len() >= 6 && p[5] >= 1 && p.len() == 6 + 3 * usize::from(p[5]),
    }
}

/// The index just past the entropy-coded data that starts at `i`: the
/// position of the next real marker's 0xFF.
fn entropy_end(d: &[u8], mut i: usize) -> Option<usize> {
    while i + 1 < d.len() {
        if d[i] == 0xFF {
            let next = d[i + 1];
            // stuffed 0xFF, restart markers and fill bytes belong to the scan
            if next == 0x00 || is_rst(next) || next == 0xFF {
                i += if next == 0xFF { 1 } else { 2 };
                continue;
            }
            return Some(i);
        }
        i += 1;
    }
    None
}

pub fn clean(d: &[u8], removed: &mut Vec<Removed>) -> Result<Vec<u8>, CleanError> {
    let mut out = Vec::with_capacity(d.len());
    out.extend_from_slice(&[0xFF, SOI]);
    let mut keep_exif = None;
    // where a minimal EXIF goes: after SOI and JFIF
    let mut exif_at = out.len();
    let mut i = 2;
    loop {
        if d.get(i) != Some(&0xFF) {
            return Err(CleanError::Damaged);
        }
        while d.get(i) == Some(&0xFF) {
            i += 1;
        }
        let marker = *d.get(i).ok_or(CleanError::Damaged)?;
        i += 1;
        if marker == EOI {
            out.extend_from_slice(&[0xFF, EOI]);
            if i < d.len() {
                removed.push(Removed::ExtraImages);
            }
            break;
        }
        if standalone(marker) {
            // a stray SOI or RST outside a scan carries nothing; drop it
            continue;
        }
        let len = usize::from(u16::from_be_bytes(
            d.get(i..i + 2)
                .ok_or(CleanError::Damaged)?
                .try_into()
                .map_err(|_| CleanError::Damaged)?,
        ));
        let end = i
            .checked_add(len)
            .filter(|&e| len >= 2 && e <= d.len())
            .ok_or(CleanError::Damaged)?;
        let payload = &d[i + 2..end];
        let mut damaged = false;
        let keep = judge(marker, payload, removed, &mut keep_exif, &mut damaged);
        if damaged {
            return Err(CleanError::Damaged);
        }
        if keep {
            out.extend_from_slice(&[0xFF, marker]);
            out.extend_from_slice(&d[i..end]);
            if marker == APP0 {
                exif_at = out.len();
            }
        }
        i = end;
        if marker == SOS {
            let scan_end = entropy_end(d, i).ok_or(CleanError::Damaged)?;
            out.extend_from_slice(&d[i..scan_end]);
            i = scan_end;
        }
    }
    if let Some(exif) = keep_exif {
        let mut seg = Vec::with_capacity(4 + EXIF.len() + exif.len());
        seg.extend_from_slice(&[0xFF, APP1]);
        let len = u16::try_from(2 + EXIF.len() + exif.len()).map_err(|_| CleanError::Damaged)?;
        seg.extend_from_slice(&len.to_be_bytes());
        seg.extend_from_slice(EXIF);
        seg.extend_from_slice(&exif);
        out.splice(exif_at..exif_at, seg);
    }
    Ok(out)
}
