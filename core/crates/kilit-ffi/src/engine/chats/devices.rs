//! One Kilit ID on several devices (spec/MULTI-DEVICE.md): a message goes
//! to every device of the person it is for, and a copy to this ID's own
//! other devices, so each shows what the others sent. Linking a device:
//! it shows a QR code with a one-time X-Wing key; the phone seals the ID's
//! secrets to that key and hands them over through the relays; the new
//! device answers with its prekeys, sealed with a key from that package.

use chacha20poly1305::aead::Aead;
use kilit_klt::{XWingIdentity, XWingRecipient};

use super::*;

const LINK: &str = "link";
const LINK_NAME: &str = "link.cbor";
/// `kilit://link?k=<X-Wing public key>&t=<tag>`
pub const LINK_URL: &str = "kilit://link?";
/// A linking not finished in this long is dropped.
const LINK_LIFE: i64 = 15 * 60;

/// On a new device: the key it showed and the tag the phone answers on.
#[derive(Clone, Serialize, Deserialize)]
struct Offer {
    seed: ByteBuf,
    tag: String,
    at: i64,
}

/// On the phone: the device it is linking, and the key the answer comes
/// sealed with.
#[derive(Clone, Serialize, Deserialize)]
struct Waiting {
    device: u32,
    key: ByteBuf,
    reply_tag: String,
    at: i64,
}

#[derive(Default, Serialize, Deserialize)]
struct Linking {
    offer: Option<Offer>,
    waiting: Option<Waiting>,
    /// The code both screens show, once both sides have the package.
    code: Option<String>,
    /// Linking finished here.
    done: bool,
    /// Names and dates of this ID's devices, by number.
    names: BTreeMap<u32, (String, i64)>,
    /// The card changed (a device came or went): publish it again.
    card_dirty: bool,
}

#[derive(Serialize, Deserialize)]
struct Wrap {
    package: ByteBuf,
    key: ByteBuf,
    name: String,
}

#[derive(Serialize, Deserialize)]
struct Reply {
    bundle: kilit_vault::messaging::DeviceBundle,
    name: String,
}

/// Where linking stands, for the screens.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LinkState {
    /// A new device: the text its QR code shows, while it waits.
    pub offer: Option<String>,
    /// The phone: waiting for the new device to answer.
    pub waiting: bool,
    /// The code to compare on both screens.
    pub code: Option<String>,
    /// Linking finished.
    pub done: bool,
}

/// One of this ID's devices.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DeviceInfo {
    pub id: u32,
    pub name: String,
    pub added: i64,
    /// The device this runs on.
    pub this: bool,
}

/// Six digits from the answer key, the same on both screens.
fn code_of(key: &[u8]) -> String {
    let h = Sha256::digest([b"kilit/v1/link-code\0".as_slice(), key].concat());
    let n = u32::from_le_bytes([h[0], h[1], h[2], h[3]]) % 1_000_000;
    format!("{:03} {:03}", n / 1000, n % 1000)
}

fn reply_tag(tag: &str) -> String {
    hex(&Sha256::digest(
        format!("kilit/v1/link-reply\0{tag}").as_bytes(),
    ))
}

impl Engine {
    fn linking(&self) -> Result<Linking, EngineError> {
        let mut l: Linking = self.load(LINK)?;
        let now = (self.now)();
        // an old, unfinished linking is forgotten
        if l.offer.as_ref().is_some_and(|o| now - o.at > LINK_LIFE) {
            l.offer = None;
        }
        if l.waiting.as_ref().is_some_and(|w| now - w.at > LINK_LIFE) {
            l.waiting = None;
        }
        Ok(l)
    }

    fn save_linking(&self, l: &Linking) -> Result<(), EngineError> {
        self.save(LINK, LINK_NAME, l)
    }

