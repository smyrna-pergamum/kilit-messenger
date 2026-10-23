//! Signal sessions with contacts, from the official libsignal: PQXDH (X25519
//! plus Kyber-1024) to start a session, then the Double Ratchet together with
//! SPQR, the sparse post-quantum ratchet, for every message after. libsignal
//! insists on both; a session without them cannot be made.
//!
//! There is no key server. A contact's prekeys come from their **contact
//! card**, a `KLC1:` text shared however the two people like (in person, a
//! chat app). Messages travel as `KLM1:` text the same way until the network
//! arrives; libsignal does not care how they get there.
//!
//! What is kept: one signed prekey and one last-resort Kyber prekey (both on
//! the card), and each contact's identity key, session and name. The Signal
//! identity itself is derived from the vault's master secret. [`Messaging`]
//! serialises to bytes the caller seals to the vault.

use std::collections::BTreeMap;
use std::future::Future;
use std::pin::pin;
use std::task::{Context, Poll, Waker};
use std::time::SystemTime;

use async_trait::async_trait;
use base64::Engine;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
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

use crate::Vault;
use crate::identity::seed;

/// Text prefix of a contact card.
pub const CARD_PREFIX: &str = "KLC1:";
/// Text prefix of a message.
pub const MESSAGE_PREFIX: &str = "KLM1:";
/// Ends both kinds of text; not in the base64url alphabet.
const TEXT_END: char = '.';

const IDENTITY_INFO: &[u8] = b"kilit/v1/signal-identity";
const STATE_VERSION: u8 = 1;
const CARD_VERSION: u8 = 1;
const BODY_VERSION: u8 = 1;
/// libsignal's message type bytes.
const PREKEY_MESSAGE: u8 = 3;
const SIGNAL_MESSAGE: u8 = 2;
/// Plaintext is padded to a multiple of this, as Signal's clients do, so a
/// message's length says little about its text.
const PAD_BLOCK: usize = 160;
/// The longest message text, in bytes.
pub const MAX_TEXT: usize = 32 * 1024;
/// How many base keys of the last-resort Kyber prekey are remembered, to
/// refuse a replayed first message.
const BASE_KEYS_KEPT: usize = 4096;
/// Contacts this vault holds at most.
pub const MAX_CONTACTS: usize = 1000;
/// Packets [`find`] looks for in one paste.
const MAX_FOUND: usize = 16;
const NAME_CHARS: usize = 64;
const FINGERPRINT_ITERATIONS: u32 = 5200;
const FINGERPRINT_VERSION: u32 = 2;

