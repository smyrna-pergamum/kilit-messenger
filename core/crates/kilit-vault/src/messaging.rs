//! Signal sessions with contacts, from the official libsignal: PQXDH (X25519
//! plus Kyber-1024) to start a session, then the Double Ratchet together with
//! SPQR, the sparse post-quantum ratchet, for every message after. libsignal
//! insists on both; a session without them cannot be made.
//!
//! **Who is who.** A person's Kilit ID is four words, `@word-word-word-word`,
//! taken from the hash of their Signal identity key; their address is the
//! first 128 bits of the same hash. Neither is chosen or registered: there is
//! no account and no server.
//!
//! **Finding someone.** Each vault publishes its contact card (the prekeys a
//! session starts from) to the relays under its ID. Whoever has the ID, the
//! invite link or its QR code fetches the card and checks that its identity
//! key hashes to that ID and address, so a forged card is refused.
//!
//! **Mailboxes.** A message goes to a tag only the two people can compute:
//! HMAC over their X25519 shared secret, the recipient's address and the day,
//! so it changes daily and links nothing across days. Someone not yet known
//! writes to the recipient's first-contact tag (on the card) and must attach a
//! proof of work; their first message lands in Requests.
//!
//! What is kept: one signed prekey and one last-resort Kyber prekey (both on
//! the card), and each contact's identity key, session, name and state. The
//! Signal identity itself is derived from the vault's master secret.
//! [`Messaging`] serialises to bytes the caller seals to the vault.

use std::collections::BTreeMap;
use std::future::Future;
use std::pin::pin;
use std::task::{Context, Poll, Waker};
use std::time::SystemTime;

use async_trait::async_trait;
use hmac::{Hmac, KeyInit, Mac};
use libsignal_protocol::{
    DeviceId, Direction, Fingerprint, GenericSignedPreKey, IdentityChange, IdentityKey,
    IdentityKeyPair, IdentityKeyStore, KeyPair, KyberPreKeyId, KyberPreKeyRecord, KyberPreKeyStore,
    PreKeyBundle, PreKeyId, PreKeyRecord, PreKeySignalMessage, PreKeyStore, PrivateKey,
    ProtocolAddress, PublicKey, SessionRecord, SessionStore, SignalMessage, SignalProtocolError,
    SignedPreKeyId, SignedPreKeyRecord, SignedPreKeyStore, Timestamp, kem, message_decrypt_prekey,
    message_decrypt_signal, message_encrypt, process_prekey_bundle,
};
use rand::TryRngCore;
use serde::{Deserialize, Serialize};
use serde_bytes::ByteBuf;
use sha2::{Digest, Sha256};

use argon2::{Algorithm, Argon2, Params, Version};

use crate::Vault;
use crate::identity::seed;

/// The start of an invite link.
pub const LINK_PREFIX: &str = "kilit://add?";

const IDENTITY_INFO: &[u8] = b"kilit/v1/signal-identity";
const FIRST_CONTACT_INFO: &[u8] = b"kilit/v1/first-contact";
const CARD_KEY_INFO: &[u8] = b"kilit/v1/nostr-card";
const FIRST_CONTACT_LABEL: &[u8] = b"kilit/v1/fc\0";
const MAILBOX_LABEL: &[u8] = b"kilit/v1/mailbox\0";
const POW_LABEL: &[u8] = b"kilit/v1/pow\0";
const STATE_VERSION: u8 = 1;
const CARD_VERSION: u8 = 1;
const BODY_VERSION: u8 = 1;
const ENVELOPE_VERSION: u8 = 1;
/// An envelope from a device other than 1: it names the sending device.
const ENVELOPE_VERSION_DEVICE: u8 = 2;
/// Most devices one Kilit ID can have: the phone and four more.
pub const MAX_DEVICES: u32 = 5;
const LINK_VERSION: u8 = 1;
const FLAG_POW: u8 = 1;
/// libsignal's message type bytes.
const PREKEY_MESSAGE: u8 = 3;
const SIGNAL_MESSAGE: u8 = 2;
/// Leading zero bits a stranger's first message must show: about a million
/// hashes, a second or two on a phone, and a real cost for a spammer.
pub const POW_BITS: u32 = 20;
/// Plaintext is padded to a multiple of this, as Signal's clients do (they
/// use 160; a Kilit body also carries the ID salt and the timer), so a
/// message's length says little about its text.
const PAD_BLOCK: usize = 256;
/// The longest message text, in bytes.
pub const MAX_TEXT: usize = 32 * 1024;
/// How many base keys of the last-resort Kyber prekey are remembered, to
/// refuse a replayed first message.
const BASE_KEYS_KEPT: usize = 4096;
/// Contacts this vault holds at most, requests included.
pub const MAX_CONTACTS: usize = 1000;
/// Requests waiting at most; more strangers are not let in until some are
/// answered.
pub const MAX_REQUESTS: usize = 50;
const NAME_CHARS: usize = 64;
const FINGERPRINT_ITERATIONS: u32 = 5200;
const FINGERPRINT_VERSION: u32 = 2;
const DAY_SECS: i64 = 86_400;
/// Argon2id for the four words: 8 MiB, two passes. Some tens of
/// milliseconds on a phone, and for someone hunting a matching key, every
/// try costs the same.
const ID_KDF_KIB: u32 = 8 * 1024;
const ID_KDF_T: u32 = 2;
/// After a new ID, the old first-contact tag is still watched this long, so
/// a message already on its way is not lost.
const RETIRED_FC_SECS: i64 = 7 * DAY_SECS;
/// The disappearing-message times on offer stay below this.
pub const MAX_TIMER: u32 = 4 * 7 * 86_400;

const WORDS: &str = include_str!("bip39-english.txt");

/// Why a messaging call failed. Says no more than the user may see.
#[derive(Debug, PartialEq, Eq)]
pub enum MessagingError {
    /// Not a contact card, or one that does not match the ID it came under.
    NotACard,
    /// The card is this vault's own.
    OwnCard,
    /// Not a message, damaged, or a stranger's message without the proof of
    /// work.
    NotAMessage,
    /// A message from someone with no session here.
    UnknownSender,
    /// From a blocked contact; dropped.
    Blocked,
    /// Already read: the same message was opened before.
    Duplicate,
    /// The contact's identity key is not the one kept for them.
    IdentityChanged,
    /// No such contact.
    NoContact,
    /// Too many contacts or requests, or a text too long.
    TooLarge,
    /// Stored state is damaged.
    Damaged,
    /// The system gave no randomness, or libsignal failed in a way that
    /// says nothing about the input.
    Crypto,
}

impl From<SignalProtocolError> for MessagingError {
    fn from(e: SignalProtocolError) -> Self {
        match e {
            SignalProtocolError::DuplicatedMessage(..) => Self::Duplicate,
            SignalProtocolError::UntrustedIdentity(_) => Self::IdentityChanged,
            SignalProtocolError::SessionNotFound(_) => Self::UnknownSender,
            SignalProtocolError::InvalidState(..) => Self::Damaged,
            SignalProtocolError::InvalidArgument(_)
            | SignalProtocolError::FfiBindingError(_)
            | SignalProtocolError::ApplicationCallbackError(..) => Self::Crypto,
            // everything else is about the bytes that came in
            _ => Self::NotAMessage,
        }
    }
}

/// Runs one of libsignal's futures. Our stores answer at once, so one poll
/// finishes them.
fn run<T>(f: impl Future<Output = Result<T, SignalProtocolError>>) -> Result<T, MessagingError> {
    let mut f = pin!(f);
    match f.as_mut().poll(&mut Context::from_waker(Waker::noop())) {
        Poll::Ready(r) => Ok(r?),
        Poll::Pending => Err(MessagingError::Crypto),
    }
}

fn rng() -> impl rand::Rng + rand::CryptoRng {
    rand::rngs::OsRng.unwrap_err()
}

/// For any parse failure of a card.
fn not_a_card<E>(_: E) -> MessagingError {
    MessagingError::NotACard
}

fn device_address(name: &str, device: u32) -> Result<ProtocolAddress, MessagingError> {
    let d = u8::try_from(device).map_err(|_| MessagingError::Damaged)?;
    let device = DeviceId::new(d).map_err(|_| MessagingError::Damaged)?;
    Ok(ProtocolAddress::new(name.to_owned(), device))
}

/// Where a session is kept: device 1 under the bare address, as before
/// devices existed; others as `address.device`.
fn session_key(a: &ProtocolAddress) -> String {
    let d = u32::from(a.device_id());
    if d <= 1 {
        a.name().to_owned()
    } else {
        format!("{}.{d}", a.name())
    }
}

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn identity_hash(identity: &IdentityKey) -> [u8; 32] {
    Sha256::digest(identity.serialize()).into()
}

/// A contact's address: the first half of the SHA-256 of their identity key,
/// in hex.
fn address_name(identity: &IdentityKey) -> String {
    hex(&identity_hash(identity)[..16])
}

