//! What the UI's calls actually do: the vault file, the encrypted item
//! index, the attempt counter, and the vault's items. Plain Rust, so it is
//! tested without Flutter; `api.rs` only adapts it for the bridge.

#![deny(unsafe_code)]

use std::time::{SystemTime, UNIX_EPOCH};

use kilit_klt::PacketSigner;
use kilit_klt::{
    Carried, KdfParams, KltError, PassphraseIdentity, PassphraseRecipient, Signature, SignerKeys,
    XWingIdentity, find_in_text, open, open_message, seal, seal_message,
};
use kilit_store::Store;
use kilit_vault::{SoftwareKey, Vault, VaultError};
use secrecy::SecretString;
use serde::{Deserialize, Serialize};

const VAULT: &str = "vault";
const DEVICE_KEY: &str = "device-key";
const ATTEMPTS: &str = "attempts";
const INDEX: &str = "index";
const INDEX_NAME: &str = "index.cbor";
const INDEX_MIME: &str = "application/cbor";

/// Misses before the first wait.
const FREE_MISSES: u32 = 5;
/// The first wait; it doubles with every further miss, up to 2^10 times.
const FIRST_WAIT_SECS: u64 = 30;

/// Why a call failed, in words the UI can map to a message.
#[derive(Debug, PartialEq, Eq)]
pub enum EngineError {
    /// Needs an unlocked vault.
    Locked,
    /// There is no vault yet.
    NoVault,
    /// A vault already exists.
    AlreadyExists,
    /// The PIN or passphrase was refused before trying (too short, too weak).
    Rejected(String),
    /// Stored data is damaged or was replaced.
    Damaged,
    /// Too long for this use.
    TooLong,
    /// No such item.
    NotFound,
    /// Reading or writing the store failed.
    Storage(String),
}

impl From<std::io::Error> for EngineError {
    fn from(e: std::io::Error) -> Self {
        Self::Storage(e.kind().to_string())
    }
}

impl From<KltError> for EngineError {
    fn from(e: KltError) -> Self {
        match e {
            KltError::Io(e) => Self::Storage(e.kind().to_string()),
            KltError::Malformed(why) if why.contains("too long") || why.contains("too large") => {
                Self::TooLong
            }
            _ => Self::Damaged,
        }
    }
}

/// The result of one unlock attempt.
#[derive(Debug, PartialEq, Eq)]
pub enum Unlock {
    /// Open.
    Unlocked,
    /// Wrong PIN; `wait_secs` is non-zero once the free misses are used up.
    WrongPin {
        /// Seconds until the next attempt is allowed.
        wait_secs: u64,
    },
    /// Too soon after the last miss; nothing was tried.
    Wait {
        /// Seconds until the next attempt is allowed.
        wait_secs: u64,
    },
}

/// One item in the vault, as the list shows it.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Entry {
    /// 16 hex digits.
    pub id: String,
    /// The original name.
    pub name: String,
    /// The media type.
    pub mime: String,
    /// Content length in bytes.
    pub size: u64,
    /// When it was added, Unix seconds.
    pub added: i64,
    /// Whether the vault signed it.
    pub signed: bool,
}

/// "Paket analizi" for one item.
#[derive(Debug, PartialEq, Eq)]
pub struct Report {
    /// The entry as listed.
    pub entry: Entry,
    /// The `.klt` file's length.
    pub packet_bytes: u64,
    /// Stanza types the packet was sealed with.
    pub recipients: Vec<String>,
    /// Who signed it.
    pub signature: SignatureCheck,
}

/// How a packet's signature checked out.
#[derive(Debug, PartialEq, Eq)]
pub enum SignatureCheck {
    /// Not signed.
    Unsigned,
    /// Signed by this vault.
    Mine,
    /// Signed by someone else, and the signature verifies.
    Other,
}

/// A packet found in pasted text, or why one could not be read.
#[derive(Debug, PartialEq, Eq)]
pub enum Found {
    /// The packet bytes.
    Packet(Vec<u8>),
    /// The chat app cut it off.
    Truncated,
    /// Damaged.
    Malformed,
}

