//! Two vaults meeting the way phones will: one fetches the other's card by
//! its ID, writes first to the first-contact tag, and from the reply on both
//! use the mailbox they share. The relays are a map from tag to envelopes.

#![allow(clippy::unwrap_used, clippy::panic)]

use std::time::{Duration, SystemTime};

use kilit_vault::messaging::{
    ContactState, Content, FileRef, Invite, Messaging, MessagingError, card_matches, parse_invite,
};
use kilit_vault::{KdfParams, PinMac, Vault};
use serde_bytes::ByteBuf;

fn vault(seed: u8) -> Vault {
    Vault::create_with_mac(&PinMac::from_bytes([seed; 32]), KdfParams::MINIMUM)
        .unwrap()
        .0
}

fn now() -> SystemTime {
    SystemTime::now()
}

struct Person {
    vault: Vault,
    m: Messaging,
}

impl Person {
    fn new(seed: u8) -> Self {
        let vault = vault(seed);
        let m = Messaging::create(&vault).unwrap();
        Self { vault, m }
    }

    fn restart(&mut self) {
        let bytes = self.m.to_bytes().unwrap();
        self.m = Messaging::from_bytes(&self.vault, &bytes).unwrap();
    }

    fn invite(&self) -> Invite {
        parse_invite(&self.m.invite_link()).unwrap()
    }

    /// Sends, and checks the recipient watches the tag it went to.
    fn send(&mut self, to: &mut Person, contact: &str, text: &str) -> Vec<u8> {
        let out = self.m.encrypt(contact, text, now()).unwrap();
        assert!(
            to.m.inbox_tags(now()).unwrap().contains(&out.tag),
            "the recipient does not watch {}",
            out.tag
        );
        out.payload
    }
}

/// Ayşe adds Bora by his link and writes first.
fn pair() -> (Person, Person, String, String) {
    let mut ayse = Person::new(1);
    let bora = Person::new(2);
    let card = bora.m.card("Bora").unwrap();
    let inv = bora.invite();
    assert!(card_matches(&card, &inv));
    let bora_id = ayse.m.add_contact(&card, Some(&inv), None, now()).unwrap();
    let ayse_id = ayse.m.my_address().to_owned();
    (ayse, bora, ayse_id, bora_id)
}

#[test]
fn ids_links_and_typed_ids() {
    let p = Person::new(9);
    let id = p.m.kilit_id().to_owned();
    assert_eq!(id.split('-').count(), 4);
    let link = p.m.invite_link();
    assert!(link.starts_with("kilit://add?id="));
    let inv = parse_invite(&link).unwrap();
    assert_eq!(inv.id, id);
    assert_eq!(inv.address.as_deref(), Some(p.m.my_address()));
    assert_eq!(
        parse_invite(&format!("  @{}  ", id.to_uppercase())),
        Some(Invite {
            id: id.clone(),
            address: None
        })
    );
    for bad in [
        id.as_str(),
        "@one-two-three",
        "@abandon-ability-able-notaword",
        "kilit://add?id=abandon-ability-able-about&id=abandon-ability-able-above",
        "kilit://add?id=abandon-ability-able-about&a=XYZ",
        "https://example.com/@abandon-ability-able-about",
    ] {
        assert_eq!(parse_invite(bad), None, "{bad}");
    }
    // the same vault always has the same ID
    let mut q = Person {
        vault: p.vault,
        m: p.m,
    };
    q.restart();
    assert_eq!(q.m.kilit_id(), id);
}

#[test]
fn a_card_under_someone_elses_id_is_refused() {
    let mut ayse = Person::new(1);
    let bora = Person::new(2);
    let cem = Person::new(3);
    let cems_card = cem.m.card("Bora").unwrap();
    assert!(!card_matches(&cems_card, &bora.invite()));
    assert_eq!(
        ayse.m
            .add_contact(&cems_card, Some(&bora.invite()), None, now()),
        Err(MessagingError::NotACard)
    );
    assert_eq!(
        ayse.m
            .add_contact(&ayse.m.card("me").unwrap(), None, None, now()),
        Err(MessagingError::OwnCard)
    );
}

