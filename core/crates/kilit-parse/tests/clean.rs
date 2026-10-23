//! Real pictures, made by the image crate, with real metadata put in. The
//! cleaned file must decode to exactly the same pixels and carry none of it.

#![allow(clippy::unwrap_used, clippy::panic)]

use image::{ImageEncoder, RgbImage};
use img_parts::png::{Png, PngChunk};
use img_parts::{Bytes, ImageEXIF};
use kilit_parse::{CleanError, Removed, clean};

fn picture() -> RgbImage {
    RgbImage::from_fn(32, 24, |x, y| {
        image::Rgb([(x * 8) as u8, (y * 10) as u8, 128])
    })
}

fn jpeg_bytes() -> Vec<u8> {
    let mut out = Vec::new();
    image::codecs::jpeg::JpegEncoder::new_with_quality(&mut out, 90)
        .write_image(&picture(), 32, 24, image::ExtendedColorType::Rgb8)
        .unwrap();
    out
}

fn png_bytes() -> Vec<u8> {
    let mut out = Vec::new();
    image::codecs::png::PngEncoder::new(&mut out)
        .write_image(&picture(), 32, 24, image::ExtendedColorType::Rgb8)
        .unwrap();
    out
}

/// An EXIF with an orientation of 6 (turned right), a GPS pointer, and a
/// make string, little-endian like most phones write it.
fn phone_exif() -> Vec<u8> {
    let mut v = b"II\x2a\x00\x08\x00\x00\x00".to_vec();
    v.extend_from_slice(&3u16.to_le_bytes()); // three entries
    // Make (ASCII, count 8, offset 50)
    v.extend_from_slice(&0x010Fu16.to_le_bytes());
    v.extend_from_slice(&2u16.to_le_bytes());
    v.extend_from_slice(&8u32.to_le_bytes());
    v.extend_from_slice(&50u32.to_le_bytes());
    // Orientation = 6
    v.extend_from_slice(&0x0112u16.to_le_bytes());
    v.extend_from_slice(&3u16.to_le_bytes());
    v.extend_from_slice(&1u32.to_le_bytes());
    v.extend_from_slice(&6u16.to_le_bytes());
    v.extend_from_slice(&[0, 0]);
    // GPS IFD pointer
    v.extend_from_slice(&0x8825u16.to_le_bytes());
    v.extend_from_slice(&4u16.to_le_bytes());
    v.extend_from_slice(&1u32.to_le_bytes());
    v.extend_from_slice(&58u32.to_le_bytes());
    v.extend_from_slice(&0u32.to_le_bytes()); // no next IFD
    v.extend_from_slice(b"PhoneCo\0");
    v.extend_from_slice(b"GPS 41.0082N 28.9784E");
    v
}

fn segment(marker: u8, payload: &[u8]) -> Vec<u8> {
    let mut s = vec![0xFF, marker];
    s.extend_from_slice(&((payload.len() + 2) as u16).to_be_bytes());
    s.extend_from_slice(payload);
    s
}

/// A JPEG the way a phone leaves it: EXIF with GPS, XMP, IPTC, a comment,
/// an MPF index, and a second picture with its own EXIF after the end.
fn dirty_jpeg() -> Vec<u8> {
    let clean = jpeg_bytes();
    let mut d = clean[..2].to_vec(); // SOI
    let mut exif = b"Exif\0\0".to_vec();
    exif.extend_from_slice(&phone_exif());
    d.extend(segment(0xE1, &exif));
    d.extend(segment(
        0xE1,
        b"http://ns.adobe.com/xap/1.0/\0<x:xmpmeta>Ayse Yilmaz</x:xmpmeta>",
    ));
    d.extend(segment(
        0xED,
        b"Photoshop 3.0\08BIM caption: secret meeting",
    ));
    d.extend(segment(0xFE, b"taken at the secret place"));
    d.extend(segment(0xE2, b"MPF\0index of appended pictures"));
    d.extend_from_slice(&clean[2..]);
    // the appended picture, with location of its own
    let mut second = clean[..2].to_vec();
    second.extend(segment(0xE1, &exif));
    second.extend_from_slice(&clean[2..]);
    d.extend(second);
    d
}

fn contains(hay: &[u8], needle: &[u8]) -> bool {
    hay.windows(needle.len()).any(|w| w == needle)
}

