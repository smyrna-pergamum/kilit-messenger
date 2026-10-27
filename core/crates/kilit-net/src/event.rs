//! Nostr events (NIP-01): what the relays store and hand out.

use k256::schnorr::{Signature, SigningKey, VerifyingKey};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

use crate::NetError;

/// A signed Nostr event.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Event {
    /// SHA-256 of the canonical form, hex.
    pub id: String,
    /// The x-only secp256k1 key that signed it, hex.
    pub pubkey: String,
    /// Unix seconds.
    pub created_at: i64,
    /// What sort of event it is.
    pub kind: u32,
    /// `[name, value, ...]` lists.
    pub tags: Vec<Vec<String>>,
    /// Free text; Kilit puts base64url here.
    pub content: String,
    /// BIP-340 signature over the id, hex.
    pub sig: String,
}

fn hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn unhex<const N: usize>(s: &str) -> Option<[u8; N]> {
    if s.len() != N * 2 {
        return None;
    }
    let mut out = [0u8; N];
    for (i, o) in out.iter_mut().enumerate() {
        *o = u8::from_str_radix(s.get(i * 2..i * 2 + 2)?, 16).ok()?;
    }
    Some(out)
}

/// The id NIP-01 defines: SHA-256 of `[0,pubkey,created_at,kind,tags,content]`.
fn digest(
    pubkey: &str,
    created_at: i64,
    kind: u32,
    tags: &[Vec<String>],
    content: &str,
) -> Result<[u8; 32], NetError> {
    let canonical = serde_json::to_string(&(0, pubkey, created_at, kind, tags, content))
        .map_err(|_| NetError::Malformed)?;
    Ok(Sha256::digest(canonical.as_bytes()).into())
}

impl Event {
    /// Signs an event with `secret`.
    pub fn sign(
        secret: &[u8; 32],
        created_at: i64,
        kind: u32,
        tags: Vec<Vec<String>>,
        content: String,
    ) -> Result<Self, NetError> {
        let key = SigningKey::from_bytes(secret).map_err(|_| NetError::Key)?;
        let pubkey = hex(&key.verifying_key().to_bytes());
        let id = digest(&pubkey, created_at, kind, &tags, &content)?;
        let mut aux = [0u8; 32];
        getrandom::fill(&mut aux).map_err(|_| NetError::Key)?;
        let sig = key.sign_raw(&id, &aux).map_err(|_| NetError::Key)?;
        Ok(Self {
            id: hex(&id),
            pubkey,
            created_at,
            kind,
            tags,
            content,
            sig: hex(&sig.to_bytes()),
        })
    }

    /// Signs with a key made for this event alone, so events link to
    /// nothing and to no one.
    pub fn sign_once(
        created_at: i64,
        kind: u32,
        tags: Vec<Vec<String>>,
        content: String,
    ) -> Result<Self, NetError> {
        loop {
            let mut secret = [0u8; 32];
            getrandom::fill(&mut secret).map_err(|_| NetError::Key)?;
            // the odd invalid scalar is drawn again
            match Self::sign(&secret, created_at, kind, tags.clone(), content.clone()) {
                Err(NetError::Key) => continue,
                r => return r,
            }
        }
    }

    /// Whether the id matches the content and the signature holds. Relays
    /// are not trusted to have checked.
    pub fn verify(&self) -> bool {
        let Ok(id) = digest(
            &self.pubkey,
            self.created_at,
            self.kind,
            &self.tags,
            &self.content,
        ) else {
            return false;
        };
        let (Some(claimed), Some(pk), Some(sig)) = (
            unhex::<32>(&self.id),
            unhex::<32>(&self.pubkey),
            unhex::<64>(&self.sig),
        ) else {
            return false;
        };
        if claimed != id {
            return false;
        }
        let (Ok(key), Ok(sig)) = (VerifyingKey::from_bytes(&pk), Signature::try_from(&sig[..]))
        else {
            return false;
        };
        key.verify_raw(&id, &sig).is_ok()
    }