/// Four BIP-39 words from the first 44 bits of Argon2id(identity key,
/// salt). The salt is the vault's own and is on its card: a new salt is a
/// new ID for the same identity. Argon2id makes making a key whose ID
/// matches someone else's slow and costly; an empty answer means a salt too
/// short to use.
fn id_words(identity: &IdentityKey, salt: &[u8]) -> String {
    let mut h = [0u8; 32];
    let hashed = salt.len() >= 16
        && Params::new(ID_KDF_KIB, ID_KDF_T, 1, Some(32))
            .ok()
            .is_some_and(|p| {
                Argon2::new(Algorithm::Argon2id, Version::V0x13, p)
                    .hash_password_into(&identity.serialize(), salt, &mut h)
                    .is_ok()
            });
    if !hashed {
        return String::new();
    }
    let bits = u64::from_be_bytes([h[0], h[1], h[2], h[3], h[4], h[5], 0, 0]) >> 20;
    let words: Vec<&str> = WORDS.lines().collect();
    (0..4)
        .map(|i| {
            let n = ((bits >> (33 - 11 * i)) & 0x7ff) as usize;
            words.get(n).copied().unwrap_or("?")
        })
        .collect::<Vec<_>>()
        .join("-")
}

fn random_bytes<const N: usize>() -> Result<[u8; N], MessagingError> {
    let mut b = [0u8; N];
    getrandom::fill(&mut b).map_err(|_| MessagingError::Crypto)?;
    Ok(b)
}

fn unix_secs(t: SystemTime) -> i64 {
    t.duration_since(SystemTime::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

fn short(name: &str) -> String {
    name.trim().chars().take(NAME_CHARS).collect()
}

fn hmac(key: &[u8], parts: &[&[u8]]) -> Result<[u8; 32], MessagingError> {
    let mut m =
        <Hmac<Sha256> as KeyInit>::new_from_slice(key).map_err(|_| MessagingError::Crypto)?;
    for p in parts {
        m.update(p);
    }
    Ok(m.finalize().into_bytes().into())
}

fn leading_zero_bits(h: &[u8]) -> u32 {
    let mut n = 0;
    for &b in h {
        if b == 0 {
            n += 8;
        } else {
            return n + b.leading_zeros();
        }
    }
    n
}

fn pow_ok(msg: &[u8], nonce: u64, bits: u32) -> bool {
    let h = Sha256::new()
        .chain_update(POW_LABEL)
        .chain_update(msg)
        .chain_update(nonce.to_le_bytes())
        .finalize();
    leading_zero_bits(&h) >= bits
}

fn pow_solve(msg: &[u8], bits: u32) -> Result<u64, MessagingError> {
    (0..1u64 << 32)
        .find(|&n| pow_ok(msg, n, bits))
        .ok_or(MessagingError::Crypto)
}

/// What a link, a QR code or a typed `@ID` names.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Invite {
    /// The four words, without `@`.
    pub id: String,
    /// The 32-hex address, when the invite carried it (links and QR codes
    /// do; a typed ID does not).
    pub address: Option<String>,
}

pub(crate) fn is_words(s: &str) -> bool {
    let parts: Vec<&str> = s.split('-').collect();
    parts.len() == 4
        && parts
            .iter()
            .all(|p| !p.is_empty() && WORDS.lines().any(|w| w == *p))
}

/// Reads `kilit://add?id=…&a=…`, `@word-word-word-word` or the same with
/// spaces around it. Anything else is not an invite.
pub fn parse_invite(text: &str) -> Option<Invite> {
    let t = text.trim();
    if let Some(q) = t.strip_prefix(LINK_PREFIX) {
        let mut id = None;
        let mut addr = None;
        for kv in q.split('&') {
            let (k, v) = kv.split_once('=')?;
            let slot = match k {
                "id" => &mut id,
                "a" => &mut addr,
                _ => continue,
            };
            // a repeated parameter is a trick, not an invite
            if slot.replace(v.to_owned()).is_some() {
                return None;
            }
        }
        let id = id.filter(|i| is_words(i))?;
        let address = match addr {
            Some(a)
                if a.len() == 32
                    && a.bytes()
                        .all(|b| b.is_ascii_hexdigit() && !b.is_ascii_uppercase()) =>
            {
                Some(a)
            }
            Some(_) => return None,
            None => None,
        };
        return Some(Invite { id, address });
    }
    let id = t.strip_prefix('@')?.to_lowercase();
    is_words(&id).then_some(Invite { id, address: None })
}

/// A message ready for the network.
#[derive(Debug, PartialEq, Eq)]
pub struct Outgoing {
    /// The mailbox tag to post it under.
    pub tag: String,
    /// The envelope: what the relay carries.
    pub payload: Vec<u8>,
    /// The message's own id, for delivery receipts later.
    pub id: Vec<u8>,
}

/// Where a contact stands.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub enum ContactState {
    /// Added by this vault, or a request that was accepted.
    #[default]
    Accepted,
    /// Wrote first without being added; waits in Requests.
    Request,
    /// Messages are dropped and no mailbox is watched for them.
    Blocked,
    /// Known only as a member of a group: not in the chats or Requests.
    /// Writing one to one makes them a request.
    Member,
}

/// What it takes to start a session with one device: its prekeys, signed
/// with the identity all of an ID's devices share.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct DeviceBundle {
    /// The device's Signal registration id.
    pub registration_id: u32,
    /// Its signed EC prekey's id.
    pub signed_prekey_id: u32,
    /// Its signed EC prekey.
    pub signed_prekey: ByteBuf,
    /// The identity's signature on it.
    pub signed_prekey_signature: ByteBuf,
    /// Its last-resort Kyber1024 prekey's id.
    pub kyber_prekey_id: u32,
    /// Its last-resort Kyber1024 prekey.
    pub kyber_prekey: ByteBuf,
    /// The identity's signature on it.
    pub kyber_prekey_signature: ByteBuf,
}

/// A linked device's copy of the secrets the phone derives from its vault.
#[derive(Clone, Serialize, Deserialize)]
struct Linked {
    identity: ByteBuf,
    fc_key: ByteBuf,
    card_key: ByteBuf,
}

#[derive(Clone, Default, Serialize, Deserialize)]
struct Meta {
    name: String,
    /// When the contact was added, Unix seconds.
    added: i64,
    #[serde(default)]
    state: ContactState,
    /// Their first-contact tag, from their card; used until they know us.
    #[serde(default)]
    first_contact: Option<String>,
    /// True once a message from them arrived: they have our session, so
    /// we write to the shared daily mailbox.
    #[serde(default)]
    knows_us: bool,
    /// Their ID salt, from their card or their messages, and the four
    /// words it gives; kept so the list need not run Argon2id each time.
    #[serde(default)]
    id_salt: ByteBuf,
    #[serde(default)]
    kilit_id: String,
    /// Seconds after which messages in this conversation disappear; 0 keeps
    /// them.
    #[serde(default)]
    timer: u32,
    /// Their phone's bundle, from their card, so a device linked later can
    /// start its own session with them.
    #[serde(default)]
    bundle: Option<DeviceBundle>,
    /// Their other devices (2 and up), and the version of that list.
    #[serde(default)]
    devices: BTreeMap<u32, DeviceBundle>,
    #[serde(default)]
    devices_version: u32,
}

/// Kept apart, so each of libsignal's stores borrows its own part.
#[derive(Clone, Serialize, Deserialize)]
struct State {
    v: u8,
    registration_id: u32,
    signed_prekey: ByteBuf,
    kyber_prekey: ByteBuf,
    /// SHA-256 of base keys seen with the last-resort Kyber prekey.
    base_keys: Vec<ByteBuf>,
    identities: BTreeMap<String, ByteBuf>,
    sessions: BTreeMap<String, ByteBuf>,
    contacts: BTreeMap<String, Meta>,
    /// What the vault's four words come from; a new one is a new ID.
    #[serde(default)]
    id_salt: ByteBuf,
    /// Which first-contact tag is current; it moves with the ID.
    #[serde(default)]
    fc_counter: u32,
    /// Earlier first-contact tags and until when they are still watched.
    #[serde(default)]
    retired_fc: Vec<(String, i64)>,
    /// Earlier IDs whose cards are to be blanked on the relays.
    #[serde(default)]
    retired_words: Vec<String>,
    /// This device's number; 0 or 1 is the phone that made the ID.
    #[serde(default)]
    device_id: u32,
    /// Set on a linked device: the secrets the phone gave it.
    #[serde(default)]
    linked: Option<Linked>,
    /// The ID's other devices, by number, and the version of that list.
    #[serde(default)]
    own_devices: BTreeMap<u32, DeviceBundle>,
    #[serde(default)]
    devices_version: u32,
}

#[derive(Serialize, Deserialize)]
struct Card {
    v: u8,
    name: String,
    registration_id: u32,
    signed_prekey_id: u32,
    signed_prekey: ByteBuf,
    signed_prekey_signature: ByteBuf,
    kyber_prekey_id: u32,
    kyber_prekey: ByteBuf,
    kyber_prekey_signature: ByteBuf,
    identity: ByteBuf,
    /// Where someone not yet known writes first.
    #[serde(default)]
    first_contact: String,
    /// What the four words come from.
    #[serde(default)]
    id_salt: ByteBuf,
    /// The ID's other devices (2 and up); the fields above are device 1's.
    #[serde(default)]
    devices: BTreeMap<u32, DeviceBundle>,
    #[serde(default)]
    devices_version: u32,
}