/// Why a messaging call failed. Says no more than the user may see.
#[derive(Debug, PartialEq, Eq)]
pub enum MessagingError {
    /// Not a contact card, or a forged one.
    NotACard,
    /// The card is this vault's own.
    OwnCard,
    /// Not a message, or damaged.
    NotAMessage,
    /// A message from someone with no session here. Their first message
    /// starts one; later ones need it.
    UnknownSender,
    /// Already read: the same message was opened before.
    Duplicate,
    /// The contact's identity key is not the one kept for them.
    IdentityChanged,
    /// No such contact.
    NoContact,
    /// Too many contacts, or a text too long.
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

/// A contact's address: the first half of the SHA-256 of their identity key,
/// in hex. Nothing else names them: there is no number or account.
fn address_name(identity: &IdentityKey) -> String {
    Sha256::digest(identity.serialize())[..16]
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect()
}

fn unix_secs(t: SystemTime) -> i64 {
    t.duration_since(SystemTime::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

fn short(name: &str) -> String {
    name.trim().chars().take(NAME_CHARS).collect()
}

#[derive(Clone, Default, Serialize, Deserialize)]
struct Meta {
    name: String,
    /// When the contact was added, Unix seconds.
    added: i64,
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
}

#[derive(Serialize, Deserialize)]
struct Body {
    v: u8,
    text: String,
    /// When it was written, Unix seconds, by the sender's clock.
    sent: i64,
}

/// A contact as the list shows it.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct ContactInfo {
    /// The contact's address (32 hex digits).
    pub id: String,
    /// The name given to them; empty until one is given.
    pub name: String,
    /// When they were added, Unix seconds.
    pub added: i64,
}

/// An opened message.
#[derive(Debug, PartialEq, Eq)]
pub struct Received {
    /// Who sent it.
    pub contact: String,
    /// True when this message made them a contact.
    pub new_contact: bool,
    /// The text.
    pub text: String,
    /// When it was written, by the sender's clock, Unix seconds.
    pub sent: i64,
}

/// What [`find`] found in pasted text.
#[derive(Debug, PartialEq, Eq)]
pub enum Found {
    /// A card's or a message's bytes.
    Packet(Vec<u8>),
    /// The chat app cut it off before the end marker.
    Truncated,
    /// Not valid base64url.
    Malformed,
}

/// `<prefix><base64url>.`
fn armor(prefix: &str, bytes: &[u8]) -> String {
    format!("{prefix}{}{TEXT_END}", URL_SAFE_NO_PAD.encode(bytes))
}

/// Finds texts that start with `prefix` ([`CARD_PREFIX`] or
/// [`MESSAGE_PREFIX`]) in pasted text. Line breaks a chat app put inside
/// one are skipped.
pub fn find(prefix: &str, text: &str) -> Vec<Found> {
    let mut found = Vec::new();
    let mut rest = text;
    while let Some(at) = rest.find(prefix) {
        if found.len() == MAX_FOUND {
            break;
        }
        rest = &rest[at + prefix.len()..];
        let mut body = String::new();
        let mut ended = false;
        let mut used = rest.len();
        for (i, c) in rest.char_indices() {
            if c == TEXT_END {
                ended = true;
                used = i + 1;
                break;
            }
            if c.is_ascii_alphanumeric() || c == '-' || c == '_' {
                body.push(c);
            } else if !c.is_whitespace() {
                used = i;
                break;
            }
        }
        rest = &rest[used..];
        found.push(if !ended {
            Found::Truncated
        } else {
            match URL_SAFE_NO_PAD.decode(body.as_bytes()) {
                Ok(b) if !b.is_empty() => Found::Packet(b),
                _ => Found::Malformed,
            }
        });
    }
    found
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
    s: State,
}

impl Messaging {
    fn identity(vault: &Vault) -> Result<IdentityKeyPair, MessagingError> {
        let seed = seed(vault.master(), IDENTITY_INFO).map_err(|_| MessagingError::Crypto)?;
        let private = PrivateKey::deserialize(&seed[..]).map_err(|_| MessagingError::Crypto)?;
        IdentityKeyPair::try_from(private).map_err(|_| MessagingError::Crypto)
    }

    fn with_state(vault: &Vault, s: State) -> Result<Self, MessagingError> {
        let me = Self::identity(vault)?;
        Ok(Self {
            my_address: address_name(me.identity_key()),
            me,
            s,
        })
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

    /// The `KLC1:` card to give to contacts: what they need to start a
    /// session, and the `name` to show them first. It holds no secret.
    pub fn card(&self, name: &str) -> Result<String, MessagingError> {
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
        };
        let mut b = Vec::new();
        ciborium::into_writer(&card, &mut b).map_err(|_| MessagingError::Crypto)?;
        Ok(armor(CARD_PREFIX, &b))
    }

    /// Adds the contact whose card `card` is (the bytes inside `KLC1:`) and
    /// starts a session with them. The name on the card is used unless
    /// `name` is given. Returns their address. The same card again starts a
    /// new session.
    pub fn add_contact(
        &mut self,
        card: &[u8],
        name: Option<&str>,
        now: SystemTime,
    ) -> Result<String, MessagingError> {
        let c: Card = ciborium::from_reader(card).map_err(not_a_card)?;
        if c.v != CARD_VERSION {
            return Err(MessagingError::NotACard);
        }
        let identity = IdentityKey::try_from(c.identity.as_slice()).map_err(not_a_card)?;
        let id = address_name(&identity);
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
        let given = short(name.unwrap_or(&c.name));
        if !given.is_empty() {
            meta.name = given;
        }
        self.s = s;
        Ok(id)
    }

    /// Seals `text` for a contact as `KLM1:` text.
    pub fn encrypt(
        &mut self,
        contact: &str,
        text: &str,
        now: SystemTime,
    ) -> Result<String, MessagingError> {
        if text.len() > MAX_TEXT {
            return Err(MessagingError::TooLarge);
        }
        if !self.s.contacts.contains_key(contact) {
            return Err(MessagingError::NoContact);
        }
        let mut body = Vec::new();
        ciborium::into_writer(
            &Body {
                v: BODY_VERSION,
                text: text.to_owned(),
                sent: unix_secs(now),
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
        let mut out = vec![m.message_type() as u8];
        out.extend_from_slice(m.serialize());
        self.s = s;
        Ok(armor(MESSAGE_PREFIX, &out))
    }

    /// Opens a message (the bytes inside `KLM1:`). A first message from
    /// someone who has this vault's card makes them a contact, unnamed.
    pub fn decrypt(&mut self, packet: &[u8], now: SystemTime) -> Result<Received, MessagingError> {
        let (&kind, body) = packet.split_first().ok_or(MessagingError::NotAMessage)?;
        let me = address(&self.my_address)?;
        let (contact, plain, s) = match kind {
            PREKEY_MESSAGE => {
                let m = PreKeySignalMessage::try_from(body)?;
                let id = address_name(m.identity_key());
                if id == self.my_address {
                    return Err(MessagingError::NotAMessage);
                }
                if !self.s.contacts.contains_key(&id) && self.s.contacts.len() >= MAX_CONTACTS {
                    return Err(MessagingError::TooLarge);
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
                for id in self.s.sessions.keys() {
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
        s.contacts.entry(contact.clone()).or_insert_with(|| Meta {
            name: String::new(),
            added: unix_secs(now),
        });
        self.s = s;
        Ok(Received {
            contact,
            new_contact,
            text: b.text,
            sent: b.sent,
        })
    }

    /// The contacts, by name, unnamed ones last.
    pub fn contacts(&self) -> Vec<ContactInfo> {
        let mut v: Vec<_> = self
            .s
            .contacts
            .iter()
            .map(|(id, m)| ContactInfo {
                id: id.clone(),
                name: m.name.clone(),
                added: m.added,
            })
            .collect();
        v.sort_by_cached_key(|c| (c.name.is_empty(), c.name.to_lowercase(), c.id.clone()));
        v
    }

    /// Gives a contact a name.
    pub fn rename(&mut self, contact: &str, name: &str) -> Result<(), MessagingError> {
        self.s
            .contacts
            .get_mut(contact)
            .ok_or(MessagingError::NoContact)?
            .name = short(name);
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
