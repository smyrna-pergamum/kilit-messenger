# Kilit: bağlı cihazlar (tasarım taslağı)

Durum: taslak, henüz uygulanmadı. Bu belge, bir bilgisayarın (Windows) ya da
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
   anahtar çifti ve rastgele bir etiket üretir, ekranda QR olarak gösterir:
   `kilit://link?k=<X-Wing açık anahtarı>&t=<etiket>`.
2. **Telefon**, Ayarlar → Bağlı cihazlar → Cihaz bağla'dan QR'ı okur. Kullanıcı
   PIN'iyle onaylar.
3. Telefon bir **bağlama paketi** hazırlar: kimlik anahtar çifti, kart
   anahtarı, kimlik tuzu, atanan cihaz numarası, kişiler (kimlikleri ve cihaz
   listeleriyle), gruplar ve 32 baytlık tek kullanımlık bir yanıt anahtarı. Paket,
   QR'daki X-Wing anahtarına KLT1 ile mühürlenir ve Tor üzerinden relay'lere,
   QR'daki etiketle bırakılır.
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

## Cihaz çıkarma

Telefon bir cihazı listeden çıkarır, kartı yeniden yayımlar ve kişilere
haber verir. Çıkarılan cihaza "kendini sil" iletisi gider. Kimlik anahtarı o
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