/// The result of opening a pasted message.
#[derive(Debug, PartialEq, Eq)]
pub enum Message {
    /// The text and who signed it.
    Text(String, SignatureCheck),
    /// No key or passphrase we hold opens it.
    WrongKey,
    /// Damaged or changed.
    Damaged,
    /// It holds a file, not a message.
    File,
}

#[derive(Default, Serialize, Deserialize)]
struct Attempts {
    failures: u32,
    retry_at: i64,
}

struct Open {
    vault: Vault,
    me: XWingIdentity,
    my_keys: SignerKeys,
    index: Vec<Entry>,
}

/// One user's Kilit on this device.
pub struct Engine {
    store: Store,
    hw: SoftwareKey,
    params: KdfParams,
    open: Option<Open>,
    now: fn() -> i64,
}

fn unix_now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

fn random_hex<const N: usize>() -> Result<String, EngineError> {
    let mut b = [0u8; N];
    getrandom::fill(&mut b).map_err(|_| EngineError::Storage("no system randomness".into()))?;
    Ok(b.iter().map(|x| format!("{x:02x}")).collect())
}

fn item_blob(id: &str) -> Result<String, EngineError> {
    if id.len() == 16
        && id
            .bytes()
            .all(|b| b.is_ascii_hexdigit() && !b.is_ascii_uppercase())
    {
        Ok(format!("item-{id}"))
    } else {
        Err(EngineError::NotFound)
    }
}

fn vault_err(e: VaultError) -> EngineError {
    match e {
        VaultError::Rejected(why) => EngineError::Rejected(why.to_owned()),
        VaultError::Locked => EngineError::Damaged,
        _ => EngineError::Damaged,
    }
}

impl Engine {
    /// Opens the store in `dir`. `desktop` picks Argon2id costs: 256 MiB on
    /// desktops, 64 MiB on phones.
    pub fn open(dir: &str, desktop: bool) -> Result<Self, EngineError> {
        Self::open_with_clock(dir, desktop, unix_now)
    }

    fn open_with_clock(dir: &str, desktop: bool, now: fn() -> i64) -> Result<Self, EngineError> {
        let store = Store::open(dir)?;
        // No hardware key yet: a random per-install key kept beside the
        // vault. It protects nothing against a copy of the whole directory;
        // the UI says so until StrongBox/TPM replace it.
        let key = match store.read(DEVICE_KEY)? {
            Some(k) => k.try_into().map_err(|_| EngineError::Damaged)?,
            None => {
                let mut k = [0u8; 32];
                getrandom::fill(&mut k)
                    .map_err(|_| EngineError::Storage("no system randomness".into()))?;
                store.write(DEVICE_KEY, &k)?;
                k
            }
        };
        let params = if desktop {
            KdfParams::DEFAULT
        } else {
            KdfParams::MINIMUM
        };
        Ok(Self {
            store,
            hw: SoftwareKey::new(key),
            params,
            open: None,
            now,
        })
    }

    /// Whether a vault exists.
    pub fn has_vault(&self) -> Result<bool, EngineError> {
        Ok(self.store.len(VAULT)?.is_some())
    }

    /// Makes a new identity sealed under `pin` and leaves it unlocked.
    pub fn create_vault(&mut self, pin: String) -> Result<(), EngineError> {
        if self.has_vault()? {
            return Err(EngineError::AlreadyExists);
        }
        let (vault, sealed) =
            Vault::create(&SecretString::from(pin), &self.hw, self.params).map_err(vault_err)?;
        self.store.write(VAULT, &sealed)?;
        self.open = Some(Self::opened(vault, Vec::new())?);
        self.save_index()?;
        Ok(())
    }

    fn opened(vault: Vault, index: Vec<Entry>) -> Result<Open, EngineError> {
        let me = vault.klt_identity().map_err(vault_err)?;
        let my_keys = vault.signer_keys();
        Ok(Open {
            vault,
            me,
            my_keys,
            index,
        })
    }

