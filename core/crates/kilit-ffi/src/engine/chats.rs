//! Contacts and conversations: the vault's Signal sessions
//! ([`kilit_vault::messaging`]) and each contact's chat log, both sealed to
//! the vault like the item index.

use std::time::{Duration, SystemTime, UNIX_EPOCH};

use kilit_vault::messaging::{
    CARD_PREFIX, ContactInfo, Found, MESSAGE_PREFIX, Messaging, MessagingError, find,
};
use serde::{Deserialize, Serialize};

use super::{Engine, EngineError};

/// The Signal state: identity prekeys, contacts, sessions.
const SIGNAL: &str = "signal";
const SIGNAL_NAME: &str = "signal.cbor";
const CHAT_NAME: &str = "chat.cbor";
const CBOR: &str = "application/cbor";
/// Lines kept per conversation; older ones drop off.
const MAX_LINES: usize = 5000;

fn chat_blob(contact: &str) -> Result<String, EngineError> {
    if contact.len() == 32
        && contact
            .bytes()
            .all(|b| b.is_ascii_hexdigit() && !b.is_ascii_uppercase())
    {
        Ok(format!("chat-{contact}"))
    } else {
        Err(EngineError::NotFound)
    }
}

fn messaging_err(e: MessagingError) -> EngineError {
    match e {
        MessagingError::NoContact => EngineError::NotFound,
        MessagingError::TooLarge => EngineError::TooLong,
        MessagingError::Damaged => EngineError::Damaged,
        MessagingError::NotACard => EngineError::Rejected("not a contact card".into()),
        MessagingError::OwnCard => EngineError::Rejected("this is your own card".into()),
        e => EngineError::Rejected(format!("{e:?}")),
    }
}

/// One line of a conversation.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Line {
    /// Written here (true) or received.
    pub outgoing: bool,
    /// The text.
    pub text: String,
    /// When it was written (outgoing) or opened (incoming), Unix seconds.
    pub at: i64,
    /// When the sender says they wrote it, Unix seconds.
    pub sent: i64,
}

/// A contact with the newest line of the conversation, for the list.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Contact {
    /// The address (32 hex digits).
    pub id: String,
    /// The name given; empty until one is.
    pub name: String,
    /// When they were added, Unix seconds.
    pub added: i64,
    /// The newest line, if there is one.
    pub last: Option<Line>,
}

/// What one message found in pasted text came to.
#[derive(Debug, PartialEq, Eq)]
pub enum Incoming {
    /// Opened and added to the conversation with `contact`.
    Opened {
        /// Who sent it.
        contact: String,
        /// This message made them a contact.
        new_contact: bool,
        /// The text.
        text: String,
    },
    /// Opened before.
    Duplicate,
    /// From no one with a session here.
    Unknown,
    /// Damaged, or not a message.
    Damaged,
    /// The chat app cut it off.
    Truncated,
}

impl Engine {
    fn messaging(&self) -> Result<Messaging, EngineError> {
        let o = self.require_open()?;
        match self.store.read(SIGNAL)? {
            Some(packet) => {
                let (bytes, _) = self.open_mine(&packet)?;
                Messaging::from_bytes(&o.vault, &bytes).map_err(messaging_err)
            }
            None => Messaging::create(&o.vault).map_err(messaging_err),
        }
    }

    fn save_messaging(&self, m: &Messaging) -> Result<(), EngineError> {
        let bytes = m.to_bytes().map_err(messaging_err)?;
        let packet = self.seal_to_me(SIGNAL_NAME, CBOR, &bytes)?;
        Ok(self.store.write(SIGNAL, &packet)?)
    }

    fn system_now(&self) -> SystemTime {
        UNIX_EPOCH + Duration::from_secs((self.now)().max(0) as u64)
    }

    /// This vault's contact card, `KLC1:` text, with the name to show.
    pub fn my_card(&self, name: &str) -> Result<String, EngineError> {
        let m = self.messaging()?;
        let card = m.card(name).map_err(messaging_err)?;
        // the first card fixes the prekeys on it; keep them
        if self.store.len(SIGNAL)?.is_none() {
            self.save_messaging(&m)?;
        }
        Ok(card)
    }