    /// Seals `content` for every device of `contact` there is a session
    /// with. The first event is the one for their phone.
    pub(super) fn seal_all(
        &self,
        m: &mut Messaging,
        contact: &str,
        content: &Content,
    ) -> Result<Vec<Event>, EngineError> {
        let mut events = Vec::new();
        for d in m.devices_of(contact) {
            let out = m
                .seal_to(contact, d, content, self.system_now())
                .map_err(messaging_err)?;
            events.push(self.message_event(out.tag, &out.payload)?);
        }
        Ok(events)
    }

    /// Copies of `content` for this ID's other devices, marked with whom it
    /// went to.
    pub(super) fn copy_to_own(
        &self,
        m: &mut Messaging,
        sync_to: &str,
        content: &Content,
    ) -> Result<Vec<Event>, EngineError> {
        let c = Content {
            sync_to: sync_to.to_owned(),
            ..content.clone()
        };
        let mut events = Vec::new();
        for d in m.own_devices() {
            let out = m
                .seal_own(d, &c, self.system_now())
                .map_err(messaging_err)?;
            events.push(self.message_event(out.tag, &out.payload)?);
        }
        Ok(events)
    }

    /// Whether this is the phone the ID was made on, which publishes the
    /// card and links devices.
    pub fn is_primary(&self) -> Result<bool, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(true);
        }
        Ok(self.messaging()?.device_id() == 1)
    }

    /// Takes "the card changed" once: the caller publishes it again.
    pub fn take_card_dirty(&mut self) -> Result<bool, EngineError> {
        let mut l = self.linking()?;
        if !l.card_dirty {
            return Ok(false);
        }
        l.card_dirty = false;
        self.save_linking(&l)?;
        Ok(true)
    }

    /// Tells every accepted contact the ID's devices changed, with the new
    /// card, so their apps write to the new device too.
    fn tell_contacts_card(&mut self) -> Result<(), EngineError> {
        let mut m = self.messaging()?;
        let card = m.card("").map_err(messaging_err)?;
        let content = Content {
            card: Some(card.clone()),
            ..Content::default()
        };
        let mut events = Vec::new();
        for c in m.contacts() {
            if c.state == ContactState::Accepted {
                events.extend(self.seal_all(&mut m, &c.id, &content)?);
            }
        }
        // the other devices learn the list from the card too
        events.extend(self.copy_to_own(&mut m, "", &content)?);
        self.save_messaging(&m)?;
        self.queue(events)
    }

    /// A new device: starts linking. Returns the text its QR code shows.
    /// Only for a device that has nothing yet: it becomes the phone's.
    pub fn link_offer(&mut self) -> Result<String, EngineError> {
        if self.store.len(SIGNAL)?.is_some() {
            let m = self.messaging()?;
            if m.device_id() != 1 || !m.contacts().is_empty() || !m.own_devices().is_empty() {
                return Err(EngineError::Rejected(
                    "only a new Kilit, with no contacts yet, can be linked".into(),
                ));
            }
        }
        let seed = random::<32>()?;
        let xw = XWingIdentity::from_seed(&seed).map_err(|_| EngineError::Damaged)?;
        let tag = hex(&random::<16>()?);
        let mut l = self.linking()?;
        l.offer = Some(Offer {
            seed: ByteBuf::from(seed.to_vec()),
            tag: tag.clone(),
            at: (self.now)(),
        });
        l.code = None;
        l.done = false;
        self.save_linking(&l)?;
        Ok(format!(
            "{LINK_URL}k={}&t={tag}",
            URL_SAFE_NO_PAD.encode(xw.recipient().to_bytes())
        ))
    }

    /// The phone: links the device whose QR code said `text`. Returns the
    /// events that carry the package, and the code to compare.
    pub fn link_accept(
        &mut self,
        text: &str,
        name: &str,
    ) -> Result<(Vec<Event>, String), EngineError> {
        let rest = text
            .trim()
            .strip_prefix(LINK_URL)
            .ok_or_else(|| EngineError::Rejected("not a Kilit linking code".into()))?;
        let mut key_b64 = None;
        let mut tag = None;
        for kv in rest.split('&') {
            match kv.split_once('=') {
                Some(("k", v)) => key_b64 = Some(v),
                Some(("t", v)) if v.len() == 32 && v.bytes().all(|b| b.is_ascii_hexdigit()) => {
                    tag = Some(v.to_owned());
                }
                _ => {}
            }
        }
        let (Some(key_b64), Some(tag)) = (key_b64, tag) else {
            return Err(EngineError::Rejected("not a Kilit linking code".into()));
        };
        let recipient = URL_SAFE_NO_PAD
            .decode(key_b64)
            .ok()
            .and_then(|b| XWingRecipient::from_bytes(&b).ok())
            .ok_or_else(|| EngineError::Rejected("not a Kilit linking code".into()))?;
        let m = self.messaging()?;
        let (package, device) = m.link_package().map_err(messaging_err)?;
        let key = random::<32>()?;
        let wrap = Wrap {
            package: ByteBuf::from(package),
            key: ByteBuf::from(key.to_vec()),
            name: name.chars().take(64).collect(),
        };
        let mut plain = Vec::new();
        ciborium::into_writer(&wrap, &mut plain).map_err(|_| EngineError::Damaged)?;
        let sealed = kilit_klt::seal(
            "link",
            CBOR,
            plain.len() as u64,
            plain.as_slice(),
            &[&recipient],
            None,
            Vec::new(),
        )
        .map_err(|_| EngineError::Damaged)?;
        let event = self.message_event(tag.clone(), &sealed)?;
        self.queue(vec![event.clone()])?;
        let code = code_of(&key);
        let mut l = self.linking()?;
        l.waiting = Some(Waiting {
            device,
            key: ByteBuf::from(key.to_vec()),
            reply_tag: reply_tag(&tag),
            at: (self.now)(),
        });
        l.code = Some(code.clone());
        l.done = false;
        self.save_linking(&l)?;
        Ok((vec![event], code))
    }

    /// The tags linking listens on, for the inbox filter.
    pub(super) fn link_tags(&self) -> Result<Vec<String>, EngineError> {
        let l = self.linking()?;
        let mut v = Vec::new();
        if let Some(o) = &l.offer {
            v.push(o.tag.clone());
        }
        if let Some(w) = &l.waiting {
            v.push(w.reply_tag.clone());
        }
        Ok(v)
    }

    /// Takes events meant for linking. Returns those it did not want.
    pub(super) fn take_link_events<'a>(
        &mut self,
        events: Vec<&'a Event>,
    ) -> Result<Vec<&'a Event>, EngineError> {
        let l = self.linking()?;
        if l.offer.is_none() && l.waiting.is_none() {
            return Ok(events);
        }
        let mut rest = Vec::new();
        for e in events {
            let tag = e.tag("p").unwrap_or_default().to_owned();
            if l.offer.as_ref().is_some_and(|o| o.tag == tag) {
                // a package that does not open is someone else's: ignore
                let _ = self.take_package(e);
            } else if l.waiting.as_ref().is_some_and(|w| w.reply_tag == tag) {
                let _ = self.take_reply(e);
            } else {
                rest.push(e);
            }
        }
        Ok(rest)
    }

    /// The new device: the phone's package came. It becomes a device of the
    /// phone's ID and answers with its prekeys.
    fn take_package(&mut self, e: &Event) -> Result<(), EngineError> {
        let mut l = self.linking()?;
        let offer = l.offer.clone().ok_or(EngineError::NotFound)?;
        let sealed = URL_SAFE_NO_PAD
            .decode(&e.content)
            .map_err(|_| EngineError::Damaged)?;
        let seed: [u8; 32] = offer
            .seed
            .as_slice()
            .try_into()
            .map_err(|_| EngineError::Damaged)?;
        let xw = XWingIdentity::from_seed(&seed).map_err(|_| EngineError::Damaged)?;
        let mut plain = Vec::new();
        kilit_klt::open(sealed.as_slice(), &[&xw], &mut plain).map_err(|_| EngineError::Damaged)?;
        let wrap: Wrap =
            ciborium::from_reader(plain.as_slice()).map_err(|_| EngineError::Damaged)?;
        let o = self.require_open()?;
        let m = Messaging::create_linked(&o.vault, &wrap.package, self.system_now())
            .map_err(messaging_err)?;
        self.save_messaging(&m)?;
        let reply = Reply {
            bundle: m.device_bundle().map_err(messaging_err)?,
            name: device_name(),
        };
        let mut body = Vec::new();
        ciborium::into_writer(&reply, &mut body).map_err(|_| EngineError::Damaged)?;
        let cipher =
            XChaCha20Poly1305::new_from_slice(&wrap.key).map_err(|_| EngineError::Damaged)?;
        let nonce = random::<24>()?;
        let mut content = nonce.to_vec();
        content.extend(
            cipher
                .encrypt(&XNonce::from(nonce), body.as_slice())
                .map_err(|_| EngineError::Damaged)?,
        );
        let event = self.message_event(reply_tag(&offer.tag), &content)?;
        self.queue(vec![event])?;
        l.offer = None;
        l.code = Some(code_of(&wrap.key));
        l.done = true;
        l.names.insert(1, (wrap.name, (self.now)()));
        l.names.insert(m.device_id(), (device_name(), (self.now)()));
        self.save_linking(&l)
    }

    /// The phone: the new device answered. It joins the ID; contacts are
    /// told, and the card is published again.
    fn take_reply(&mut self, e: &Event) -> Result<(), EngineError> {
        let mut l = self.linking()?;
        let w = l.waiting.clone().ok_or(EngineError::NotFound)?;
        let raw = URL_SAFE_NO_PAD
            .decode(&e.content)
            .map_err(|_| EngineError::Damaged)?;
        if raw.len() < 24 {
            return Err(EngineError::Damaged);
        }
        let (nonce, ct) = raw.split_at(24);
        let nonce: [u8; 24] = nonce.try_into().map_err(|_| EngineError::Damaged)?;
        let cipher = XChaCha20Poly1305::new_from_slice(&w.key).map_err(|_| EngineError::Damaged)?;
        let body = cipher
            .decrypt(&XNonce::from(nonce), ct)
            .map_err(|_| EngineError::Damaged)?;
        let reply: Reply =
            ciborium::from_reader(body.as_slice()).map_err(|_| EngineError::Damaged)?;
        let mut m = self.messaging()?;
        m.add_own_device(w.device, &reply.bundle, self.system_now())
            .map_err(messaging_err)?;
        self.save_messaging(&m)?;
        l.waiting = None;
        l.done = true;
        l.card_dirty = true;
        let name: String = reply.name.chars().take(64).collect();
        l.names.insert(w.device, (name, (self.now)()));
        self.save_linking(&l)?;
        self.tell_contacts_card()
    }

    /// Where linking stands.
    pub fn link_state(&self) -> Result<LinkState, EngineError> {
        let l = self.linking()?;
        let offer = match &l.offer {
            Some(o) => {
                let seed: [u8; 32] = o
                    .seed
                    .as_slice()
                    .try_into()
                    .map_err(|_| EngineError::Damaged)?;
                let xw = XWingIdentity::from_seed(&seed).map_err(|_| EngineError::Damaged)?;
                Some(format!(
                    "{LINK_URL}k={}&t={}",
                    URL_SAFE_NO_PAD.encode(xw.recipient().to_bytes()),
                    o.tag
                ))
            }
            None => None,
        };
        Ok(LinkState {
            offer,
            waiting: l.waiting.is_some(),
            code: l.code,
            done: l.done,
        })
    }

    /// Stops a linking under way.
    pub fn link_cancel(&mut self) -> Result<(), EngineError> {
        let mut l = self.linking()?;
        l.offer = None;
        l.waiting = None;
        l.code = None;
        l.done = false;
        self.save_linking(&l)
    }

    /// This ID's devices, this one included.
    pub fn devices(&self) -> Result<Vec<DeviceInfo>, EngineError> {
        if self.store.len(SIGNAL)?.is_none() {
            return Ok(Vec::new());
        }
        let m = self.messaging()?;
        let l = self.linking()?;
        let mut ids = m.own_devices();
        ids.push(m.device_id());
        ids.sort_unstable();
        Ok(ids
            .into_iter()
            .map(|id| {
                let (name, added) = l.names.get(&id).cloned().unwrap_or_default();
                DeviceInfo {
                    id,
                    name,
                    added,
                    this: id == m.device_id(),
                }
            })
            .collect())
    }

    /// The phone: takes a linked device off this ID. Contacts are told.
    pub fn unlink_device(&mut self, device: u32) -> Result<(), EngineError> {
        let mut m = self.messaging()?;
        m.remove_own_device(device).map_err(messaging_err)?;
        self.save_messaging(&m)?;
        let mut l = self.linking()?;
        l.names.remove(&device);
        l.card_dirty = true;
        self.save_linking(&l)?;
        self.tell_contacts_card()
    }

    /// A copy from an own device: what it sent, a contact it added, or the
    /// ID's card after a device came or went.
    pub(super) fn take_own(
        &mut self,
        m: &mut Messaging,
        r: Received,
        files: &mut Files,
    ) -> Result<(), EngineError> {
        let now = self.system_now();
        if r.sync_to.is_empty() {
            if let Some(card) = &r.card {
                m.take_own_card(card, now).map_err(messaging_err)?;
                self.save_messaging(m)?;
            }
            return Ok(());
        }
        if let Some(addr) = r.sync_to.strip_prefix("add:") {
            // a contact the other device added
            if let Some(card) = &r.card
                && m.add_contact(card, None, Some(&r.text), now)
                    .ok()
                    .as_deref()
                    == Some(addr)
            {
                self.save_messaging(m)?;
            }
            return Ok(());
        }
        if r.sync_to.starts_with("group:")
            && let Some(wire) = &r.group
        {
            let me = m.my_address().to_owned();
            self.take_own_group(&me, wire)?;
        }
        if r.text.is_empty() && r.file.is_none() && r.sticker.is_empty() || r.id.len() != 16 {
            return Ok(());
        }
        let group = r.sync_to.strip_prefix("group:").map(str::to_owned);
        let mut lines = match &group {
            Some(g) => self.load_group_chat(g)?,
            None => {
                if !m.contacts().iter().any(|c| c.id == r.sync_to) {
                    return Ok(());
                }
                self.load_chat(&r.sync_to)?
            }
        };
        if lines.iter().any(|l| l.outgoing && *l.id == *r.id) {
            return Ok(());
        }
        let file = match &r.file {
            Some(f) if f.chunks > 0 && f.chunks as usize <= MAX_FILE.div_ceil(CHUNK) + 1 => {
                if files.pending.len() < MAX_PENDING_FILES {
                    files.pending.insert(
                        f.tag.clone(),
                        Pending {
                            contact: r.sync_to.clone(),
                            line: ByteBuf::from(r.id.clone()),
                            file: f.clone(),
                            got: BTreeMap::new(),
                            group: group.clone().unwrap_or_default(),
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
            outgoing: true,
            text: r.text.clone(),
            at: (self.now)(),
            sent: r.sent,
            state: LineState::Sent,
            id: ByteBuf::from(r.id.clone()),
            file,
            file_ref: r.file.clone(),
            sticker: r.sticker.clone(),
            ..Line::default()
        });
        match &group {
            Some(g) => self.save_group_chat(g, lines),
            None => self.save_chat(&r.sync_to, lines),
        }
    }
}

/// A name for this device, shown in the list of devices.
fn device_name() -> String {
    let os = std::env::consts::OS;
    let host = std::env::var("COMPUTERNAME")
        .or_else(|_| std::env::var("HOSTNAME"))
        .unwrap_or_default();
    let kind = match os {
        "windows" => "Windows",
        "android" => "Android",
        "linux" => "Linux",
        "macos" => "macOS",
        _ => os,
    };
    if host.is_empty() {
        kind.to_owned()
    } else {
        format!("{kind} · {}", host.chars().take(32).collect::<String>())
    }
}
