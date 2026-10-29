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

fn address(name: &str) -> Result<ProtocolAddress, MessagingError> {
    let device = DeviceId::new(1).map_err(|_| MessagingError::Crypto)?;
    Ok(ProtocolAddress::new(name.to_owned(), device))
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

/// `version | flags | [nonce] | signal type | signal message`
fn envelope(kind: u8, msg: &[u8], pow: bool) -> Result<Vec<u8>, MessagingError> {
    let mut inner = vec![kind];
    inner.extend_from_slice(msg);
    let mut out = vec![ENVELOPE_VERSION, if pow { FLAG_POW } else { 0 }];
    if pow {
        out.extend_from_slice(&pow_solve(&inner, POW_BITS)?.to_le_bytes());
    }
    out.extend_from_slice(&inner);
    Ok(out)
}

/// The Signal part of an envelope, and whether its proof of work holds.
fn open_envelope(e: &[u8]) -> Result<(&[u8], bool), MessagingError> {
    match e {
        [ENVELOPE_VERSION, 0, inner @ ..] => Ok((inner, false)),
        [ENVELOPE_VERSION, FLAG_POW, rest @ ..] if rest.len() > 8 => {
            let (nonce, inner) = rest.split_at(8);
            let nonce =
                u64::from_le_bytes(nonce.try_into().map_err(|_| MessagingError::NotAMessage)?);
            Ok((inner, pow_ok(inner, nonce, POW_BITS)))
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
        match self.0.get(address.name()) {
            Some(b) => Ok(Some(SessionRecord::deserialize(b)?)),
            None => Ok(None),
        }
    }

    async fn store_session(
        &mut self,
        address: &ProtocolAddress,
        record: &SessionRecord,
    ) -> Result<(), SignalProtocolError> {
        self.0.insert(
            address.name().to_owned(),
            ByteBuf::from(record.serialize()?),
        );
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
    s: State,
}

impl Messaging {
    fn identity(vault: &Vault) -> Result<IdentityKeyPair, MessagingError> {
        let seed = seed(vault.master(), IDENTITY_INFO).map_err(|_| MessagingError::Crypto)?;
        let private = PrivateKey::deserialize(&seed[..]).map_err(|_| MessagingError::Crypto)?;
        IdentityKeyPair::try_from(private).map_err(|_| MessagingError::Crypto)
    }

    fn with_state(vault: &Vault, mut s: State) -> Result<Self, MessagingError> {
        let me = Self::identity(vault)?;
        if s.id_salt.len() < 16 {
            s.id_salt = ByteBuf::from(random_bytes::<16>()?.to_vec());
        }
        let fc_key =
            seed(vault.master(), FIRST_CONTACT_INFO).map_err(|_| MessagingError::Crypto)?;
        let card_key = seed(vault.master(), CARD_KEY_INFO).map_err(|_| MessagingError::Crypto)?;
        let mut m = Self {
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
        Self::with_state(
            vault,
            State {
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
            },
        )
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
        let bundle = PreKeyBundle::new(
            c.registration_id,
            DeviceId::new(1).map_err(|_| MessagingError::Crypto)?,
            None,
            SignedPreKeyId::from(c.signed_prekey_id),
            PublicKey::deserialize(&c.signed_prekey).map_err(not_a_card)?,
            c.signed_prekey_signature.into_vec(),
            KyberPreKeyId::from(c.kyber_prekey_id),
            kem::PublicKey::deserialize(&c.kyber_prekey).map_err(not_a_card)?,
            c.kyber_prekey_signature.into_vec(),
            identity,
        )
        .map_err(not_a_card)?;
        let mut s = self.s.clone();
        // the signatures on both prekeys are checked here: a forged card fails
        run(process_prekey_bundle(
            &address(&id)?,
            &address(&self.my_address)?,
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
        })?;
        let meta = s.contacts.entry(id.clone()).or_default();
        if meta.added == 0 {
            meta.added = unix_secs(now);
        }
        // adding someone is answering them: a request becomes a contact
        meta.state = state;
        if !c.first_contact.is_empty() {
            meta.first_contact = Some(c.first_contact);
        }
        meta.id_salt = c.id_salt;
        meta.kilit_id = words;
        let given = short(name.unwrap_or(&c.name));
        if !given.is_empty() {
            meta.name = given;
        }
        self.s = s;
        Ok(id)
    }

    fn mailbox(&self, contact: &str, recipient: &str, day: i64) -> Result<String, MessagingError> {
        let theirs = self
            .s
            .identities
            .get(contact)
            .ok_or(MessagingError::NoContact)?;
        let theirs =
            IdentityKey::try_from(theirs.as_slice()).map_err(|_| MessagingError::Damaged)?;
        let shared = self
            .me
            .private_key()
            .calculate_agreement(theirs.public_key())
            .map_err(|_| MessagingError::Crypto)?;
        Ok(hex(&hmac(
            &shared,
            &[MAILBOX_LABEL, recipient.as_bytes(), &day.to_le_bytes()],
        )?))
    }

    /// The tags to watch on the relays: this vault's first-contact tag and,
    /// for every contact not blocked, today's mailbox with the days on
    /// either side (clocks differ).
    pub fn inbox_tags(&self, now: SystemTime) -> Result<Vec<String>, MessagingError> {
        let day = unix_secs(now).div_euclid(DAY_SECS);
        let mut tags = vec![self.first_contact.clone()];
        tags.extend(
            self.s
                .retired_fc
                .iter()
                .filter(|(_, until)| *until > unix_secs(now))
                .map(|(t, _)| t.clone()),
        );
        for (id, meta) in &self.s.contacts {
            if meta.state == ContactState::Blocked || !self.s.identities.contains_key(id) {
                continue;
            }
            for d in day - 1..=day + 1 {
                tags.push(self.mailbox(id, &self.my_address, d)?);
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
        if content.text.len() > MAX_TEXT || content.timer > MAX_TIMER {
            return Err(MessagingError::TooLarge);
        }
        let meta = self
            .s
            .contacts
            .get(contact)
            .ok_or(MessagingError::NoContact)?;
        if meta.state == ContactState::Blocked {
            return Err(MessagingError::Blocked);
        }
        let first = !meta.knows_us;
        let tag = match (&meta.first_contact, first) {
            (Some(fc), true) => fc.clone(),
            _ => self.mailbox(contact, contact, unix_secs(now).div_euclid(DAY_SECS))?,
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
            },
            &mut body,
        )
        .map_err(|_| MessagingError::Crypto)?;
        let mut s = self.s.clone();
        let m = run(message_encrypt(
            &pad(body),
            &address(contact)?,
            &address(&self.my_address)?,
            &mut Sessions(&mut s.sessions),
            &mut Identities {
                me: &self.me,
                registration_id: s.registration_id,
                known: &mut s.identities,
            },
            now,
            &mut rng(),
        ))?;
        let payload = envelope(m.message_type() as u8, m.serialize(), first)?;
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
        let (inner, proven) = open_envelope(payload)?;
        let (&kind, body) = inner.split_first().ok_or(MessagingError::NotAMessage)?;
        let me = address(&self.my_address)?;
        let (contact, plain, s) = match kind {
            PREKEY_MESSAGE => {
                let m = PreKeySignalMessage::try_from(body)?;
                let id = address_name(m.identity_key());
                if id == self.my_address {
                    return Err(MessagingError::NotAMessage);
                }
                match self.s.contacts.get(&id) {
                    Some(meta) if meta.state == ContactState::Blocked => {
                        return Err(MessagingError::Blocked);
                    }
                    Some(_) => {}
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
                    &address(&id)?,
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
                let mut opened = None;
                for (id, meta) in &self.s.contacts {
                    if meta.state == ContactState::Blocked || !self.s.sessions.contains_key(id) {
                        continue;
                    }
                    let mut s = self.s.clone();
                    let r = run(message_decrypt_signal(
                        &m,
                        &address(id)?,
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
        let new_contact = !s.contacts.contains_key(&contact);
        let meta = s.contacts.entry(contact.clone()).or_insert_with(|| Meta {
            added: unix_secs(now),
            state: ContactState::Request,
            ..Meta::default()
        });
        // they wrote: they have the session, the daily mailbox works now
        meta.knows_us = true;
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
        let only_receipts = b.text.is_empty() && b.file.is_none() && !b.receipts.is_empty();
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