    fn attempts(&self) -> Attempts {
        self.store
            .read(ATTEMPTS)
            .ok()
            .flatten()
            .and_then(|b| ciborium::from_reader(b.as_slice()).ok())
            .unwrap_or_default()
    }

    fn save_attempts(&self, a: &Attempts) -> Result<(), EngineError> {
        let mut b = Vec::new();
        ciborium::into_writer(a, &mut b).map_err(|_| EngineError::Damaged)?;
        Ok(self.store.write(ATTEMPTS, &b)?)
    }

    /// Tries `pin`. Counts misses across restarts; after five, each miss
    /// doubles the wait, starting at 30 seconds.
    ///
    /// The count lives in the store, so someone who can edit the app's files
    /// can reset it. Only the hardware key layer can enforce a real limit.
    pub fn unlock(&mut self, pin: String) -> Result<Unlock, EngineError> {
        let sealed = self.store.read(VAULT)?.ok_or(EngineError::NoVault)?;
        let mut a = self.attempts();
        let now = (self.now)();
        if a.retry_at > now {
            return Ok(Unlock::Wait {
                wait_secs: (a.retry_at - now) as u64,
            });
        }
        match Vault::unlock(&sealed, &SecretString::from(pin), &self.hw) {
            Ok(vault) => {
                if a.failures != 0 || a.retry_at != 0 {
                    self.save_attempts(&Attempts::default())?;
                }
                self.open = Some(Self::opened(vault, Vec::new())?);
                let index = self.load_index()?;
                if let Some(o) = self.open.as_mut() {
                    o.index = index;
                }
                Ok(Unlock::Unlocked)
            }
            Err(VaultError::Locked) => {
                a.failures = a.failures.saturating_add(1);
                let wait_secs = if a.failures >= FREE_MISSES {
                    FIRST_WAIT_SECS << (a.failures - FREE_MISSES).min(10)
                } else {
                    0
                };
                a.retry_at = if wait_secs > 0 {
                    now + wait_secs as i64
                } else {
                    0
                };
                self.save_attempts(&a)?;
                Ok(Unlock::WrongPin { wait_secs })
            }
            Err(e) => Err(vault_err(e)),
        }
    }

    /// Drops every key and decrypted entry.
    pub fn lock(&mut self) {
        self.open = None;
    }

    fn require_open(&self) -> Result<&Open, EngineError> {
        self.open.as_ref().ok_or(EngineError::Locked)
    }

    /// The safety number.
    pub fn fingerprint(&self) -> Result<String, EngineError> {
        Ok(self
            .require_open()?
            .vault
            .public_identity()
            .map_err(vault_err)?
            .fingerprint())
    }

    fn check(&self, sig: &Signature) -> Result<SignatureCheck, EngineError> {
        let o = self.require_open()?;
        Ok(match sig {
            Signature::Unsigned => SignatureCheck::Unsigned,
            Signature::Verified(k) if *k == o.my_keys => SignatureCheck::Mine,
            Signature::Verified(_) => SignatureCheck::Other,
        })
    }

    /// Seals bytes to this vault and signs them.
    fn seal_to_me(&self, name: &str, mime: &str, data: &[u8]) -> Result<Vec<u8>, EngineError> {
        let o = self.require_open()?;
        Ok(seal(
            name,
            mime,
            data.len() as u64,
            data,
            &[&o.me.recipient()],
            Some(&o.vault),
            Vec::new(),
        )?)
    }

    /// Opens one of our own blobs; anything not signed by this vault was
    /// planted and is refused.
    fn open_mine(&self, packet: &[u8]) -> Result<(Vec<u8>, kilit_klt::Opened), EngineError> {
        let o = self.require_open()?;
        let mut out = Vec::new();
        let opened = open(packet, &[&o.me], &mut out)?;
        if self.check(&opened.signature)? != SignatureCheck::Mine {
            return Err(EngineError::Damaged);
        }
        Ok((out, opened))
    }

