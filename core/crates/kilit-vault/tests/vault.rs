//! The vault: who can unlock it, and what it can do once open.

#![allow(clippy::unwrap_used, clippy::panic)]

use kilit_klt::{KdfParams, Signature, open, seal};
use kilit_vault::{HardwareKey, SoftwareKey, Vault, VaultError};
use secrecy::SecretString;

fn pin(p: &str) -> SecretString {
    SecretString::from(p.to_owned())
}

fn device(n: u8) -> SoftwareKey {
    SoftwareKey::new([n; 32])
}

fn new_vault() -> (Vault, Vec<u8>) {
    Vault::create(&pin("482916"), &device(1), KdfParams::MINIMUM).unwrap()
}

#[test]
fn the_right_pin_on_the_right_device_unlocks_the_same_identity() {
    let (vault, sealed) = new_vault();
    let again = Vault::unlock(&sealed, &pin("482916"), &device(1)).unwrap();
    assert_eq!(
        vault.public_identity().unwrap(),
        again.public_identity().unwrap()
    );
}

#[test]
fn a_wrong_pin_stays_locked() {
    let (_, sealed) = new_vault();
    assert_eq!(
        Vault::unlock(&sealed, &pin("482917"), &device(1)).err(),
        Some(VaultError::Locked)
    );
}

#[test]
fn a_copied_vault_does_not_open_on_another_device() {
    let (_, sealed) = new_vault();
    assert_eq!(
        Vault::unlock(&sealed, &pin("482916"), &device(2)).err(),
        Some(VaultError::Locked)
    );
}

#[test]
fn a_changed_byte_keeps_it_locked() {
    let (_, sealed) = new_vault();
    for at in [sealed.len() / 2, sealed.len() - 1] {
        let mut bad = sealed.clone();
        bad[at] ^= 0x01;
        assert!(
            Vault::unlock(&bad, &pin("482916"), &device(1)).is_err(),
            "flip at {at}"
        );
    }
}

#[test]
fn short_pins_and_weak_costs_are_refused() {
    assert!(matches!(
        Vault::create(&pin("12345"), &device(1), KdfParams::MINIMUM),
        Err(VaultError::Rejected(_))
    ));
    let weak = KdfParams {
        m_kib: 8 * 1024,
        t: 1,
        p: 1,
    };
    assert!(matches!(
        Vault::create(&pin("482916"), &device(1), weak),
        Err(VaultError::Rejected(_))
    ));
}

#[test]
fn changing_the_pin_keeps_the_identity() {
    let (vault, _) = new_vault();
    let resealed = vault
        .seal(&pin("739204"), &device(1), KdfParams::MINIMUM)
        .unwrap();
    let again = Vault::unlock(&resealed, &pin("739204"), &device(1)).unwrap();
    assert_eq!(
        vault.public_identity().unwrap(),
        again.public_identity().unwrap()
    );
    assert!(Vault::unlock(&resealed, &pin("482916"), &device(1)).is_err());
}

#[test]
fn two_vaults_are_two_different_people() {
    let (a, _) = new_vault();
    let (b, _) = new_vault();
    let (pa, pb) = (a.public_identity().unwrap(), b.public_identity().unwrap());
    assert_ne!(pa, pb);
    assert_ne!(pa.fingerprint(), pb.fingerprint());
}

#[test]
fn the_fingerprint_is_twelve_groups_of_five_digits() {
    let (v, _) = new_vault();
    let fp = v.public_identity().unwrap().fingerprint();
    let groups: Vec<&str> = fp.split(' ').collect();
    assert_eq!(groups.len(), 12);
    assert!(
        groups
            .iter()
            .all(|g| g.len() == 5 && g.bytes().all(|b| b.is_ascii_digit()))
    );
}

#[test]
fn a_packet_sealed_to_the_vault_and_signed_by_it_opens_verified() {
    let (vault, _) = new_vault();
    let me = vault.klt_identity().unwrap();
    let packet = seal(
        "kasa.txt",
        "text/plain",
        5,
        &b"kasam"[..],
        &[&me.recipient()],
        Some(&vault),
        Vec::new(),
    )
    .unwrap();
    let mut out = Vec::new();
    let opened = open(packet.as_slice(), &[&me], &mut out).unwrap();
    assert_eq!(out, b"kasam");
    let keys = match opened.signature {
        Signature::Verified(k) => k,
        Signature::Unsigned => panic!("expected a signature"),
    };
    assert_eq!(
        keys.ed25519,
        vault.public_identity().unwrap().ed25519.to_vec()
    );
}

#[test]
fn the_software_key_says_it_is_not_hardware() {
    assert!(!device(1).is_hardware_backed());
}