#[test]
fn a_phone_jpeg_loses_every_trace_and_keeps_every_pixel() {
    let dirty = dirty_jpeg();
    let report = clean(&dirty).unwrap();
    assert_eq!(
        report.removed,
        vec![
            Removed::Exif,
            Removed::Location,
            Removed::Xmp,
            Removed::Iptc,
            Removed::Comment,
            Removed::ExtraImages,
        ]
    );
    for leak in [&b"PhoneCo"[..], b"41.0082N", b"Ayse", b"secret", b"MPF\0"] {
        assert!(
            !contains(&report.data, leak),
            "{:?} survived",
            String::from_utf8_lossy(leak)
        );
    }
    // exactly one picture: one start and one end of image
    assert_eq!(
        report
            .data
            .windows(2)
            .filter(|w| w == &[0xFF, 0xD8])
            .count(),
        1
    );
    assert!(report.data.ends_with(&[0xFF, 0xD9]));

    let before = image::load_from_memory(&jpeg_bytes()).unwrap().to_rgb8();
    let after = image::load_from_memory(&report.data).unwrap().to_rgb8();
    assert_eq!(before, after, "the picture changed");
}

#[test]
fn the_orientation_survives_so_the_photo_is_not_on_its_side() {
    let report = clean(&dirty_jpeg()).unwrap();
    let at = report
        .data
        .windows(6)
        .position(|w| w == b"Exif\0\0")
        .unwrap();
    let exif = &report.data[at + 6..at + 6 + 26];
    assert_eq!(
        exif,
        &[
            b'M', b'M', 0, 0x2a, 0, 0, 0, 8, 0, 1, 0x01, 0x12, 0, 3, 0, 0, 0, 1, 0, 6, 0, 0, 0, 0,
            0, 0
        ]
    );
}

#[test]
fn cleaning_twice_finds_nothing_more() {
    let once = clean(&dirty_jpeg()).unwrap();
    let twice = clean(&once.data).unwrap();
    assert_eq!(twice.removed, vec![]);
    assert_eq!(twice.data, once.data);
}

#[test]
fn a_clean_jpeg_comes_back_unchanged() {
    let plain = jpeg_bytes();
    let report = clean(&plain).unwrap();
    assert!(report.removed.is_empty(), "{:?}", report.removed);
    // nothing to remove: the very same bytes
    assert_eq!(report.data, plain);
}

#[test]
fn a_png_loses_its_text_and_exif() {
    let mut png = Png::from_bytes(Bytes::from(png_bytes())).unwrap();
    png.chunks_mut().insert(
        1,
        PngChunk::new(*b"tEXt", Bytes::from_static(b"Author\0Ayse Yilmaz")),
    );
    png.chunks_mut().insert(
        1,
        PngChunk::new(*b"tIME", Bytes::from_static(&[7, 234, 10, 23, 9, 30, 0])),
    );
    png.set_exif(Some(Bytes::from(phone_exif())));
    let dirty = png.encoder().bytes().to_vec();

    let report = clean(&dirty).unwrap();
    assert_eq!(
        report.removed,
        vec![Removed::Exif, Removed::Location, Removed::Text]
    );
    assert!(!contains(&report.data, b"Ayse"));
    assert!(!contains(&report.data, b"41.0082N"));
    assert_eq!(
        image::load_from_memory(&report.data).unwrap().to_rgb8(),
        picture()
    );
}

#[test]
fn a_cut_off_jpeg_is_damaged() {
    let jpeg = jpeg_bytes();
    assert_eq!(clean(&jpeg[..jpeg.len() / 2]), Err(CleanError::Damaged));
    assert_eq!(
        clean(&[0xFF, 0xD8, 0xFF, 0xE1, 0xFF]),
        Err(CleanError::Damaged)
    );
}

/// Untrusted input: every cut and many flipped bytes must give a result or
/// an error, never a panic or a hang.
#[test]
fn broken_files_never_panic() {
    let dirty = dirty_jpeg();
    for cut in 0..dirty.len() {
        let _ = clean(&dirty[..cut]);
    }
    let mut seed = 0x9E37_79B9u32;
    for _ in 0..2000 {
        let mut bad = dirty.clone();
        for _ in 0..4 {
            seed ^= seed << 13;
            seed ^= seed >> 17;
            seed ^= seed << 5;
            let at = seed as usize % bad.len();
            bad[at] = (seed >> 8) as u8;
        }
        if let Ok(r) = clean(&bad) {
            // whatever survives a mangled file is still free of the GPS text
            assert!(!contains(&r.data, b"41.0082N"));
        }
    }
    let mut png = png_bytes();
    for cut in 0..png.len() {
        let _ = clean(&png[..cut]);
    }
    png[20] ^= 0xFF;
    let _ = clean(&png);
}
