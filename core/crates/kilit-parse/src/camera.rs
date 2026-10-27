//! A camera frame to a JPEG, in memory. The camera hands over YUV 4:2:0
//! planes; nothing of the picture is ever written to disk, and the JPEG has
//! no metadata at all: no EXIF, no location, no camera model.

use image::codecs::jpeg::JpegEncoder;
use image::{ExtendedColorType, ImageEncoder, RgbImage, imageops};

use crate::CleanError;

/// The largest frame accepted, per side.
const MAX_SIDE: u32 = 8192;

/// One YUV 4:2:0 frame, plane by plane, with the strides the camera gave.
pub struct Frame<'a> {
    /// Width in pixels.
    pub width: u32,
    /// Height in pixels.
    pub height: u32,
    /// The luma plane.
    pub y: &'a [u8],
    /// The blue-difference plane.
    pub u: &'a [u8],
    /// The red-difference plane.
    pub v: &'a [u8],
    /// Bytes per row of the luma plane.
    pub y_row: usize,
    /// Bytes per row of the chroma planes.
    pub uv_row: usize,
    /// Bytes from one chroma sample to the next (1 planar, 2 interleaved).
    pub uv_pixel: usize,
    /// Clockwise turn that makes the picture upright: 0, 90, 180 or 270.
    pub rotation: u16,
}

fn clamp(x: f32) -> u8 {
    x.round().clamp(0.0, 255.0) as u8
}

/// The frame as a JPEG of the given quality (1 to 100), turned upright.
pub fn to_jpeg(f: &Frame<'_>, quality: u8) -> Result<Vec<u8>, CleanError> {
    let (w, h) = (f.width, f.height);
    if w == 0 || h == 0 || w > MAX_SIDE || h > MAX_SIDE || f.uv_pixel == 0 {
        return Err(CleanError::Damaged);
    }
    let (wu, hu) = (w as usize, h as usize);
    // every sample read below must be inside its plane
    let y_need = (hu - 1) * f.y_row + wu;
    let uv_need = ((hu - 1) / 2) * f.uv_row + ((wu - 1) / 2) * f.uv_pixel + 1;
    if f.y_row < wu || f.y.len() < y_need || f.u.len() < uv_need || f.v.len() < uv_need {
        return Err(CleanError::Damaged);
    }
    let mut rgb = RgbImage::new(w, h);
    for (x, y, px) in rgb.enumerate_pixels_mut() {
        let (xu, yu) = (x as usize, y as usize);
        let luma = f32::from(f.y[yu * f.y_row + xu]);
        let c = (yu / 2) * f.uv_row + (xu / 2) * f.uv_pixel;
        let cb = f32::from(f.u[c]) - 128.0;
        let cr = f32::from(f.v[c]) - 128.0;
        // ITU-R BT.601, full range, as Android's cameras give it
        *px = image::Rgb([
            clamp(luma + 1.402 * cr),
            clamp(luma - 0.344_136 * cb - 0.714_136 * cr),
            clamp(luma + 1.772 * cb),
        ]);
    }
    let rgb = match f.rotation {
        0 => rgb,
        90 => imageops::rotate90(&rgb),
        180 => imageops::rotate180(&rgb),
        270 => imageops::rotate270(&rgb),
        _ => return Err(CleanError::Damaged),
    };
    let mut out = Vec::new();
    JpegEncoder::new_with_quality(&mut out, quality.clamp(1, 100))
        .write_image(
            rgb.as_raw(),
            rgb.width(),
            rgb.height(),
            ExtendedColorType::Rgb8,
        )
        .map_err(|_| CleanError::Damaged)?;
    Ok(out)
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    /// A grey 6x4 frame, its chroma interleaved as Android's NV21 often is.
    fn grey(rotation: u16) -> Vec<u8> {
        let y = vec![128u8; 6 * 4];
        let uv = vec![128u8; 6 * 2];
        to_jpeg(
            &Frame {
                width: 6,
                height: 4,
                y: &y,
                u: &uv,
                v: &uv[1..],
                y_row: 6,
                uv_row: 6,
                uv_pixel: 2,
                rotation,
            },
            85,
        )
        .unwrap()
    }

    #[test]
    fn a_frame_becomes_an_upright_jpeg_without_metadata() {
        let jpeg = grey(90);
        assert!(jpeg.starts_with(&[0xFF, 0xD8]));
        let img = image::load_from_memory(&jpeg).unwrap();
        // turned: 4 wide, 6 high
        assert_eq!((img.width(), img.height()), (4, 6));
        // nothing for the cleaner to take out
        assert_eq!(crate::clean(&jpeg).unwrap().removed, vec![]);
        let px = img.to_rgb8().get_pixel(1, 1).0;
        assert!(px.iter().all(|&c| (120..=136).contains(&c)), "{px:?}");
    }

    #[test]
    fn short_planes_and_odd_turns_are_refused() {
        let y = vec![0u8; 10];
        let uv = vec![0u8; 10];
        let f = |w, rotation| Frame {
            width: w,
            height: 4,
            y: &y,
            u: &uv,
            v: &uv,
            y_row: w as usize,
            uv_row: w as usize,
            uv_pixel: 1,
            rotation,
        };
        assert_eq!(to_jpeg(&f(6, 0), 80), Err(CleanError::Damaged));
        assert_eq!(to_jpeg(&f(0, 0), 80), Err(CleanError::Damaged));
        assert_eq!(to_jpeg(&f(2, 45), 80), Err(CleanError::Damaged));
        assert!(grey(0).len() > 100 && grey(180).len() > 100 && grey(270).len() > 100);
    }
}
