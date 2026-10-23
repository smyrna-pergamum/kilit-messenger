//! The `klt-argon2id` recipient: a passphrase shared out of band, the
//! successor of the old project's shared-password packets.

use std::collections::HashSet;

use age::secrecy::{ExposeSecret, SecretString};
use age::{DecryptError, EncryptError};
use age_core::format::{FileKey, Stanza};
use argon2::{Algorithm, Argon2, Params, Version};
use base64::Engine;
use base64::engine::general_purpose::STANDARD_NO_PAD;
use chacha20poly1305::aead::Aead;
use chacha20poly1305::{ChaCha20Poly1305, KeyInit, Nonce};
use zeroize::Zeroizing;

use crate::{KltError, PQ_LABEL};

pub(crate) const TAG: &str = "klt-argon2id";
const SALT_LABEL: &[u8] = b"kilit/klt1/argon2id";
const SALT_LEN: usize = 16;
const BODY_LEN: usize = 16 + 16;

/// Argon2id cost parameters.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct KdfParams {
    /// Memory in KiB.
    pub m_kib: u32,
    /// Passes.
    pub t: u32,
    /// Lanes.
    pub p: u32,
}

impl KdfParams {
    /// The default for new packets: 256 MiB, 4 passes.
    pub const DEFAULT: Self = Self {
        m_kib: 256 * 1024,
        t: 4,
        p: 1,
    };
    /// The least a new packet may use: 64 MiB, 3 passes.
    pub const MINIMUM: Self = Self {
        m_kib: 64 * 1024,
        t: 3,
        p: 1,
    };
    /// The most an incoming packet may ask for: 1 GiB, 10 passes, 4 lanes.
    pub const MAXIMUM: Self = Self {
        m_kib: 1024 * 1024,
        t: 10,
        p: 4,
    };

    fn at_least_minimum(self) -> bool {
        self.m_kib >= Self::MINIMUM.m_kib && self.t >= Self::MINIMUM.t && self.p >= 1
    }

    fn within_maximum(self) -> bool {
        self.m_kib <= Self::MAXIMUM.m_kib && self.t <= Self::MAXIMUM.t && self.p <= Self::MAXIMUM.p
    }
}

fn derive(
    passphrase: &SecretString,
    salt: &[u8; SALT_LEN],
    params: KdfParams,
) -> Option<Zeroizing<[u8; 32]>> {
    let p = Params::new(params.m_kib, params.t, params.p, Some(32)).ok()?;
    let mut full_salt = Vec::with_capacity(SALT_LABEL.len() + SALT_LEN);
    full_salt.extend_from_slice(SALT_LABEL);
    full_salt.extend_from_slice(salt);
    let mut key = Zeroizing::new([0u8; 32]);
    Argon2::new(Algorithm::Argon2id, Version::V0x13, p)
        .hash_password_into(
            passphrase.expose_secret().as_bytes(),
            &full_salt,
            key.as_mut(),
        )
        .ok()?;
    Some(key)
}

fn cipher(key: &[u8; 32]) -> Option<ChaCha20Poly1305> {
    ChaCha20Poly1305::new_from_slice(key).ok()
}

/// Seals a packet so anyone who knows the passphrase can open it.
pub struct PassphraseRecipient {
    passphrase: SecretString,
    params: KdfParams,
}

impl PassphraseRecipient {
    /// A recipient with [`KdfParams::DEFAULT`].
    pub fn new(passphrase: SecretString) -> Self {
        Self {
            passphrase,
            params: KdfParams::DEFAULT,
        }
    }

    /// A recipient with explicit costs, which must be at least
    /// [`KdfParams::MINIMUM`] and at most [`KdfParams::MAXIMUM`].
    pub fn with_params(passphrase: SecretString, params: KdfParams) -> Result<Self, KltError> {
        if !params.at_least_minimum() || !params.within_maximum() {
            return Err(KltError::Key("Argon2id parameters out of range"));
        }
        Ok(Self { passphrase, params })
    }
}