    fn load_index(&self) -> Result<Vec<Entry>, EngineError> {
        let Some(packet) = self.store.read(INDEX)? else {
            return Ok(Vec::new());
        };
        let (bytes, _) = self.open_mine(&packet)?;
        ciborium::from_reader(bytes.as_slice()).map_err(|_| EngineError::Damaged)
    }

    fn save_index(&self) -> Result<(), EngineError> {
        let o = self.require_open()?;
        let mut bytes = Vec::new();
        ciborium::into_writer(&o.index, &mut bytes).map_err(|_| EngineError::Damaged)?;
        let packet = self.seal_to_me(INDEX_NAME, INDEX_MIME, &bytes)?;
        Ok(self.store.write(INDEX, &packet)?)
    }

    /// The vault's items, newest first.
    pub fn items(&self) -> Result<Vec<Entry>, EngineError> {
        let mut v = self.require_open()?.index.clone();
        v.sort_by(|a, b| b.added.cmp(&a.added).then(b.id.cmp(&a.id)));
        Ok(v)
    }

    /// Seals a text note into the vault.
    pub fn add_note(&mut self, title: &str, text: &str) -> Result<Entry, EngineError> {
        self.add(
            &format!("{title}.txt"),
            "text/plain; charset=utf-8",
            text.as_bytes(),
        )
    }

    /// Seals any bytes into the vault.
    pub fn add(&mut self, name: &str, mime: &str, data: &[u8]) -> Result<Entry, EngineError> {
        let packet = self.seal_to_me(name, mime, data)?;
        let id = random_hex::<8>()?;
        self.store.write(&item_blob(&id)?, &packet)?;
        let entry = Entry {
            id,
            name: name.to_owned(),
            mime: mime.to_owned(),
            size: data.len() as u64,
            added: (self.now)(),
            signed: true,
        };
        if let Some(o) = self.open.as_mut() {
            o.index.push(entry.clone());
        }
        self.save_index()?;
        Ok(entry)
    }

    /// Removes an item: the index entry first, then the packet.
    pub fn delete(&mut self, id: &str) -> Result<(), EngineError> {
        let blob = item_blob(id)?;
        let o = self.open.as_mut().ok_or(EngineError::Locked)?;
        let before = o.index.len();
        o.index.retain(|e| e.id != id);
        if o.index.len() == before {
            return Err(EngineError::NotFound);
        }
        self.save_index()?;
        Ok(self.store.delete(&blob)?)
    }

    /// Opens an item's content into memory.
    pub fn read(&self, id: &str) -> Result<Vec<u8>, EngineError> {
        let packet = self
            .store
            .read(&item_blob(id)?)?
            .ok_or(EngineError::NotFound)?;
        Ok(self.open_mine(&packet)?.0)
    }

    /// Packet analysis for one item.
    pub fn inspect(&self, id: &str) -> Result<Report, EngineError> {
        let entry = self
            .require_open()?
            .index
            .iter()
            .find(|e| e.id == id)
            .cloned()
            .ok_or(EngineError::NotFound)?;
        let packet = self
            .store
            .read(&item_blob(id)?)?
            .ok_or(EngineError::NotFound)?;
        let (_, opened) = self.open_mine(&packet)?;
        Ok(Report {
            entry,
            packet_bytes: packet.len() as u64,
            recipients: vec!["klt-xwing".to_owned()],
            signature: self.check(&opened.signature)?,
        })
    }

    /// A message as `KLT1:` text. With a passphrase it is unsigned, like the
    /// old project's shared-password packets, and kept short; without one it
    /// is sealed to this vault and signed.
    pub fn seal_for_carrier(
        &self,
        message: &str,
        passphrase: Option<String>,
    ) -> Result<String, EngineError> {
        let carried = match passphrase {
            Some(p) => {
                if p.chars().count() < 12 {
                    return Err(EngineError::Rejected("passphrase too short".into()));
                }
                let r = PassphraseRecipient::with_params(SecretString::from(p), self.params)?;
                seal_message(message, &[&r], None)?
            }
            None => {
                let o = self.require_open()?;
                seal_message(message, &[&o.me.recipient()], Some(&o.vault))?
            }
        };
        match carried {
            Carried::Text(t) => Ok(t),
            Carried::File { .. } => Err(EngineError::TooLong),
        }
    }