#[test]
fn first_contact_then_the_shared_mailbox() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();

    let first = ayse.send(&mut bora, &bora_id, "merhaba Bora");
    let got = bora.m.decrypt(&first, now()).unwrap();
    assert_eq!((got.text.as_str(), got.new_contact), ("merhaba Bora", true));
    assert_eq!(got.contact, ayse_id);
    // Bora never added Ayşe: she is a request until he says yes
    let c = &bora.m.contacts()[0];
    assert_eq!((c.state, c.name.as_str()), (ContactState::Request, ""));
    assert_eq!(c.kilit_id, ayse.m.kilit_id());
    bora.m.accept(&ayse_id).unwrap();
    assert_eq!(bora.m.contacts()[0].state, ContactState::Accepted);

    let reply = bora.send(&mut ayse, &ayse_id, "selam Ayşe");
    let got = ayse.m.decrypt(&reply, now()).unwrap();
    assert_eq!((got.text.as_str(), got.new_contact), ("selam Ayşe", false));

    // now Ayşe writes to the daily mailbox, without a proof of work
    let again = ayse.m.encrypt(&bora_id, "nasılsın?", now()).unwrap();
    assert!(again.payload.len() < first.len());
    assert!(bora.m.inbox_tags(now()).unwrap().contains(&again.tag));
    assert_eq!(
        bora.m.decrypt(&again.payload, now()).unwrap().text,
        "nasılsın?"
    );
}

#[test]
fn a_stranger_without_the_proof_of_work_is_dropped() {
    let (mut ayse, mut bora, _, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    // strip the proof: version, flags=0, then the message
    let mut cheap = vec![first[0], 0];
    cheap.extend_from_slice(&first[10..]);
    assert_eq!(
        bora.m.decrypt(&cheap, now()),
        Err(MessagingError::NotAMessage)
    );
    assert!(bora.m.contacts().is_empty());
    assert!(bora.m.decrypt(&first, now()).is_ok());
}

#[test]
fn a_blocked_contact_is_not_heard_or_watched() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let watched = bora.m.inbox_tags(now()).unwrap().len();
    bora.m.block(&ayse_id).unwrap();
    assert_eq!(bora.m.inbox_tags(now()).unwrap().len(), watched - 3);
    assert_eq!(bora.m.contacts()[0].state, ContactState::Blocked);
    // a new session and first message from the same person: dropped too
    ayse.m
        .add_contact(&bora.m.card("Bora").unwrap(), None, None, now())
        .unwrap();
    let again = ayse.m.encrypt(&bora_id, "beni engelleme", now()).unwrap();
    assert_eq!(
        bora.m.decrypt(&again.payload, now()),
        Err(MessagingError::Blocked)
    );
}

#[test]
fn mailboxes_change_every_day() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let r = bora.m.encrypt(&ayse_id, "y", now()).unwrap();
    ayse.m.decrypt(&r.payload, now()).unwrap();
    let today = ayse.m.encrypt(&bora_id, "a", now()).unwrap().tag;
    let tomorrow = ayse
        .m
        .encrypt(&bora_id, "b", now() + Duration::from_secs(86_400))
        .unwrap()
        .tag;
    assert_ne!(today, tomorrow);
    assert_eq!(today.len(), 64);
    // Bora still hears a message sent by a clock one day ahead
    assert!(bora.m.inbox_tags(now()).unwrap().contains(&tomorrow));
}

#[test]
fn both_phones_show_the_same_safety_number() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let a = ayse.m.safety_number(&bora_id).unwrap();
    assert_eq!(a, bora.m.safety_number(&ayse_id).unwrap());
    assert_eq!(a.split(' ').count(), 12);
}

#[test]
fn a_message_opens_only_once_and_out_of_order() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "bir");
    bora.m.decrypt(&first, now()).unwrap();
    assert_eq!(
        bora.m.decrypt(&first, now()),
        Err(MessagingError::Duplicate)
    );
    let r = bora.send(&mut ayse, &ayse_id, "ok");
    ayse.m.decrypt(&r, now()).unwrap();
    let two = ayse.send(&mut bora, &bora_id, "iki");
    let three = ayse.send(&mut bora, &bora_id, "üç");
    assert_eq!(bora.m.decrypt(&three, now()).unwrap().text, "üç");
    assert_eq!(bora.m.decrypt(&two, now()).unwrap().text, "iki");
    assert_eq!(bora.m.decrypt(&two, now()), Err(MessagingError::Duplicate));
}

#[test]
fn sessions_and_states_survive_a_restart() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    ayse.restart();
    let first = ayse.send(&mut bora, &bora_id, "yeniden");
    bora.restart();
    bora.m.decrypt(&first, now()).unwrap();
    bora.restart();
    assert_eq!(bora.m.contacts()[0].state, ContactState::Request);
    let reply = bora.send(&mut ayse, &ayse_id, "aldım");
    ayse.restart();
    assert_eq!(ayse.m.decrypt(&reply, now()).unwrap().text, "aldım");
}