impl Card {
    fn bundle(&self) -> DeviceBundle {
        DeviceBundle {
            registration_id: self.registration_id,
            signed_prekey_id: self.signed_prekey_id,
            signed_prekey: self.signed_prekey.clone(),
            signed_prekey_signature: self.signed_prekey_signature.clone(),
            kyber_prekey_id: self.kyber_prekey_id,
            kyber_prekey: self.kyber_prekey.clone(),
            kyber_prekey_signature: self.kyber_prekey_signature.clone(),
        }
    }
}

/// What a phone hands a device it links: the ID's secrets, its contacts and
/// their keys, and the number the new device gets. No session and no
/// message history.
#[derive(Serialize, Deserialize)]
struct LinkPackage {
    v: u8,
    device_id: u32,
    identity: ByteBuf,
    fc_key: ByteBuf,
    card_key: ByteBuf,
    id_salt: ByteBuf,
    fc_counter: u32,
    card: ByteBuf,
    identities: BTreeMap<String, ByteBuf>,
    contacts: BTreeMap<String, Meta>,
}

/// A file sent with a message. The file travels encrypted in pieces of its
/// own on the relays, under `tag`; this says how to fetch and open it.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FileRef {
    /// The XChaCha20-Poly1305 key the pieces are sealed with.
    pub key: ByteBuf,
    /// The tag the pieces are posted under.
    pub tag: String,
    /// How many pieces.
    pub chunks: u32,
    /// The whole file's length.
    pub size: u64,
    /// SHA-256 of the whole file.
    pub sha256: ByteBuf,
    /// The name to show; never a path.
    pub name: String,
    /// The media type.
    pub mime: String,
}

/// Most people in a group, its maker included.
pub const MAX_GROUP: usize = 20;
/// Longest group name, in characters.
pub const MAX_GROUP_NAME: usize = 64;

/// Someone in a group: their address and their four words, so a member who
/// does not know them can fetch their card.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct RosterMember {
    /// Their address (32 hex digits).
    pub address: String,
    /// Their four words.
    pub kilit_id: String,
}

/// A group as its maker set it last. A newer stamp replaces an older one.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Roster {
    /// When the maker set it, Unix seconds; only ever goes up.
    pub stamp: i64,
    /// The group's name.
    pub name: String,
    /// Everyone in it, the maker included.
    pub members: Vec<RosterMember>,
    /// The maker ended it: nobody writes in it any more.
    #[serde(default)]
    pub ended: bool,
}

impl Roster {
    /// Whether it holds together: a name, 2 to [`MAX_GROUP`] different
    /// people with well-formed addresses and words.
    pub fn sound(&self) -> bool {
        let mut seen = std::collections::BTreeSet::new();
        self.name.chars().count() <= MAX_GROUP_NAME
            && (2..=MAX_GROUP).contains(&self.members.len())
            && self.members.iter().all(|m| {
                m.address.len() == 32
                    && m.address
                        .bytes()
                        .all(|b| matches!(b, b'0'..=b'9' | b'a'..=b'f'))
                    && is_words(&m.kilit_id)
                    && seen.insert(m.address.clone())
            })
    }
}

/// Marks a message as one in a group.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct GroupWire {
    /// The group's id, 16 random bytes.
    pub id: ByteBuf,
    /// From the maker: who is in it now.
    #[serde(default)]
    pub roster: Option<Roster>,
    /// The sender left.
    #[serde(default)]
    pub leave: bool,
}

/// What one message carries.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Content {
    /// The text; may be empty with a file or receipts.
    pub text: String,
    /// Ids of messages from the recipient that arrived here.
    pub receipts: Vec<Vec<u8>>,
    /// Seconds until it disappears; 0 keeps it.
    pub timer: u32,
    /// A file, when there is one.
    pub file: Option<FileRef>,
    /// Sending a message again: its id (16 bytes) and when it was written,
    /// so the recipient knows it for the same one. None for a new message.
    /// A group message sent to each member uses one id for all.
    pub again: Option<(Vec<u8>, i64)>,
    /// A group message, or a change to a group.
    pub group: Option<GroupWire>,
    /// A sticker, by name; the app draws it. Empty for none.
    pub sticker: String,
    /// To this ID's own other devices: whom the message went to (an
    /// address, or `group:` and a group's id), so they show it as sent; or
    /// `add:` and an address for a contact added, with their card.
    pub sync_to: String,
    /// The sender's current card, when its devices changed.
    pub card: Option<Vec<u8>>,
}

/// Longest sticker name. A name is lowercase letters, digits and `-`.
pub const MAX_STICKER: usize = 32;

/// Whether `name` can be a sticker's name.
pub fn sticker_name(name: &str) -> bool {
    !name.is_empty()
        && name.len() <= MAX_STICKER
        && name
            .bytes()
            .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'-')
}

#[derive(Serialize, Deserialize)]
struct Body {
    v: u8,
    /// Random, so the same text twice is two messages.
    #[serde(default)]
    id: ByteBuf,
    text: String,
    /// When it was written, Unix seconds, by the sender's clock.
    sent: i64,
    /// The sender's ID salt, so the recipient shows their current ID.
    #[serde(default)]
    id_salt: ByteBuf,
    #[serde(default)]
    receipts: Vec<ByteBuf>,
    #[serde(default)]
    timer: u32,
    #[serde(default)]
    file: Option<FileRef>,
    #[serde(default)]
    group: Option<GroupWire>,
    #[serde(default)]
    sticker: String,
    #[serde(default)]
    sync_to: String,
    #[serde(default)]
    card: Option<ByteBuf>,
}

/// A contact as the list shows it.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ContactInfo {
    /// The contact's address (32 hex digits).
    pub id: String,
    /// Their Kilit ID: four words.
    pub kilit_id: String,
    /// The name given to them; empty until one is given.
    pub name: String,
    /// When they were added, Unix seconds.
    pub added: i64,
    /// Accepted, a request, or blocked.
    pub state: ContactState,
    /// Disappearing-message time in seconds; 0 keeps messages.
    pub timer: u32,
}

/// An opened message.
#[derive(Debug, PartialEq, Eq)]
pub struct Received {
    /// Who sent it.
    pub contact: String,
    /// True when this message made them a contact: a new request.
    pub new_contact: bool,
    /// The message's own id.
    pub id: Vec<u8>,
    /// The text.
    pub text: String,
    /// When it was written, by the sender's clock, Unix seconds.
    pub sent: i64,
    /// Ids of our messages that reached them.
    pub receipts: Vec<Vec<u8>>,
    /// The sender's disappearing-message time, now this conversation's.
    pub timer: u32,
    /// A file, when there is one.
    pub file: Option<FileRef>,
    /// Set when it belongs to a group.
    pub group: Option<GroupWire>,
    /// A sticker's name; empty for none, and for a name that is not one.
    pub sticker: String,
    /// The sending device.
    pub device: u32,
    /// From this ID's own other device: a copy of what it sent.
    pub own: bool,
    /// On a copy from an own device: whom it went to.
    pub sync_to: String,
    /// The sender's card, when they sent it along.
    pub card: Option<Vec<u8>>,
}

fn pad(mut b: Vec<u8>) -> Vec<u8> {
    b.push(0x80);
    let full = b.len().div_ceil(PAD_BLOCK) * PAD_BLOCK;
    b.resize(full, 0);
    b
}

fn unpad(b: &[u8]) -> Result<&[u8], MessagingError> {
    let end = b
        .iter()
        .rposition(|&x| x != 0)
        .ok_or(MessagingError::NotAMessage)?;
    if b[end] != 0x80 {
        return Err(MessagingError::NotAMessage);
    }
    Ok(&b[..end])
}

/// `version | flags | [nonce] | [device] | signal type | signal message`.
/// Device 1 writes version 1 without the device byte, as before devices
/// existed; any other device writes version 2 with it.
fn envelope(kind: u8, msg: &[u8], pow: bool, device: u32) -> Result<Vec<u8>, MessagingError> {
    let mut inner = Vec::with_capacity(msg.len() + 2);
    if device > 1 {
        inner.push(u8::try_from(device).map_err(|_| MessagingError::Damaged)?);
    }
    inner.push(kind);
    inner.extend_from_slice(msg);
    let version = if device > 1 {
        ENVELOPE_VERSION_DEVICE
    } else {
        ENVELOPE_VERSION
    };
    let mut out = vec![version, if pow { FLAG_POW } else { 0 }];
    if pow {
        out.extend_from_slice(&pow_solve(&inner, POW_BITS)?.to_le_bytes());
    }
    out.extend_from_slice(&inner);
    Ok(out)
}

/// The Signal part of an envelope, whether its proof of work holds, and
/// the sending device.
fn open_envelope(e: &[u8]) -> Result<(&[u8], bool, u32), MessagingError> {
    let (version, flags, rest) = match e {
        [
            v @ (ENVELOPE_VERSION | ENVELOPE_VERSION_DEVICE),
            f,
            rest @ ..,
        ] => (*v, *f, rest),
        _ => return Err(MessagingError::NotAMessage),
    };
    let (inner, proven) = match flags {
        0 => (rest, false),
        FLAG_POW if rest.len() > 8 => {
            let (nonce, inner) = rest.split_at(8);
            let nonce =
                u64::from_le_bytes(nonce.try_into().map_err(|_| MessagingError::NotAMessage)?);
            (inner, pow_ok(inner, nonce, POW_BITS))
        }
        _ => return Err(MessagingError::NotAMessage),
    };
    if version == ENVELOPE_VERSION {
        return Ok((inner, proven, 1));
    }
    match inner {
        [d, signal @ ..] if (2..=MAX_DEVICES).contains(&u32::from(*d)) => {
            Ok((signal, proven, u32::from(*d)))
        }
        _ => Err(MessagingError::NotAMessage),
    }
}