    /// Finds `KLT1:` packets in pasted text.
    pub fn find_packets(text: &str) -> Vec<Found> {
        find_in_text(text)
            .into_iter()
            .map(|r| match r {
                Ok(p) => Found::Packet(p),
                Err(KltError::Truncated) => Found::Truncated,
                Err(_) => Found::Malformed,
            })
            .collect()
    }

    /// Opens a pasted message with the passphrase given, and with this
    /// vault's key when it is unlocked.
    pub fn open_message(&self, packet: &[u8], passphrase: Option<String>) -> Message {
        let pass = passphrase.map(|p| PassphraseIdentity::new(SecretString::from(p)));
        let mut ids: Vec<&dyn age::Identity> = Vec::new();
        if let Some(o) = self.open.as_ref() {
            ids.push(&o.me);
        }
        if let Some(p) = pass.as_ref() {
            ids.push(p);
        }
        match open_message(packet, &ids) {
            Ok((text, opened)) => match self.check(&opened.signature) {
                Ok(c) => Message::Text(text, c),
                // locked and signed: say who signed only when we know
                Err(_) => Message::Text(
                    text,
                    match opened.signature {
                        Signature::Unsigned => SignatureCheck::Unsigned,
                        Signature::Verified(_) => SignatureCheck::Other,
                    },
                ),
            },
            Err(KltError::WrongKey) => Message::WrongKey,
            Err(KltError::NotAMessage) => Message::File,
            Err(_) => Message::Damaged,
        }
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    fn engine(dir: &tempfile::TempDir) -> Engine {
        Engine::open(dir.path().to_str().unwrap(), false).unwrap()
    }

    fn ready(dir: &tempfile::TempDir) -> Engine {
        let mut e = engine(dir);
        e.create_vault("482916".into()).unwrap();
        e
    }

    #[test]
    fn a_new_vault_survives_a_restart() {
        let dir = tempfile::tempdir().unwrap();
        let fp = {
            let mut e = ready(&dir);
            e.add_note("ilk", "merhaba").unwrap();
            e.fingerprint().unwrap()
        };
        let mut e = engine(&dir);
        assert!(e.has_vault().unwrap());
        assert_eq!(e.items(), Err(EngineError::Locked));
        assert_eq!(e.unlock("482916".into()).unwrap(), Unlock::Unlocked);
        assert_eq!(e.fingerprint().unwrap(), fp);
        let items = e.items().unwrap();
        assert_eq!(items.len(), 1);
        assert_eq!(e.read(&items[0].id).unwrap(), b"merhaba");
    }

    #[test]
    fn a_second_vault_cannot_overwrite_the_first() {
        let dir = tempfile::tempdir().unwrap();
        let mut e = ready(&dir);
        assert_eq!(
            e.create_vault("111111".into()),
            Err(EngineError::AlreadyExists)
        );
    }

    #[test]
    fn locking_forgets_everything() {
        let dir = tempfile::tempdir().unwrap();
        let mut e = ready(&dir);
        e.lock();
        assert_eq!(e.fingerprint(), Err(EngineError::Locked));
        assert_eq!(e.items(), Err(EngineError::Locked));
    }

    fn fixed_now() -> i64 {
        1_000_000
    }

    #[test]
    fn misses_are_counted_across_restarts_and_then_slowed() {
        let dir = tempfile::tempdir().unwrap();
        ready(&dir);
        for _ in 0..4 {
            let mut e =
                Engine::open_with_clock(dir.path().to_str().unwrap(), false, fixed_now).unwrap();
            assert_eq!(
                e.unlock("000000".into()).unwrap(),
                Unlock::WrongPin { wait_secs: 0 }
            );
        }
        let mut e =
            Engine::open_with_clock(dir.path().to_str().unwrap(), false, fixed_now).unwrap();
        assert_eq!(
            e.unlock("000000".into()).unwrap(),
            Unlock::WrongPin { wait_secs: 30 }
        );
        // even the right PIN is not tried while waiting
        assert_eq!(
            e.unlock("482916".into()).unwrap(),
            Unlock::Wait { wait_secs: 30 }
        );
    }

    #[test]
    fn a_planted_item_is_refused() {
        let dir = tempfile::tempdir().unwrap();
        let mut e = ready(&dir);
        let entry = e.add_note("gerçek", "x").unwrap();
        // someone with our public key seals their own content into the slot
        let planted = {
            let me = &e.open.as_ref().unwrap().me;
            seal(
                "sahte",
                "",
                1,
                &b"y"[..],
                &[&me.recipient()],
                None,
                Vec::new(),
            )
            .unwrap()
        };
        e.store
            .write(&item_blob(&entry.id).unwrap(), &planted)
            .unwrap();
        assert_eq!(e.read(&entry.id), Err(EngineError::Damaged));
    }

    #[test]
    fn deleting_removes_the_entry_and_the_packet() {
        let dir = tempfile::tempdir().unwrap();
        let mut e = ready(&dir);
        let a = e.add_note("a", "1").unwrap();
        e.add_note("b", "2").unwrap();
        e.delete(&a.id).unwrap();
        assert_eq!(e.items().unwrap().len(), 1);
        assert_eq!(e.store.read(&item_blob(&a.id).unwrap()).unwrap(), None);
        assert_eq!(e.delete(&a.id), Err(EngineError::NotFound));
        assert_eq!(e.delete("../../etc"), Err(EngineError::NotFound));
    }

    #[test]
    fn packet_analysis_names_the_vault_as_signer() {
        let dir = tempfile::tempdir().unwrap();
        let mut e = ready(&dir);
        let a = e.add_note("not", "içerik").unwrap();
        let r = e.inspect(&a.id).unwrap();
        assert_eq!(r.signature, SignatureCheck::Mine);
        assert_eq!(r.entry.name, "not.txt");
        assert!(r.packet_bytes > 1000);
    }

    #[test]
    fn a_passphrase_message_opens_on_another_device() {
        let (d1, d2) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let ayse = ready(&d1);
        let bob = ready(&d2);
        let text = ayse
            .seal_for_carrier("yarın 10'da", Some("uzun bir ortak parola".into()))
            .unwrap();
        let found = Engine::find_packets(&format!("Ayşe: {text} görüşürüz"));
        let Found::Packet(p) = &found[0] else {
            panic!("not found")
        };
        assert_eq!(
            bob.open_message(p, Some("uzun bir ortak parola".into())),
            Message::Text("yarın 10'da".into(), SignatureCheck::Unsigned)
        );
        assert_eq!(
            bob.open_message(p, Some("yanlış parola!!!".into())),
            Message::WrongKey
        );
    }

    #[test]
    fn a_note_to_self_is_signed_and_only_this_vault_opens_it() {
        let (d1, d2) = (tempfile::tempdir().unwrap(), tempfile::tempdir().unwrap());
        let me = ready(&d1);
        let other = ready(&d2);
        let text = me.seal_for_carrier("kendime", None).unwrap();
        let Found::Packet(p) = &Engine::find_packets(&text)[0] else {
            panic!("not found")
        };
        assert_eq!(
            me.open_message(p, None),
            Message::Text("kendime".into(), SignatureCheck::Mine)
        );
        assert_eq!(other.open_message(p, None), Message::WrongKey);
    }

    #[test]
    fn short_passphrases_are_refused() {
        let dir = tempfile::tempdir().unwrap();
        let e = ready(&dir);
        assert!(matches!(
            e.seal_for_carrier("x", Some("kısa".into())),
            Err(EngineError::Rejected(_))
        ));
    }
}
