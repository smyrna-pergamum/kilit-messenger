//! The committed vectors in spec/vectors must open with every future
//! version. Regenerate them only when the format version changes:
//!
//!     KILIT_WRITE_VECTORS=1 cargo test -p kilit-klt --test vectors the_signed

#![allow(clippy::unwrap_used, clippy::panic)]

mod common;

use std::path::PathBuf;

use age::secrecy::SecretString;
use common::*;
use kilit_klt::{
    KdfParams, PassphraseIdentity, PassphraseRecipient, Signature, XWingIdentity, open, seal,
};

fn dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../../spec/vectors")
}

fn write_vectors() {
    let me = XWingIdentity::from_seed(&VECTOR_XWING_SEED).unwrap();
    let signer = TestSigner::new(VECTOR_SIGNER_SEED);
    let pass = PassphraseRecipient::with_params(
        SecretString::from(VECTOR_PASSPHRASE.to_owned()),
        KdfParams::MINIMUM,
    )
    .unwrap();
    let len = VECTOR_CONTENT.len() as u64;
    let xw = seal(
        "vektor.txt",
        "text/plain",
        len,
        VECTOR_CONTENT,
        &[&me.recipient()],
        Some(&signer),
        Vec::new(),
    )
    .unwrap();
    let pw = seal(
        "vektor.txt",
        "text/plain",
        len,
        VECTOR_CONTENT,
        &[&pass],
        None,
        Vec::new(),
    )
    .unwrap();
    std::fs::create_dir_all(dir()).unwrap();
    std::fs::write(dir().join("xwing-signed-v1.klt"), xw).unwrap();
    std::fs::write(dir().join("passphrase-v1.klt"), pw).unwrap();
}

#[test]
fn the_signed_xwing_vector_opens() {
    if std::env::var_os("KILIT_WRITE_VECTORS").is_some() {
        write_vectors();
    }
    let packet = std::fs::read(dir().join("xwing-signed-v1.klt")).unwrap();
    let me = XWingIdentity::from_seed(&VECTOR_XWING_SEED).unwrap();
    let mut out = Vec::new();
    let opened = open(packet.as_slice(), &[&me], &mut out).unwrap();
    assert_eq!(out, VECTOR_CONTENT);
    assert_eq!(opened.manifest.name, "vektor.txt");
    assert_eq!(
        opened.signature,
        Signature::Verified(TestSigner::new(VECTOR_SIGNER_SEED).keys())
    );
}

#[test]
fn the_passphrase_vector_opens() {
    let packet = std::fs::read(dir().join("passphrase-v1.klt")).unwrap();
    let id = PassphraseIdentity::new(SecretString::from(VECTOR_PASSPHRASE.to_owned()));
    let mut out = Vec::new();
    let opened = open(packet.as_slice(), &[&id], &mut out).unwrap();
    assert_eq!(out, VECTOR_CONTENT);
    assert_eq!(opened.signature, Signature::Unsigned);
}