struct Identities<'a> {
    me: &'a IdentityKeyPair,
    registration_id: u32,
    known: &'a mut BTreeMap<String, ByteBuf>,
}

#[async_trait(?Send)]
impl IdentityKeyStore for Identities<'_> {
    async fn get_identity_key_pair(&self) -> Result<IdentityKeyPair, SignalProtocolError> {
        Ok(*self.me)
    }

    async fn get_local_registration_id(&self) -> Result<u32, SignalProtocolError> {
        Ok(self.registration_id)
    }

    async fn save_identity(
        &mut self,
        address: &ProtocolAddress,
        identity: &IdentityKey,
    ) -> Result<IdentityChange, SignalProtocolError> {
        let new = ByteBuf::from(identity.serialize().to_vec());
        let old = self.known.insert(address.name().to_owned(), new.clone());
        Ok(IdentityChange::from_changed(old.is_some_and(|o| o != new)))
    }

    async fn is_trusted_identity(
        &self,
        address: &ProtocolAddress,
        identity: &IdentityKey,
        _direction: Direction,
    ) -> Result<bool, SignalProtocolError> {
        // an address is the hash of its identity key, so no address can
        // ever belong to another key
        Ok(address.name() == address_name(identity)
            && self
                .known
                .get(address.name())
                .is_none_or(|k| k.as_slice() == &*identity.serialize()))
    }

    async fn get_identity(
        &self,
        address: &ProtocolAddress,
    ) -> Result<Option<IdentityKey>, SignalProtocolError> {
        match self.known.get(address.name()) {
            Some(k) => Ok(Some(IdentityKey::try_from(k.as_slice())?)),
            None => Ok(None),
        }
    }
}

struct Sessions<'a>(&'a mut BTreeMap<String, ByteBuf>);

#[async_trait(?Send)]
impl SessionStore for Sessions<'_> {
    async fn load_session(
        &self,
        address: &ProtocolAddress,
    ) -> Result<Option<SessionRecord>, SignalProtocolError> {
        match self.0.get(&session_key(address)) {
            Some(b) => Ok(Some(SessionRecord::deserialize(b)?)),
            None => Ok(None),
        }
    }

    async fn store_session(
        &mut self,
        address: &ProtocolAddress,
        record: &SessionRecord,
    ) -> Result<(), SignalProtocolError> {
        self.0
            .insert(session_key(address), ByteBuf::from(record.serialize()?));
        Ok(())
    }
}

/// One-time EC prekeys need a server to hand them out one by one; a card
/// cannot, so there are none. PQXDH runs with the signed prekey and the
/// Kyber prekey.
struct NoPreKeys;

#[async_trait(?Send)]
impl PreKeyStore for NoPreKeys {
    async fn get_pre_key(&self, _id: PreKeyId) -> Result<PreKeyRecord, SignalProtocolError> {
        Err(SignalProtocolError::InvalidPreKeyId)
    }

    async fn save_pre_key(
        &mut self,
        _id: PreKeyId,
        _record: &PreKeyRecord,
    ) -> Result<(), SignalProtocolError> {
        Err(SignalProtocolError::InvalidPreKeyId)
    }

    async fn remove_pre_key(&mut self, _id: PreKeyId) -> Result<(), SignalProtocolError> {
        Ok(())
    }
}

struct Signed<'a>(&'a ByteBuf);

#[async_trait(?Send)]
impl SignedPreKeyStore for Signed<'_> {
    async fn get_signed_pre_key(
        &self,
        id: SignedPreKeyId,
    ) -> Result<SignedPreKeyRecord, SignalProtocolError> {
        let r = SignedPreKeyRecord::deserialize(self.0)?;
        if r.id()? == id {
            Ok(r)
        } else {
            Err(SignalProtocolError::InvalidSignedPreKeyId)
        }
    }

    async fn save_signed_pre_key(
        &mut self,
        _id: SignedPreKeyId,
        _record: &SignedPreKeyRecord,
    ) -> Result<(), SignalProtocolError> {
        Err(SignalProtocolError::InvalidSignedPreKeyId)
    }
}

struct Kyber<'a> {
    record: &'a ByteBuf,
    seen: &'a mut Vec<ByteBuf>,
}

#[async_trait(?Send)]
impl KyberPreKeyStore for Kyber<'_> {
    async fn get_kyber_pre_key(
        &self,
        id: KyberPreKeyId,
    ) -> Result<KyberPreKeyRecord, SignalProtocolError> {
        let r = KyberPreKeyRecord::deserialize(self.record)?;
        if r.id()? == id {
            Ok(r)
        } else {
            Err(SignalProtocolError::InvalidKyberPreKeyId)
        }
    }

    async fn save_kyber_pre_key(
        &mut self,
        _id: KyberPreKeyId,
        _record: &KyberPreKeyRecord,
    ) -> Result<(), SignalProtocolError> {
        Err(SignalProtocolError::InvalidKyberPreKeyId)
    }

    /// The card's Kyber prekey is a last-resort one: it stays, but the same
    /// first message may not be opened twice.
    async fn mark_kyber_pre_key_used(
        &mut self,
        _kyber_id: KyberPreKeyId,
        _ec_id: SignedPreKeyId,
        base_key: &PublicKey,
    ) -> Result<(), SignalProtocolError> {
        let h = ByteBuf::from(Sha256::digest(base_key.serialize()).to_vec());
        if self.seen.contains(&h) {
            return Err(SignalProtocolError::DuplicatedMessage(0, 0));
        }
        if self.seen.len() >= BASE_KEYS_KEPT {
            self.seen.remove(0);
        }
        self.seen.push(h);
        Ok(())
    }
}

/// This vault's Signal identity and its sessions with contacts.
pub struct Messaging {
    me: IdentityKeyPair,
    my_address: String,
    my_words: String,
    /// This vault's first-contact tag.
    first_contact: String,
    /// What first-contact tags are made from.
    fc_key: zeroize::Zeroizing<[u8; 32]>,
    /// The secp256k1 secret the published card is signed with, so a newer
    /// card replaces the older one on the relays.
    card_key: zeroize::Zeroizing<[u8; 32]>,
    /// This device's number.
    device: u32,
    s: State,
}

fn secret32(b: &[u8]) -> Result<zeroize::Zeroizing<[u8; 32]>, MessagingError> {
    let a: [u8; 32] = b.try_into().map_err(|_| MessagingError::Damaged)?;
    Ok(zeroize::Zeroizing::new(a))
}

fn bundle_of(
    identity: IdentityKey,
    device: u32,
    b: &DeviceBundle,
) -> Result<PreKeyBundle, MessagingError> {
    PreKeyBundle::new(
        b.registration_id,
        DeviceId::new(u8::try_from(device).map_err(|_| MessagingError::NotACard)?)
            .map_err(|_| MessagingError::NotACard)?,
        None,
        SignedPreKeyId::from(b.signed_prekey_id),
        PublicKey::deserialize(&b.signed_prekey).map_err(not_a_card)?,
        b.signed_prekey_signature.to_vec(),
        KyberPreKeyId::from(b.kyber_prekey_id),
        kem::PublicKey::deserialize(&b.kyber_prekey).map_err(not_a_card)?,
        b.kyber_prekey_signature.to_vec(),
        identity,
    )
    .map_err(not_a_card)
}

impl Messaging {
    fn identity(vault: &Vault) -> Result<IdentityKeyPair, MessagingError> {
        let seed = seed(vault.master(), IDENTITY_INFO).map_err(|_| MessagingError::Crypto)?;
        let private = PrivateKey::deserialize(&seed[..]).map_err(|_| MessagingError::Crypto)?;
        IdentityKeyPair::try_from(private).map_err(|_| MessagingError::Crypto)
    }

    fn with_state(vault: &Vault, mut s: State) -> Result<Self, MessagingError> {
        if s.id_salt.len() < 16 {
            s.id_salt = ByteBuf::from(random_bytes::<16>()?.to_vec());
        }
        // a linked device holds the phone's secrets; the phone derives them
        let (me, fc_key, card_key) = match &s.linked {
            Some(l) => (
                IdentityKeyPair::try_from(l.identity.as_slice())
                    .map_err(|_| MessagingError::Damaged)?,
                secret32(&l.fc_key)?,
                secret32(&l.card_key)?,
            ),
            None => (
                Self::identity(vault)?,
                seed(vault.master(), FIRST_CONTACT_INFO).map_err(|_| MessagingError::Crypto)?,
                seed(vault.master(), CARD_KEY_INFO).map_err(|_| MessagingError::Crypto)?,
            ),
        };
        let device = s.device_id.max(1);
        let mut m = Self {
            device,
            my_address: address_name(me.identity_key()),
            my_words: String::new(),
            first_contact: String::new(),
            fc_key,
            card_key,
            me,
            s,
        };
        m.derive_id()?;
        Ok(m)
    }

