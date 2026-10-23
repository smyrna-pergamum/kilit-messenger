//! Sealing and opening whole packets (spec/KLT1.md, "İç düzen").

use std::io::{self, Read, Write};

use sha2::{Digest, Sha512};

use crate::manifest::MAX_MANIFEST_LEN;
use crate::padme::padded_len;
use crate::sign::{MAX_SIGNATURE_LEN, MLDSA_CONTEXT, signed_message};
use crate::{HybridSignature, KltError, MAGIC, Manifest, PacketSigner, SignerKeys, verify};

const CHUNK: usize = 64 * 1024;

/// Who vouches for an opened packet.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Signature {
    /// Nobody signed it.
    Unsigned,
    /// These keys signed it and both signatures verified.
    Verified(SignerKeys),
}

/// What [`open`] found.
#[derive(Clone, Debug)]
pub struct Opened {
    /// The manifest, already validated.
    pub manifest: Manifest,
    /// Who signed it.
    pub signature: Signature,
}

fn len_u32(len: usize) -> Result<[u8; 4], KltError> {
    u32::try_from(len)
        .map(u32::to_be_bytes)
        .map_err(|_| KltError::Malformed("field too long"))
}

/// Encrypts `size` bytes from `content` into a `.klt` packet written to `out`.
///
/// Every recipient must carry the `postquantum` label (all Kilit recipients
/// do). With a `signer`, the packet is signed and the manifest names the
/// signer. Returns `out` once the packet is complete.
pub fn seal<R: Read, W: Write>(
    name: &str,
    mime: &str,
    size: u64,
    mut content: R,
    recipients: &[&dyn age::Recipient],
    signer: Option<&dyn PacketSigner>,
    mut out: W,
) -> Result<W, KltError> {
    if recipients.is_empty() {
        return Err(KltError::Key("no recipients"));
    }
    let manifest = Manifest {
        v: 1,
        name: name.to_owned(),
        mime: mime.to_owned(),
        size,
        signer: signer.map(PacketSigner::signer_keys),
    };
    let manifest_bytes = manifest.encode()?;

    let encryptor = age::Encryptor::with_recipients(recipients.iter().copied())?;
    out.write_all(MAGIC)?;
    let mut w = encryptor.wrap_output(out)?;

    w.write_all(&len_u32(manifest_bytes.len())?)?;
    w.write_all(&manifest_bytes)?;

    let mut hasher = Sha512::new();
    let mut buf = vec![0u8; CHUNK];
    let mut left = size;
    while left > 0 {
        let want = usize::try_from(left.min(CHUNK as u64)).unwrap_or(CHUNK);
        let n = content.read(&mut buf[..want])?;
        if n == 0 {
            return Err(KltError::SizeMismatch);
        }
        hasher.update(&buf[..n]);
        w.write_all(&buf[..n])?;
        left -= n as u64;
    }
    if content.read(&mut buf[..1])? != 0 {
        return Err(KltError::SizeMismatch);
    }

    let sig_bytes = match signer {
        Some(s) => {
            let msg = signed_message(&manifest_bytes, &hasher.finalize());
            let sig = s.sign(&msg, MLDSA_CONTEXT)?;
            let mut v = Vec::new();
            ciborium::into_writer(&sig, &mut v).map_err(|_| KltError::Malformed("signature"))?;
            v
        }
        None => Vec::new(),
    };
    w.write_all(&len_u32(sig_bytes.len())?)?;
    w.write_all(&sig_bytes)?;

    let inner = 4 + manifest_bytes.len() as u64 + size + 4 + sig_bytes.len() as u64;
    let mut pad = padded_len(inner) - inner;
    buf.fill(0);
    while pad > 0 {
        let n = usize::try_from(pad.min(CHUNK as u64)).unwrap_or(CHUNK);
        w.write_all(&buf[..n])?;
        pad -= n as u64;
    }
    Ok(w.finish()?)
}