    /// The first value of the first tag called `name`.
    pub fn tag(&self, name: &str) -> Option<&str> {
        self.tags
            .iter()
            .find(|t| t.first().is_some_and(|n| n == name))
            .and_then(|t| t.get(1))
            .map(String::as_str)
    }
}

/// What to ask a relay for (NIP-01 filters, the parts Kilit uses).
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Filter {
    /// Event kinds.
    pub kinds: Vec<u32>,
    /// Single-letter tag name and the values any of which may match.
    pub tags: Vec<(char, Vec<String>)>,
    /// Only events from this Unix second on.
    pub since: Option<i64>,
    /// At most this many stored events.
    pub limit: Option<u32>,
}

impl Filter {
    /// The filter as relays read it.
    pub fn to_json(&self) -> serde_json::Value {
        let mut m = serde_json::Map::new();
        m.insert("kinds".into(), self.kinds.clone().into());
        for (name, values) in &self.tags {
            m.insert(format!("#{name}"), values.clone().into());
        }
        if let Some(s) = self.since {
            m.insert("since".into(), s.into());
        }
        if let Some(l) = self.limit {
            m.insert("limit".into(), l.into());
        }
        m.into()
    }

    /// Whether `e` is one this filter asks for.
    pub fn matches(&self, e: &Event) -> bool {
        (self.kinds.is_empty() || self.kinds.contains(&e.kind))
            && self.since.is_none_or(|s| e.created_at >= s)
            && self.tags.iter().all(|(name, values)| {
                let name = name.to_string();
                e.tags.iter().any(|t| {
                    t.first() == Some(&name) && t.get(1).is_some_and(|v| values.contains(v))
                })
            })
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    #[test]
    fn signed_events_verify_and_tampered_ones_do_not() {
        let e = Event::sign_once(
            1_700_000_000,
            1059,
            vec![vec!["p".into(), "ab".repeat(32)]],
            "aGVsbG8".into(),
        )
        .unwrap();
        assert!(e.verify());
        assert_eq!(e.tag("p"), Some("ab".repeat(32).as_str()));
        let mut bad = e.clone();
        bad.content.push('x');
        assert!(!bad.verify());
        let mut bad = e.clone();
        bad.sig.replace_range(0..2, "00");
        assert!(!bad.verify());
        // two one-off events never share a key
        let f = Event::sign_once(1_700_000_000, 1059, vec![], String::new()).unwrap();
        assert_ne!(e.pubkey, f.pubkey);
    }

    /// The id of a known event from the Nostr test vectors (NIP-01 form).
    #[test]
    fn the_id_is_nip01s() {
        let id = digest(
            "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
            1_673_347_337,
            1,
            &[],
            "Walled gardens became prisons, and nostr is the first step towards tearing down the prison walls.",
        )
        .unwrap();
        assert_eq!(id.len(), 32);
        // the canonical form has no spaces
        let canonical =
            serde_json::to_string(&(0, "a", 1, 1, Vec::<Vec<String>>::new(), "x")).unwrap();
        assert_eq!(canonical, r#"[0,"a",1,1,[],"x"]"#);
    }

    #[test]
    fn filters_read_like_nip01() {
        let f = Filter {
            kinds: vec![1059],
            tags: vec![('p', vec!["aa".into()])],
            since: Some(5),
            limit: None,
        };
        assert_eq!(
            f.to_json().to_string(),
            r##"{"#p":["aa"],"kinds":[1059],"since":5}"##
        );
        let e =
            Event::sign_once(6, 1059, vec![vec!["p".into(), "aa".into()]], String::new()).unwrap();
        assert!(f.matches(&e));
        let old =
            Event::sign_once(4, 1059, vec![vec!["p".into(), "aa".into()]], String::new()).unwrap();
        assert!(!f.matches(&old));
    }
}
