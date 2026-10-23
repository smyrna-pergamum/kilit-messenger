# KLT1 dosya biçimi (taslak)

Durum: taslak, Aşama 1'de kesinleşecek. Test vektörleri `spec/vectors/` altına gelecek.

## Yapı

```
"KLT1"                       4 bayt sihirli değer
age-encryption.org/v1        age v1 başlığı
-> mlkem768x25519 ...        alıcı satırı: kişiye ya da kendi kasana
-> klt-argon2id ...          alıcı satırı: paylaşılan parola (isteğe bağlı)
--- <başlık MAC'i>
[ChaCha20-Poly1305 STREAM, 64 KiB parçalar]
   manifest (CBOR): dosya adı, MIME türü, boyut, oluşturanın imzası
   içerik
   dolgu: bir üst boyut sınıfına kadar
```

## Alıcı türleri

| Tür | Anahtar | Not |
| --- | --- | --- |
| `mlkem768x25519` | Kişinin ya da kasanın hibrit anahtarı | age v1.3 ile aynı |
| `klt-argon2id` | Argon2id(parola, tuz), 256 MiB, t=4 | Kilit'e özgü |

## İmza

Manifest, oluşturan kişinin Ed25519 ve ML-DSA-65 anahtarlarıyla imzalanır.
İki imzanın da doğrulanması gerekir.

## Metin zırhı

Kısa paketler `KLT1:` önekiyle ve base64url kodlamasıyla metne çevrilir.
