# Kilit

Hesapsız, telefon numarasız, uçtan uca ve post-kuantum şifreli bir mesajlaşma
uygulaması ve dosya kasası. Mesajlar Signal protokolüyle (PQXDH, Kyber1024)
şifrelenir ve yalnızca Tor üzerinden açık Nostr relay'lerine bırakılır; sunucu
yoktur. Tor engelliyse yerleşik obfs4 ya da snowflake köprüleri, veya
kullanıcının kendi köprüleri kullanılır. En fazla 20 kişilik gruplar
desteklenir; grup mesajları her üyeye ayrı ayrı şifrelenir. Belge, resim ve
videolar `.klt` paketlerine şifrelenir.

> **Durum:** Alfa. Android'de iki telefon arasında denendi. Güvenlik denetiminden geçmedi.

## Yapı

| Klasör | İçerik |
| --- | --- |
| `core/` | Rust çekirdeği. Her bölme ayrı bir crate (Qubes OS esinli) |
| `app/` | Flutter arayüzü (Android, Windows) |
| `engine-tor/` | Android için gömülü Tor ve köprüler (Kryfo'dan) |
| `spec/` | KLT1 dosya biçimi, IPC protokolü |
| `repro/` | Tekrarlanabilir derleme ortamı (Docker) |
| `scripts/` | Geliştirme ortamı kurulumu |
| `docs/` | Derleme, relay listesi |

## Derleme

`docs/BUILDING.md` dosyasına bakın. Kısaca: Windows'ta WSL2 (Ubuntu 24.04) ve
içinde Docker Engine kurulur, ardından:

    ./repro/build.sh test

## Lisans

GPL-3.0-or-later. Kryfo'dan türetilen parçalar için `NOTICE` dosyasına bakın.
