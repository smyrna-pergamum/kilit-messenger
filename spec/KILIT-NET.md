# Kilit ağı: kimlik, kart, posta kutusu

Mesajlar her zaman Tor üzerinden, açık Nostr relay'lerine (`docs/RELAYS.md`)
gider. İçerik libsignal ile uçtan uca şifrelidir (PQXDH + SPQR). Bu belge
relay'lerin gördüğü biçimi anlatır. Kod: `core/crates/kilit-vault/src/messaging.rs`
(kimlik, kart, zarf), `core/crates/kilit-net` (relay istemcisi),
`core/crates/kilit-ffi/src/engine/chats.rs` (çıkış kutusu, gelen kutusu).

## Kimlik

- Signal kimlik anahtarı kasanın ana sırrından türetilir:
  HKDF-SHA256(ana sır, `kilit/v1/signal-identity`).
- **Adres:** SHA-256(kimlik anahtarı) değerinin ilk 16 baytı, onaltılık
  (32 karakter).
- **Kilit kimliği:** Argon2id(kimlik anahtarı, kimlik tuzu; 8 MiB, 2 tur)
  değerinin ilk 44 bitinden dört BIP-39 kelimesi, örneğin
  `@elma-nehir-taş-bulut` biçiminde, BIP-39 İngilizce listesiyle. Hesap ya da
  sunucu yoktur; kimse kimliğini seçmez ya da kaydettirmez. Tuz kasanındır ve
  kartta yazar. Argon2id, başkasının kimliğine uyan bir anahtar aramayı her
  denemede pahalı kılar.
- **Kimliği yenilemek:** Yeni tuz, yeni ilk temas etiketi. Kimlik anahtarı ve
  oturumlar aynı kalır; kişiler yazışmaya devam eder. Eski kimliğin kartı,
  aynı `d` etiketiyle boş içerikli bir olayla relay'lerde değiştirilir. Eski
  ilk temas etiketi yolda olan mesajlar için bir hafta daha izlenir.
- **Davet bağlantısı:** `kilit://add?id=<dört kelime>&a=<adres>`. QR kod bu
  bağlantıyı taşır. Elle yazılan `@dört-kelime` adresi taşımaz; o zaman kart
  yalnızca kelimelere göre doğrulanır.

## Kart

Her kasa kartını relay'lere yayınlar:

| Alan | Değer |
| --- | --- |
| kind | 30078 (NIP-78, `d` etiketi başına değiştirilebilir) |
| tags | `["d", "kilit:<dört kelime>"]` |
| content | base64url(CBOR kart) |
| imza | Kasadan türetilen secp256k1 anahtarı (`kilit/v1/nostr-card`) |

Kart içeriği: imzalı önanahtar, son çare Kyber-1024 önanahtarı (ikisi de
kimlik anahtarıyla imzalı), kimlik anahtarı, kayıt numarası, ilk temas
etiketi ve kimlik tuzu. Gizli hiçbir şey içermez.

Kartı alan, kartın kimlik anahtarının kelimelere (ve varsa adrese) uyduğunu
denetler. Aynı `d` etiketiyle yayınlanan başka kartlar yok sayılır. Uyanların
en yenisi kullanılır.

## Posta kutuları

- **İlk temas etiketi:** HMAC-SHA256(HKDF(ana sır, `kilit/v1/first-contact`),
  `kilit/v1/fc\0` ‖ sayaç). Karttadır. Henüz tanınmayan biri ilk mesajını
  buraya yazar.
- **Ortak posta kutusu:** HMAC-SHA256(X25519(benim kimliğim, onun kimliği),
  `kilit/v1/mailbox\0` ‖ alıcının adresi ‖ gün). Gün, UTC ile Unix gün
  numarasıdır. İkisi dışında kimse hesaplayamaz. Etiket her gün değişir; alıcı,
  saat farklarına karşı dün, bugün ve yarının etiketlerini izler.
- Karşı taraftan bir mesaj gelene kadar mesajlar ilk temas etiketine, sonra
  ortak posta kutusuna gider.

## Mesaj olayı

| Alan | Değer |
| --- | --- |
| kind | 1059 |
| tags | `["p", "<posta kutusu etiketi>"]` |
| content | base64url(zarf) |
| imza | Her olay için yeni, tek kullanımlık bir anahtar |

**Zarf:** `sürüm(1) | bayrak | [nonce(8)] | Signal türü | Signal mesajı`.
Bayrağın 1. biti iş kanıtıdır: SHA-256(`kilit/v1/pow\0` ‖ iç kısım ‖ nonce)
en az 20 sıfır bitle başlamalıdır. Tanınmayan birinin ilk mesajı iş kanıtı
taşımazsa sessizce düşürülür. Bekleyen istek sayısı da sınırlıdır.

Düz metin 256 baytın katlarına doldurulur. Mesaj gövdesi (CBOR): kimlik,
metin, gönderilme zamanı, gönderenin kimlik tuzu, alındı bildirimleri, süre ve
dosya bilgisi.

## Alındı bildirimi (çift tik)

Kabul edilmiş bir kişiden gelen her mesaj, yalnızca o mesajların
kimliklerini taşıyan bir mesajla yanıtlanır. Gönderende satır "teslim edildi"
olur. İstekler kabul edilene kadar yanıtlanmaz; böylece tanımayan biri,
mesajının okunup okunmadığını öğrenemez. Kabul edilince bildirim gider.

## Süreli mesajlar

Sohbetin süresi her mesajla birlikte gider; alan taraf aynı süreyi sohbete
uygular. Süresi dolan satır, dosyasıyla birlikte kasadan silinir.

## Dosyalar

- Dosya kendi anahtarıyla (XChaCha20-Poly1305, rastgele 32 bayt) 24 KiB'lik
  parçalara bölünerek şifrelenir. i. parçanın nonce'u i'dir, ek veri olarak
  etiket kullanılır. Her parça ayrı bir olaydır: `["p", <rastgele etiket>]`,
  içerik `base64url(i ‖ şifreli parça)`. En fazla 5 MiB.
- Dosyayı adlandıran mesaj anahtarı, etiketi, parça sayısını, boyutu,
  SHA-256 özetini, adı ve türü taşır.
- Alıcı etiketi parçalar tamamlanana kadar izler, sonra özeti denetler.
  Uymayan dosya saklanmaz. Resimlerin üst verisi gönderilmeden önce silinir.
- Kamera fotoğrafları önizleme akışından bellekte alınır. YUV kare Rust'ta
  JPEG'e çevrilir ve diske hiçbir şey yazılmaz.

## Relay'in gördükleri

- Tek kullanımlık anahtarlar, her gün değişen rastgele görünen bir etiket, şifreli
  bir içerik ve zaman.
- Bir kasanın kartı ve kelimeleri (kart herkese açıktır).
- Bir posta kutusuna ne zaman kaç mesaj geldiği, ama yalnızca o gün için.

Bağlantılar Tor üzerinden kurulur. Her relay bağlantısı kendi SOCKS kimlik
bilgileriyle açılır, böylece ayrı bir Tor devresi kullanır.

## Henüz yok

- Teslim edilmeyen mesajın 48 saat sonra yeniden yayını.
- Doğrudan onion bağlantısı.
- Video.
