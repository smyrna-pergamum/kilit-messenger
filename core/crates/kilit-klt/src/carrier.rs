//! Carrier mode: moving packets through channels Kilit does not control,
//! such as WhatsApp, e-mail or a USB stick (spec/KLT1.md, "Taşıyıcı modu").
//!
//! This module decides how a packet travels and turns text messages into
//! packets and back. Sharing and clipboard access belong to the platform
//! layer; nothing here touches either.

use std::io::{self, Write};

use crate::armor::MAX_ARMORED;
use crate::{KltError, Opened, PacketSigner, open, seal, to_text};

/// The manifest name of a text message.
pub const MESSAGE_NAME: &str = "mesaj.txt";
/// The manifest media type of a text message.
pub const MESSAGE_MIME: &str = "text/x-kilit-message; charset=utf-8";
/// The longest text message, in UTF-8 bytes.
pub const MAX_MESSAGE_BYTES: usize = 16 * 1024;

/// A packet ready to hand to another app.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Carried {
    /// Small enough to paste: `KLT1:...`.
    Text(String),
    /// Too large to paste; share it as a file.
    File {
        /// A random name that says nothing about the content.
        file_name: String,
        /// The `.klt` bytes.
        packet: Vec<u8>,
    },
}

/// A file name of the form `kilit-<8 hex digits>.klt`.
pub fn carrier_file_name() -> Result<String, KltError> {
    let mut b = [0u8; 4];
    getrandom::fill(&mut b).map_err(|_| KltError::Key("no system randomness"))?;
    Ok(format!(
        "kilit-{:02x}{:02x}{:02x}{:02x}.klt",
        b[0], b[1], b[2], b[3]
    ))
}

/// Picks text when the packet fits in one chat message, a file otherwise.
pub fn carry(packet: Vec<u8>) -> Result<Carried, KltError> {
    if packet.len() <= MAX_ARMORED {
        Ok(Carried::Text(to_text(&packet)?))
    } else {
        Ok(Carried::File {
            file_name: carrier_file_name()?,
            packet,
        })
    }
}

/// Seals a short text message for carrier mode.
pub fn seal_message(
    message: &str,
    recipients: &[&dyn age::Recipient],
    signer: Option<&dyn PacketSigner>,
) -> Result<Carried, KltError> {
    if message.len() > MAX_MESSAGE_BYTES {
        return Err(KltError::Malformed("message too long; send it as a file"));
    }
    let packet = seal(
        MESSAGE_NAME,
        MESSAGE_MIME,
        message.len() as u64,
        message.as_bytes(),
        recipients,
        signer,
        Vec::new(),
    )?;
    carry(packet)
}

/// A writer that refuses to grow past a limit, so a hostile manifest that
/// claims a huge size cannot make us buffer it.
struct Capped {
    buf: Vec<u8>,
    cap: usize,
}

impl Write for Capped {
    fn write(&mut self, data: &[u8]) -> io::Result<usize> {
        if self.buf.len() + data.len() > self.cap {
            return Err(io::Error::other("message too long"));
        }
        self.buf.extend_from_slice(data);
        Ok(data.len())
    }

    fn flush(&mut self) -> io::Result<()> {
        Ok(())
    }
}

/// Opens a packet as a text message.
///
/// Fails with [`KltError::NotAMessage`] when the packet holds a file; the
/// caller should then open it with [`open`] and show it as a file.
pub fn open_message(
    packet: &[u8],
    identities: &[&dyn age::Identity],
) -> Result<(String, Opened), KltError> {
    let mut out = Capped {
        buf: Vec::new(),
        cap: MAX_MESSAGE_BYTES,
    };
    let opened = match open(packet, identities, &mut out) {
        Ok(o) => o,
        // the cap tripped: a large file, not a message
        Err(KltError::Io(_)) => return Err(KltError::NotAMessage),
        Err(e) => return Err(e),
    };
    if opened.manifest.name != MESSAGE_NAME || opened.manifest.mime != MESSAGE_MIME {
        return Err(KltError::NotAMessage);
    }
    let text =
        String::from_utf8(out.buf).map_err(|_| KltError::Malformed("message is not UTF-8"))?;
    Ok((text, opened))
}