    /// Adds the contact whose card is in `text`, with `name` or the card's.
    pub fn add_contact(&mut self, text: &str, name: Option<&str>) -> Result<Contact, EngineError> {
        let card = match find(CARD_PREFIX, text).into_iter().next() {
            Some(Found::Packet(p)) => p,
            Some(Found::Truncated) => {
                return Err(EngineError::Rejected("the card was cut off".into()));
            }
            _ => return Err(EngineError::Rejected("not a contact card".into())),
        };
        let mut m = self.messaging()?;
        let id = m
            .add_contact(
                &card,
                name.filter(|n| !n.trim().is_empty()),
                self.system_now(),
            )
            .map_err(messaging_err)?;
        self.save_messaging(&m)?;
        self.contact(&m, &id)
    }

    fn contact(&self, m: &Messaging, id: &str) -> Result<Contact, EngineError> {
        let c = m
            .contacts()
            .into_iter()
            .find(|c| c.id == id)
            .ok_or(EngineError::NotFound)?;
        self.with_last(c)
    }

    fn with_last(&self, c: ContactInfo) -> Result<Contact, EngineError> {
        let last = self.chat(&c.id)?.pop();
        Ok(Contact {
            id: c.id,
            name: c.name,
            added: c.added,
            last,
        })
    }

    /// The contacts, newest conversation first.
    pub fn contacts(&self) -> Result<Vec<Contact>, EngineError> {
        let m = match self.store.len(SIGNAL)? {
            Some(_) => self.messaging()?,
            None => return Ok(Vec::new()),
        };
        let mut v = m
            .contacts()
            .into_iter()
            .map(|c| self.with_last(c))
            .collect::<Result<Vec<_>, _>>()?;
        v.sort_by_key(|c| std::cmp::Reverse(c.last.as_ref().map_or(c.added, |l| l.at)));
        Ok(v)
    }

    /// Gives a contact a name.
    pub fn rename_contact(&mut self, id: &str, name: &str) -> Result<(), EngineError> {
        let mut m = self.messaging()?;
        m.rename(id, name).map_err(messaging_err)?;
        self.save_messaging(&m)
    }

    /// Forgets a contact: session, identity key and conversation.
    pub fn remove_contact(&mut self, id: &str) -> Result<(), EngineError> {
        let blob = chat_blob(id)?;
        let mut m = self.messaging()?;
        m.remove(id).map_err(messaging_err)?;
        self.save_messaging(&m)?;
        Ok(self.store.delete(&blob)?)
    }

    /// The safety number to compare with a contact.
    pub fn safety_number(&self, id: &str) -> Result<String, EngineError> {
        self.messaging()?.safety_number(id).map_err(messaging_err)
    }

    /// A conversation, oldest line first.
    pub fn chat(&self, id: &str) -> Result<Vec<Line>, EngineError> {
        let Some(packet) = self.store.read(&chat_blob(id)?)? else {
            return Ok(Vec::new());
        };
        let (bytes, _) = self.open_mine(&packet)?;
        ciborium::from_reader(bytes.as_slice()).map_err(|_| EngineError::Damaged)
    }

    fn append(&self, id: &str, line: Line) -> Result<(), EngineError> {
        let mut lines = self.chat(id)?;
        lines.push(line);
        if lines.len() > MAX_LINES {
            lines.drain(..lines.len() - MAX_LINES);
        }
        let mut bytes = Vec::new();
        ciborium::into_writer(&lines, &mut bytes).map_err(|_| EngineError::Damaged)?;
        let packet = self.seal_to_me(CHAT_NAME, CBOR, &bytes)?;
        Ok(self.store.write(&chat_blob(id)?, &packet)?)
    }

    /// Seals `text` for a contact and returns the `KLM1:` text to send.
    pub fn send_message(&mut self, id: &str, text: &str) -> Result<String, EngineError> {
        let mut m = self.messaging()?;
        let now = (self.now)();
        let out = m
            .encrypt(id, text, self.system_now())
            .map_err(messaging_err)?;
        // the session moved on: keep it before anything else
        self.save_messaging(&m)?;
        self.append(
            id,
            Line {
                outgoing: true,
                text: text.to_owned(),
                at: now,
                sent: now,
            },
        )?;
        Ok(out)
    }

