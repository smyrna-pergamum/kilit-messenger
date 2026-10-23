//! Whole-packet behaviour: who can open what, and what a damaged or forged
//! packet does.

#![allow(clippy::unwrap_used, clippy::panic)]

mod common;

use age::secrecy::SecretString;
use common::TestSigner;
use kilit_klt::{
    KdfParams, KltError, PacketSigner, PassphraseIdentity, PassphraseRecipient, Signature,
    XWingIdentity, from_text, open, seal, to_text,
};

fn identity(n: u8) -> XWingIdentity {
    XWingIdentity::from_seed(&[n; 32]).unwrap()
}

fn content(len: usize) -> Vec<u8> {
    (0..len).map(|i| (i * 31 % 251) as u8).collect()
}

fn seal_to(
    data: &[u8],
    recipients: &[&dyn age::Recipient],
    signer: Option<&dyn PacketSigner>,
) -> Vec<u8> {
    seal(
        "not.txt",
        "text/plain",
        data.len() as u64,
        data,
        recipients,
        signer,
        Vec::new(),
    )
    .unwrap()
}

fn open_with(
    packet: &[u8],
    identities: &[&dyn age::Identity],
) -> Result<(kilit_klt::Opened, Vec<u8>), KltError> {
    let mut out = Vec::new();
    open(packet, identities, &mut out).map(|o| (o, out))
}

fn weak_passphrase(p: &str) -> PassphraseRecipient {
    PassphraseRecipient::with_params(SecretString::from(p.to_owned()), KdfParams::MINIMUM).unwrap()
}

#[test]
fn the_recipient_reads_exactly_what_was_sealed() {
    let alice = identity(1);
    let data = content(1000);
    let packet = seal_to(&data, &[&alice.recipient()], None);
    let (opened, out) = open_with(&packet, &[&alice]).unwrap();
    assert_eq!(out, data);
    assert_eq!(opened.manifest.name, "not.txt");
    assert_eq!(opened.signature, Signature::Unsigned);
}

#[test]
fn every_recipient_can_open_and_nobody_else() {
    let (a, b, c) = (identity(1), identity(2), identity(3));
    let packet = seal_to(b"merhaba", &[&a.recipient(), &b.recipient()], None);
    assert!(open_with(&packet, &[&a]).is_ok());
    assert!(open_with(&packet, &[&b]).is_ok());
    assert!(matches!(open_with(&packet, &[&c]), Err(KltError::WrongKey)));
}

#[test]
fn a_shared_passphrase_opens_and_a_wrong_one_does_not() {
    let packet = seal_to(b"gizli", &[&weak_passphrase("doğru at pil zımba")], None);
    let right = PassphraseIdentity::new(SecretString::from("doğru at pil zımba".to_owned()));
    let wrong = PassphraseIdentity::new(SecretString::from("yanlış".to_owned()));
    assert_eq!(open_with(&packet, &[&right]).unwrap().1, b"gizli");
    assert!(matches!(
        open_with(&packet, &[&wrong]),
        Err(KltError::WrongKey)
    ));
}

#[test]
fn a_passphrase_and_a_contact_can_share_one_packet() {
    let alice = identity(1);
    let packet = seal_to(
        b"ikisi de",
        &[&alice.recipient(), &weak_passphrase("ortak parola")],
        None,
    );
    assert!(open_with(&packet, &[&alice]).is_ok());
    let pass = PassphraseIdentity::new(SecretString::from("ortak parola".to_owned()));
    assert!(open_with(&packet, &[&pass]).is_ok());
}

#[test]
fn empty_and_multi_chunk_content_round_trip() {
    let alice = identity(1);
    for len in [0, 1, 65_536, 200_001] {
        let data = content(len);
        let packet = seal_to(&data, &[&alice.recipient()], None);
        assert_eq!(open_with(&packet, &[&alice]).unwrap().1, data, "len {len}");
    }
}

#[test]
fn a_signed_packet_names_its_signer() {
    let alice = identity(1);
    let signer = TestSigner::new(5);
    let packet = seal_to(b"imzali", &[&alice.recipient()], Some(&signer));
    let (opened, _) = open_with(&packet, &[&alice]).unwrap();
    assert_eq!(opened.signature, Signature::Verified(signer.keys()));
}

