//! The surface flutter_rust_bridge turns into Dart. Only plain records and
//! C-like enums cross; the vault itself stays behind an opaque handle.

#![deny(unsafe_code)]

use std::sync::{Mutex, MutexGuard};

use flutter_rust_bridge::frb;

use crate::engine::{self, Engine, EngineError, Found, Message, SignatureCheck, Unlock};

/// Called once by the generated Dart `RustLib.init()`.
#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// What kind of failure a call ended in.
pub enum KilitErrorKind {
    /// Needs an unlocked vault.
    Locked,
    /// There is no vault yet.
    NoVault,
    /// A vault already exists.
    AlreadyExists,
    /// Refused before trying: a PIN or passphrase too short.
    Rejected,
    /// Stored or pasted data is damaged.
    Damaged,
    /// Too long for this use.
    TooLong,
    /// No such item.
    NotFound,
    /// The device's storage failed.
    Storage,
}

/// The error every fallible call throws in Dart.
pub struct KilitError {
    /// What went wrong.
    pub kind: KilitErrorKind,
    /// A short English detail for logs. Never secret.
    pub detail: String,
}

impl From<EngineError> for KilitError {
    fn from(e: EngineError) -> Self {
        let (kind, detail) = match e {
            EngineError::Locked => (KilitErrorKind::Locked, String::new()),
            EngineError::NoVault => (KilitErrorKind::NoVault, String::new()),
            EngineError::AlreadyExists => (KilitErrorKind::AlreadyExists, String::new()),
            EngineError::Rejected(d) => (KilitErrorKind::Rejected, d),
            EngineError::Damaged => (KilitErrorKind::Damaged, String::new()),
            EngineError::TooLong => (KilitErrorKind::TooLong, String::new()),
            EngineError::NotFound => (KilitErrorKind::NotFound, String::new()),
            EngineError::Storage(d) => (KilitErrorKind::Storage, d),
        };
        Self { kind, detail }
    }
}

/// How an unlock attempt ended.
pub enum UnlockOutcome {
    /// Open.
    Unlocked,
    /// Wrong PIN.
    WrongPin,
    /// Too soon; nothing was tried.
    Wait,
}

/// An unlock attempt's result.
pub struct UnlockReply {
    /// How it ended.
    pub outcome: UnlockOutcome,
    /// Seconds until the next attempt is allowed; 0 for none.
    pub wait_secs: u64,
}

/// One vault item as the list shows it.
pub struct ItemInfo {
    /// 16 hex digits.
    pub id: String,
    /// The original file name.
    pub name: String,
    /// The media type.
    pub mime: String,
    /// Content length in bytes.
    pub size: u64,
    /// When it was added, Unix seconds.
    pub added_unix: i64,
    /// Whether the vault signed it.
    pub signed: bool,
}

impl From<engine::Entry> for ItemInfo {
    fn from(e: engine::Entry) -> Self {
        Self {
            id: e.id,
            name: e.name,
            mime: e.mime,
            size: e.size,
            added_unix: e.added,
            signed: e.signed,
        }
    }
}

/// Who signed a packet.
pub enum SignedBy {
    /// Not signed.
    Nobody,
    /// This vault.
    Me,
    /// Someone else, and the signature verifies.
    Someone,
}

impl From<SignatureCheck> for SignedBy {
    fn from(c: SignatureCheck) -> Self {
        match c {
            SignatureCheck::Unsigned => Self::Nobody,
            SignatureCheck::Mine => Self::Me,
            SignatureCheck::Other => Self::Someone,
        }
    }
}

/// "Paket analizi" for one item.
pub struct PacketReport {
    /// The item as listed.
    pub item: ItemInfo,
    /// The `.klt` file's length.
    pub packet_bytes: u64,
    /// Stanza types, such as `klt-xwing`.
    pub recipients: Vec<String>,
    /// Who signed it.
    pub signed_by: SignedBy,
}

/// What kind of thing was found in pasted text.
pub enum FoundKind {
    /// A whole packet; see `packet`.
    Packet,
    /// Cut off by the chat app.
    Truncated,
    /// Damaged.
    Malformed,
}

/// One packet found in pasted text.
pub struct FoundPacket {
    /// What was found.
    pub kind: FoundKind,
    /// The packet bytes when `kind` is `Packet`, else empty.
    pub packet: Vec<u8>,
}

/// How opening a pasted message went.
pub enum MessageKind {
    /// Opened; see `text`.
    Text,
    /// No key or passphrase we hold opens it.
    WrongKey,
    /// Damaged or changed.
    Damaged,
    /// It holds a file, not a message.
    NotAMessage,
}

/// A pasted message, opened.
pub struct MessageReply {
    /// How it went.
    pub kind: MessageKind,
    /// The message when `kind` is `Text`, else empty.
    pub text: String,
    /// Who signed it.
    pub signed_by: SignedBy,
}

