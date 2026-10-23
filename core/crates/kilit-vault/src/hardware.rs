//! The device-bound key that MACs the PIN before Argon2id.

use hmac::{Hmac, KeyInit, Mac};
use sha2::Sha256;
use zeroize::Zeroizing;

use crate::VaultError;

/// A keyed MAC whose key stays inside secure hardware.
///
/// Android implements it with an HMAC key in StrongBox (or the TEE) created
/// with `setUserAuthenticationRequired` off and `setUnlockedDeviceRequired`
/// on; Windows with a TPM 2.0 HMAC key through the Platform Crypto Provider.
pub trait HardwareKey {
    /// HMAC-SHA256 of `data` under the device key.
    fn mac(&self, data: &[u8]) -> Result<[u8; 32], VaultError>;
    /// Whether the key really lives in hardware. The UI warns when not.
    fn is_hardware_backed(&self) -> bool;
}

/// An in-memory stand-in for tests, and for development builds on machines
/// without a TPM. It gives none of the protection of a real hardware key.
pub struct SoftwareKey(Zeroizing<[u8; 32]>);

impl SoftwareKey {
    /// A software key from fixed bytes.
    pub fn new(key: [u8; 32]) -> Self {
        Self(Zeroizing::new(key))
    }
}

impl HardwareKey for SoftwareKey {
    fn mac(&self, data: &[u8]) -> Result<[u8; 32], VaultError> {
        let mut m = <Hmac<Sha256> as KeyInit>::new_from_slice(self.0.as_ref())
            .map_err(|_| VaultError::Crypto)?;
        m.update(data);
        Ok(m.finalize().into_bytes().into())
    }

    fn is_hardware_backed(&self) -> bool {
        false
    }
}