#[test]
fn a_signature_under_someone_elses_name_is_refused() {
    let alice = identity(1);
    let mut forger = TestSigner::new(5);
    forger.claimed = Some(TestSigner::new(6).keys());
    let packet = seal_to(b"sahte", &[&alice.recipient()], Some(&forger));
    assert!(matches!(
        open_with(&packet, &[&alice]),
        Err(KltError::BadSignature)
    ));
}

#[test]
fn any_changed_byte_is_detected() {
    let alice = identity(1);
    let packet = seal_to(
        &content(3000),
        &[&alice.recipient()],
        Some(&TestSigner::new(5)),
    );
    // header, header MAC, first chunk, last bytes
    for at in [20, packet.len() / 3, packet.len() / 2, packet.len() - 1] {
        let mut bad = packet.clone();
        bad[at] ^= 0x01;
        assert!(open_with(&bad, &[&alice]).is_err(), "flip at {at} accepted");
    }
}

#[test]
fn a_cut_off_packet_is_refused() {
    let alice = identity(1);
    let packet = seal_to(&content(3000), &[&alice.recipient()], None);
    for keep in [3, 100, packet.len() - 1] {
        assert!(
            open_with(&packet[..keep], &[&alice]).is_err(),
            "kept {keep}"
        );
    }
}

#[test]
fn other_files_are_not_klt() {
    let alice = identity(1);
    assert!(matches!(
        open_with(b"VEIL1:abc", &[&alice]),
        Err(KltError::NotKlt)
    ));
    assert!(matches!(open_with(b"", &[&alice]), Err(KltError::NotKlt)));
}

#[test]
fn sealing_checks_the_declared_size() {
    let alice = identity(1);
    for (declared, real) in [(10, 9), (10, 11)] {
        let r = seal(
            "x",
            "",
            declared,
            &content(real)[..],
            &[&alice.recipient()],
            None,
            Vec::new(),
        );
        assert!(matches!(r, Err(KltError::SizeMismatch)));
    }
}

#[test]
fn unsafe_names_cannot_be_sealed() {
    let alice = identity(1);
    let r = seal(
        "../../evil",
        "",
        0,
        &b""[..],
        &[&alice.recipient()],
        None,
        Vec::new(),
    );
    assert!(matches!(r, Err(KltError::Malformed(_))));
}

/// The length of the encrypted stream after the age header. The header itself
/// varies by a few bytes because age adds a random grease stanza.
fn stream_len(packet: &[u8]) -> usize {
    let mac = packet.windows(5).position(|w| w == b"\n--- ").unwrap();
    let end = mac + 1 + packet[mac + 1..].iter().position(|&b| b == b'\n').unwrap();
    packet.len() - end - 1
}

#[test]
fn padding_hides_the_exact_length() {
    let alice = identity(1);
    let a = seal_to(&content(1000), &[&alice.recipient()], None);
    let b = seal_to(&content(1010), &[&alice.recipient()], None);
    assert_eq!(stream_len(&a), stream_len(&b));
    let c = seal_to(&content(5000), &[&alice.recipient()], None);
    assert!(stream_len(&c) > stream_len(&a));
}

#[test]
fn a_small_packet_survives_being_pasted_as_text() {
    let alice = identity(1);
    let packet = seal_to(b"WhatsApp ile", &[&alice.recipient()], None);
    let text = to_text(&packet).unwrap();
    assert!(text.starts_with("KLT1:"));
    let back = from_text(&text).unwrap();
    assert_eq!(open_with(&back, &[&alice]).unwrap().1, b"WhatsApp ile");
}

#[test]
fn only_the_first_passphrase_stanza_is_tried() {
    // two passphrase stanzas: the reader must not run Argon2id for the second
    let packet = seal_to(
        b"x",
        &[&weak_passphrase("birinci"), &weak_passphrase("ikinci")],
        None,
    );
    let first = PassphraseIdentity::new(SecretString::from("birinci".to_owned()));
    let second = PassphraseIdentity::new(SecretString::from("ikinci".to_owned()));
    assert!(open_with(&packet, &[&first]).is_ok());
    assert!(matches!(
        open_with(&packet, &[&second]),
        Err(KltError::WrongKey)
    ));
}