    /// The four words and the first-contact tag, from the salt and counter.
    fn derive_id(&mut self) -> Result<(), MessagingError> {
        self.my_words = id_words(self.me.identity_key(), &self.s.id_salt);
        if self.my_words.is_empty() {
            return Err(MessagingError::Crypto);
        }
        self.first_contact = hex(&hmac(
            &self.fc_key[..],
            &[FIRST_CONTACT_LABEL, &self.s.fc_counter.to_le_bytes()],
        )?);
        Ok(())
    }

    /// A new ID for the same identity: new four words, a new link and QR
    /// code, a new first-contact tag. Contacts keep talking as before; the
    /// old ID and link find nobody any more. The old first-contact tag is
    /// still watched for a week, for messages already on their way.
    pub fn renew_id(&mut self, now: SystemTime) -> Result<(), MessagingError> {
        let until = unix_secs(now) + RETIRED_FC_SECS;
        self.s.retired_fc.push((self.first_contact.clone(), until));
        self.s.retired_words.push(self.my_words.clone());
        self.s.id_salt = ByteBuf::from(random_bytes::<16>()?.to_vec());
        self.s.fc_counter = self.s.fc_counter.wrapping_add(1);
        self.derive_id()
    }

    /// Earlier IDs whose cards should be blanked on the relays; each is
    /// handed out once.
    pub fn take_retired_ids(&mut self) -> Vec<String> {
        std::mem::take(&mut self.s.retired_words)
    }

    /// New prekeys and no contacts, for a vault that has never messaged.
    pub fn create(vault: &Vault) -> Result<Self, MessagingError> {
        let me = Self::identity(vault)?;
        Self::with_state(vault, Self::fresh_state(&me)?)
    }

    /// A new state with fresh prekeys signed by `me`.
    fn fresh_state(me: &IdentityKeyPair) -> Result<State, MessagingError> {
        let mut rng = rng();
        let ec = KeyPair::generate(&mut rng);
        let ec_sig = me
            .private_key()
            .calculate_signature(&ec.public_key.serialize(), &mut rng)
            .map_err(|_| MessagingError::Crypto)?;
        let now = Timestamp::from_epoch_millis(unix_secs(SystemTime::now()) as u64 * 1000);
        let signed = SignedPreKeyRecord::new(SignedPreKeyId::from(1u32), now, &ec, &ec_sig);
        let kyber = KyberPreKeyRecord::generate(
            kem::KeyType::Kyber1024,
            KyberPreKeyId::from(1u32),
            me.private_key(),
        )?;
        let mut reg = [0u8; 4];
        getrandom::fill(&mut reg).map_err(|_| MessagingError::Crypto)?;
        Ok(State {
            v: STATE_VERSION,
            // the range Signal's clients use
            registration_id: u32::from_le_bytes(reg) % 16380 + 1,
            signed_prekey: ByteBuf::from(signed.serialize()?),
            kyber_prekey: ByteBuf::from(kyber.serialize()?),
            base_keys: Vec::new(),
            identities: BTreeMap::new(),
            sessions: BTreeMap::new(),
            contacts: BTreeMap::new(),
            id_salt: ByteBuf::from(random_bytes::<16>()?.to_vec()),
            fc_counter: 0,
            retired_fc: Vec::new(),
            retired_words: Vec::new(),
            device_id: 1,
            linked: None,
            own_devices: BTreeMap::new(),
            devices_version: 0,
        })
    }

    /// This device's number: 1 for the phone that made the ID.
    pub fn device_id(&self) -> u32 {
        self.device
    }

    /// The ID's other devices, by number.
    pub fn own_devices(&self) -> Vec<u32> {
        self.s
            .own_devices
            .keys()
            .copied()
            .filter(|d| *d != self.device)
            .collect()
    }

    /// This device's bundle, for the phone to put on the card.
    pub fn device_bundle(&self) -> Result<DeviceBundle, MessagingError> {
        let signed = SignedPreKeyRecord::deserialize(&self.s.signed_prekey)?;
        let kyber = KyberPreKeyRecord::deserialize(&self.s.kyber_prekey)?;
        Ok(DeviceBundle {
            registration_id: self.s.registration_id,
            signed_prekey_id: signed.id()?.into(),
            signed_prekey: ByteBuf::from(signed.public_key()?.serialize().to_vec()),
            signed_prekey_signature: ByteBuf::from(signed.signature()?),
            kyber_prekey_id: kyber.id()?.into(),
            kyber_prekey: ByteBuf::from(kyber.public_key()?.serialize().to_vec()),
            kyber_prekey_signature: ByteBuf::from(kyber.signature()?),
        })
    }

    /// Starts a session with `device` of `name` from its bundle, in `s`.
    /// The prekey signatures are checked against `identity`.
    fn start_session(
        &self,
        s: &mut State,
        name: &str,
        device: u32,
        identity: IdentityKey,
        b: &DeviceBundle,
        now: SystemTime,
    ) -> Result<(), MessagingError> {
        let bundle = bundle_of(identity, device, b)?;
        run(process_prekey_bundle(
            &device_address(name, device)?,
            &device_address(&self.my_address, self.device)?,
            &mut Sessions(&mut s.sessions),
            &mut Identities {
                me: &self.me,
                registration_id: s.registration_id,
                known: &mut s.identities,
            },
            &bundle,
            now,
            &mut rng(),
        ))
        .map_err(|e| match e {
            MessagingError::NotAMessage => MessagingError::NotACard,
            e => e,
        })
    }

    /// The phone, linking a new device: the package to hand it (sealed by
    /// the caller to the key the new device showed), and its number.
    pub fn link_package(&self) -> Result<(Vec<u8>, u32), MessagingError> {
        if self.device != 1 {
            return Err(MessagingError::Damaged);
        }
        let device = (2..=MAX_DEVICES)
            .find(|d| !self.s.own_devices.contains_key(d))
            .ok_or(MessagingError::TooLarge)?;
        let p = LinkPackage {
            v: LINK_VERSION,
            device_id: device,
            identity: ByteBuf::from(self.me.serialize().to_vec()),
            fc_key: ByteBuf::from(self.fc_key.to_vec()),
            card_key: ByteBuf::from(self.card_key.to_vec()),
            id_salt: self.s.id_salt.clone(),
            fc_counter: self.s.fc_counter,
            card: ByteBuf::from(self.card("")?),
            identities: self.s.identities.clone(),
            contacts: self.s.contacts.clone(),
        };
        let mut b = Vec::new();
        ciborium::into_writer(&p, &mut b).map_err(|_| MessagingError::Crypto)?;
        Ok((b, device))
    }

    /// A device linked to a phone, from the package the phone sent: the
    /// same ID, prekeys of its own, sessions with the phone and with every
    /// contact whose bundle the phone knew.
    pub fn create_linked(
        vault: &Vault,
        package: &[u8],
        now: SystemTime,
    ) -> Result<Self, MessagingError> {
        let p: LinkPackage =
            ciborium::from_reader(package).map_err(|_| MessagingError::NotAMessage)?;
        if p.v != LINK_VERSION || !(2..=MAX_DEVICES).contains(&p.device_id) {
            return Err(MessagingError::NotAMessage);
        }
        let me = IdentityKeyPair::try_from(p.identity.as_slice())
            .map_err(|_| MessagingError::Damaged)?;
        let card: Card = ciborium::from_reader(p.card.as_slice()).map_err(not_a_card)?;
        if card.identity.as_slice() != &*me.identity_key().serialize() {
            return Err(MessagingError::NotACard);
        }
        let mut s = Self::fresh_state(&me)?;
        s.device_id = p.device_id;
        s.linked = Some(Linked {
            identity: p.identity,
            fc_key: p.fc_key,
            card_key: p.card_key,
        });
        s.id_salt = p.id_salt;
        s.fc_counter = p.fc_counter;
        s.identities = p.identities;
        s.contacts = p.contacts;
        let mut m = Self::with_state(vault, s)?;
        m.take_own_card(&p.card, now)?;
        let mut s = m.s.clone();
        for (id, meta) in &m.s.contacts {
            if meta.state == ContactState::Blocked {
                continue;
            }
            let Some(identity) =
                m.s.identities
                    .get(id)
                    .and_then(|k| IdentityKey::try_from(k.as_slice()).ok())
            else {
                continue;
            };
            if let Some(b) = &meta.bundle {
                m.start_session(&mut s, id, 1, identity, b, now)?;
            }
            for (d, b) in &meta.devices {
                m.start_session(&mut s, id, *d, identity, b, now)?;
            }
        }
        m.s = s;
        Ok(m)
    }

    /// The phone: adds a linked device's bundle to this ID, starts a
    /// session with it and bumps the device list; the card shows it.
    pub fn add_own_device(
        &mut self,
        device: u32,
        b: &DeviceBundle,
        now: SystemTime,
    ) -> Result<(), MessagingError> {
        if self.device != 1 || !(2..=MAX_DEVICES).contains(&device) {
            return Err(MessagingError::Damaged);
        }
        let mut s = self.s.clone();
        let identity = *self.me.identity_key();
        let my = self.my_address.clone();
        self.start_session(&mut s, &my, device, identity, b, now)?;
        s.own_devices.insert(device, b.clone());
        s.devices_version += 1;
        self.s = s;
        Ok(())
    }

