//! Carrier mode end to end: a message sealed here, pasted through a chat
//! app, found and opened on the other side.

#![allow(clippy::unwrap_used, clippy::panic)]

mod common;

use age::secrecy::SecretString;
use common::TestSigner;
use kilit_klt::{
    Carried, KdfParams, KltError, MAX_ARMORED, MAX_MESSAGE_BYTES, PassphraseIdentity,
    PassphraseRecipient, Signature, XWingIdentity, carrier_file_name, carry, find_in_text,
    open_message, seal, seal_message,
};

fn identity(n: u8) -> XWingIdentity {
    XWingIdentity::from_seed(&[n; 32]).unwrap()
}

fn text_of(c: Carried) -> String {
    match c {
        Carried::Text(t) => t,
        Carried::File { .. } => panic!("expected text"),
    }
}

#[test]
fn a_message_pasted_into_a_conversation_opens_on_the_other_side() {
    let bob = identity(2);
    let armored =
        text_of(seal_message("Yarın 10'da, kapının önünde.", &[&bob.recipient()], None).unwrap());
    let paste = format!("[23.10.2026 14:02] Ayşe: {armored}\n[23.10.2026 14:03] Ayşe: aldın mı?");
    let found = find_in_text(&paste);
    assert_eq!(found.len(), 1);
    let packet = found.into_iter().next().unwrap().unwrap();
    let (text, opened) = open_message(&packet, &[&bob]).unwrap();
    assert_eq!(text, "Yarın 10'da, kapının önünde.");
    assert_eq!(opened.signature, Signature::Unsigned);
}

#[test]
fn a_signed_message_says_who_sent_it() {
    let bob = identity(2);
    let ayse = TestSigner::new(5);
    let armored = text_of(seal_message("imzalı", &[&bob.recipient()], Some(&ayse)).unwrap());
    let packet = find_in_text(&armored).remove(0).unwrap();
    let (_, opened) = open_message(&packet, &[&bob]).unwrap();
    assert_eq!(opened.signature, Signature::Verified(ayse.keys()));
}

#[test]
fn a_shared_passphrase_message_works_like_the_old_project() {
    let pass = PassphraseRecipient::with_params(
        SecretString::from("ortak parola cümlesi".to_owned()),
        KdfParams::MINIMUM,
    )
    .unwrap();
    let armored = text_of(seal_message("eski usul", &[&pass], None).unwrap());
    let packet = find_in_text(&armored).remove(0).unwrap();
    let id = PassphraseIdentity::new(SecretString::from("ortak parola cümlesi".to_owned()));
    assert_eq!(open_message(&packet, &[&id]).unwrap().0, "eski usul");
}

#[test]
fn a_file_packet_is_not_opened_as_a_message() {
    let bob = identity(2);
    let packet = seal(
        "foto.jpg",
        "image/jpeg",
        3,
        &b"abc"[..],
        &[&bob.recipient()],
        None,
        Vec::new(),
    )
    .unwrap();
    assert!(matches!(
        open_message(&packet, &[&bob]),
        Err(KltError::NotAMessage)
    ));
}

#[test]
fn a_large_file_is_not_buffered_as_a_message() {
    let bob = identity(2);
    let big = vec![0u8; 100_000];
    let packet = seal(
        "x.bin",
        "application/octet-stream",
        big.len() as u64,
        big.as_slice(),
        &[&bob.recipient()],
        None,
        Vec::new(),
    )
    .unwrap();
    assert!(matches!(
        open_message(&packet, &[&bob]),
        Err(KltError::NotAMessage)
    ));
}

#[test]
fn over_long_messages_are_refused() {
    let bob = identity(2);
    let long = "a".repeat(MAX_MESSAGE_BYTES + 1);
    assert!(matches!(
        seal_message(&long, &[&bob.recipient()], None),
        Err(KltError::Malformed(_))
    ));
}

#[test]
fn small_packets_travel_as_text_and_large_ones_as_files() {
    let bob = identity(2);
    let small = seal("a", "", 1, &b"a"[..], &[&bob.recipient()], None, Vec::new()).unwrap();
    assert!(matches!(carry(small).unwrap(), Carried::Text(_)));
    let data = vec![1u8; MAX_ARMORED];
    let large = seal(
        "b",
        "",
        data.len() as u64,
        data.as_slice(),
        &[&bob.recipient()],
        None,
        Vec::new(),
    )
    .unwrap();
    match carry(large).unwrap() {
        Carried::File { file_name, packet } => {
            assert!(file_name.starts_with("kilit-") && file_name.ends_with(".klt"));
            assert!(packet.len() > MAX_ARMORED);
        }
        Carried::Text(_) => panic!("expected a file"),
    }
}

#[test]
fn carrier_file_names_are_random_and_say_nothing() {
    let a = carrier_file_name().unwrap();
    let b = carrier_file_name().unwrap();
    assert_ne!(a, b);
    assert_eq!(a.len(), "kilit-00000000.klt".len());
}

#[test]
fn a_cut_off_message_is_reported() {
    let bob = identity(2);
    let armored = text_of(seal_message("kesilecek", &[&bob.recipient()], None).unwrap());
    let cut = &armored[..armored.len() / 2];
    assert!(matches!(
        find_in_text(cut).remove(0),
        Err(KltError::Truncated)
    ));
}

/// Prints how long armored messages really are, for the spec's size note.
#[test]
fn armored_message_sizes() {
    let bob = identity(2);
    let plain = text_of(seal_message("merhaba", &[&bob.recipient()], None).unwrap());
    let signed =
        text_of(seal_message("merhaba", &[&bob.recipient()], Some(&TestSigner::new(5))).unwrap());
    println!(
        "unsigned: {} chars, signed: {} chars",
        plain.len(),
        signed.len()
    );
    assert!(plain.len() < 4_000);
    assert!(signed.len() < 12_000);
}
