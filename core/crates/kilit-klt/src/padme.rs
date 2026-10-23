//! Padmé padding (Nikitin et al., "Reducing Metadata Leakage from Encrypted
//! Files and Communication with PURBs", PETS 2019).
//!
//! Rounds a length up so that only O(log log L) bits of it remain visible,
//! with at most about 12% overhead.

/// The padded length for a plaintext of `len` bytes.
pub fn padded_len(len: u64) -> u64 {
    if len < 2 {
        return len;
    }
    let e = 63 - len.leading_zeros(); // floor(log2 len), at least 1
    let s = 32 - e.leading_zeros(); // floor(log2 e) + 1
    let zero_bits = e - s;
    let mask = (1u64 << zero_bits) - 1;
    (len + mask) & !mask
}

#[cfg(test)]
mod tests {
    use super::padded_len;

    #[test]
    fn never_shrinks_and_stays_within_twelve_percent() {
        for len in (0..5000u64).chain([65_535, 1 << 20, 3_000_001, 1 << 40]) {
            let p = padded_len(len);
            assert!(p >= len);
            assert!(p - len <= len / 8 + 1, "len {len} padded to {p}");
        }
    }

    #[test]
    fn known_values() {
        assert_eq!(padded_len(0), 0);
        assert_eq!(padded_len(1), 1);
        assert_eq!(padded_len(9), 10);
        assert_eq!(padded_len(1000), 1024);
        assert_eq!(padded_len(1025), 1088);
    }
}
