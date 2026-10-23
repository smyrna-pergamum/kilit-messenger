use std::fmt;
use std::io;

/// Everything that can go wrong sealing or opening a packet.
///
/// The variants say what kind of failure it was, never which byte or which
/// key: callers show them to users and the messages must not leak secrets.
#[derive(Debug)]
pub enum KltError {
    /// The bytes do not start with `KLT1`.
    NotKlt,
    /// None of the given keys or passphrases opens this packet.
    WrongKey,
    /// The packet is damaged or was changed after it was made.
    Corrupt,
    /// Pasted text ends before the packet does: the chat app cut it off.
    Truncated,
    /// The packet opened, but it is a file, not a text message.
    NotAMessage,
    /// The packet is well formed but breaks a rule of the format.
    Malformed(&'static str),
    /// The packet asks for more work or memory than Kilit allows.
    TooExpensive,
    /// The content was a different length than the manifest said.
    SizeMismatch,
    /// The packet is signed but the signature does not verify.
    BadSignature,
    /// A recipient or signer could not be used.
    Key(&'static str),
    /// Reading or writing failed.
    Io(io::Error),
}

impl fmt::Display for KltError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NotKlt => f.write_str("not a .klt packet"),
            Self::WrongKey => f.write_str("no matching key or passphrase"),
            Self::Corrupt => f.write_str("the packet is damaged or was changed"),
            Self::Truncated => f.write_str("the pasted packet was cut off"),
            Self::NotAMessage => f.write_str("the packet holds a file, not a message"),
            Self::Malformed(why) => write!(f, "malformed packet: {why}"),
            Self::TooExpensive => f.write_str("the packet asks for too much work"),
            Self::SizeMismatch => f.write_str("the content length does not match"),
            Self::BadSignature => f.write_str("the signature does not verify"),
            Self::Key(why) => write!(f, "key error: {why}"),
            Self::Io(e) => write!(f, "i/o error: {e}"),
        }
    }
}

impl std::error::Error for KltError {}

impl From<io::Error> for KltError {
    fn from(e: io::Error) -> Self {
        Self::Io(e)
    }
}

impl From<age::DecryptError> for KltError {
    fn from(e: age::DecryptError) -> Self {
        match e {
            age::DecryptError::NoMatchingKeys => Self::WrongKey,
            age::DecryptError::ExcessiveWork { .. } => Self::TooExpensive,
            age::DecryptError::UnknownFormat => Self::Malformed("unknown age format"),
            age::DecryptError::Io(e) if e.kind() == io::ErrorKind::InvalidData => Self::Corrupt,
            age::DecryptError::Io(e) => Self::Io(e),
            _ => Self::Corrupt,
        }
    }
}

impl From<age::EncryptError> for KltError {
    fn from(e: age::EncryptError) -> Self {
        match e {
            age::EncryptError::Io(e) => Self::Io(e),
            _ => Self::Key("recipients cannot be combined"),
        }
    }
}
