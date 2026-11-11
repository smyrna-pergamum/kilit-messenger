# Kilit: bağlı cihazlar

Durum: 0.1.4 ile uygulandı ve bir telefon ile bir Windows bilgisayarda denendi. Bu belge, bir bilgisayarın (Windows) ya da
ikinci bir telefonun aynı Kilit kimliğine **ayrı bir cihaz** olarak
katılmasını tanımlar. Bağlanmayan bir bilgisayar, telefondaki gibi kendi
kimliğiyle bağımsız çalışır; bunun için protokolde değişiklik gerekmez.

Model Signal'in bağlı cihazlarına benzer: bir hesabın tek bir kimlik anahtarı
vardır, ama her cihazın kendi ön anahtarları (prekey) ve kendi oturumları
vardır. Bir cihaz kapalıyken diğerleri çalışmaya devam eder.

## Kavramlar

- **Kimlik:** Hesabın Signal kimlik anahtarı. Adres (`hex(SHA-256(kimlik)[..16])`)
  ve dört kelime ondan türer. Bağlanan cihaz bu anahtarın bir kopyasını alır;
  bu yüzden adres ve kelimeler her cihazda aynıdır.
- **Cihaz numarası:** Telefon (kimliği ilk oluşturan) 1'dir. Bağlanan her
  cihaz bir sonraki boş numarayı alır (2, 3, …), en fazla 5 cihaz.
- **Birincil cihaz:** Kimliği oluşturan telefon. Kartı yayımlar, cihaz
  listesini tutar, cihaz ekler ve çıkarır.

## Kart

Kart, cihaz başına bir paket taşır:

| Alan | Değer |
| --- | --- |
| `devices` | Her cihaz için: numara, kayıt numarası, imzalı ön anahtar ve imzası, Kyber ön anahtarı ve imzası |
| `devices_version` | Liste her değiştiğinde artan sayı |

Eski tek paketli alanlar 1 numaralı cihazın paketi olarak kalır, böylece eski
sürümler en azından telefona yazmayı sürdürür. Ön anahtar imzaları ortak
kimlik anahtarıyla atılır; bir paketi kimliğin sahibi olmayan biri
ekleyemez.

## Posta kutuları

Bir cihaza giden mesaj, alıcı cihazın numarasıyla ayrılmış bir posta kutusuna
bırakılır:

    HMAC(X25519(ben, o), "kilit/v1/mailbox\0" ‖ alıcı adres ‖ cihaz(1 bayt) ‖ gün)

1 numaralı cihaz için cihaz baytı eklenmez; bugünkü etiketler aynen kalır.
Her cihaz yalnızca kendi posta kutularını izler ve başka cihazın kopyasını
hiç indirmez.

## Gönderme

- **Bir kişiye:** Mesaj, kişinin her cihazına, o cihazla olan oturum
  üzerinden ayrı ayrı mühürlenir. Tüm kopyalar aynı 16 baytlık mesaj
  kimliğini taşır.
- **Kendi diğer cihazlarına:** Gönderen, aynı mesajı bir "gönderildi kaydı"
  olarak kendi diğer cihazlarına da gönderir: kime gittiği, metin, dosya
  bilgisi, çıkartma ve zaman. Böylece telefondan yazılan bilgisayarda,
  bilgisayardan yazılan telefonda görünür.
- **Gruplar:** Her üyenin her cihazına, artı kendi diğer cihazlarına.
- **Teslim:** Kişinin herhangi bir cihazından alındı bildirimi gelirse satır
  "teslim edildi" olur. Yeniden gönderme, hiç bildirim gelmeyen cihazlara
  yapılır.

## Bağlama (provisioning)

