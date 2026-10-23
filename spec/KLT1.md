# KLT1 dosya biçimi

Sürüm 1. Durum: Aşama 1 uygulaması `core/crates/kilit-klt` içinde.

Bir `.klt` dosyası, 4 baytlık `KLT1` sihirli değeri ve ardından gelen bir
[age v1](https://age-encryption.org/v1) dosyasından oluşur. age'in başlığı,
başlık MAC'i ve ChaCha20-Poly1305 STREAM şifrelemesi (64 KiB parçalar) olduğu
gibi kullanılır. Kilit yalnızca iki alıcı türü ve şifreli içeriğin iç
düzenini ekler.

```
"KLT1"
age-encryption.org/v1
-> klt-xwing <enc>                     kişiye ya da kendi kasana
<sarmalanmış dosya anahtarı>
-> klt-argon2id <tuz> <m> <t> <p>      paylaşılan parola
<sarmalanmış dosya anahtarı>
--- <başlık MAC'i>
<STREAM: aşağıdaki iç düzen>
```

age, her başlığa rastgele adlı ve rastgele uzunlukta bir "grease" satırı
ekler. Bu yüzden dosya boyutu, aynı içerik için bile birkaç onlarca bayt
değişir; okuyucular bu satırı yok sayar.

Bütün alıcılar `postquantum` etiketini taşır. Bu yüzden klasik bir `X25519`
alıcısıyla aynı dosyada birleştirilemezler; age bunu kendisi reddeder.

## Alıcı türü `klt-xwing`

- **KEM:** X-Wing (draft-connolly-cfrg-xwing-kem-06, ML-KEM-768 ve X25519),
  HPKE kod noktası `0x647a`
- **HPKE:** RFC 9180, Base modu, HKDF-SHA256, ChaCha20-Poly1305
- **info:** `kilit/klt1/xwing`, **aad:** boş
- **Argüman:** `enc` (1120 bayt), dolgusuz standart base64
- **Gövde:** HPKE ile şifrelenmiş 16 baytlık age dosya anahtarı (32 bayt)
- **Uygulama:** hpke-rs 0.8 ve libcrux arka ucu (biçimsel olarak doğrulanmış ML-KEM)

Yanlış anahtarla açma girişimi "bu alıcı değil" sayılır. Biçimi bozuk bir
satır ise hata olarak döner.

## Alıcı türü `klt-argon2id`

- **Anahtar:** `Argon2id(parola, "kilit/klt1/argon2id" || tuz)`, 32 bayt, sürüm 0x13
- **Argümanlar:** 16 baytlık tuz (dolgusuz base64), `m` (KiB), `t`, `p` (ondalık)
- **Gövde:** `ChaCha20-Poly1305(anahtar, sıfır nonce, dosya anahtarı)`. Tuz her
  dosyada yeni üretildiği için anahtar da her seferinde benzersizdir; age'in
  scrypt alıcısı da aynı yöntemi kullanır.
- **Oluştururken:** en az 64 MiB, t ≥ 3. Varsayılan 256 MiB, t = 4, p = 1.
- **Açarken üst sınır:** 1 GiB, t ≤ 10, p ≤ 4. Bunun üstündeki dosyalar
  reddedilir, böylece bir dosya cihazı kilitleyemez.
- **Paket başına en fazla bir parola satırı:** Okuyucu yalnızca ilk
  `klt-argon2id` satırını dener. Böylece çok sayıda pahalı satır içeren kötü
  niyetli bir dosya, Argon2id'yi birden fazla kez çalıştıramaz.

## İç düzen (şifreli akışın içi)

| Alan | Boyut | İçerik |
| --- | --- | --- |
| manifest uzunluğu | 4 bayt, büyük endian | ≤ 64 KiB |
| manifest | değişken | CBOR, aşağıda |
| içerik | `manifest.size` bayt | dosyanın kendisi |
| imza uzunluğu | 4 bayt, büyük endian | 0 ise imzasız, en fazla 8 KiB |
| imza | değişken | CBOR, aşağıda |
| dolgu | değişken | sıfır baytlar |

**Manifest (CBOR haritası):** `v` = 1, `name` (en fazla 255 bayt; `/`, `\`,
denetim karakterleri, `.` ve `..` yasak), `mime` (en fazla 127 bayt),
`size` (bayt), `signer` (isteğe bağlı: `ed25519` 32 bayt, `mldsa65` 1952 bayt).

**İmza (CBOR haritası):** `ed25519` (64 bayt) ve `mldsa65` (3309 bayt).
İmzalanan mesaj:

```
"KLT1-sig-v1" || 0x00 || SHA-512(manifest baytları) || SHA-512(içerik)
```

ML-DSA bağlamı (context) `kilit/klt1` olur. İki imzanın da doğru olması
gerekir. Manifestte `signer` varsa imza zorunludur, yoksa imza boş olmalıdır.

**Dolgu:** İç düzenin toplam uzunluğu L ise, dolgu sonrası uzunluk
Padmé(L) olur. Böylece dışarıdan yalnızca boyut sınıfı görünür; ek yük en
fazla yaklaşık %12'dir. Dolgu tam olarak `Padmé(L) - L` sıfır bayt olmalıdır.
Başka bir değer çıkarsa dosya reddedilir.

## Okuma kuralı

İmza ve dolgu, içerik okunduktan sonra denetlenir. Okuyucu, `open` başarıyla
dönene kadar çıktıyı güvenilmez saymalı ve hata durumunda çıktıyı atmalıdır.
Kilit içeriği önce bellekte açar, diske yalnızca kullanıcı dışa aktarınca
yazar.

## Metin zırhı

64 KiB'a kadar olan paketler `KLT1:` önekiyle ve dolgusuz base64url
kodlamasıyla metne çevrilir. Böylece WhatsApp gibi uygulamalara
yapıştırılabilir.

## Test vektörleri

`spec/vectors/` altındaki dosyaların her Kilit sürümünde açılabilmesi gerekir.
`spec/vectors/README.md` dosyası, her vektörün anahtarını ya da parolasını ve
beklenen içeriğini listeler.
