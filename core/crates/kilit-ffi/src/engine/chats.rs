//! Contacts and conversations over the relays: the vault's Signal sessions
//! ([`kilit_vault::messaging`]), each contact's chat log, files and the
//! outbox, all sealed to the vault like the item index.
//!
//! The engine never touches the network. It hands out events to publish
//! (the card, messages from the outbox) and the filter to watch, and takes
//! the events that arrived; `api.rs` moves them through `kilit_net::Net`.
//!
//! **Receipts.** A message from an accepted contact is answered with a
//! receipt (a message whose only content is the ids it confirms); the
//! sender's line then shows two ticks. A request is not answered until it
//! is accepted, so a stranger learns nothing.
//!
//! **Files.** A file is sealed with a key of its own (XChaCha20-Poly1305),
//! cut into pieces and posted under a random tag; the message that names
//! it carries the key, the tag and the file's hash. The recipient watches
//! the tag until every piece is in, then checks the hash.
//!
//! **Disappearing messages.** A conversation's timer goes with every
//! message; a line is removed, file and all, once its time is up.

use std::collections::{BTreeMap, HashMap};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use base64::Engine as _;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use chacha20poly1305::aead::{Aead, Payload};
use chacha20poly1305::{KeyInit, XChaCha20Poly1305, XNonce};
use kilit_net::{Event, Filter};
use kilit_vault::messaging::{
    ContactInfo, ContactState, Content, FileRef, GroupWire, Invite, MAX_GROUP, MAX_GROUP_NAME,
    MAX_TEXT, Messaging, MessagingError, Received, Roster, RosterMember, card_matches, card_tag,
    parse_invite,
};
use serde::{Deserialize, Serialize};
use serde_bytes::ByteBuf;
use sha2::{Digest, Sha256};

use super::{Engine, EngineError};

mod groups;
pub use groups::{Group, Target};

/// The Signal state: identity prekeys, contacts, sessions.
const SIGNAL: &str = "signal";
const SIGNAL_NAME: &str = "signal.cbor";
const OUTBOX: &str = "outbox";
const OUTBOX_NAME: &str = "outbox.cbor";
const FILES: &str = "files";
const FILES_NAME: &str = "files.cbor";
const CHAT_NAME: &str = "chat.cbor";
const CBOR: &str = "application/cbor";
/// Lines kept per conversation; older ones drop off.
const MAX_LINES: usize = 5000;
/// Events waiting for a relay at most.
const MAX_OUTBOX: usize = 4000;
/// Kind of a message event: gift wraps (NIP-59) are what relays expect to
/// be signed by throwaway keys.
pub const MESSAGE_KIND: u32 = 1059;
/// Kind of the published card: application data (NIP-78), replaceable per
/// key and `d` tag.
pub const CARD_KIND: u32 = 30078;
/// How far back the inbox asks the relays.
const INBOX_BACK: Duration = Duration::from_secs(7 * 86_400);
/// A piece of a file, before sealing: small enough that every relay in use
/// takes the event (base64 grows it by a third).
const CHUNK: usize = 24 * 1024;
/// The largest file sent: 5 MiB, some two hundred pieces.
pub const MAX_FILE: usize = 5 * 1024 * 1024;
/// Files being fetched at once at most.
const MAX_PENDING_FILES: usize = 50;
/// A message that a relay kept but whose receipt has not come is sealed
/// again this long after the last try, under the day's mailbox: the
/// recipient watches only yesterday's, today's and tomorrow's.
const RESEND_EVERY: i64 = 20 * 3600;
/// And at most this many times, about a week.
const MAX_RESENDS: u32 = 7;

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

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

/// Where a received or sent file is kept: `att-` and 16 hex digits.
fn att_blob(id: &str) -> Result<String, EngineError> {
    if id.len() == 16
        && id
            .bytes()
            .all(|b| b.is_ascii_hexdigit() && !b.is_ascii_uppercase())
    {
        Ok(format!("att-{id}"))
    } else {
        Err(EngineError::NotFound)
    }
}

fn random<const N: usize>() -> Result<[u8; N], EngineError> {
    let mut b = [0u8; N];
    getrandom::fill(&mut b).map_err(|_| EngineError::Storage("no system randomness".into()))?;
    Ok(b)
}

fn messaging_err(e: MessagingError) -> EngineError {
    match e {
        MessagingError::NoContact => EngineError::NotFound,
        MessagingError::TooLarge => EngineError::TooLong,
        MessagingError::Damaged => EngineError::Damaged,
        MessagingError::NotACard => EngineError::Rejected("no card for this ID".into()),
        MessagingError::OwnCard => EngineError::Rejected("this is your own ID".into()),
        e => EngineError::Rejected(format!("{e:?}")),
    }
}

/// The nonce of piece `i`: unique per piece under a key used for one file.
fn chunk_nonce(i: u32) -> XNonce {
    let mut n = [0u8; 24];
    n[..4].copy_from_slice(&i.to_le_bytes());
    XNonce::from(n)
}

/// Where an outgoing line is.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum LineState {
    /// Waiting for a relay: no network, or none answered yet.
    #[default]
    Queued,
    /// At least one relay stored it.
    Sent,
    /// Their phone opened it and said so.
    Delivered,
}

/// A file on a line.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LineFile {
    /// The name to show.
    pub name: String,
    /// The media type.
    pub mime: String,
    /// Its length in bytes.
    pub size: u64,
    /// Where it is kept once complete (`att-…`); empty while its pieces
    /// are still coming.
    pub blob: String,
}

/// One line of a conversation.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct Line {
    /// Written here (true) or received.
    pub outgoing: bool,
    /// The text.
    pub text: String,
    /// When it was written (outgoing) or opened (incoming), Unix seconds.
    pub at: i64,
    /// When the sender says they wrote it, Unix seconds.
    pub sent: i64,
    /// For outgoing lines.
    #[serde(default)]
    pub state: LineState,
    /// The event that carries it, for outgoing lines.
    #[serde(default)]
    pub event: String,
    /// The message's own id, which receipts name.
    #[serde(default)]
    pub id: ByteBuf,
    /// When it disappears, Unix seconds; 0 never.
    #[serde(default)]
    pub expires: i64,
    /// A file with it.
    #[serde(default)]
    pub file: Option<LineFile>,
    /// Outgoing lines with a file: what opens it, to send it again.
    #[serde(default)]
    pub file_ref: Option<FileRef>,
    /// Outgoing: how many times it was sent again, and when last (Unix
    /// seconds; 0 never).
    #[serde(default)]
    pub tries: u32,
    #[serde(default)]
    pub tried: i64,
    /// In a group: who wrote an incoming line, or did what a notice says.
    #[serde(default)]
    pub from: String,
    /// In a group: each member's copy of an outgoing line.
    #[serde(default)]
    pub to: Vec<Target>,
    /// In a group: a change rather than a message (see `groups::notice`); 0 for a
    /// message.
    #[serde(default)]
    pub notice: u8,
    /// Who a notice is about.
    #[serde(default)]
    pub about: Vec<String>,
}