    /// Opens every `KLM1:` message in pasted text.
    pub fn receive(&mut self, text: &str) -> Result<Vec<Incoming>, EngineError> {
        let found = find(MESSAGE_PREFIX, text);
        if found.is_empty() {
            return Ok(Vec::new());
        }
        let mut m = self.messaging()?;
        let mut out = Vec::new();
        for f in found {
            let packet = match f {
                Found::Packet(p) => p,
                Found::Truncated => {
                    out.push(Incoming::Truncated);
                    continue;
                }
                Found::Malformed => {
                    out.push(Incoming::Damaged);
                    continue;
                }
            };
            out.push(match m.decrypt(&packet, self.system_now()) {
                Ok(r) => {
                    self.save_messaging(&m)?;
                    self.append(
                        &r.contact,
                        Line {
                            outgoing: false,
                            text: r.text.clone(),
                            at: (self.now)(),
                            sent: r.sent,
                        },
                    )?;
                    Incoming::Opened {
                        contact: r.contact,
                        new_contact: r.new_contact,
                        text: r.text,
                    }
                }
                Err(MessagingError::Duplicate) => Incoming::Duplicate,
                Err(MessagingError::UnknownSender) => Incoming::Unknown,
                Err(MessagingError::Crypto) => return Err(EngineError::Damaged),
                Err(_) => Incoming::Damaged,
            });
        }
        Ok(out)
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    fn ready(dir: &tempfile::TempDir, pin: &str) -> Engine {
        let mut e = Engine::open(dir.path().to_str().unwrap(), false).unwrap();
        e.create_vault(pin.into()).unwrap();
        e
    }

    #[test]
    fn two_vaults_talk_through_pasted_text() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        assert!(ayse.contacts().unwrap().is_empty());

        let card = bora.my_card("Bora").unwrap();
        let c = ayse
            .add_contact(&format!("Bora's card: {card}"), None)
            .unwrap();
        assert_eq!((c.name.as_str(), c.last.is_none()), ("Bora", true));

        let m = ayse.send_message(&c.id, "selam").unwrap();
        let got = bora.receive(&m).unwrap();
        let Some(Incoming::Opened {
            contact,
            new_contact: true,
            text,
        }) = got.into_iter().next()
        else {
            unreachable!("Bora opens Ayşe's first message");
        };
        assert_eq!(text, "selam");
        assert_eq!(bora.receive(&m).unwrap(), vec![Incoming::Duplicate]);
        bora.rename_contact(&contact, "Ayşe").unwrap();

        let r = bora.send_message(&contact, "aleyküm selam").unwrap();
        // the vault locks and opens in between: the session is in the store
        ayse.lock();
        ayse.unlock("482916".into()).unwrap();
        ayse.receive(&r).unwrap();
        let lines = ayse.chat(&c.id).unwrap();
        assert_eq!(
            lines
                .iter()
                .map(|l| (l.outgoing, l.text.as_str()))
                .collect::<Vec<_>>(),
            vec![(true, "selam"), (false, "aleyküm selam")]
        );
        assert_eq!(
            ayse.contacts().unwrap()[0].last.as_ref().unwrap().text,
            "aleyküm selam"
        );
        assert_eq!(
            ayse.safety_number(&c.id).unwrap(),
            bora.safety_number(&contact).unwrap()
        );

        ayse.remove_contact(&c.id).unwrap();
        assert!(ayse.contacts().unwrap().is_empty());
        assert!(ayse.chat(&c.id).unwrap().is_empty());
    }

    #[test]
    fn cards_and_messages_that_are_not_are_refused() {
        let d = tempfile::tempdir().unwrap();
        let mut e = ready(&d, "482916");
        assert!(matches!(
            e.add_contact("hello", None),
            Err(EngineError::Rejected(_))
        ));
        let own = e.my_card("me").unwrap();
        assert!(matches!(
            e.add_contact(&own, None),
            Err(EngineError::Rejected(_))
        ));
        assert_eq!(e.receive("no message here").unwrap(), vec![]);
        assert_eq!(e.receive("KLM1:AAAA").unwrap(), vec![Incoming::Truncated]);
        assert_eq!(e.receive("KLM1:AAAA.").unwrap(), vec![Incoming::Damaged]);
    }

    #[test]
    fn the_panic_code_takes_the_conversations_too() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let bora = ready(&db, "739204");
        let c = ayse
            .add_contact(&bora.my_card("Bora").unwrap(), None)
            .unwrap();
        ayse.send_message(&c.id, "x").unwrap();
        ayse.set_panic("7391".into()).unwrap();
        ayse.lock();
        assert_eq!(
            ayse.unlock("7391".into()).unwrap(),
            super::super::Unlock::Wiped
        );
        assert_eq!(std::fs::read_dir(da.path()).unwrap().count(), 0);
    }
}