/// Turns a read error inside the encrypted stream into a packet error:
/// a failed chunk tag or a cut-off stream means the packet was damaged.
fn stream_err(e: io::Error) -> KltError {
    match e.kind() {
        io::ErrorKind::InvalidData | io::ErrorKind::UnexpectedEof => KltError::Corrupt,
        _ => KltError::Io(e),
    }
}

fn read_u32<R: Read>(r: &mut R) -> Result<u32, KltError> {
    let mut b = [0u8; 4];
    r.read_exact(&mut b).map_err(stream_err)?;
    Ok(u32::from_be_bytes(b))
}

fn read_vec<R: Read>(r: &mut R, len: u32) -> Result<Vec<u8>, KltError> {
    let mut v = vec![0u8; len as usize];
    r.read_exact(&mut v).map_err(stream_err)?;
    Ok(v)
}

/// Decrypts a `.klt` packet, writing its content to `out`.
///
/// The signature and padding are checked only after the content has been
/// written. **Treat `out` as untrusted until this returns `Ok`, and discard
/// it on any error.**
pub fn open<R: Read, W: Write>(
    mut input: R,
    identities: &[&dyn age::Identity],
    out: &mut W,
) -> Result<Opened, KltError> {
    let mut magic = [0u8; 4];
    match input.read_exact(&mut magic) {
        Ok(()) if &magic == MAGIC => {}
        Ok(()) => return Err(KltError::NotKlt),
        Err(e) if e.kind() == io::ErrorKind::UnexpectedEof => return Err(KltError::NotKlt),
        Err(e) => return Err(KltError::Io(e)),
    }

    let decryptor = age::Decryptor::new(input)?;
    let mut r = decryptor.decrypt(identities.iter().copied())?;

    let manifest_len = read_u32(&mut r)?;
    if manifest_len > MAX_MANIFEST_LEN {
        return Err(KltError::Malformed("manifest too long"));
    }
    let manifest_bytes = read_vec(&mut r, manifest_len)?;
    let manifest = Manifest::decode(&manifest_bytes)?;

    let mut hasher = Sha512::new();
    let mut buf = vec![0u8; CHUNK];
    let mut left = manifest.size;
    while left > 0 {
        let want = usize::try_from(left.min(CHUNK as u64)).unwrap_or(CHUNK);
        r.read_exact(&mut buf[..want]).map_err(stream_err)?;
        hasher.update(&buf[..want]);
        out.write_all(&buf[..want])?;
        left -= want as u64;
    }

    let sig_len = read_u32(&mut r)?;
    if sig_len > MAX_SIGNATURE_LEN {
        return Err(KltError::Malformed("signature too long"));
    }
    let sig_bytes = read_vec(&mut r, sig_len)?;

    // the padding must be exactly Padmé(L) - L zero bytes
    let inner = 4 + u64::from(manifest_len) + manifest.size + 4 + u64::from(sig_len);
    let mut pad = padded_len(inner) - inner;
    loop {
        let n = r.read(&mut buf).map_err(stream_err)?;
        if n == 0 {
            break;
        }
        if n as u64 > pad || buf[..n].iter().any(|&b| b != 0) {
            return Err(KltError::Malformed("bad padding"));
        }
        pad -= n as u64;
    }
    if pad != 0 {
        return Err(KltError::Corrupt);
    }

    let signature = match (&manifest.signer, sig_bytes.is_empty()) {
        (None, true) => Signature::Unsigned,
        (Some(keys), false) => {
            let sig: HybridSignature = ciborium::from_reader(sig_bytes.as_slice())
                .map_err(|_| KltError::Malformed("signature"))?;
            let msg = signed_message(&manifest_bytes, &hasher.finalize());
            verify(keys, &msg, MLDSA_CONTEXT, &sig)?;
            Signature::Verified(keys.clone())
        }
        _ => return Err(KltError::Malformed("signer and signature disagree")),
    };

    Ok(Opened {
        manifest,
        signature,
    })
}