/// A contact with the newest line of the conversation, for the list.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Contact {
    /// The address (32 hex digits).
    pub id: String,
    /// Their Kilit ID, four words.
    pub kilit_id: String,
    /// The name given; empty until one is.
    pub name: String,
    /// When they were added, Unix seconds.
    pub added: i64,
    /// Accepted, a request, or blocked.
    pub state: ContactState,
    /// Disappearing-message time, seconds; 0 keeps messages.
    pub timer: u32,
    /// The newest line, if there is one.
    pub last: Option<Line>,
}

/// A message that arrived and opened.
#[derive(Debug, PartialEq, Eq)]
pub struct Incoming {
    /// Who sent it.
    pub contact: String,
    /// This message made them a contact: a new request.
    pub new_contact: bool,
    /// The text.
    pub text: String,
    /// The group it came in; empty one to one.
    pub group: String,
}

/// This vault as others find it.
#[derive(Debug, PartialEq, Eq)]
pub struct MyKilit {
    /// Four words, shown with `@`.
    pub kilit_id: String,
    /// `kilit://add?…`: the link and the QR code.
    pub link: String,
}

#[derive(Default, Serialize, Deserialize)]
struct Outbox {
    events: Vec<Event>,
}

/// A file whose pieces are on their way.
#[derive(Clone, Serialize, Deserialize)]
struct Pending {
    contact: String,
    line: ByteBuf,
    file: FileRef,
    got: BTreeMap<u32, ByteBuf>,
    /// Set when the line is in a group's conversation.
    #[serde(default)]
    group: String,
}

#[derive(Default, Serialize, Deserialize)]
struct Files {
    /// By piece tag.
    pending: BTreeMap<String, Pending>,
}

impl Engine {
    fn system_now(&self) -> SystemTime {
        UNIX_EPOCH + Duration::from_secs((self.now)().max(0) as u64)
    }

    /// The Signal state, made on first use and saved at once, so the card
    /// published and the prekeys kept always agree.
    fn messaging(&self) -> Result<Messaging, EngineError> {
        let o = self.require_open()?;
        match self.store.read(SIGNAL)? {
            Some(packet) => {
                let (bytes, _) = self.open_mine(&packet)?;
                Messaging::from_bytes(&o.vault, &bytes).map_err(messaging_err)
            }
            None => {
                let m = Messaging::create(&o.vault).map_err(messaging_err)?;
                self.save_messaging(&m)?;
                Ok(m)
            }
        }
    }

    fn save_messaging(&self, m: &Messaging) -> Result<(), EngineError> {
        let bytes = m.to_bytes().map_err(messaging_err)?;
        let packet = self.seal_to_me(SIGNAL_NAME, CBOR, &bytes)?;
        Ok(self.store.write(SIGNAL, &packet)?)
    }

    fn load<T: Default + for<'de> Deserialize<'de>>(&self, blob: &str) -> Result<T, EngineError> {
        let Some(packet) = self.store.read(blob)? else {
            return Ok(T::default());
        };
        let (bytes, _) = self.open_mine(&packet)?;
        ciborium::from_reader(bytes.as_slice()).map_err(|_| EngineError::Damaged)
    }

    fn save<T: Serialize>(&self, blob: &str, name: &str, v: &T) -> Result<(), EngineError> {
        let mut bytes = Vec::new();
        ciborium::into_writer(v, &mut bytes).map_err(|_| EngineError::Damaged)?;
        let packet = self.seal_to_me(name, CBOR, &bytes)?;
        Ok(self.store.write(blob, &packet)?)
    }

    /// This vault's Kilit ID and invite link.
    pub fn my_kilit(&self) -> Result<MyKilit, EngineError> {
        let m = self.messaging()?;
        Ok(MyKilit {
            kilit_id: m.kilit_id().to_owned(),
            link: m.invite_link(),
        })
    }

    /// A new Kilit ID: new words, link and QR code. Contacts stay.
    pub fn renew_kilit_id(&mut self) -> Result<MyKilit, EngineError> {
        let mut m = self.messaging()?;
        m.renew_id(self.system_now()).map_err(messaging_err)?;
        self.save_messaging(&m)?;
        self.my_kilit()
    }

    /// The card to publish, signed with the vault's card key.
    pub fn card_event(&self) -> Result<Event, EngineError> {
        let m = self.messaging()?;
        let card = m.card("").map_err(messaging_err)?;
        Event::sign(
            m.card_key(),
            (self.now)(),
            CARD_KIND,
            vec![vec!["d".into(), m.card_tag()]],
            URL_SAFE_NO_PAD.encode(card),
        )
        .map_err(|_| EngineError::Damaged)
    }

    /// Empty cards under earlier IDs, which replace the old cards on the
    /// relays so the old ID finds nobody. Each is handed out once.
    pub fn retired_card_events(&mut self) -> Result<Vec<Event>, EngineError> {
        let mut m = self.messaging()?;
        let old = m.take_retired_ids();
        if old.is_empty() {
            return Ok(Vec::new());
        }
        self.save_messaging(&m)?;
        old.iter()
            .map(|w| {
                Event::sign(
                    m.card_key(),
                    (self.now)(),
                    CARD_KIND,
                    vec![vec!["d".into(), card_tag(w)]],
                    String::new(),
                )
                .map_err(|_| EngineError::Damaged)
            })
            .collect()
    }

    /// What to watch on the relays: messages to any of this vault's tags,
    /// and the pieces of files on their way.
    pub fn inbox_filter(&self) -> Result<Filter, EngineError> {
        let m = self.messaging()?;
        let mut tags = m.inbox_tags(self.system_now()).map_err(messaging_err)?;
        let files: Files = self.load(FILES)?;
        tags.extend(files.pending.keys().cloned());
        Ok(Filter {
            kinds: vec![MESSAGE_KIND],
            tags: vec![('p', tags)],
            since: Some((self.now)() - INBOX_BACK.as_secs() as i64),
            limit: None,
        })
    }

    /// Reads a link, a QR code's text or a typed `@ID`.
    pub fn invite(text: &str) -> Result<Invite, EngineError> {
        parse_invite(text).ok_or_else(|| EngineError::Rejected("not a Kilit ID or link".into()))
    }

    /// The filter that finds the card an invite names.
    pub fn card_filter(invite: &Invite) -> Filter {
        Filter {
            kinds: vec![CARD_KIND],
            tags: vec![('d', vec![card_tag(&invite.id)])],
            since: None,
            limit: Some(20),
        }
    }

