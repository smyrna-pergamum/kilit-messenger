# KLT1 test vectors

Every Kilit release must be able to open these files.
`core/crates/kilit-klt/tests/vectors.rs` checks that. They are made again
only when the format version changes:

```bash
KILIT_WRITE_VECTORS=1 cargo test -p kilit-klt --test vectors the_signed
```

The keys and the passphrase are public, for testing only. The Turkish text
below is the vectors' actual content and must stay exactly as it is.

| File | Opened by | Signature | Content |
| --- | --- | --- | --- |
| `xwing-signed-v1.klt` | X-Wing, seed 32 × `0x42` | Ed25519 and ML-DSA-65, seed 32 × `0x07` | `Kilit KLT1 test vektörü.\n` |
| `passphrase-v1.klt` | Passphrase `kilit test vektörü bir`, Argon2id 64 MiB, t=3, p=1 | None | the same |

In both, the file name is `vektor.txt` and the MIME type is `text/plain`.