    /// The phone: forgets a linked device. Its sessions go; the card no
    /// longer shows it.
    pub fn remove_own_device(&mut self, device: u32) -> Result<(), MessagingError> {
        if self.device != 1 || self.s.own_devices.remove(&device).is_none() {
            return Err(MessagingError::NoContact);
        }
        self.s
            .sessions
            .remove(&format!("{}.{device}", self.my_address));
        self.s.devices_version += 1;
        Ok(())
    }

    /// A linked device: takes this ID's card as the phone published it, so
    /// it knows the other devices and has a session with each.
    pub fn take_own_card(&mut self, card: &[u8], now: SystemTime) -> Result<(), MessagingError> {
        let c: Card = ciborium::from_reader(card).map_err(not_a_card)?;
        if c.v != CARD_VERSION || c.identity.as_slice() != &*self.me.identity_key().serialize() {
            return Err(MessagingError::NotACard);
        }
        if c.devices_version < self.s.devices_version {
            return Ok(());
        }
        let mut all = c.devices.clone();
        all.insert(1, c.bundle());
        all.retain(|d, _| (1..=MAX_DEVICES).contains(d));
        let identity = *self.me.identity_key();
        let my = self.my_address.clone();
        let mut s = self.s.clone();
        for (d, b) in &all {
            if *d != self.device && s.own_devices.get(d) != Some(b) {
                self.start_session(&mut s, &my, *d, identity, b, now)?;
            }
        }
        all.remove(&self.device);
        s.own_devices = all;
        s.devices_version = c.devices_version;
        self.s = s;
        Ok(())
    }

    /// A contact's card that came in a message from them: their device list
    /// changed. Sessions start with devices that are new.
    pub fn take_contact_card(
        &mut self,
        contact: &str,
        card: &[u8],
        now: SystemTime,
    ) -> Result<(), MessagingError> {
        let c: Card = ciborium::from_reader(card).map_err(not_a_card)?;
        let known = self
            .s
            .identities
            .get(contact)
            .ok_or(MessagingError::NoContact)?;
        if c.v != CARD_VERSION || c.identity.as_slice() != known.as_slice() {
            return Err(MessagingError::NotACard);
        }
        let identity = IdentityKey::try_from(c.identity.as_slice()).map_err(not_a_card)?;
        let meta = self
            .s
            .contacts
            .get(contact)
            .ok_or(MessagingError::NoContact)?;
        if c.devices_version <= meta.devices_version {
            return Ok(());
        }
        let mut s = self.s.clone();
        self.take_devices(&mut s, contact, identity, &c, now)?;
        self.s = s;
        Ok(())
    }

    fn take_devices(
        &self,
        s: &mut State,
        id: &str,
        identity: IdentityKey,
        c: &Card,
        now: SystemTime,
    ) -> Result<(), MessagingError> {
        let old = s
            .contacts
            .get(id)
            .map(|m| m.devices.clone())
            .unwrap_or_default();
        let mut devices = c.devices.clone();
        devices.retain(|d, _| (2..=MAX_DEVICES).contains(d));
        for (d, b) in &devices {
            if old.get(d) != Some(b) {
                self.start_session(s, id, *d, identity, b, now)?;
            }
        }
        for d in old.keys().filter(|d| !devices.contains_key(d)) {
            s.sessions.remove(&format!("{id}.{d}"));
        }
        if let Some(meta) = s.contacts.get_mut(id) {
            meta.devices = devices;
            meta.devices_version = c.devices_version;
            meta.bundle = Some(c.bundle());
        }
        Ok(())
    }

    /// The devices of `contact` there is a session with: 1 first.
    pub fn devices_of(&self, contact: &str) -> Vec<u32> {
        let mut v = vec![1];
        if let Some(m) = self.s.contacts.get(contact) {
            v.extend(
                m.devices
                    .keys()
                    .copied()
                    .filter(|d| self.s.sessions.contains_key(&format!("{contact}.{d}"))),
            );
        }
        v
    }

    /// Contacts this device has no session with yet (a linked device, for
    /// contacts whose bundle the phone did not have): their words and
    /// address, to fetch their cards by.
    pub fn without_session(&self) -> Vec<Invite> {
        self.s
            .contacts
            .iter()
            .filter(|(id, m)| {
                m.state != ContactState::Blocked
                    && !m.kilit_id.is_empty()
                    && !self.s.sessions.contains_key(*id)
            })
            .map(|(id, m)| Invite {
                id: m.kilit_id.clone(),
                address: Some(id.clone()),
            })
            .collect()
    }

    /// Messaging state saved by [`Messaging::to_bytes`].
    pub fn from_bytes(vault: &Vault, bytes: &[u8]) -> Result<Self, MessagingError> {
        let s: State = ciborium::from_reader(bytes).map_err(|_| MessagingError::Damaged)?;
        if s.v != STATE_VERSION {
            return Err(MessagingError::Damaged);
        }
        Self::with_state(vault, s)
    }

    /// The state to seal and store. Holds session secrets.
    pub fn to_bytes(&self) -> Result<Vec<u8>, MessagingError> {
        let mut b = Vec::new();
        ciborium::into_writer(&self.s, &mut b).map_err(|_| MessagingError::Crypto)?;
        Ok(b)
    }

    /// This vault's address (32 hex digits).
    pub fn my_address(&self) -> &str {
        &self.my_address
    }

    /// This vault's Kilit ID: four words, shown with `@`.
    pub fn kilit_id(&self) -> &str {
        &self.my_words
    }

    /// The link (and QR code) that adds this vault: the ID to look the card
    /// up by and the full address to check it against.
    pub fn invite_link(&self) -> String {
        format!("{LINK_PREFIX}id={}&a={}", self.my_words, self.my_address)
    }

    /// The key to sign the published card with.
    pub fn card_key(&self) -> &[u8; 32] {
        &self.card_key
    }

    /// The tag this vault's card is published under.
    pub fn card_tag(&self) -> String {
        card_tag(&self.my_words)
    }

    /// The card to publish: what a contact needs to start a session, the
    /// first-contact tag and the `name` to show. It holds no secret.
    pub fn card(&self, name: &str) -> Result<Vec<u8>, MessagingError> {
        let signed = SignedPreKeyRecord::deserialize(&self.s.signed_prekey)?;
        let kyber = KyberPreKeyRecord::deserialize(&self.s.kyber_prekey)?;
        let card = Card {
            v: CARD_VERSION,
            name: short(name),
            registration_id: self.s.registration_id,
            signed_prekey_id: signed.id()?.into(),
            signed_prekey: ByteBuf::from(signed.public_key()?.serialize().to_vec()),
            signed_prekey_signature: ByteBuf::from(signed.signature()?),
            kyber_prekey_id: kyber.id()?.into(),
            kyber_prekey: ByteBuf::from(kyber.public_key()?.serialize().to_vec()),
            kyber_prekey_signature: ByteBuf::from(kyber.signature()?),
            identity: ByteBuf::from(self.me.identity_key().serialize().to_vec()),
            first_contact: self.first_contact.clone(),
            id_salt: self.s.id_salt.clone(),
            devices: self
                .s
                .own_devices
                .iter()
                .filter(|(d, _)| **d >= 2)
                .map(|(d, b)| (*d, b.clone()))
                .collect(),
            devices_version: self.s.devices_version,
        };
        let mut b = Vec::new();
        ciborium::into_writer(&card, &mut b).map_err(|_| MessagingError::Crypto)?;
        Ok(b)
    }

    /// Adds the contact whose card `card` is and starts a session with them.
    /// With an invite, the card must be the one it names. The name on the
    /// card is used unless `name` is given. Returns their address.
    pub fn add_contact(
        &mut self,
        card: &[u8],
        invite: Option<&Invite>,
        name: Option<&str>,
        now: SystemTime,
    ) -> Result<String, MessagingError> {
        self.take_card(card, invite, name, ContactState::Accepted, now)
    }

    /// Starts a session with a group member from their card, which must be
    /// the one `invite` (their words and address, from the group) names.
    /// Someone not known yet becomes a [`ContactState::Member`]; anyone
    /// known keeps where they stand.
    pub fn add_member(
        &mut self,
        card: &[u8],
        invite: &Invite,
        now: SystemTime,
    ) -> Result<String, MessagingError> {
        if invite.address.is_none() {
            return Err(MessagingError::NotACard);
        }
        let state = invite
            .address
            .as_ref()
            .and_then(|a| self.s.contacts.get(a))
            .map_or(ContactState::Member, |m| m.state);
        if state == ContactState::Blocked {
            return Err(MessagingError::Blocked);
        }
        self.take_card(card, Some(invite), None, state, now)
    }

    /// Moves a contact between request, member and contact.
    pub fn set_state(&mut self, contact: &str, state: ContactState) -> Result<(), MessagingError> {
        self.meta(contact)?.state = state;
        Ok(())
    }