impl age::Recipient for PassphraseRecipient {
    fn wrap_file_key(
        &self,
        file_key: &FileKey,
    ) -> Result<(Vec<Stanza>, HashSet<String>), EncryptError> {
        let fail = |what: &str| EncryptError::Io(std::io::Error::other(what.to_owned()));
        let mut salt = [0u8; SALT_LEN];
        getrandom::fill(&mut salt).map_err(|_| fail("no system randomness"))?;
        let key =
            derive(&self.passphrase, &salt, self.params).ok_or_else(|| fail("Argon2id failed"))?;
        // the key is unique to this salt, so a fixed nonce is safe (as in age's scrypt)
        let body = cipher(&key)
            .ok_or_else(|| fail("bad key"))?
            .encrypt(&Nonce::default(), file_key.expose_secret().as_slice())
            .map_err(|_| fail("wrap failed"))?;
        let stanza = Stanza {
            tag: TAG.to_owned(),
            args: vec![
                STANDARD_NO_PAD.encode(salt),
                self.params.m_kib.to_string(),
                self.params.t.to_string(),
                self.params.p.to_string(),
            ],
            body,
        };
        Ok((vec![stanza], HashSet::from([PQ_LABEL.to_owned()])))
    }
}

/// Opens packets sealed to a passphrase.
pub struct PassphraseIdentity {
    passphrase: SecretString,
}

impl PassphraseIdentity {
    /// An identity that tries this passphrase.
    pub fn new(passphrase: SecretString) -> Self {
        Self { passphrase }
    }
}

fn parse_args(args: &[String]) -> Option<([u8; SALT_LEN], KdfParams)> {
    let [salt, m, t, p] = args else { return None };
    let salt: [u8; SALT_LEN] = STANDARD_NO_PAD.decode(salt).ok()?.try_into().ok()?;
    // canonical decimal only: no sign, no leading zeros
    let num = |s: &str| -> Option<u32> {
        if s.is_empty()
            || (s.len() > 1 && s.starts_with('0'))
            || !s.bytes().all(|b| b.is_ascii_digit())
        {
            return None;
        }
        s.parse().ok()
    };
    Some((
        salt,
        KdfParams {
            m_kib: num(m)?,
            t: num(t)?,
            p: num(p)?,
        },
    ))
}

impl age::Identity for PassphraseIdentity {
    fn unwrap_stanza(&self, stanza: &Stanza) -> Option<Result<FileKey, DecryptError>> {
        if stanza.tag != TAG {
            return None;
        }
        let Some((salt, params)) = parse_args(&stanza.args) else {
            return Some(Err(DecryptError::InvalidHeader));
        };
        if stanza.body.len() != BODY_LEN {
            return Some(Err(DecryptError::InvalidHeader));
        }
        if !params.within_maximum() {
            return Some(Err(DecryptError::ExcessiveWork {
                required: 0,
                target: 0,
            }));
        }
        let key = derive(&self.passphrase, &salt, params)?;
        // a failed open means a different passphrase
        let plain = Zeroizing::new(
            cipher(&key)?
                .decrypt(&Nonce::default(), stanza.body.as_slice())
                .ok()?,
        );
        let file_key: &[u8; 16] = plain.as_slice().try_into().ok()?;
        Some(Ok(FileKey::new(Box::new(*file_key))))
    }

    /// Tries only the first passphrase stanza of a file. Each attempt can
    /// cost up to 1 GiB and 10 passes, so a hostile packet with many of
    /// them must not get to run Argon2id more than once.
    fn unwrap_stanzas(&self, stanzas: &[Stanza]) -> Option<Result<FileKey, DecryptError>> {
        let first = stanzas.iter().find(|s| s.tag == TAG)?;
        self.unwrap_stanza(first)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn args_must_be_canonical() {
        let salt = STANDARD_NO_PAD.encode([7u8; 16]);
        let ok = [salt.clone(), "65536".into(), "3".into(), "1".into()];
        assert!(parse_args(&ok).is_some());
        for bad in ["065536", "+65536", "", "6e4"] {
            let args = [salt.clone(), bad.into(), "3".into(), "1".into()];
            assert!(parse_args(&args).is_none(), "{bad} accepted");
        }
        assert!(parse_args(&ok[..3]).is_none());
    }

    #[test]
    fn weak_params_are_refused_when_sealing() {
        let weak = KdfParams {
            m_kib: 1024,
            t: 1,
            p: 1,
        };
        assert!(
            PassphraseRecipient::with_params(SecretString::from("x".to_owned()), weak).is_err()
        );
    }
}
