//! Vault compartment.
//!
//! Holds identity keys, Signal sessions and the PIN table. Keys never leave this process; other compartments ask it to encrypt, decrypt or sign. No network access.