    fn take_card(
        &mut self,
        card: &[u8],
        invite: Option<&Invite>,
        name: Option<&str>,
        state: ContactState,
        now: SystemTime,
    ) -> Result<String, MessagingError> {
        let c: Card = ciborium::from_reader(card).map_err(not_a_card)?;
        if c.v != CARD_VERSION {
            return Err(MessagingError::NotACard);
        }
        let identity = IdentityKey::try_from(c.identity.as_slice()).map_err(not_a_card)?;
        let id = address_name(&identity);
        let words = id_words(&identity, &c.id_salt);
        if let Some(inv) = invite
            && (inv.id != words || inv.address.as_ref().is_some_and(|a| *a != id))
        {
            return Err(MessagingError::NotACard);
        }
        if id == self.my_address {
            return Err(MessagingError::OwnCard);
        }
        if !self.s.contacts.contains_key(&id) && self.s.contacts.len() >= MAX_CONTACTS {
            return Err(MessagingError::TooLarge);
        }
        let mut s = self.s.clone();
        // the signatures on both prekeys are checked here: a forged card fails
        self.start_session(&mut s, &id, 1, identity, &c.bundle(), now)?;
        s.contacts.entry(id.clone()).or_default();
        self.take_devices(&mut s, &id, identity, &c, now)?;
        let meta = s.contacts.entry(id.clone()).or_default();
        if meta.added == 0 {
            meta.added = unix_secs(now);
        }
        // adding someone is answering them: a request becomes a contact
        meta.state = state;
        if !c.first_contact.is_empty() {
            meta.first_contact = Some(c.first_contact);
        }
        meta.id_salt = c.id_salt.clone();
        meta.kilit_id = words;
        let given = short(name.unwrap_or(&c.name));
        if !given.is_empty() {
            meta.name = given;
        }
        self.s = s;
        Ok(id)
    }

    /// The mailbox `recipient`'s `device` reads on `day`, shared with
    /// `contact` (who may be this ID itself, for its own devices).
    fn mailbox(
        &self,
        contact: &str,
        recipient: &str,
        device: u32,
        day: i64,
    ) -> Result<String, MessagingError> {
        let theirs = if contact == self.my_address {
            *self.me.identity_key()
        } else {
            let k = self
                .s
                .identities
                .get(contact)
                .ok_or(MessagingError::NoContact)?;
            IdentityKey::try_from(k.as_slice()).map_err(|_| MessagingError::Damaged)?
        };
        let shared = self
            .me
            .private_key()
            .calculate_agreement(theirs.public_key())
            .map_err(|_| MessagingError::Crypto)?;
        // device 1's mailboxes are as they were before devices existed
        let d = [u8::try_from(device).map_err(|_| MessagingError::Damaged)?];
        let day = day.to_le_bytes();
        let parts: Vec<&[u8]> = if device <= 1 {
            vec![MAILBOX_LABEL, recipient.as_bytes(), &day]
        } else {
            vec![MAILBOX_LABEL, recipient.as_bytes(), &d, &day]
        };
        Ok(hex(&hmac(&shared, &parts)?))
    }

    /// The tags to watch on the relays: this vault's first-contact tag and,
    /// for every contact not blocked, today's mailbox with the days on
    /// either side (clocks differ).
    pub fn inbox_tags(&self, now: SystemTime) -> Result<Vec<String>, MessagingError> {
        let day = unix_secs(now).div_euclid(DAY_SECS);
        let mut tags = Vec::new();
        // strangers write to the phone only: its card is what they found
        if self.device == 1 {
            tags.push(self.first_contact.clone());
            tags.extend(
                self.s
                    .retired_fc
                    .iter()
                    .filter(|(_, until)| *until > unix_secs(now))
                    .map(|(t, _)| t.clone()),
            );
        }
        for (id, meta) in &self.s.contacts {
            if meta.state == ContactState::Blocked || !self.s.identities.contains_key(id) {
                continue;
            }
            for d in day - 1..=day + 1 {
                tags.push(self.mailbox(id, &self.my_address, self.device, d)?);
            }
        }
        if !self.own_devices().is_empty() {
            for d in day - 1..=day + 1 {
                tags.push(self.mailbox(&self.my_address, &self.my_address, self.device, d)?);
            }
        }
        Ok(tags)
    }

    /// Seals `text` for a contact, with the conversation's timer.
    pub fn encrypt(
        &mut self,
        contact: &str,
        text: &str,
        now: SystemTime,
    ) -> Result<Outgoing, MessagingError> {
        let timer = self.timer(contact)?;
        self.seal(
            contact,
            &Content {
                text: text.to_owned(),
                timer,
                ..Content::default()
            },
            now,
        )
    }

    /// Seals a message for a contact. Until they have written back, it goes
    /// to their first-contact tag with a proof of work; after, to the
    /// mailbox the two share today.
    pub fn seal(
        &mut self,
        contact: &str,
        content: &Content,
        now: SystemTime,
    ) -> Result<Outgoing, MessagingError> {
        self.seal_to(contact, 1, content, now)
    }

    /// Seals a message for one device of a contact.
    pub fn seal_to(
        &mut self,
        contact: &str,
        device: u32,
        content: &Content,
        now: SystemTime,
    ) -> Result<Outgoing, MessagingError> {
        self.seal_device(contact, device, content, now)
    }

    /// Seals a copy for one of this ID's own other devices.
    pub fn seal_own(
        &mut self,
        device: u32,
        content: &Content,
        now: SystemTime,
    ) -> Result<Outgoing, MessagingError> {
        if device == self.device || !self.s.own_devices.contains_key(&device) {
            return Err(MessagingError::NoContact);
        }
        let my = self.my_address.clone();
        self.seal_device(&my, device, content, now)
    }

    fn seal_device(
        &mut self,
        contact: &str,
        device: u32,
        content: &Content,
        now: SystemTime,
    ) -> Result<Outgoing, MessagingError> {
        if content.text.len() > MAX_TEXT
            || content.timer > MAX_TIMER
            || (!content.sticker.is_empty() && !sticker_name(&content.sticker))
        {
            return Err(MessagingError::TooLarge);
        }
        let day = unix_secs(now).div_euclid(DAY_SECS);
        let (first, tag) = if contact == self.my_address {
            (false, self.mailbox(contact, contact, device, day)?)
        } else {
            let meta = self
                .s
                .contacts
                .get(contact)
                .ok_or(MessagingError::NoContact)?;
            if meta.state == ContactState::Blocked {
                return Err(MessagingError::Blocked);
            }
            // until their phone has written back, it is reached through
            // its first-contact tag; their other devices never are
            let first = device == 1 && !meta.knows_us;
            match (&meta.first_contact, first) {
                (Some(fc), true) => (true, fc.clone()),
                _ => (false, self.mailbox(contact, contact, device, day)?),
            }
        };
        let mut id = [0u8; 16];
        let mut sent = unix_secs(now);
        match &content.again {
            Some((old, at)) if old.len() == id.len() => {
                id.copy_from_slice(old);
                sent = *at;
            }
            Some(_) => return Err(MessagingError::Damaged),
            None => getrandom::fill(&mut id).map_err(|_| MessagingError::Crypto)?,
        }
        let mut body = Vec::new();
        ciborium::into_writer(
            &Body {
                v: BODY_VERSION,
                id: ByteBuf::from(id.to_vec()),
                text: content.text.clone(),
                sent,
                id_salt: self.s.id_salt.clone(),
                receipts: content
                    .receipts
                    .iter()
                    .map(|r| ByteBuf::from(r.clone()))
                    .collect(),
                timer: content.timer,
                file: content.file.clone(),
                group: content.group.clone(),
                sticker: content.sticker.clone(),
                sync_to: content.sync_to.clone(),
                card: content.card.clone().map(ByteBuf::from),
            },
            &mut body,
        )
        .map_err(|_| MessagingError::Crypto)?;
        let mut s = self.s.clone();
        let m = run(message_encrypt(
            &pad(body),
            &device_address(contact, device)?,
            &device_address(&self.my_address, self.device)?,
            &mut Sessions(&mut s.sessions),
            &mut Identities {
                me: &self.me,
                registration_id: s.registration_id,
                known: &mut s.identities,
            },
            now,
            &mut rng(),
        ))?;
        let payload = envelope(m.message_type() as u8, m.serialize(), first, self.device)?;
        self.s = s;
        Ok(Outgoing {
            tag,
            payload,
            id: id.to_vec(),
        })
    }

