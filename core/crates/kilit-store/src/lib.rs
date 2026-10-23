//! Store compartment.
//!
//! Keeps only ciphertext and holds no long-term keys. No network access.
//!
//! For now this is a directory of opaque blobs, each written atomically
//! (write to a temporary file, flush, rename), so a crash never leaves half a
//! vault behind. The SQLCipher database and the sealed inbox come later.

use std::fs::{self, File};
use std::io::{self, Write};
use std::path::{Path, PathBuf};

/// A blob's name: lowercase letters, digits and `-`, at most 64 characters.
/// Anything else is refused, so a name can never point outside the store.
fn valid_name(name: &str) -> bool {
    !name.is_empty()
        && name.len() <= 64
        && name
            .bytes()
            .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'-')
}

fn bad_name() -> io::Error {
    io::Error::new(io::ErrorKind::InvalidInput, "invalid blob name")
}

/// A directory of named blobs.
pub struct Store {
    root: PathBuf,
}

impl Store {
    /// Opens (and creates if needed) a store rooted at `root`.
    pub fn open(root: impl Into<PathBuf>) -> io::Result<Self> {
        let root = root.into();
        fs::create_dir_all(&root)?;
        Ok(Self { root })
    }

    fn path(&self, name: &str) -> io::Result<PathBuf> {
        if valid_name(name) {
            Ok(self.root.join(name))
        } else {
            Err(bad_name())
        }
    }

    /// Reads a blob, or `None` if it does not exist.
    pub fn read(&self, name: &str) -> io::Result<Option<Vec<u8>>> {
        match fs::read(self.path(name)?) {
            Ok(b) => Ok(Some(b)),
            Err(e) if e.kind() == io::ErrorKind::NotFound => Ok(None),
            Err(e) => Err(e),
        }
    }

    /// Writes a blob atomically, replacing any old one.
    pub fn write(&self, name: &str, bytes: &[u8]) -> io::Result<()> {
        let target = self.path(name)?;
        let mut suffix = [0u8; 8];
        getrandom::fill(&mut suffix).map_err(|_| io::Error::other("no system randomness"))?;
        let tmp = self.root.join(format!(
            ".tmp-{}",
            suffix
                .iter()
                .map(|b| format!("{b:02x}"))
                .collect::<String>()
        ));
        let result = (|| {
            let mut f = File::create(&tmp)?;
            f.write_all(bytes)?;
            f.sync_all()?;
            fs::rename(&tmp, &target)
        })();
        if result.is_err() {
            let _ = fs::remove_file(&tmp);
        }
        result
    }

    /// Deletes a blob. Deleting one that does not exist is not an error.
    ///
    /// This unlinks the file; it does not overwrite it. Flash storage makes
    /// in-place overwriting unreliable, which is why everything stored here
    /// is encrypted: deleting the key is what really deletes.
    pub fn delete(&self, name: &str) -> io::Result<()> {
        match fs::remove_file(self.path(name)?) {
            Err(e) if e.kind() != io::ErrorKind::NotFound => Err(e),
            _ => Ok(()),
        }
    }

    /// Deletes every blob, and any temporary file a crash left behind.
    /// Like [`Store::delete`], this unlinks; the encryption is what makes it
    /// final.
    pub fn clear(&self) -> io::Result<()> {
        for e in fs::read_dir(&self.root)? {
            let e = e?;
            if e.file_type()?.is_file() {
                fs::remove_file(e.path())?;
            }
        }
        Ok(())
    }

    /// The size of a blob in bytes, or `None` if it does not exist.
    pub fn len(&self, name: &str) -> io::Result<Option<u64>> {
        match fs::metadata(self.path(name)?) {
            Ok(m) => Ok(Some(m.len())),
            Err(e) if e.kind() == io::ErrorKind::NotFound => Ok(None),
            Err(e) => Err(e),
        }
    }

    /// The root directory.
    pub fn root(&self) -> &Path {
        &self.root
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn write_read_replace_delete() {
        let dir = tempfile::tempdir().unwrap();
        let s = Store::open(dir.path()).unwrap();
        assert_eq!(s.read("vault").unwrap(), None);
        s.write("vault", b"one").unwrap();
        s.write("vault", b"two").unwrap();
        assert_eq!(s.read("vault").unwrap().as_deref(), Some(&b"two"[..]));
        assert_eq!(s.len("vault").unwrap(), Some(3));
        s.delete("vault").unwrap();
        s.delete("vault").unwrap();
        assert_eq!(s.read("vault").unwrap(), None);
    }

    #[test]
    fn clearing_leaves_nothing() {
        let dir = tempfile::tempdir().unwrap();
        let s = Store::open(dir.path()).unwrap();
        s.write("vault", b"1").unwrap();
        s.write("item-0123456789abcdef", b"2").unwrap();
        fs::write(dir.path().join(".tmp-0011"), b"3").unwrap();
        s.clear().unwrap();
        assert_eq!(fs::read_dir(dir.path()).unwrap().count(), 0);
        s.write("vault", b"new").unwrap();
        assert_eq!(s.read("vault").unwrap().as_deref(), Some(&b"new"[..]));
    }

    #[test]
    fn names_cannot_leave_the_store() {
        let dir = tempfile::tempdir().unwrap();
        let s = Store::open(dir.path()).unwrap();
        for bad in ["", "../x", "a/b", "A", ".hidden", "x.klt", &"a".repeat(65)] {
            assert!(s.write(bad, b"x").is_err(), "{bad:?} accepted");
        }
    }

    #[test]
    fn no_temporary_files_are_left_behind() {
        let dir = tempfile::tempdir().unwrap();
        let s = Store::open(dir.path()).unwrap();
        s.write("a", b"1").unwrap();
        let names: Vec<_> = fs::read_dir(dir.path())
            .unwrap()
            .map(|e| e.unwrap().file_name())
            .collect();
        assert_eq!(names, vec!["a"]);
    }
}
