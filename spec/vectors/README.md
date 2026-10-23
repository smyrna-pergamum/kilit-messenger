# KLT1 test vektörleri

Bu dosyalar her Kilit sürümünde açılabilmelidir. `core/crates/kilit-klt/tests/vectors.rs`
bunu denetler. Yalnızca biçim sürümü değişirse yeniden üretilirler:

    KILIT_WRITE_VECTORS=1 cargo test -p kilit-klt --test vectors the_signed

Anahtarlar ve parola herkese açıktır; yalnızca test içindir.

| Dosya | Açan | İmza | İçerik |
| --- | --- | --- | --- |
| `xwing-signed-v1.klt` | X-Wing, tohum 32 × `0x42` | Ed25519 ve ML-DSA-65, tohum 32 × `0x07` | `Kilit KLT1 test vektörü.\n` |
| `passphrase-v1.klt` | Parola `kilit test vektörü bir`, Argon2id 64 MiB, t=3, p=1 | Yok | aynı |

Dosya adı her ikisinde de `vektor.txt`, MIME türü `text/plain`.
