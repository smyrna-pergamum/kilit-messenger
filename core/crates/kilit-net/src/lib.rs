//! Network gateway compartment.
//!
//! Runs Tor (a separate tor.exe on Windows), the onion door and the Nostr relay connections. Sees only sealed packets, never keys or plaintext.
