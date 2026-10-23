//! Two vaults that only ever exchange text, as two phones over WhatsApp
//! would: a contact card one way, then messages back and forth.

#![allow(clippy::unwrap_used, clippy::panic)]

use std::time::{Duration, SystemTime};

use kilit_vault::messaging::{CARD_PREFIX, Found, MESSAGE_PREFIX, Messaging, MessagingError, find};
use kilit_vault::{KdfParams, PinMac, Vault};

fn vault(seed: u8) -> Vault {
    Vault::create_with_mac(&PinMac::from_bytes([seed; 32]), KdfParams::MINIMUM)
        .unwrap()
        .0
}

fn one(prefix: &str, text: &str) -> Vec<u8> {
    match find(prefix, text).as_slice() {
        [Found::Packet(p)] => p.clone(),
        other => panic!("{other:?}"),
    }
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

    /// Saves and loads the state, as a restart would.
    fn restart(&mut self) {
        let bytes = self.m.to_bytes().unwrap();
        self.m = Messaging::from_bytes(&self.vault, &bytes).unwrap();
    }

    fn card(&self, name: &str) -> Vec<u8> {
        one(CARD_PREFIX, &self.m.card(name).unwrap())
    }

    fn send(&mut self, to: &str, text: &str) -> Vec<u8> {
        one(MESSAGE_PREFIX, &self.m.encrypt(to, text, now()).unwrap())
    }
}

/// Ayşe adds Bora's card and writes first.
fn pair() -> (Person, Person, String, String) {
    let mut ayse = Person::new(1);
    let bora = Person::new(2);
    let bora_id = ayse.m.add_contact(&bora.card("Bora"), None, now()).unwrap();
    let ayse_id = ayse.m.my_address().to_owned();
    (ayse, bora, ayse_id, bora_id)
}

#[test]
fn a_card_then_messages_both_ways() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    assert_eq!(ayse.m.contacts()[0].name, "Bora");

    let first = ayse.send(&bora_id, "merhaba Bora");
    let got = bora.m.decrypt(&first, now()).unwrap();
    assert_eq!(got.text, "merhaba Bora");
    assert_eq!(got.contact, ayse_id);
    assert!(got.new_contact);
    // Bora never had Ayşe's card: she arrives unnamed
    assert_eq!(bora.m.contacts()[0].name, "");
    bora.m.rename(&ayse_id, "Ayşe").unwrap();

    let reply = bora.send(&ayse_id, "selam Ayşe");
    let got = ayse.m.decrypt(&reply, now()).unwrap();
    assert_eq!((got.text.as_str(), got.new_contact), ("selam Ayşe", false));
    assert_eq!(got.contact, bora_id);

    let again = ayse.send(&bora_id, "nasılsın?");
    assert_eq!(bora.m.decrypt(&again, now()).unwrap().text, "nasılsın?");
}

#[test]
fn both_phones_show_the_same_safety_number() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let a = ayse.m.safety_number(&bora_id).unwrap();
    let b = bora.m.safety_number(&ayse_id).unwrap();
    assert_eq!(a, b);
    assert_eq!(a.split(' ').count(), 12);
    assert!(
        a.split(' ')
            .all(|g| g.len() == 5 && g.bytes().all(|c| c.is_ascii_digit()))
    );
}

#[test]
fn a_message_opens_only_once() {
    let (mut ayse, mut bora, _, bora_id) = pair();
    let first = ayse.send(&bora_id, "bir kez");
    bora.m.decrypt(&first, now()).unwrap();
    assert_eq!(
        bora.m.decrypt(&first, now()),
        Err(MessagingError::Duplicate)
    );

    let ayse_id = ayse.m.my_address().to_owned();
    let reply = bora.send(&ayse_id, "tamam");
    ayse.m.decrypt(&reply, now()).unwrap();
    assert_eq!(
        ayse.m.decrypt(&reply, now()),
        Err(MessagingError::Duplicate)
    );
}