    /// Opens an envelope from the relays. A first message from someone who
    /// has this vault's card makes them a request, if it carries the proof
    /// of work; a message from a blocked contact is dropped.
    pub fn decrypt(&mut self, payload: &[u8], now: SystemTime) -> Result<Received, MessagingError> {
        let (inner, proven, device) = open_envelope(payload)?;
        let (&kind, body) = inner.split_first().ok_or(MessagingError::NotAMessage)?;
        let me = device_address(&self.my_address, self.device)?;
        let own_device = |d: u32| d != self.device && self.s.own_devices.contains_key(&d);
        let (contact, plain, s) = match kind {
            PREKEY_MESSAGE => {
                let m = PreKeySignalMessage::try_from(body)?;
                let id = address_name(m.identity_key());
                // this ID's other device: only one this device knows
                if id == self.my_address && !own_device(device) {
                    return Err(MessagingError::NotAMessage);
                }
                match self.s.contacts.get(&id) {
                    _ if id == self.my_address => {}
                    Some(meta) if meta.state == ContactState::Blocked => {
                        return Err(MessagingError::Blocked);
                    }
                    Some(_) => {}
                    // a stranger's first word comes from their phone
                    None if device != 1 => return Err(MessagingError::NotAMessage),
                    None => {
                        // a stranger: they must have paid, and there must
                        // be room for one more request
                        if !proven {
                            return Err(MessagingError::NotAMessage);
                        }
                        let waiting = self
                            .s
                            .contacts
                            .values()
                            .filter(|m| m.state == ContactState::Request)
                            .count();
                        if waiting >= MAX_REQUESTS || self.s.contacts.len() >= MAX_CONTACTS {
                            return Err(MessagingError::TooLarge);
                        }
                    }
                }
                let mut s = self.s.clone();
                let plain = run(message_decrypt_prekey(
                    &m,
                    &device_address(&id, device)?,
                    &me,
                    &mut Sessions(&mut s.sessions),
                    &mut Identities {
                        me: &self.me,
                        registration_id: s.registration_id,
                        known: &mut s.identities,
                    },
                    &mut NoPreKeys,
                    &Signed(&s.signed_prekey),
                    &mut Kyber {
                        record: &s.kyber_prekey,
                        seen: &mut s.base_keys,
                    },
                    &mut rng(),
                ))?;
                (id, plain, s)
            }
            SIGNAL_MESSAGE => {
                let m = SignalMessage::try_from(body)?;
                // the message does not say who sent it: try each session
                // with that device number
                let mut opened = None;
                let mut who: Vec<&String> = self
                    .s
                    .contacts
                    .iter()
                    .filter(|(_, meta)| meta.state != ContactState::Blocked)
                    .map(|(id, _)| id)
                    .collect();
                if own_device(device) {
                    who.push(&self.my_address);
                }
                for id in who {
                    let from = device_address(id, device)?;
                    if !self.s.sessions.contains_key(&session_key(&from)) {
                        continue;
                    }
                    let mut s = self.s.clone();
                    let r = run(message_decrypt_signal(
                        &m,
                        &from,
                        &me,
                        &mut Sessions(&mut s.sessions),
                        &mut Identities {
                            me: &self.me,
                            registration_id: s.registration_id,
                            known: &mut s.identities,
                        },
                        &mut rng(),
                    ));
                    match r {
                        Ok(p) => {
                            opened = Some((id.clone(), p, s));
                            break;
                        }
                        // only the right session knows it saw this one
                        Err(MessagingError::Duplicate) => return Err(MessagingError::Duplicate),
                        Err(_) => {}
                    }
                }
                opened.ok_or(MessagingError::UnknownSender)?
            }
            _ => return Err(MessagingError::NotAMessage),
        };
        let b: Body =
            ciborium::from_reader(unpad(&plain)?).map_err(|_| MessagingError::NotAMessage)?;
        if b.v != BODY_VERSION {
            return Err(MessagingError::NotAMessage);
        }
        let mut s = s;
        let sticker = if sticker_name(&b.sticker) {
            b.sticker.clone()
        } else {
            String::new()
        };
        if contact == self.my_address {
            // a copy from an own device: no contact to keep, nothing to learn
            self.s = s;
            return Ok(Received {
                contact,
                new_contact: false,
                id: b.id.into_vec(),
                text: b.text,
                sent: b.sent,
                receipts: b.receipts.into_iter().map(ByteBuf::into_vec).collect(),
                timer: b.timer,
                file: b.file,
                group: b.group,
                sticker,
                device,
                own: true,
                sync_to: b.sync_to,
                card: b.card.map(ByteBuf::into_vec),
            });
        }
        let new_contact = !s.contacts.contains_key(&contact);
        let meta = s.contacts.entry(contact.clone()).or_insert_with(|| Meta {
            added: unix_secs(now),
            state: ContactState::Request,
            ..Meta::default()
        });
        // their phone wrote: it has the session, the daily mailbox works now
        if device == 1 {
            meta.knows_us = true;
        }
        if b.id_salt.len() >= 16 && b.id_salt != meta.id_salt {
            if let Some(k) = s
                .identities
                .get(&contact)
                .and_then(|k| IdentityKey::try_from(k.as_slice()).ok())
            {
                meta.kilit_id = id_words(&k, &b.id_salt);
            }
            meta.id_salt = b.id_salt;
        }
        // a receipt says nothing of the timer, nor does a group message;
        // anything else sets it
        let only_receipts =
            b.text.is_empty() && b.file.is_none() && b.sticker.is_empty() && !b.receipts.is_empty();
        if !only_receipts && b.group.is_none() && b.timer <= MAX_TIMER {
            meta.timer = b.timer;
        }
        self.s = s;
        Ok(Received {
            contact,
            new_contact,
            id: b.id.into_vec(),
            text: b.text,
            sent: b.sent,
            receipts: b.receipts.into_iter().map(ByteBuf::into_vec).collect(),
            timer: b.timer,
            file: b.file,
            group: b.group,
            sticker,
            device,
            own: false,
            sync_to: String::new(),
            card: b.card.map(ByteBuf::into_vec),
        })
    }

    /// The contacts, requests and blocked ones included, by name.
    pub fn contacts(&self) -> Vec<ContactInfo> {
        let mut v: Vec<_> = self
            .s
            .contacts
            .iter()
            .map(|(id, m)| ContactInfo {
                id: id.clone(),
                kilit_id: m.kilit_id.clone(),
                name: m.name.clone(),
                added: m.added,
                state: m.state,
                timer: m.timer,
            })
            .collect();
        v.sort_by_cached_key(|c| (c.name.is_empty(), c.name.to_lowercase(), c.id.clone()));
        v
    }

    fn meta(&mut self, contact: &str) -> Result<&mut Meta, MessagingError> {
        self.s
            .contacts
            .get_mut(contact)
            .ok_or(MessagingError::NoContact)
    }

    /// Gives a contact a name.
    pub fn rename(&mut self, contact: &str, name: &str) -> Result<(), MessagingError> {
        self.meta(contact)?.name = short(name);
        Ok(())
    }

    /// The conversation's disappearing-message time, in seconds.
    pub fn timer(&self, contact: &str) -> Result<u32, MessagingError> {
        Ok(self
            .s
            .contacts
            .get(contact)
            .ok_or(MessagingError::NoContact)?
            .timer)
    }

    /// Sets the disappearing-message time; the next message tells them.
    pub fn set_timer(&mut self, contact: &str, secs: u32) -> Result<(), MessagingError> {
        if secs > MAX_TIMER {
            return Err(MessagingError::TooLarge);
        }
        self.meta(contact)?.timer = secs;
        Ok(())
    }

    /// Lets a request in.
    pub fn accept(&mut self, contact: &str) -> Result<(), MessagingError> {
        self.meta(contact)?.state = ContactState::Accepted;
        Ok(())
    }

    /// Drops everything from a contact from now on, and stops watching for
    /// them. Their identity stays, so they are recognised.
    pub fn block(&mut self, contact: &str) -> Result<(), MessagingError> {
        let m = self.meta(contact)?;
        m.state = ContactState::Blocked;
        self.s.sessions.remove(contact);
        Ok(())
    }

    /// Forgets a contact, their identity key and the session with them.
    pub fn remove(&mut self, contact: &str) -> Result<(), MessagingError> {
        self.s
            .contacts
            .remove(contact)
            .ok_or(MessagingError::NoContact)?;
        self.s.identities.remove(contact);
        self.s.sessions.remove(contact);
        Ok(())
    }

    /// The safety number two people compare to know no one sits between
    /// them: 60 digits in 12 groups, the same on both phones.
    pub fn safety_number(&self, contact: &str) -> Result<String, MessagingError> {
        let theirs = self
            .s
            .identities
            .get(contact)
            .ok_or(MessagingError::NoContact)?;
        let theirs =
            IdentityKey::try_from(theirs.as_slice()).map_err(|_| MessagingError::Damaged)?;
        let digits = Fingerprint::new(
            FINGERPRINT_VERSION,
            FINGERPRINT_ITERATIONS,
            self.my_address.as_bytes(),
            self.me.identity_key(),
            contact.as_bytes(),
            &theirs,
        )
        .and_then(|f| f.display_string())
        .map_err(|_| MessagingError::Crypto)?;
        Ok(digits
            .as_bytes()
            .chunks(5)
            .map(|c| String::from_utf8_lossy(c).into_owned())
            .collect::<Vec<_>>()
            .join(" "))
    }
}

/// The tag a card is published under: `kilit:` and the four words.
pub fn card_tag(words: &str) -> String {
    format!("kilit:{words}")
}

/// The address (32 hex digits) of the identity a card carries.
pub fn card_address(card: &[u8]) -> Option<String> {
    let c = ciborium::from_reader::<Card, _>(card).ok()?;
    let identity = IdentityKey::try_from(c.identity.as_slice()).ok()?;
    Some(address_name(&identity))
}

/// Whether a card fetched from the relays is the one `invite` names: its
/// identity key hashes to the ID, and to the address when there is one.
pub fn card_matches(card: &[u8], invite: &Invite) -> bool {
    let Ok(c) = ciborium::from_reader::<Card, _>(card) else {
        return false;
    };
    let Ok(identity) = IdentityKey::try_from(c.identity.as_slice()) else {
        return false;
    };
    id_words(&identity, &c.id_salt) == invite.id
        && invite
            .address
            .as_ref()
            .is_none_or(|a| *a == address_name(&identity))
}
