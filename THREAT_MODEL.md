# Tehdit modeli

Taslak. Her aşamada güncellenecek.

## Korur

- **Ağ gözlemcileri:** Trafik Tor üzerinden gider. İnternet sağlayıcısı kiminle konuştuğunuzu görmez.
- **Relay'ler:** Mesajlar Signal (PQXDH ve Triple Ratchet) ve NIP-44/59 ile çift şifrelidir. Relay içeriği okuyamaz.
- **Gelecekteki kuantum bilgisayarlar:** Anahtar alışverişleri hibrittir (X25519 ve ML-KEM).
- **Bozuk ya da kötü amaçlı dosyalar:** Dosyalar, her işten sonra yok edilen tek kullanımlık bir bölmede açılır.

## Korumaz

- **Açık relay'lerdeki meta veri:** Bir posta kutusu adresini bilen kişi, o adrese gelen mesajların zamanını ve sayısını görebilir. Adresler 24 saatte bir değişir, ama bir gün içindeki trafik görünür.
- **Ele geçirilmiş bir cihaz:** Kilidi açık bir telefonu ya da çekirdek düzeyinde zararlı yazılımı olan bir cihazı koruyamaz. Bölmeler sanal makine değil, işletim sisteminin süreç yalıtımıyla ayrılır.
- **Konuştuğunuz kişi:** Ekran görüntüsü alabilir ya da mesajları başkalarına iletebilir.
- **Küresel trafik analizi:** Ağın büyük bir kısmını izleyen biri zamanlama ilişkisi kurmayı deneyebilir. Örtü trafiği (cover traffic) yoktur.
- **`.klt` anahtarını ele geçiren biri:** Koruma anahtardan gelir, programdan değil.
