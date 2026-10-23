//! Message schemas and the IPC policy shared by every compartment.
//!
//! Compartments never talk to each other directly. Every request goes to the
//! broker, which checks it against a [`Policy`]. A policy starts empty, so
//! anything not explicitly allowed is refused (the qrexec model from Qubes OS).

use std::collections::BTreeSet;

/// One isolated part of Kilit, each running as its own process.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Compartment {
    /// Flutter UI. Sees what it draws, nothing else.
    Ui,
    /// In-app camera. Captures into memory only.
    Camera,
    /// Keys, Signal sessions, PIN table.
    Vault,
    /// Ciphertext at rest.
    Store,
    /// Disposable parser for untrusted files.
    Parse,
    /// Tor and relays. Sealed packets only.
    Net,
}

/// What a request asks the receiving compartment to do.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum Call {
    /// Seal a plaintext for a contact (to the vault).
    Seal,
    /// Open a sealed packet (to the vault).
    Open,
    /// Store or load ciphertext (to the store).
    Persist,
    /// Hand a sealed packet to the network (to the gateway).
    Send,
    /// Deliver a received sealed packet (from the gateway to the vault).
    Deliver,
    /// Decode an untrusted file (to the parser).
    Decode,
}

/// The largest IPC message the broker accepts, in bytes. Media moves in
/// stream chunks, never as one message.
pub const MAX_MESSAGE_BYTES: usize = 256 * 1024;

/// A default-deny allow list of `(from, to, call)` triples.
#[derive(Clone, Debug, Default)]
pub struct Policy {
    allowed: BTreeSet<(Compartment, Compartment, Call)>,
}

impl Policy {
    /// Allows `from` to make `call` on `to`.
    pub fn allow(mut self, from: Compartment, to: Compartment, call: Call) -> Self {
        self.allowed.insert((from, to, call));
        self
    }

    /// Whether the broker should forward this request.
    pub fn permits(&self, from: Compartment, to: Compartment, call: Call) -> bool {
        self.allowed.contains(&(from, to, call))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_policy_refuses_everything() {
        let p = Policy::default();
        assert!(!p.permits(Compartment::Ui, Compartment::Vault, Call::Seal));
    }

    #[test]
    fn allow_is_one_direction_and_one_call() {
        let p = Policy::default().allow(Compartment::Ui, Compartment::Vault, Call::Seal);
        assert!(p.permits(Compartment::Ui, Compartment::Vault, Call::Seal));
        assert!(!p.permits(Compartment::Vault, Compartment::Ui, Call::Seal));
        assert!(!p.permits(Compartment::Ui, Compartment::Vault, Call::Open));
        assert!(!p.permits(Compartment::Ui, Compartment::Net, Call::Send));
    }
}
