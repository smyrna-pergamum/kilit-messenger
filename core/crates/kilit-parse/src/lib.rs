//! Disposable parser compartment.
//!
//! Decodes untrusted images, PDFs and video, makes thumbnails and strips
//! metadata. Runs isolated and is killed after every job (for now it runs
//! in-process; the isolated process comes with the broker).
//!
//! [`clean`] removes what a file says about where, when and on what it was
//! made, without decoding or re-encoding the picture, so there is no loss of
//! quality. The format is recognised by its bytes, never by a name or a
//! media type someone else chose.

pub mod camera;
mod exif;
mod jpeg;

use img_parts::png::Png;
use img_parts::webp::{CHUNK_XMP, WebP};
use img_parts::{Bytes, ImageEXIF};

/// What [`clean`] took out.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum Removed {
    /// EXIF: camera, settings, dates, often a thumbnail.
    Exif,
    /// GPS coordinates inside the EXIF.
    Location,
    /// XMP: editing history, sometimes location and names.
    Xmp,
    /// IPTC: captions, author, copyright.
    Iptc,
    /// Free-text comments.
    Comment,
    /// More pictures after the main one: depth maps, previews, the other
    /// half of a "motion photo", each with its own metadata.
    ExtraImages,
    /// PNG text chunks (software, author, description) and timestamps.
    Text,
    /// Metadata blocks of other kinds.
    Other,
}

/// The result of cleaning a file.
#[derive(Debug, PartialEq, Eq)]
pub struct Report {
    /// The file without its metadata.
    pub data: Vec<u8>,
    /// What was removed, sorted, each kind once. Empty when there was
    /// nothing to remove.
    pub removed: Vec<Removed>,
}

/// Why a file could not be cleaned.
#[derive(Debug, PartialEq, Eq)]
pub enum CleanError {
    /// Not a format Kilit can clean (yet): send it as it is only after
    /// telling the user it may carry metadata.
    Unsupported,
    /// It claims a supported format but its structure is broken.
    Damaged,
}

/// The formats [`clean`] understands.
#[derive(Debug, PartialEq, Eq)]
enum Format {
    Jpeg,
    Png,
    WebP,
}

fn sniff(data: &[u8]) -> Option<Format> {
    if data.starts_with(&[0xFF, 0xD8, 0xFF]) {
        Some(Format::Jpeg)
    } else if data.starts_with(b"\x89PNG\r\n\x1a\n") {
        Some(Format::Png)
    } else if data.len() >= 12 && &data[0..4] == b"RIFF" && &data[8..12] == b"WEBP" {
        Some(Format::WebP)
    } else {
        None
    }
}

/// Strips location, camera, author and editing metadata from a JPEG, PNG or
/// WebP picture. The picture's orientation is kept, so it is not shown on
/// its side, and so are colour profiles, so its colours do not change.
pub fn clean(data: &[u8]) -> Result<Report, CleanError> {
    let mut removed = Vec::new();
    let data = match sniff(data).ok_or(CleanError::Unsupported)? {
        Format::Jpeg => jpeg::clean(data, &mut removed)?,
        Format::Png => clean_png(data, &mut removed)?,
        Format::WebP => clean_webp(data, &mut removed)?,
    };
    removed.sort();
    removed.dedup();
    Ok(Report { data, removed })
}

/// Notes what an EXIF block held, and returns the minimal one to keep.
fn take_exif(exif: &[u8], removed: &mut Vec<Removed>) -> Option<Vec<u8>> {
    let keep = exif::orientation(exif)
        .filter(|&o| o != 1)
        .map(exif::minimal);
    // a block that already is the minimal one was left by an earlier clean
    if keep.as_deref() != Some(exif) {
        removed.push(Removed::Exif);
    }
    if exif::has_gps(exif) {
        removed.push(Removed::Location);
    }
    keep
}

fn clean_png(data: &[u8], removed: &mut Vec<Removed>) -> Result<Vec<u8>, CleanError> {
    let mut png = Png::from_bytes(Bytes::copy_from_slice(data)).map_err(|_| CleanError::Damaged)?;
    let keep_exif = png.exif().and_then(|e| take_exif(&e, removed));
    let before = png.chunks().len();
    png.chunks_mut()
        .retain(|c| !matches!(&c.kind(), b"tEXt" | b"zTXt" | b"iTXt" | b"tIME"));
    if png.chunks().len() != before {
        removed.push(Removed::Text);
    }
    png.set_exif(keep_exif.map(Bytes::from));
    Ok(png.encoder().bytes().to_vec())
}

fn clean_webp(data: &[u8], removed: &mut Vec<Removed>) -> Result<Vec<u8>, CleanError> {
    let mut webp =
        WebP::from_bytes(Bytes::copy_from_slice(data)).map_err(|_| CleanError::Damaged)?;
    let keep_exif = webp.exif().and_then(|e| take_exif(&e, removed));
    if webp.has_chunk(CHUNK_XMP) {
        webp.remove_chunks_by_id(CHUNK_XMP);
        removed.push(Removed::Xmp);
    }
    // also rewrites the VP8X flags to match the chunks that are left
    webp.set_exif(keep_exif.map(Bytes::from));
    Ok(webp.encoder().bytes().to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn other_files_are_not_touched() {
        assert_eq!(clean(b"%PDF-1.7 ..."), Err(CleanError::Unsupported));
        assert_eq!(clean(b""), Err(CleanError::Unsupported));
        assert_eq!(clean(b"PK\x03\x04docx"), Err(CleanError::Unsupported));
    }

    #[test]
    fn a_broken_png_is_damaged_not_unsupported() {
        assert_eq!(clean(b"\x89PNG\r\n\x1a\nxx"), Err(CleanError::Damaged));
    }
}
