//! Network gateway compartment.
//!
//! Talks to the Nostr relays over Tor (the embedded Tor on Android, a
//! separate tor.exe on Windows later): publishes events, watches inbox tags,
//! looks contact cards up. Sees only sealed packets, never keys or
//! plaintext.

mod event;
mod net;
mod relay;

pub use event::{Event, Filter};
pub use net::{Net, RelayStatus};

/// The relays Kilit uses: free, open to read, one per operator
/// (docs/RELAYS.md).
pub const RELAYS: &[&str] = &[
    "wss://nos.lol",
    "wss://relay.primal.net",
    "wss://nostr.oxtr.dev",
    "wss://offchain.pub",
    "wss://nostr-pub.wellorder.net",
    "wss://nostr.data.haus",
];

/// Why a network call failed.
#[derive(Debug, PartialEq, Eq)]
pub enum NetError {
    /// Not a `wss://` relay address Kilit accepts.
    Url,
    /// The connection or the TLS or WebSocket handshake failed.
    Connect(String),
    /// A key could not be made or used.
    Key,
    /// Bytes that do not form an event.
    Malformed,
}

impl std::fmt::Display for NetError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Url => f.write_str("not a wss:// relay address"),
            Self::Connect(why) => write!(f, "connection failed: {why}"),
            Self::Key => f.write_str("key error"),
            Self::Malformed => f.write_str("malformed event"),
        }
    }
}

impl std::error::Error for NetError {}