#[test]
fn messages_out_of_order_still_open() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&bora_id, "bir");
    bora.m.decrypt(&first, now()).unwrap();
    let r = bora.send(&ayse_id, "ok");
    ayse.m.decrypt(&r, now()).unwrap();

    let two = ayse.send(&bora_id, "iki");
    let three = ayse.send(&bora_id, "üç");
    assert_eq!(bora.m.decrypt(&three, now()).unwrap().text, "üç");
    assert_eq!(bora.m.decrypt(&two, now()).unwrap().text, "iki");
}

#[test]
fn sessions_survive_a_restart() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    ayse.restart();
    let first = ayse.send(&bora_id, "yeniden");
    bora.restart();
    bora.m.decrypt(&first, now()).unwrap();
    bora.restart();
    let reply = bora.send(&ayse_id, "aldım");
    ayse.restart();
    assert_eq!(ayse.m.decrypt(&reply, now()).unwrap().text, "aldım");
}

#[test]
fn a_third_person_reads_nothing() {
    let (mut ayse, _bora, _, bora_id) = pair();
    let mut cem = Person::new(3);
    let first = ayse.send(&bora_id, "gizli");
    assert!(cem.m.decrypt(&first, now()).is_err());
    assert!(cem.m.contacts().is_empty());
}

#[test]
fn forged_and_own_cards_are_refused() {
    let mut ayse = Person::new(1);
    let bora = Person::new(2);
    assert_eq!(
        ayse.m.add_contact(&ayse.card("me"), None, now()),
        Err(MessagingError::OwnCard)
    );
    // flip one byte at a time: no forged card is ever accepted
    let card = bora.card("Bora");
    let mut accepted = 0;
    for i in 0..card.len() {
        let mut bad = card.clone();
        bad[i] ^= 0x01;
        if ayse.m.add_contact(&bad, None, now()).is_ok() {
            accepted += 1;
        }
    }
    // only bytes outside every key and signature (the name) may change
    assert!(accepted <= 8, "{accepted} forged cards accepted");
    assert!(ayse.m.add_contact(b"not a card", None, now()).is_err());
}

#[test]
fn a_message_from_a_removed_contact_cannot_be_read() {
    let (mut ayse, mut bora, ayse_id, bora_id) = pair();
    let first = ayse.send(&bora_id, "x");
    bora.m.decrypt(&first, now()).unwrap();
    let r = bora.send(&ayse_id, "y");
    ayse.m.remove(&bora_id).unwrap();
    assert!(ayse.m.contacts().is_empty());
    assert_eq!(
        ayse.m.decrypt(&r, now()),
        Err(MessagingError::UnknownSender)
    );
}

#[test]
fn texts_are_found_in_chat_app_paste() {
    let mut ayse = Person::new(1);
    let bora = Person::new(2);
    let id = ayse.m.add_contact(&bora.card("Bora"), None, now()).unwrap();
    let text = ayse.m.encrypt(&id, "satır", now()).unwrap();
    // a chat app wrapped it and added a name and a time
    let (a, b) = text.split_at(40);
    let pasted = format!("[10:42] Ayşe: {a}\n{b} (edited)");
    assert!(matches!(
        find(MESSAGE_PREFIX, &pasted).as_slice(),
        [Found::Packet(_)]
    ));
    assert_eq!(
        find(MESSAGE_PREFIX, &text[..text.len() - 1]),
        vec![Found::Truncated]
    );
    assert_eq!(find(CARD_PREFIX, &text), vec![]);
}

#[test]
fn padding_hides_short_lengths() {
    let (mut ayse, _bora, _, bora_id) = pair();
    let a = ayse.send(&bora_id, "a");
    let b = ayse.send(&bora_id, &"b".repeat(100));
    assert_eq!(a.len(), b.len());
}

#[test]
fn a_later_clock_does_not_matter() {
    let (mut ayse, mut bora, _, bora_id) = pair();
    let first = ayse
        .m
        .encrypt(&bora_id, "ileri", now() + Duration::from_secs(3600))
        .unwrap();
    let first = one(MESSAGE_PREFIX, &first);
    assert_eq!(bora.m.decrypt(&first, now()).unwrap().text, "ileri");
}
