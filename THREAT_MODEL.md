# Tehdit modeli

Taslak. Her aşamada güncellenecek.

## Korur

- **Ağ gözlemcileri:** Trafik Tor üzerinden gider. İnternet sağlayıcısı kiminle konuştuğunuzu görmez.
- **Relay'ler:** Mesajlar Signal (PQXDH ve Triple Ratchet) ve NIP-44/59 ile çift şifrelidir. Relay içeriği okuyamaz.
- **Gelecekteki kuantum bilgisayarlar:** Anahtar alışverişleri hibrittir (X25519 ve ML-KEM).
- **Bozuk ya da kötü amaçlı dosyalar:** Dosyalar, her işten sonra yok edilen tek kullanımlık bir bölmede açılır.
- **Kopyalanan kasa dosyaları:** PIN, cihazın donanım anahtarıyla (Android'de StrongBox ya da TEE, Windows'ta TPM 2.0) MAC'lenir, ardından Argon2id'den geçer. Donanım anahtarı dışarı çıkarılamaz. Bu yüzden uygulama klasörünün bir kopyası başka bir cihazda denenemez.

## Korumaz

- **Açık relay'lerdeki meta veri:** Bir posta kutusu adresini bilen kişi, o adrese gelen mesajların zamanını ve sayısını görebilir. Adresler 24 saatte bir değişir, ama bir gün içindeki trafik görünür.
- **Cihazın kendisinde PIN denemek:** Donanım anahtarının bir deneme sınırı yoktur. Uygulamanın deneme sayacı ise diskte durur. Telefonda root yetkisi elde eden biri, donanım anahtarını kendisi çağırıp PIN'leri tek tek deneyebilir. Argon2id her denemeyi yavaşlatır (telefonda 64 MiB ile yaklaşık 0,3 saniye), ama 6 haneli bir PIN yine de birkaç gün içinde bulunabilir. Bu tehdide karşı daha uzun bir PIN kullanın. Windows'ta TPM'in kendi kilitleme mekanizması bilerek kullanılmadı, çünkü bu mekanizma Windows Hello ile ortaktır ve kullanıcıyı Windows'un dışında bırakabilir.
- **Donanım anahtarının kaybı:** Uygulama verileri silinirse ya da cihaz sıfırlanırsa donanım anahtarı da gider ve kasa bir daha açılamaz. Bu bilinçli bir tercih; şifreli yedekleme sonraki bir aşamada gelecek.
- **Ele geçirilmiş bir cihaz:** Kilidi açık bir telefonu ya da çekirdek düzeyinde zararlı yazılımı olan bir cihazı koruyamaz. Bölmeler sanal makine değil, işletim sisteminin süreç yalıtımıyla ayrılır.
- **Konuştuğunuz kişi:** Ekran görüntüsü alabilir ya da mesajları başkalarına iletebilir.
- **Küresel trafik analizi:** Ağın büyük bir kısmını izleyen biri zamanlama ilişkisi kurmayı deneyebilir. Örtü trafiği (cover traffic) yoktur.
- **`.klt` anahtarını ele geçiren biri:** Koruma anahtardan gelir, programdan değil.