#[test]
fn a_third_person_reads_nothing() {
    let (mut ayse, mut bora, _, bora_id) = pair();
    let mut cem = Person::new(3);
    let first = ayse.send(&mut bora, &bora_id, "gizli");
    assert!(cem.m.decrypt(&first, now()).is_err());
    assert!(cem.m.contacts().is_empty());
    assert!(
        !cem.m
            .inbox_tags(now())
            .unwrap()
            .contains(&ayse.m.encrypt(&bora_id, "x", now()).unwrap().tag)
    );
}

#[test]
fn padding_hides_short_lengths() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let r = bora.send(&mut ayse, &ayse_id, "y");
    ayse.m.decrypt(&r, now()).unwrap();
    let a = ayse.m.encrypt(&bora_id, "a", now()).unwrap().payload;
    let b = ayse
        .m
        .encrypt(&bora_id, &"b".repeat(100), now())
        .unwrap()
        .payload;
    assert_eq!(a.len(), b.len());
}

/// Ayşe writes, Bora answers: from here both use the shared mailbox.
fn talking() -> (Person, Person, String, String) {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&mut bora, &bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    bora.m.accept(&ayse_id).unwrap();
    let r = bora.send(&mut ayse, &ayse_id, "y");
    ayse.m.decrypt(&r, now()).unwrap();
    (ayse, bora, ayse_id, bora_id)
}

#[test]
fn receipts_timers_and_files_travel_with_messages() {
    let (mut ayse, mut bora, ayse_id, bora_id) = talking();
    let file = FileRef {
        key: ByteBuf::from(vec![7; 32]),
        tag: "ab".repeat(32),
        chunks: 3,
        size: 70_000,
        sha256: ByteBuf::from(vec![1; 32]),
        name: "tatil.jpg".into(),
        mime: "image/jpeg".into(),
    };
    let out = ayse
        .m
        .seal(
            &bora_id,
            &Content {
                text: "bak".into(),
                timer: 3600,
                file: Some(file.clone()),
                ..Content::default()
            },
            now(),
        )
        .unwrap();
    let got = bora.m.decrypt(&out.payload, now()).unwrap();
    assert_eq!(got.id, out.id);
    assert_eq!(got.file, Some(file));
    assert_eq!(got.timer, 3600);
    // the timer is now the conversation's on Bora's side too
    assert_eq!(bora.m.timer(&ayse_id).unwrap(), 3600);
    assert_eq!(bora.m.contacts()[0].timer, 3600);

    // Bora's receipt: it does not change the timer
    let receipt = bora
        .m
        .seal(
            &ayse_id,
            &Content {
                receipts: vec![got.id.clone()],
                ..Content::default()
            },
            now(),
        )
        .unwrap();
    ayse.m.set_timer(&bora_id, 60).unwrap();
    let back = ayse.m.decrypt(&receipt.payload, now()).unwrap();
    assert_eq!(back.receipts, vec![out.id]);
    assert_eq!(ayse.m.timer(&bora_id).unwrap(), 60);
    assert!(ayse.m.set_timer(&bora_id, 365 * 86_400).is_err());
}

#[test]
fn a_new_id_keeps_the_contacts_and_retires_the_old_link() {
    let (mut ayse, mut bora, ayse_id, bora_id) = talking();
    let old_id = bora.m.kilit_id().to_owned();
    let old_link = bora.invite();
    let old_tags = bora.m.inbox_tags(now()).unwrap();
    assert_eq!(ayse.m.contacts()[0].kilit_id, old_id);

    bora.m.renew_id(now()).unwrap();
    assert_ne!(bora.m.kilit_id(), old_id);
    assert_eq!(bora.m.my_address(), bora_id, "the identity stays");
    assert_eq!(bora.m.take_retired_ids(), vec![old_id.clone()]);
    assert!(bora.m.take_retired_ids().is_empty());
    // the new card answers the new link, not the old one
    let card = bora.m.card("Bora").unwrap();
    assert!(card_matches(&card, &bora.invite()));
    assert!(!card_matches(&card, &old_link));
    // the old first-contact tag is still heard for a while
    let tags = bora.m.inbox_tags(now()).unwrap();
    assert!(tags.contains(&old_tags[0]));
    assert!(
        !bora
            .m
            .inbox_tags(now() + std::time::Duration::from_secs(8 * 86_400))
            .unwrap()
            .contains(&old_tags[0])
    );

    // the conversation goes on, and Ayşe now shows Bora's new ID
    let m = bora.send(&mut ayse, &ayse_id, "yeni kimliğim");
    assert_eq!(ayse.m.decrypt(&m, now()).unwrap().text, "yeni kimliğim");
    assert_eq!(ayse.m.contacts()[0].kilit_id, bora.m.kilit_id());
    // and survives a restart
    let id = bora.m.kilit_id().to_owned();
    bora.restart();
    assert_eq!(bora.m.kilit_id(), id);
}