    /// Adds the contact `invite` names from the cards the relays returned:
    /// the newest whose identity matches the invite. Others claiming the
    /// same ID are ignored.
    pub fn add_from_cards(
        &mut self,
        invite: &Invite,
        cards: &[Event],
        name: Option<&str>,
    ) -> Result<Contact, EngineError> {
        let mut found: Vec<(i64, Vec<u8>)> = cards
            .iter()
            .filter(|e| e.kind == CARD_KIND && !e.content.is_empty() && e.verify())
            .filter_map(|e| Some((e.created_at, URL_SAFE_NO_PAD.decode(&e.content).ok()?)))
            .collect();
        found.sort_by_key(|(t, _)| std::cmp::Reverse(*t));
        // each check runs Argon2id: the newest few are enough
        let card = found
            .into_iter()
            .take(5)
            .map(|(_, c)| c)
            .find(|c| card_matches(c, invite))
            .ok_or_else(|| EngineError::Rejected("no card for this ID".into()))?;
        let mut m = self.messaging()?;
        let id = m
            .add_contact(
                &card,
                Some(invite),
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
            kilit_id: c.kilit_id,
            name: c.name,
            added: c.added,
            state: c.state,
            timer: c.timer,
            last,
        })
    }

    /// The contacts, requests and blocked ones included, newest
    /// conversation first.
    pub fn contacts(&self) -> Result<Vec<Contact>, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(Vec::new());
        }
        let m = self.messaging()?;
        let mut v = m
            .contacts()
            .into_iter()
            .map(|c| self.with_last(c))
            .collect::<Result<Vec<_>, _>>()?;
        v.sort_by_key(|c| std::cmp::Reverse(c.last.as_ref().map_or(c.added, |l| l.at)));
        Ok(v)
    }

    fn change_messaging(
        &mut self,
        f: impl FnOnce(&mut Messaging) -> Result<(), MessagingError>,
    ) -> Result<(), EngineError> {
        let mut m = self.messaging()?;
        f(&mut m).map_err(messaging_err)?;
        self.save_messaging(&m)
    }

    /// Gives a contact a name.
    pub fn rename_contact(&mut self, id: &str, name: &str) -> Result<(), EngineError> {
        self.change_messaging(|m| m.rename(id, name))
    }

    /// Lets a request in, and tells them their messages arrived.
    pub fn accept_contact(&mut self, id: &str) -> Result<(), EngineError> {
        self.change_messaging(|m| m.accept(id))?;
        let ids: Vec<Vec<u8>> = self
            .chat(id)?
            .into_iter()
            .filter(|l| !l.outgoing && !l.id.is_empty())
            .map(|l| l.id.into_vec())
            .collect();
        self.send_receipts(id, ids)
    }

    /// Hears nothing more from a contact.
    pub fn block_contact(&mut self, id: &str) -> Result<(), EngineError> {
        self.change_messaging(|m| m.block(id))
    }

    /// Forgets a contact: session, identity key, conversation and files.
    pub fn remove_contact(&mut self, id: &str) -> Result<(), EngineError> {
        let blob = chat_blob(id)?;
        for l in self.chat(id)? {
            self.drop_file(&l)?;
        }
        self.change_messaging(|m| m.remove(id))?;
        Ok(self.store.delete(&blob)?)
    }

    /// Sets the conversation's disappearing-message time, in seconds; 0
    /// keeps messages. The next message tells them.
    pub fn set_timer(&mut self, id: &str, secs: u32) -> Result<(), EngineError> {
        self.change_messaging(|m| m.set_timer(id, secs))
    }

    /// The safety number to compare with a contact.
    pub fn safety_number(&self, id: &str) -> Result<String, EngineError> {
        self.messaging()?.safety_number(id).map_err(messaging_err)
    }

    /// A conversation, oldest line first, without the lines whose time is
    /// up.
    pub fn chat(&self, id: &str) -> Result<Vec<Line>, EngineError> {
        let now = (self.now)();
        let lines: Vec<Line> = self.load_chat(id)?;
        Ok(lines
            .into_iter()
            .filter(|l| l.expires == 0 || l.expires > now)
            .collect())
    }

    fn load_chat(&self, id: &str) -> Result<Vec<Line>, EngineError> {
        self.load(&chat_blob(id)?)
    }

    fn save_chat(&self, id: &str, mut lines: Vec<Line>) -> Result<(), EngineError> {
        if lines.len() > MAX_LINES {
            lines.drain(..lines.len() - MAX_LINES);
        }
        self.save(&chat_blob(id)?, CHAT_NAME, &lines)
    }

    fn drop_file(&self, l: &Line) -> Result<(), EngineError> {
        if let Some(f) = &l.file
            && !f.blob.is_empty()
        {
            self.store.delete(&f.blob)?;
        }
        Ok(())
    }

    /// Removes the lines whose time is up, with their files, from every
    /// conversation. Run now and then; [`Engine::chat`] hides them anyway.
    pub fn sweep_expired(&mut self) -> Result<(), EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(());
        }
        let now = (self.now)();
        for c in self.messaging()?.contacts() {
            let lines = self.load_chat(&c.id)?;
            let (gone, kept): (Vec<Line>, Vec<Line>) = lines
                .into_iter()
                .partition(|l| l.expires != 0 && l.expires <= now);
            if !gone.is_empty() {
                for l in &gone {
                    self.drop_file(l)?;
                }
                self.save_chat(&c.id, kept)?;
            }
        }
        Ok(())
    }

    fn expires(&self, timer: u32) -> i64 {
        if timer == 0 {
            0
        } else {
            (self.now)() + i64::from(timer)
        }
    }

    /// A file's bytes, sent or received.
    pub fn read_attachment(&self, blob: &str) -> Result<Vec<u8>, EngineError> {
        let blob = att_blob(blob.strip_prefix("att-").unwrap_or(blob))?;
        let packet = self.store.read(&blob)?.ok_or(EngineError::NotFound)?;
        Ok(self.open_mine(&packet)?.0)
    }

    fn queue(&self, events: Vec<Event>) -> Result<(), EngineError> {
        let mut outbox: Outbox = self.load(OUTBOX)?;
        if outbox.events.len() + events.len() > MAX_OUTBOX {
            return Err(EngineError::TooLong);
        }
        outbox.events.extend(events);
        self.save(OUTBOX, OUTBOX_NAME, &outbox)
    }

    fn message_event(&self, tag: String, payload: &[u8]) -> Result<Event, EngineError> {
        Event::sign_once(
            (self.now)(),
            MESSAGE_KIND,
            vec![vec!["p".into(), tag]],
            URL_SAFE_NO_PAD.encode(payload),
        )
        .map_err(|_| EngineError::Damaged)
    }

    fn send_receipts(&mut self, contact: &str, ids: Vec<Vec<u8>>) -> Result<(), EngineError> {
        if ids.is_empty() {
            return Ok(());
        }
        let mut m = self.messaging()?;
        let out = m
            .seal(
                contact,
                &Content {
                    receipts: ids,
                    ..Content::default()
                },
                self.system_now(),
            )
            .map_err(messaging_err)?;
        let event = self.message_event(out.tag, &out.payload)?;
        self.save_messaging(&m)?;
        self.queue(vec![event])
    }

    /// Seals `text` for a contact and queues the event that carries it.
    /// Returns the line as the conversation now shows it, and the events.
    pub fn send_message(
        &mut self,
        id: &str,
        text: &str,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        self.send(id, text, None, Vec::new(), None)
    }

    /// Sends a file (at most [`MAX_FILE`]), with `text` beside it. Pictures
    /// lose their metadata first.
    pub fn send_file(
        &mut self,
        id: &str,
        name: &str,
        mime: &str,
        data: &[u8],
        text: &str,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        let (file, pieces, shown) = self.prepare_file(name, mime, data)?;
        self.send(id, text, Some(file), pieces, Some(shown))
    }

    /// Cleans a file, seals it into pieces and keeps a copy here.
    fn prepare_file(
        &mut self,
        name: &str,
        mime: &str,
        data: &[u8],
    ) -> Result<(FileRef, Vec<Event>, LineFile), EngineError> {
        let cleaned = match kilit_parse::clean(data) {
            Ok(r) => r.data,
            Err(_) => data.to_vec(),
        };
        if cleaned.len() > MAX_FILE {
            return Err(EngineError::TooLong);
        }
        let key = random::<32>()?;
        let tag = hex(&random::<32>()?);
        let pieces = self.pieces(&key, &tag, &cleaned)?;
        let file = FileRef {
            key: ByteBuf::from(key.to_vec()),
            tag,
            chunks: pieces.len() as u32,
            size: cleaned.len() as u64,
            sha256: ByteBuf::from(Sha256::digest(&cleaned).to_vec()),
            name: name.chars().take(128).collect(),
            mime: mime.chars().take(128).collect(),
        };
        // our own copy, sealed to the vault like everything else
        let blob = att_blob(&hex(&random::<8>()?))?;
        let packet = self.seal_to_me(&file.name, &file.mime, &cleaned)?;
        self.store.write(&blob, &packet)?;
        let shown = LineFile {
            name: file.name.clone(),
            mime: file.mime.clone(),
            size: file.size,
            blob,
        };
        Ok((file, pieces, shown))
    }

    /// A file's pieces, each its own event under the file's tag. The same
    /// key, tag and bytes give the same pieces again.
    fn pieces(&self, key: &[u8], tag: &str, data: &[u8]) -> Result<Vec<Event>, EngineError> {
        let cipher = XChaCha20Poly1305::new_from_slice(key).map_err(|_| EngineError::Damaged)?;
        let mut pieces = Vec::new();
        for (i, chunk) in data.chunks(CHUNK).enumerate() {
            let i = i as u32;
            let sealed = cipher
                .encrypt(
                    &chunk_nonce(i),
                    Payload {
                        msg: chunk,
                        aad: tag.as_bytes(),
                    },
                )
                .map_err(|_| EngineError::Damaged)?;
            let mut content = i.to_le_bytes().to_vec();
            content.extend_from_slice(&sealed);
            pieces.push(self.message_event(tag.to_owned(), &content)?);
        }
        Ok(pieces)
    }

    fn send(
        &mut self,
        id: &str,
        text: &str,
        file: Option<FileRef>,
        mut pieces: Vec<Event>,
        shown: Option<LineFile>,
    ) -> Result<(Line, Vec<Event>), EngineError> {
        let mut m = self.messaging()?;
        let timer = m.timer(id).map_err(messaging_err)?;
        let now = (self.now)();
        let out = m
            .seal(
                id,
                &Content {
                    text: text.to_owned(),
                    timer,
                    file: file.clone(),
                    ..Content::default()
                },
                self.system_now(),
            )
            .map_err(messaging_err)?;
        let event = self.message_event(out.tag, &out.payload)?;
        // the session moved on: keep it first, then the events, so a crash
        // between them loses at worst this one message
        self.save_messaging(&m)?;
        // the pieces go first, so they are there when the message arrives
        pieces.push(event.clone());
        self.queue(pieces.clone())?;
        let line = Line {
            outgoing: true,
            text: text.to_owned(),
            at: now,
            sent: now,
            state: LineState::Queued,
            event: event.id.clone(),
            id: ByteBuf::from(out.id),
            expires: self.expires(timer),
            file: shown,
            file_ref: file,
            ..Line::default()
        };
        let mut lines = self.load_chat(id)?;
        lines.push(line.clone());
        self.save_chat(id, lines)?;
        Ok((line, pieces))
    }

    /// Seals an outgoing line again, as the same message under today's
    /// mailbox, and queues it; with `pieces`, its file's pieces too, from
    /// the copy kept here. A line already delivered is left alone.
    pub fn resend(&mut self, contact: &str, id: &[u8], pieces: bool) -> Result<(), EngineError> {
        let mut lines = self.load_chat(contact)?;
        let i = lines
            .iter()
            .position(|l| l.outgoing && *l.id == *id)
            .ok_or(EngineError::NotFound)?;
        let line = lines[i].clone();
        if line.state == LineState::Delivered {
            return Ok(());
        }
        let mut m = self.messaging()?;
        let timer = m.timer(contact).map_err(messaging_err)?;
        let out = m
            .seal(
                contact,
                &Content {
                    text: line.text.clone(),
                    timer,
                    file: line.file_ref.clone(),
                    again: Some((line.id.to_vec(), line.sent)),
                    ..Content::default()
                },
                self.system_now(),
            )
            .map_err(messaging_err)?;
        let event = self.message_event(out.tag, &out.payload)?;
        self.save_messaging(&m)?;
        let mut events = Vec::new();
        if pieces
            && let (Some(f), Some(shown)) = (&line.file_ref, &line.file)
            && !shown.blob.is_empty()
        {
            let data = self.read_attachment(&shown.blob)?;
            events = self.pieces(&f.key, &f.tag, &data)?;
        }
        events.push(event.clone());
        self.queue(events)?;
        let l = &mut lines[i];
        l.event = event.id;
        l.state = LineState::Queued;
        l.tries += 1;
        l.tried = (self.now)();
        self.save_chat(contact, lines)
    }

    /// Sends again every message a relay kept but whose receipt has not
    /// come, once a day for about a week. Returns how many went.
    pub fn resend_due(&mut self) -> Result<usize, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(0);
        }
        let now = (self.now)();
        let mut sent = 0;
        for c in self.messaging()?.contacts() {
            if c.state == ContactState::Blocked {
                continue;
            }
            let due: Vec<ByteBuf> = self
                .load_chat(&c.id)?
                .into_iter()
                .filter(|l| {
                    l.outgoing
                        && l.state == LineState::Sent
                        && l.tries < MAX_RESENDS
                        && (l.expires == 0 || l.expires > now)
                        && now - l.tried.max(l.at) >= RESEND_EVERY
                })
                .map(|l| l.id)
                .collect();
            for id in due {
                self.resend(&c.id, &id, false)?;
                sent += 1;
            }
        }
        Ok(sent + self.resend_due_groups()?)
    }

    /// Events waiting for a relay.
    pub fn outbox(&self) -> Result<Vec<Event>, EngineError> {
        Ok(self.load::<Outbox>(OUTBOX)?.events)
    }

    /// A relay stored these events: they leave the outbox, and their lines
    /// show as sent.
    pub fn mark_stored(&mut self, ids: &[String]) -> Result<(), EngineError> {
        if ids.is_empty() {
            return Ok(());
        }
        let mut outbox: Outbox = self.load(OUTBOX)?;
        outbox.events.retain(|e| !ids.contains(&e.id));
        self.save(OUTBOX, OUTBOX_NAME, &outbox)?;
        self.restate(
            |l| l.state == LineState::Queued && ids.contains(&l.event),
            LineState::Sent,
        )?;
        self.restate_groups(ids, &[])
    }

    /// Sets the state of every outgoing line `which` picks.
    fn restate(&mut self, which: impl Fn(&Line) -> bool, to: LineState) -> Result<(), EngineError> {
        for c in self.messaging()?.contacts() {
            let mut lines = self.load_chat(&c.id)?;
            let mut changed = false;
            for l in lines.iter_mut().filter(|l| l.outgoing && which(l)) {
                l.state = to;
                changed = true;
            }
            if changed {
                self.save_chat(&c.id, lines)?;
            }
        }
        Ok(())
    }

    /// Opens what arrived: messages, receipts, and pieces of files. What
    /// does not open (old, not for us, from a blocked contact, a stranger
    /// without the proof of work) is dropped without a word.
    pub fn receive_events(&mut self, events: &[Event]) -> Result<Vec<Incoming>, EngineError> {
        let mut files: Files = self.load(FILES)?;
        let mut pieces: HashMap<String, Vec<&Event>> = HashMap::new();
        let mut messages = Vec::new();
        for e in events
            .iter()
            .filter(|e| e.kind == MESSAGE_KIND && e.verify())
        {
            match e.tag("p") {
                Some(t) if files.pending.contains_key(t) => {
                    pieces.entry(t.to_owned()).or_default().push(e);
                }
                _ => messages.push(e),
            }
        }

        let mut m = self.messaging()?;
        let mut opened = Vec::new();
        let mut confirm: HashMap<String, Vec<Vec<u8>>> = HashMap::new();
        let mut delivered: Vec<(String, Vec<u8>)> = Vec::new();
        let mut rosters = Vec::new();
        for e in messages {
            let Ok(payload) = URL_SAFE_NO_PAD.decode(&e.content) else {
                continue;
            };
            let mut r: Received = match m.decrypt(&payload, self.system_now()) {
                Ok(r) => r,
                Err(MessagingError::Crypto) => return Err(EngineError::Damaged),
                Err(_) => continue,
            };
            // the session moved on: keep it before the line
            self.save_messaging(&m)?;
            delivered.extend(r.receipts.iter().map(|id| (r.contact.clone(), id.clone())));
            if let Some(wire) = r.group.take() {
                let told =
                    self.take_group(&mut m, r, wire, &mut files, &mut confirm, &mut rosters)?;
                opened.extend(told);
                continue;
            }
            if r.text.is_empty() && r.file.is_none() {
                continue;
            }
            // a group member writing one to one is a request like anyone
            if m.contacts()
                .iter()
                .any(|c| c.id == r.contact && c.state == ContactState::Member)
            {
                m.set_state(&r.contact, ContactState::Request)
                    .map_err(messaging_err)?;
                self.save_messaging(&m)?;
            }
            let accepted = m
                .contacts()
                .iter()
                .any(|c| c.id == r.contact && c.state == ContactState::Accepted);
            let mut lines = self.load_chat(&r.contact)?;
            if let Some(old) = lines.iter().find(|l| !l.outgoing && *l.id == *r.id) {
                // sent again: our receipt did not reach them, so it goes
                // again; a file still missing pieces is looked for again
                if accepted {
                    confirm.entry(r.contact.clone()).or_default().push(r.id);
                }
                if let (Some(f), Some(shown)) = (&r.file, &old.file)
                    && shown.blob.is_empty()
                    && !files.pending.contains_key(&f.tag)
                    && files.pending.len() < MAX_PENDING_FILES
                {
                    files.pending.insert(
                        f.tag.clone(),
                        Pending {
                            contact: r.contact.clone(),
                            line: old.id.clone(),
                            file: f.clone(),
                            got: BTreeMap::new(),
                            group: String::new(),
                        },
                    );
                }
                continue;
            }
            let file = match &r.file {
                Some(f) if f.chunks > 0 && f.chunks as usize <= MAX_FILE.div_ceil(CHUNK) + 1 => {
                    if files.pending.len() < MAX_PENDING_FILES {
                        files.pending.insert(
                            f.tag.clone(),
                            Pending {
                                contact: r.contact.clone(),
                                line: ByteBuf::from(r.id.clone()),
                                file: f.clone(),
                                got: BTreeMap::new(),
                                group: String::new(),
                            },
                        );
                    }
                    Some(LineFile {
                        name: f.name.clone(),
                        mime: f.mime.clone(),
                        size: f.size,
                        blob: String::new(),
                    })
                }
                _ => None,
            };
            lines.push(Line {
                outgoing: false,
                text: r.text.clone(),
                at: (self.now)(),
                sent: r.sent,
                state: LineState::Delivered,
                event: String::new(),
                id: ByteBuf::from(r.id.clone()),
                expires: self.expires(r.timer),
                file,
                ..Line::default()
            });
            self.save_chat(&r.contact, lines)?;
            if accepted {
                confirm.entry(r.contact.clone()).or_default().push(r.id);
            }
            opened.push(Incoming {
                contact: r.contact,
                new_contact: r.new_contact,
                text: r.text,
                group: String::new(),
            });
        }
        self.save(FILES, FILES_NAME, &files)?;
        if !delivered.is_empty() {
            self.restate(
                |l| l.state != LineState::Delivered && delivered.iter().any(|(_, d)| *d == *l.id),
                LineState::Delivered,
            )?;
            self.restate_groups(&[], &delivered)?;
        }
        for (contact, ids) in confirm {
            self.send_receipts(&contact, ids)?;
        }
        self.send_rosters(&rosters)?;
        self.take_pieces(&mut files, &pieces)?;
        Ok(opened)
    }

    /// Opens the pieces that arrived; a file whose pieces are all in is
    /// checked against its hash, kept, and shown on its line.
    fn take_pieces(
        &mut self,
        files: &mut Files,
        pieces: &HashMap<String, Vec<&Event>>,
    ) -> Result<(), EngineError> {
        if pieces.is_empty() {
            return Ok(());
        }
        let mut done = Vec::new();
        for (tag, events) in pieces {
            let Some(p) = files.pending.get_mut(tag) else {
                continue;
            };
            let Ok(cipher) = XChaCha20Poly1305::new_from_slice(&p.file.key) else {
                continue;
            };
            for e in events {
                let Ok(raw) = URL_SAFE_NO_PAD.decode(&e.content) else {
                    continue;
                };
                let Some((idx, sealed)) = raw.split_first_chunk::<4>() else {
                    continue;
                };
                let i = u32::from_le_bytes(*idx);
                if i >= p.file.chunks || p.got.contains_key(&i) {
                    continue;
                }
                if let Ok(plain) = cipher.decrypt(
                    &chunk_nonce(i),
                    Payload {
                        msg: sealed,
                        aad: tag.as_bytes(),
                    },
                ) {
                    p.got.insert(i, ByteBuf::from(plain));
                }
            }
            if p.got.len() == p.file.chunks as usize {
                done.push(tag.clone());
            }
        }
        for tag in done {
            let Some(mut p) = files.pending.remove(&tag) else {
                continue;
            };
            let whole: Vec<u8> = std::mem::take(&mut p.got)
                .into_values()
                .flat_map(ByteBuf::into_vec)
                .collect();
            let ok = whole.len() as u64 == p.file.size
                && Sha256::digest(&whole).as_slice() == p.file.sha256.as_slice();
            let mut lines = self.file_lines(&p)?;
            let Some(line) = lines.iter_mut().find(|l| !l.outgoing && l.id == p.line) else {
                continue;
            };
            if ok {
                let blob = att_blob(&hex(&random::<8>()?))?;
                let packet = self.seal_to_me(&p.file.name, &p.file.mime, &whole)?;
                self.store.write(&blob, &packet)?;
                if let Some(f) = line.file.as_mut() {
                    f.blob = blob;
                }
            } else {
                // a file that does not match its hash is not kept
                line.file = None;
            }
            self.save_file_lines(&p, lines)?;
        }
        self.save(FILES, FILES_NAME, files)
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

    /// Stands in for the relays: everything published, filtered on read.
    #[derive(Default)]
    struct Relays(Vec<Event>);

    impl Relays {
        fn get(&self, f: &Filter) -> Vec<Event> {
            self.0.iter().filter(|e| f.matches(e)).cloned().collect()
        }

        /// Publishes the outbox and tells the engine a relay kept it.
        fn take_outbox(&mut self, e: &mut Engine) {
            let out = e.outbox().unwrap();
            let ids: Vec<String> = out.iter().map(|x| x.id.clone()).collect();
            self.0.extend(out);
            e.mark_stored(&ids).unwrap();
        }

        fn deliver(&self, e: &mut Engine) -> Vec<Incoming> {
            e.receive_events(&self.get(&e.inbox_filter().unwrap()))
                .unwrap()
        }
    }

    fn meet(ayse: &mut Engine, bora: &mut Engine, relays: &mut Relays) -> (String, String) {
        relays.0.push(bora.card_event().unwrap());
        let inv = Engine::invite(&bora.my_kilit().unwrap().link).unwrap();
        let c = ayse
            .add_from_cards(&inv, &relays.get(&Engine::card_filter(&inv)), Some("Bora"))
            .unwrap();
        ayse.send_message(&c.id, "selam").unwrap();
        relays.take_outbox(ayse);
        let got = relays.deliver(bora);
        let ayse_id = got[0].contact.clone();
        bora.accept_contact(&ayse_id).unwrap();
        relays.take_outbox(bora);
        relays.deliver(ayse);
        (ayse_id, c.id)
    }

    #[test]
    fn two_vaults_find_each_other_and_talk_through_relays() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        relays.0.push(bora.card_event().unwrap());

        // Ayşe types Bora's ID
        let typed = format!("@{}", bora.my_kilit().unwrap().kilit_id);
        let inv = Engine::invite(&typed).unwrap();
        let cards = relays.get(&Engine::card_filter(&inv));
        let c = ayse.add_from_cards(&inv, &cards, Some("Bora")).unwrap();
        assert_eq!((c.name.as_str(), c.state), ("Bora", ContactState::Accepted));

        let (line, _) = ayse.send_message(&c.id, "selam").unwrap();
        assert_eq!(line.state, LineState::Queued);
        relays.take_outbox(&mut ayse);
        assert!(ayse.outbox().unwrap().is_empty());
        assert_eq!(ayse.chat(&c.id).unwrap()[0].state, LineState::Sent);

        let got = relays.deliver(&mut bora);
        assert_eq!(got.len(), 1);
        assert!(got[0].new_contact);
        let ayse_id = got[0].contact.clone();
        let req = &bora.contacts().unwrap()[0];
        assert_eq!(req.state, ContactState::Request);
        assert_eq!(req.kilit_id, ayse.my_kilit().unwrap().kilit_id);
        // a request is not answered: Ayşe's line stays at one tick
        assert!(bora.outbox().unwrap().is_empty());
        bora.accept_contact(&ayse_id).unwrap();
        // accepting answers it: two ticks
        relays.take_outbox(&mut bora);
        relays.deliver(&mut ayse);
        assert_eq!(ayse.chat(&c.id).unwrap()[0].state, LineState::Delivered);

        // the same events again open nothing new
        assert!(relays.deliver(&mut bora).is_empty());

        bora.send_message(&ayse_id, "aleyküm selam").unwrap();
        relays.take_outbox(&mut bora);
        ayse.lock();
        ayse.unlock("482916".into()).unwrap();
        let got = relays.deliver(&mut ayse);
        assert_eq!(got[0].text, "aleyküm selam");
        // Ayşe answers with a receipt on her own
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        assert_eq!(
            bora.chat(&ayse_id).unwrap().last().unwrap().state,
            LineState::Delivered
        );
        assert_eq!(
            ayse.safety_number(&c.id).unwrap(),
            bora.safety_number(&ayse_id).unwrap()
        );
    }

    use std::sync::atomic::{AtomicI64, Ordering};

    static AYSE_NOW: AtomicI64 = AtomicI64::new(0);
    static BORA_NOW: AtomicI64 = AtomicI64::new(0);

    #[test]
    fn an_unanswered_message_goes_again_under_the_new_day() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let start = (ayse.now)();
        AYSE_NOW.store(start, Ordering::SeqCst);
        BORA_NOW.store(start, Ordering::SeqCst);
        ayse.now = || AYSE_NOW.load(Ordering::SeqCst);
        bora.now = || BORA_NOW.load(Ordering::SeqCst);
        let mut relays = Relays::default();
        let (ayse_id, bora_id) = meet(&mut ayse, &mut bora, &mut relays);

        let (line, _) = ayse.send_message(&bora_id, "neredesin").unwrap();
        relays.take_outbox(&mut ayse);
        // nothing is due before a day has passed
        assert_eq!(ayse.resend_due().unwrap(), 0);

        // Bora was away three days: today's mailbox is no longer watched
        let later = start + 3 * 86_400;
        BORA_NOW.store(later, Ordering::SeqCst);
        assert!(relays.deliver(&mut bora).is_empty());

        AYSE_NOW.store(later, Ordering::SeqCst);
        assert_eq!(ayse.resend_due().unwrap(), 1);
        assert_eq!(
            ayse.chat(&bora_id).unwrap().last().unwrap().state,
            LineState::Queued
        );
        relays.take_outbox(&mut ayse);
        let got = relays.deliver(&mut bora);
        assert_eq!(got.len(), 1);
        assert_eq!(got[0].text, "neredesin");
        let theirs = bora.chat(&ayse_id).unwrap().last().unwrap().clone();
        assert_eq!(theirs.sent, line.sent, "the time it was written stays");

        // sent again by hand before the receipt came: still one line, and
        // the receipt answers both
        ayse.resend(&bora_id, &line.id, true).unwrap();
        relays.take_outbox(&mut ayse);
        assert!(relays.deliver(&mut bora).is_empty());
        assert_eq!(bora.chat(&ayse_id).unwrap().len(), 2);
        relays.take_outbox(&mut bora);
        relays.deliver(&mut ayse);
        let mine = ayse.chat(&bora_id).unwrap().last().unwrap().clone();
        assert_eq!((mine.state, mine.tries), (LineState::Delivered, 2));
        // delivered: never again
        AYSE_NOW.store(later + 2 * 86_400, Ordering::SeqCst);
        assert_eq!(ayse.resend_due().unwrap(), 0);
    }

    #[test]
    fn resending_stops_after_a_week() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        let (_, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        ayse.send_message(&bora_id, "orada mısın").unwrap();
        relays.take_outbox(&mut ayse);
        let mut lines = ayse.load_chat(&bora_id).unwrap();
        let l = lines.last_mut().unwrap();
        l.tries = MAX_RESENDS;
        l.at -= 30 * 86_400;
        ayse.save_chat(&bora_id, lines).unwrap();
        assert_eq!(ayse.resend_due().unwrap(), 0);
    }

    #[test]
    fn a_file_sent_again_brings_its_pieces() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        let (ayse_id, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        let data: Vec<u8> = (0..30_000u32).map(|i| (i * 13 % 251) as u8).collect();
        let (line, _) = ayse
            .send_file(&bora_id, "a.bin", "application/octet-stream", &data, "")
            .unwrap();
        // the relays lost the pieces; only the message got through
        let all = ayse.outbox().unwrap();
        let ids: Vec<String> = all.iter().map(|e| e.id.clone()).collect();
        relays.0.push(all.last().unwrap().clone());
        ayse.mark_stored(&ids).unwrap();
        relays.deliver(&mut bora);
        let l = bora.chat(&ayse_id).unwrap().last().unwrap().clone();
        assert_eq!(l.file.unwrap().blob, "");

        ayse.resend(&bora_id, &line.id, true).unwrap();
        assert_eq!(
            ayse.outbox().unwrap().len(),
            3,
            "two pieces and the message"
        );
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        relays.deliver(&mut bora);
        let lines = bora.chat(&ayse_id).unwrap();
        assert_eq!(
            lines.iter().filter(|l| !l.outgoing).count(),
            2,
            "selam and the file"
        );
        let f = lines.last().unwrap().file.clone().unwrap();
        assert_eq!(bora.read_attachment(&f.blob).unwrap(), data);
    }

    fn line_count(e: &Engine, g: &str) -> usize {
        e.group_chat(g)
            .unwrap()
            .iter()
            .filter(|l| l.notice == 0)
            .count()
    }

    #[test]
    fn a_group_of_three_where_two_have_never_met() {
        let (da, db, dc) = (
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
        );
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut can = ready(&dc, "615283");
        let mut relays = Relays::default();
        let (_, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        let (_, can_id) = meet(&mut ayse, &mut can, &mut relays);
        let ayse_id = ayse.my_address().unwrap();

        // only contacts go in
        assert!(ayse.create_group("Aile", &["0".repeat(32)]).is_err());
        let (g, _) = ayse
            .create_group("Aile", &[bora_id.clone(), can_id.clone()])
            .unwrap();
        relays.take_outbox(&mut ayse);
        let told = relays.deliver(&mut bora);
        assert_eq!(told[0].group, g.id);
        relays.deliver(&mut can);
        let bg = bora.group(&g.id).unwrap();
        assert_eq!(
            (bg.roster.name.as_str(), bg.admin.as_str()),
            ("Aile", ayse_id.as_str())
        );
        assert_eq!(bg.roster.members.len(), 3);
        assert_eq!(bora.group_chat(&g.id).unwrap()[0].notice, groups::notice::JOINED);

        // the admin writes: both have it, both answer, two of two
        ayse.send_group_message(&g.id, "merhaba").unwrap();
        relays.take_outbox(&mut ayse);
        let got = relays.deliver(&mut bora);
        assert_eq!(
            (got[0].text.as_str(), got[0].group.as_str()),
            ("merhaba", g.id.as_str())
        );
        relays.deliver(&mut can);
        relays.take_outbox(&mut bora);
        relays.take_outbox(&mut can);
        relays.deliver(&mut ayse);
        let mine = ayse.group_chat(&g.id).unwrap().pop().unwrap();
        assert_eq!(mine.state, LineState::Delivered);
        assert!(mine.to.iter().all(|t| t.state == LineState::Delivered));
        // nothing of the group shows one to one
        assert!(
            bora.chat(&ayse.my_address().unwrap())
                .unwrap()
                .iter()
                .all(|l| l.text != "merhaba")
        );

        // Bora does not know Can: the message waits for Can's card
        let (line, _) = bora.send_group_message(&g.id, "selam Can").unwrap();
        assert_eq!(line.state, LineState::Queued);
        let missing = bora.missing_members().unwrap();
        assert_eq!(missing.len(), 1);
        assert_eq!(missing[0].address.as_deref(), Some(can_id.as_str()));
        relays.0.push(can.card_event().unwrap());
        // a card that is not Can's does nothing
        assert!(
            bora.add_member_cards(&[ayse.card_event().unwrap()])
                .unwrap()
                .is_empty()
        );
        let cards = relays.get(&Engine::cards_filter(&missing));
        assert_eq!(bora.add_member_cards(&cards).unwrap().len(), 1);
        assert!(bora.missing_members().unwrap().is_empty());
        let can_seen = bora.contacts().unwrap();
        let c = can_seen.iter().find(|c| c.id == can_id).unwrap();
        assert_eq!(c.state, ContactState::Member);
        relays.take_outbox(&mut bora);
        relays.deliver(&mut ayse);
        let got = relays.deliver(&mut can);
        assert_eq!(got.len(), 1);
        assert_eq!(got[0].text, "selam Can");
        assert!(!got[0].new_contact);
        // for Can, Bora is one of the group, not a request
        let b = can
            .contacts()
            .unwrap()
            .into_iter()
            .find(|c| c.id == bora_id)
            .unwrap();
        assert_eq!(b.state, ContactState::Member);
        relays.take_outbox(&mut can);
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        let mine = bora.group_chat(&g.id).unwrap().pop().unwrap();
        assert_eq!(mine.state, LineState::Delivered);

        // and Can answers Bora straight away
        can.send_group_message(&g.id, "selam Bora").unwrap();
        relays.take_outbox(&mut can);
        let got = relays.deliver(&mut bora);
        assert_eq!(got[0].text, "selam Bora");
        assert_eq!(line_count(&bora, &g.id), 3);

        // the admin takes Can out; Can can no longer write in it
        ayse.remove_group_member(&g.id, &can_id).unwrap();
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        relays.deliver(&mut can);
        let cg = can.group(&g.id).unwrap();
        assert!(cg.gone);
        assert_eq!(
            can.group_chat(&g.id).unwrap().last().unwrap().notice,
            groups::notice::REMOVED_YOU
        );
        assert!(can.send_group_message(&g.id, "hey").is_err());
        assert_eq!(bora.group(&g.id).unwrap().roster.members.len(), 2);
        // only the admin changes the group
        assert!(bora.rename_group(&g.id, "Bizim").is_err());

        // Bora leaves: two became one, and the group ends
        bora.leave_group(&g.id).unwrap();
        relays.take_outbox(&mut bora);
        relays.deliver(&mut ayse);
        let ag = ayse.group(&g.id).unwrap();
        assert!(ag.roster.ended);
        assert!(ayse.delete_group(&g.id).is_ok());
        assert!(ayse.groups().unwrap().is_empty());
    }

    #[test]
    fn a_group_message_from_someone_outside_it_is_dropped() {
        let (da, db, dc) = (
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
        );
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut can = ready(&dc, "615283");
        let mut relays = Relays::default();
        let (_, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        let (_, can_bora) = meet(&mut can, &mut bora, &mut relays);
        let (g, _) = ayse.create_group("İki", std::slice::from_ref(&bora_id)).unwrap();
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        // Can knows Bora but is not in the group; Can makes a group of the
        // same id up by hand and writes in it
        let wire = GroupWire {
            id: ByteBuf::from(groups_unhex(&g.id)),
            roster: None,
            leave: false,
        };
        let mut m = can.messaging().unwrap();
        let out = m
            .seal(
                &can_bora,
                &Content {
                    text: "içeri girdim".into(),
                    group: Some(wire),
                    ..Content::default()
                },
                can.system_now(),
            )
            .unwrap();
        can.save_messaging(&m).unwrap();
        let ev = can.message_event(out.tag, &out.payload).unwrap();
        relays.0.push(ev);
        assert!(relays.deliver(&mut bora).is_empty());
        assert_eq!(line_count(&bora, &g.id), 0);
    }

    fn groups_unhex(s: &str) -> Vec<u8> {
        (0..s.len())
            .step_by(2)
            .map(|i| u8::from_str_radix(&s[i..i + 2], 16).unwrap())
            .collect()
    }

    #[test]
    fn a_picture_arrives_in_pieces_and_whole() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        let (ayse_id, bora_id) = meet(&mut ayse, &mut bora, &mut relays);

        let data: Vec<u8> = (0..70_000u32).map(|i| (i * 7 % 251) as u8).collect();
        let (line, events) = ayse
            .send_file(
                &bora_id,
                "veri.bin",
                "application/octet-stream",
                &data,
                "dosya",
            )
            .unwrap();
        assert_eq!(events.len(), 4, "three pieces and the message");
        let mine = line.file.unwrap();
        assert_eq!(ayse.read_attachment(&mine.blob).unwrap(), data);

        // the message first, the pieces later, as relays may hand them out
        let all = ayse.outbox().unwrap();
        let (msg, pieces) = all.split_last().unwrap();
        relays.0.push(msg.clone());
        relays.deliver(&mut bora);
        let l = bora.chat(&ayse_id).unwrap().last().unwrap().clone();
        assert_eq!(l.text, "dosya");
        assert_eq!(l.file.as_ref().unwrap().blob, "");
        // the filter now asks for the pieces too
        relays.0.extend(pieces.iter().cloned());
        relays.deliver(&mut bora);
        let l = bora.chat(&ayse_id).unwrap().last().unwrap().clone();
        let f = l.file.unwrap();
        assert_eq!((f.name.as_str(), f.size), ("veri.bin", 70_000));
        assert_eq!(bora.read_attachment(&f.blob).unwrap(), data);
        assert!(
            ayse.send_file(&bora_id, "x", "x", &vec![0; MAX_FILE + 1], "")
                .is_err()
        );
    }

    #[test]
    fn disappearing_messages_go_with_their_files() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        let (ayse_id, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        ayse.set_timer(&bora_id, 60).unwrap();
        let (line, _) = ayse
            .send_file(
                &bora_id,
                "a.bin",
                "application/octet-stream",
                &[1, 2, 3],
                "kısa",
            )
            .unwrap();
        assert!(line.expires > 0);
        relays.take_outbox(&mut ayse);
        relays.deliver(&mut bora);
        // the message names the file; its pieces come on the next round
        relays.deliver(&mut bora);
        assert_eq!(bora.contacts().unwrap()[0].timer, 60, "the timer travels");
        let blob = bora
            .chat(&ayse_id)
            .unwrap()
            .last()
            .unwrap()
            .file
            .clone()
            .unwrap()
            .blob;
        assert!(!blob.is_empty());

        // a minute later
        bora.now = || 4_102_444_800;
        assert!(
            bora.chat(&ayse_id)
                .unwrap()
                .iter()
                .all(|l| l.text != "kısa")
        );
        bora.sweep_expired().unwrap();
        assert!(bora.read_attachment(&blob).is_err(), "the file is gone too");
    }

    #[test]
    fn a_new_id_blanks_the_old_card_and_keeps_contacts() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let mut bora = ready(&db, "739204");
        let mut relays = Relays::default();
        let (ayse_id, bora_id) = meet(&mut ayse, &mut bora, &mut relays);
        let old = bora.my_kilit().unwrap();
        let new = bora.renew_kilit_id().unwrap();
        assert_ne!(old.kilit_id, new.kilit_id);
        let blanks = bora.retired_card_events().unwrap();
        assert_eq!(blanks.len(), 1);
        assert!(blanks[0].content.is_empty());
        assert!(bora.retired_card_events().unwrap().is_empty());
        // the old ID finds nobody once the blank replaces the card
        relays.0.retain(|e| e.kind != CARD_KIND);
        relays.0.extend(blanks);
        relays.0.push(bora.card_event().unwrap());
        let old_inv = Engine::invite(&old.link).unwrap();
        let (dc,) = (tempfile::tempdir().unwrap(),);
        let mut cem = ready(&dc, "135790");
        assert!(
            cem.add_from_cards(&old_inv, &relays.get(&Engine::card_filter(&old_inv)), None)
                .is_err()
        );
        let new_inv = Engine::invite(&new.link).unwrap();
        assert!(
            cem.add_from_cards(&new_inv, &relays.get(&Engine::card_filter(&new_inv)), None)
                .is_ok()
        );
        // Ayşe and Bora go on
        bora.send_message(&ayse_id, "yeni kimlik").unwrap();
        relays.take_outbox(&mut bora);
        assert_eq!(relays.deliver(&mut ayse)[0].text, "yeni kimlik");
        let shown = ayse
            .contacts()
            .unwrap()
            .into_iter()
            .find(|c| c.id == bora_id)
            .unwrap();
        assert_eq!(shown.kilit_id, new.kilit_id);
    }

    #[test]
    fn a_card_under_the_wrong_id_is_not_added() {
        let (da, db, dc) = (
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
            tempfile::tempdir().unwrap(),
        );
        let mut ayse = ready(&da, "482916");
        let bora = ready(&db, "739204");
        let cem = ready(&dc, "135790");
        let inv = Engine::invite(&bora.my_kilit().unwrap().link).unwrap();
        // Cem publishes his own card under Bora's tag
        let mut fake = cem.card_event().unwrap();
        fake.tags = vec![vec!["d".into(), card_tag(&inv.id)]];
        let fake = Event::sign(
            &[7; 32],
            fake.created_at,
            CARD_KIND,
            fake.tags,
            fake.content,
        )
        .unwrap();
        assert!(matches!(
            ayse.add_from_cards(&inv, std::slice::from_ref(&fake), None),
            Err(EngineError::Rejected(_))
        ));
        // with the real one among them, the real one wins
        let c = ayse
            .add_from_cards(&inv, &[fake, bora.card_event().unwrap()], None)
            .unwrap();
        assert_eq!(c.kilit_id, inv.id);
        assert!(Engine::invite("hello").is_err());
    }

    #[test]
    fn the_panic_code_takes_the_conversations_too() {
        let (da, db) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let mut ayse = ready(&da, "482916");
        let bora = ready(&db, "739204");
        let inv = Engine::invite(&bora.my_kilit().unwrap().link).unwrap();
        let c = ayse
            .add_from_cards(&inv, &[bora.card_event().unwrap()], None)
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
