//! The surface flutter_rust_bridge turns into Dart. Only plain records and
//! C-like enums cross; the vault itself stays behind an opaque handle.

#![deny(unsafe_code)]

use std::sync::{Mutex, MutexGuard};

use flutter_rust_bridge::frb;

use crate::engine::{self, Engine, EngineError, Found, KeyKind, Message, SignatureCheck, Unlock};

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
    /// The panic code: everything is erased and Kilit is as if newly
    /// installed. Delete the hardware key too.
    Wiped,
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

/// What protects the vault's PIN on this device.
pub enum PinKeyKind {
    /// No vault yet.
    None,
    /// A software key beside the vault.
    Software,
    /// A hardware key that cannot leave the device.
    Hardware,
}

/// The bytes the platform's hardware key must MAC for `pin`.
#[frb(sync)]
pub fn pin_mac_input(pin: String) -> Vec<u8> {
    kilit_vault::pin_mac_input(&secrecy::SecretString::from(pin)).to_vec()
}

fn mac32(mac: Vec<u8>) -> Result<[u8; 32], KilitError> {
    mac.try_into().map_err(|_| KilitError {
        kind: KilitErrorKind::Rejected,
        detail: "a PIN MAC is 32 bytes".into(),
    })
}

fn reply(u: Unlock) -> UnlockReply {
    match u {
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
        Unlock::Wiped => UnlockReply {
            outcome: UnlockOutcome::Wiped,
            wait_secs: 0,
        },
    }
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

/// What [`clean_metadata`] took out of a picture.
pub enum RemovedKind {
    /// Camera, settings, dates, often a thumbnail.
    Exif,
    /// GPS coordinates.
    Location,
    /// Editing history, sometimes names.
    Xmp,
    /// Captions, author, copyright.
    Iptc,
    /// Free-text comments.
    Comment,
    /// Depth maps, previews, motion-photo halves.
    ExtraImages,
    /// PNG text and timestamps.
    Text,
    /// Metadata of other kinds.
    Other,
}

impl From<kilit_parse::Removed> for RemovedKind {
    fn from(r: kilit_parse::Removed) -> Self {
        use kilit_parse::Removed as R;
        match r {
            R::Exif => Self::Exif,
            R::Location => Self::Location,
            R::Xmp => Self::Xmp,
            R::Iptc => Self::Iptc,
            R::Comment => Self::Comment,
            R::ExtraImages => Self::ExtraImages,
            R::Text => Self::Text,
            R::Other => Self::Other,
        }
    }
}

/// How cleaning a file went.
pub enum CleanOutcome {
    /// `data` is the file without its metadata (`removed` may be empty).
    Cleaned,
    /// Not a picture format Kilit can clean; the file is left as it is.
    Unsupported,
    /// A picture whose structure is broken; nothing could be checked.
    Damaged,
}

/// The result of [`clean_metadata`].
pub struct CleanReply {
    /// How it went.
    pub outcome: CleanOutcome,
    /// The cleaned file; empty unless the outcome is `Cleaned`.
    pub data: Vec<u8>,
    /// What was removed, each kind once.
    pub removed: Vec<RemovedKind>,
}

/// Strips location, camera, author and editing metadata from a JPEG, PNG
/// or WebP picture without re-encoding it. Needs no vault.
pub fn clean_metadata(data: Vec<u8>) -> CleanReply {
    match kilit_parse::clean(&data) {
        Ok(r) => CleanReply {
            outcome: CleanOutcome::Cleaned,
            data: r.data,
            removed: r.removed.into_iter().map(RemovedKind::from).collect(),
        },
        Err(e) => CleanReply {
            outcome: match e {
                kilit_parse::CleanError::Unsupported => CleanOutcome::Unsupported,
                kilit_parse::CleanError::Damaged => CleanOutcome::Damaged,
            },
            data: Vec::new(),
            removed: Vec::new(),
        },
    }
}

/// A `.klt` file ready to save or share.
pub struct ExportedKlt {
    /// A random `kilit-xxxxxxxx.klt` name that says nothing of the content.
    pub file_name: String,
    /// The packet.
    pub bytes: Vec<u8>,
}

/// How importing a `.klt` file went.
pub enum ImportKind {
    /// In the vault now; see `item`.
    Imported,
    /// No key or passphrase we hold opens it.
    WrongKey,
    /// Not a `.klt` file.
    NotKlt,
    /// Damaged or changed.
    Damaged,
}

/// The result of importing a `.klt` file.
pub struct ImportReply {
    /// How it went.
    pub kind: ImportKind,
    /// The new vault item when `kind` is `Imported`.
    pub item: Option<ItemInfo>,
    /// Who signed the original.
    pub signed_by: SignedBy,
}

/// A message kept in the vault.
pub struct KeptReply {
    /// The vault item holding it.
    pub item: ItemInfo,
    /// True when the same packet had been kept before; nothing was added.
    pub already: bool,
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

    /// What protects this vault's PIN.
    #[frb(sync)]
    pub fn key_kind(&self) -> Result<PinKeyKind, KilitError> {
        Ok(match self.engine()?.key_kind()? {
            KeyKind::None => PinKeyKind::None,
            KeyKind::Software => PinKeyKind::Software,
            KeyKind::Hardware => PinKeyKind::Hardware,
        })
    }

    /// Makes a new vault sealed under `pin` with the software key, and
    /// leaves it unlocked. Only for devices without a hardware key.
    pub fn create_vault(&self, pin: String) -> Result<(), KilitError> {
        Ok(self.engine()?.create_vault(pin)?)
    }

    /// Makes a new vault sealed under a hardware PIN MAC, and leaves it
    /// unlocked.
    pub fn create_vault_with_mac(&self, mac: Vec<u8>) -> Result<(), KilitError> {
        Ok(self.engine()?.create_vault_with_mac(mac32(mac)?)?)
    }

    /// Tries `pin` against a software-key vault.
    pub fn unlock(&self, pin: String) -> Result<UnlockReply, KilitError> {
        Ok(reply(self.engine()?.unlock(pin)?))
    }

    /// Tries a hardware PIN MAC against a hardware-key vault.
    pub fn unlock_with_mac(&self, mac: Vec<u8>) -> Result<UnlockReply, KilitError> {
        Ok(reply(self.engine()?.unlock_with_mac(mac32(mac)?)?))
    }

    /// Changes the open software-key vault's PIN. `Unlocked` means changed.
    pub fn change_pin(&self, current: String, fresh: String) -> Result<UnlockReply, KilitError> {
        Ok(reply(self.engine()?.change_pin(current, fresh)?))
    }

    /// Changes the open hardware-key vault's PIN from the two PIN MACs.
    pub fn change_pin_with_mac(
        &self,
        current: Vec<u8>,
        fresh: Vec<u8>,
    ) -> Result<UnlockReply, KilitError> {
        Ok(reply(
            self.engine()?
                .change_pin_with_mac(mac32(current)?, mac32(fresh)?)?,
        ))
    }

    /// Moves the unlocked software-key vault to the hardware key.
    pub fn move_to_hardware(&self, mac: Vec<u8>) -> Result<(), KilitError> {
        Ok(self.engine()?.move_to_hardware(mac32(mac)?)?)
    }

    /// Whether a panic code is set. Needs the open vault.
    pub fn panic_set(&self) -> Result<bool, KilitError> {
        Ok(self.engine()?.panic_set()?)
    }

    /// Sets the four-digit panic code of a software-key vault.
    pub fn set_panic(&self, code: String) -> Result<(), KilitError> {
        Ok(self.engine()?.set_panic(code)?)
    }

    /// Sets the panic code of a hardware-key vault from the code's MAC.
    pub fn set_panic_with_mac(&self, mac: Vec<u8>) -> Result<(), KilitError> {
        Ok(self.engine()?.set_panic_with_mac(mac32(mac)?)?)
    }

    /// Removes the panic code.
    pub fn clear_panic(&self) -> Result<(), KilitError> {
        Ok(self.engine()?.clear_panic()?)
    }

    /// The panic button, software key: erases everything when `code` is the
    /// panic code.
    pub fn panic_wipe(&self, code: String) -> Result<bool, KilitError> {
        Ok(self.engine()?.panic_wipe(code)?)
    }

    /// The panic button, hardware key: erases everything when `mac` is the
    /// panic code's. Then delete the hardware key.
    pub fn panic_wipe_with_mac(&self, mac: Vec<u8>) -> Result<bool, KilitError> {
        Ok(self.engine()?.panic_wipe_with_mac(mac32(mac)?)?)
    }

    /// Keeps an opened message in the vault, once per packet.
    pub fn keep_message(
        &self,
        packet: Vec<u8>,
        title: String,
        text: String,
    ) -> Result<KeptReply, KilitError> {
        Ok(match self.engine()?.keep_message(&packet, &title, &text)? {
            engine::Kept::Added(e) => KeptReply {
                item: e.into(),
                already: false,
            },
            engine::Kept::Already(e) => KeptReply {
                item: e.into(),
                already: true,
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

    /// Seals a file into the vault. At most 64 MiB.
    pub fn add_file(
        &self,
        name: String,
        mime: String,
        data: Vec<u8>,
    ) -> Result<ItemInfo, KilitError> {
        Ok(self.engine()?.add(&name, &mime, &data)?.into())
    }

    /// An item's content, decrypted into memory: to show an image, or to
    /// save it unencrypted when the user asks for exactly that.
    pub fn read_file(&self, id: String) -> Result<Vec<u8>, KilitError> {
        Ok(self.engine()?.read(&id)?)
    }

    /// An item as a `.klt` file, to a shared passphrase or to this vault.
    pub fn export_klt(
        &self,
        id: String,
        passphrase: Option<String>,
    ) -> Result<ExportedKlt, KilitError> {
        let (file_name, bytes) = self.engine()?.export(&id, passphrase)?;
        Ok(ExportedKlt { file_name, bytes })
    }

    /// Opens a `.klt` file from outside and seals its content into the vault.
    pub fn import_klt(
        &self,
        bytes: Vec<u8>,
        passphrase: Option<String>,
    ) -> Result<ImportReply, KilitError> {
        let (kind, item, signed_by) = match self.engine()?.import(&bytes, passphrase)? {
            engine::Imported::Item(e, s) => (ImportKind::Imported, Some(e.into()), s.into()),
            engine::Imported::WrongKey => (ImportKind::WrongKey, None, SignedBy::Nobody),
            engine::Imported::NotKlt => (ImportKind::NotKlt, None, SignedBy::Nobody),
            engine::Imported::Damaged => (ImportKind::Damaged, None, SignedBy::Nobody),
        };
        Ok(ImportReply {
            kind,
            item,
            signed_by,
        })
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