1. **Bilgisayar** "Telefonuma bağla"yı seçer. Tek kullanımlık bir X-Wing
   anahtar çifti ve rastgele bir etiket üretir. Açık anahtarı relay'lere
   `SHA-256("kilit/v1/link-key\0" ‖ etiket)` etiketiyle bırakır ve ekranda
   yalnızca anahtarın özetini gösterir, böylece QR küçük ve kolay okunur
   (0.1.7'den beri; 0.1.6 ve öncesi anahtarın tamamını `k=` ile koyuyordu):
   `kilit://link?h=<SHA-256("kilit/v1/link-key-hash\0" ‖ anahtar)>&t=<etiket>`.
2. **Telefon**, Ayarlar → Bağlı cihazlar → Cihaz bağla'dan QR'ı okur. Anahtarı
   relay'lerden alır ve QR'daki özetle karşılaştırır; tutmayan anahtar
   başkasınındır ve yok sayılır. Bu adım güvenliği değiştirmez: QR'ı gören
   anahtarın kendisini değil, yalnızca özetini görür.
3. Telefon bir **bağlama paketi** hazırlar: kimlik anahtar çifti, kart
   anahtarı, kimlik tuzu, atanan cihaz numarası, kişiler (kimlikleri ve cihaz
   listeleriyle), gruplar ve 32 baytlık tek kullanımlık bir yanıt anahtarı. Paket,
   QR'daki X-Wing anahtarına KLT1 ile mühürlenir ve Tor üzerinden relay'lere,
   `SHA-256("kilit/v1/link-package\0" ‖ etiket)` etiketiyle bırakılır.
   Relay'ler `p` etiketi 64 onaltılık hane olmayan olayları saklamaz;
   0.1.8'e kadar paket 32 haneli QR etiketiyle gönderildiği için hiçbir
   relay onu almıyordu (0.1.9'da düzeltildi).
4. Bilgisayar paketi alır ve açar. Kendi ön anahtarlarını üretir, cihaz
   paketini yanıt anahtarıyla şifreleyip telefona geri gönderir.
5. Telefon cihazı listeye ekler, kartı yeniden yayımlar ve her kişiye kısa
   bir "cihaz listem değişti" iletisi gönderir. Kişinin uygulaması kartı
   yeniden alır.
6. İki ekranda da paylaşılan sırdan türeyen 6 haneli bir kod görünür. Kodlar
   uyuşmazsa kullanıcı bağlamayı iptal eder.

Mesaj geçmişi bağlama paketine girmez; bilgisayar bağlandığı andan sonrasını
görür. Bu bilinçli bir tercihtir: geçmişi bir cihazdan ötekine taşımak, en
hassas veriyi bir kez daha yola çıkarmak olur.


### Kilit ID ile bağlama (0.1.8)

Kamera ya da kare kod gerekmeden:

1. **Telefon** Ayarlar → Bağlı cihazlar → "Kilit ID ile bilgisayar bağla"yı
   açar. Telefon 15 dakika boyunca `SHA-256("kilit/v1/link-request\0" ‖
   adres)` etiketini dinler ve kendi Kilit ID'sini gösterir. Dinlemiyorken
   gelen istekler hiç gösterilmez.
2. **Bilgisayar** "Telefonuma bağla" → "Kilit ID ile"yi seçip telefonun
   ID'sini yazar. Kartı relay'lerden bulur, kartın kimliğini ID'yle
   doğrular, tek kullanımlık X-Wing anahtarı ve etiket üretir. İsteği
   (anahtar + etiket; gizli bir şey yok) telefonun istek etiketine bırakır.
   Aynı anahtarı kısa kare kod için anahtar etiketine de koyar.
3. İki ekran da anahtarın özetinden türeyen aynı 6 haneli kodu gösterir.
   Telefon, kodu bilgisayardakiyle aynı olan isteği onaylar ya da
   bilgisayardaki küçük kare kodu okutur (okutmak onaydır). Başkasının
   gönderdiği istek farklı kod gösterir.
4. Telefon paketi o anahtara mühürler (`by_request` işaretiyle); bilgisayar
   paketi yalnızca yazdığı Kilit ID'ye aitse kabul eder. Kalan adımlar
   yukarıdakiyle aynıdır.

## Cihaz çıkarma

Telefon bir cihazı listeden çıkarır, kartı yeniden yayımlar ve kişilere
haber verir. Silmeden önce, o cihazla olan oturumu son bir kez kullanarak
cihaza yeni kartı gönderir. Cihaz, kendisini listelemeyen ve
`devices_version`'ı kendi bildiğinden büyük olan bu kartı görünce bir sonraki
turda kimlikten çıkar. Bu ileti 0.1.9'a kadar gönderilmiyordu; o zamana dek
çıkarılan cihaz durumu hiç öğrenmiyordu.

Bağlı cihaz kendisi de çıkabilir (Ayarlar → Bağlı cihazlar → "Bu Kilit ID'den
çık"). Telefona `sync_to = "leave"` olan bir kopya gönderir. Telefon bunu
bir sonraki turda işler: cihazı listeden siler, kartı yeniden yayımlar ve
kişilere haber verir.

Çıkan cihazda şunlar silinir: sohbetler ve ekleri, gruplar, kişiler, Signal
durumu, giden kutusu ve bağlama kaydı. Kasadaki dosyalar ve notlar kalır.
Cihaz bir sonraki kullanımda yeni bir Kilit ID ile yeni bir Kilit olur ve
yeniden bağlanabilir. Kimlik anahtarı o
cihazda bir kez bulunduğu için, kaybolan ya da çalınan bir cihaz için tek
güvenli yol kimliği yenilemektir. Bu, yeni kelimeler ve kişilerin yeniden
eklenmesi demektir.

## Sınırlar

- Kimlik anahtarı birden çok cihazda bulunur. Bir cihazın ele geçirilmesi
  kimliğin ele geçirilmesidir.
- Kişinin uygulaması yeni cihazı ancak kartı yeniden aldığında öğrenir. O
  zamana kadar yalnızca telefona yazar.
- Eski sürümler yalnızca 1 numaralı cihaza yazar.

## Aşamalar

1. **Windows uygulaması, bağımsız:** Windows'ta derleme; `tor.exe` (Tor
   Expert Bundle) ayrı süreç olarak, obfs4 ve Snowflake taşıyıcılarıyla;
   PIN'in TPM'e bağlanması.
2. **Çekirdekte cihazlar:** Cihaz numaralı oturumlar, kartta cihaz listesi,
   cihaza özel posta kutuları, kişinin cihazlarına ve kendi cihazlarına
   gönderme. Testler: üç kasa ve iki cihazlı bir hesap.
3. **Bağlama:** QR, bağlama paketi, onay kodu; telefonda "Bağlı cihazlar",
   bilgisayarda "Telefonuma bağla".
4. **Senkron:** Gönderildi kayıtları, kişi ve grup değişiklikleri, okundu
   bilgisi.