/// Finds `KLT1:` packets in pasted text. Needs no vault.
#[frb(sync)]
pub fn find_packets(text: String) -> Vec<FoundPacket> {
    Engine::find_packets(&text)
        .into_iter()
        .map(|f| match f {
            Found::Packet(packet) => FoundPacket {
                kind: FoundKind::Packet,
                packet,
            },
            Found::Truncated => FoundPacket {
                kind: FoundKind::Truncated,
                packet: Vec::new(),
            },
            Found::Malformed => FoundPacket {
                kind: FoundKind::Malformed,
                packet: Vec::new(),
            },
        })
        .collect()
}

/// One user's Kilit on this device. Dart holds only this handle.
#[frb(opaque)]
pub struct KilitHandle {
    engine: Mutex<Engine>,
}

impl KilitHandle {
    fn engine(&self) -> Result<MutexGuard<'_, Engine>, KilitError> {
        self.engine.lock().map_err(|_| KilitError {
            kind: KilitErrorKind::Storage,
            detail: "engine poisoned".into(),
        })
    }

    /// Opens the store in `dir`; `desktop` picks the larger Argon2id cost.
    pub fn open(dir: String, desktop: bool) -> Result<KilitHandle, KilitError> {
        Ok(Self {
            engine: Mutex::new(Engine::open(&dir, desktop)?),
        })
    }

    /// Whether a vault exists.
    pub fn has_vault(&self) -> Result<bool, KilitError> {
        Ok(self.engine()?.has_vault()?)
    }

    /// Makes a new vault sealed under `pin`, and leaves it unlocked.
    pub fn create_vault(&self, pin: String) -> Result<(), KilitError> {
        Ok(self.engine()?.create_vault(pin)?)
    }

    /// Tries `pin`.
    pub fn unlock(&self, pin: String) -> Result<UnlockReply, KilitError> {
        Ok(match self.engine()?.unlock(pin)? {
            Unlock::Unlocked => UnlockReply {
                outcome: UnlockOutcome::Unlocked,
                wait_secs: 0,
            },
            Unlock::WrongPin { wait_secs } => UnlockReply {
                outcome: UnlockOutcome::WrongPin,
                wait_secs,
            },
            Unlock::Wait { wait_secs } => UnlockReply {
                outcome: UnlockOutcome::Wait,
                wait_secs,
            },
        })
    }

    /// Drops every key and decrypted entry.
    #[frb(sync)]
    pub fn lock(&self) {
        if let Ok(mut e) = self.engine() {
            e.lock();
        }
    }

    /// The safety number.
    pub fn fingerprint(&self) -> Result<String, KilitError> {
        Ok(self.engine()?.fingerprint()?)
    }

    /// The vault's items, newest first.
    pub fn items(&self) -> Result<Vec<ItemInfo>, KilitError> {
        Ok(self
            .engine()?
            .items()?
            .into_iter()
            .map(Into::into)
            .collect())
    }

    /// Seals a note into the vault.
    pub fn add_note(&self, title: String, text: String) -> Result<ItemInfo, KilitError> {
        Ok(self.engine()?.add_note(&title, &text)?.into())
    }

    /// A text item's content, decrypted into memory to show it.
    pub fn read_text(&self, id: String) -> Result<String, KilitError> {
        let bytes = self.engine()?.read(&id)?;
        String::from_utf8(bytes).map_err(|_| EngineError::Damaged.into())
    }

    /// Removes an item.
    pub fn delete_item(&self, id: String) -> Result<(), KilitError> {
        Ok(self.engine()?.delete(&id)?)
    }

    /// Packet analysis for one item.
    pub fn inspect(&self, id: String) -> Result<PacketReport, KilitError> {
        let r = self.engine()?.inspect(&id)?;
        Ok(PacketReport {
            item: r.entry.into(),
            packet_bytes: r.packet_bytes,
            recipients: r.recipients,
            signed_by: r.signature.into(),
        })
    }

    /// A message as `KLT1:` text, to a shared passphrase or to this vault.
    pub fn seal_for_carrier(
        &self,
        message: String,
        passphrase: Option<String>,
    ) -> Result<String, KilitError> {
        Ok(self.engine()?.seal_for_carrier(&message, passphrase)?)
    }

    /// Opens a pasted message.
    pub fn open_message(&self, packet: Vec<u8>, passphrase: Option<String>) -> MessageReply {
        let Ok(e) = self.engine() else {
            return MessageReply {
                kind: MessageKind::Damaged,
                text: String::new(),
                signed_by: SignedBy::Nobody,
            };
        };
        let (kind, text, signed_by) = match e.open_message(&packet, passphrase) {
            Message::Text(t, c) => (MessageKind::Text, t, c.into()),
            Message::WrongKey => (MessageKind::WrongKey, String::new(), SignedBy::Nobody),
            Message::Damaged => (MessageKind::Damaged, String::new(), SignedBy::Nobody),
            Message::File => (MessageKind::NotAMessage, String::new(), SignedBy::Nobody),
        };
        MessageReply {
            kind,
            text,
            signed_by,
        }
    }
}
