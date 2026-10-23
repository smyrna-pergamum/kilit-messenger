//! Vault compartment.
//!
//! Holds identity keys, Signal sessions and the PIN table. Keys never leave
//! this process; other compartments ask it to encrypt, decrypt or sign. No
//! network access.
//!
//! Everything the vault knows grows from one 32-byte master secret. At rest
//! that secret is sealed under a key made in two steps (spec: "PIN ve
//! kilit"):
//!
//! 1. the PIN is MACed by a [`HardwareKey`] that cannot leave the device
//!    (StrongBox/TEE on Android, TPM 2.0 on Windows), so a copied vault file
//!    cannot be attacked offline without that device;
//! 2. the MAC goes through Argon2id, so even someone who extracts the
//!    hardware key still pays for every guess.
//!
//! Counting wrong guesses is the platform layer's job: only the hardware can
//! enforce a limit that survives the app being copied.

mod hardware;
mod identity;
mod sealed;

pub use hardware::{HardwareKey, SoftwareKey};
pub use identity::PublicIdentity;
pub use kilit_klt::KdfParams;
pub use sealed::Vault;

use std::fmt;

/// Why a vault operation failed. Never says more than the user may see.
#[derive(Debug, PartialEq, Eq)]
pub enum VaultError {
    /// The PIN is wrong, or the vault file was damaged. The two cannot be
    /// told apart without weakening the vault.
    Locked,
    /// The vault file is not one this version understands.
    Unsupported,
    /// The hardware key refused or is missing.
    Hardware,
    /// The PIN or the key derivation parameters are not acceptable.
    Rejected(&'static str),
    /// The system gave no randomness, or a primitive failed.
    Crypto,
}

impl fmt::Display for VaultError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Locked => f.write_str("wrong PIN, or the vault is damaged"),
            Self::Unsupported => f.write_str("unsupported vault version"),
            Self::Hardware => f.write_str("the hardware key is unavailable"),
            Self::Rejected(why) => write!(f, "rejected: {why}"),
            Self::Crypto => f.write_str("a cryptographic operation failed"),
        }
    }
}

impl std::error::Error for VaultError {}
