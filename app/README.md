# app

Kilit'in Flutter arayüzü: Android ve Windows.

> **Durum:** Arayüz, şimdilik `lib/core/dev_core.dart` dosyasındaki
> geliştirme çekirdeğiyle çalışıyor. Bu çekirdek **hiçbir şeyi şifrelemez**;
> kilit ekranında bunu söyleyen kırmızı bir uyarı görünür. Rust çekirdeğine
> (`core/crates/kilit-ffi`) flutter_rust_bridge ile bağlanma sonraki adım.

## Yapı

| Yol | İçerik |
| --- | --- |
| `lib/core/kilit_core.dart` | Arayüzün çekirdekten isteyebileceği her şey. Anahtarlar bu sınırı geçmez. |
| `lib/state/session.dart` | Kasanın açık mı kilitli mi olduğu. Uygulama arka plana geçince kilitlenir. |
| `lib/theme/` | Gece mavisi ve pirinç renk paleti, açık ve koyu tema |
| `lib/screens/lock_screen.dart` | PIN oluşturma ve kilit açma. Rakamlar her açılışta karışır. |
| `lib/screens/vault_screen.dart` | Kasa, taşıyıcı mesajı, yapıştırılanı açma, paket analizi |
| `lib/screens/shell.dart` | Telefonda alt çubuk, geniş pencerede yan menü |

## Platform sertleştirmesi

- **Android:** `FLAG_SECURE` (ekran görüntüsü ve kayıt yok), Android
  yedeklemesi ve cihaz aktarımı kapalı, release derlemesinde `INTERNET` izni
  yok, Flutter'ın `PROCESS_TEXT` sorgusu çıkarıldı. Paket kimliği
  `app.kilit.messenger`.
- **Windows:** pencere `WDA_EXCLUDEFROMCAPTURE` ile ekran yakalamadan
  gizlenir (Windows 10 2004 ve sonrası).

Yazı tipi: kodlar ve parmak izleri için uygulamayla gelen JetBrains Mono
(OFL). Diğer metinlerde platformun kendi yazı tipi kullanılır; ağdan yazı
tipi indirilmez.

## Derleme ve testler

    ./repro/build.sh android                     # imajı bir kez oluştur
    docker run --rm -v "$PWD:/src" -w /src/app kilit-android \
      sh -c 'flutter analyze && flutter test && flutter build apk --debug'

Windows uygulaması Docker'da derlenemez. Windows'ta Flutter 3.47.7 ve Visual
Studio'nun "Desktop development with C++" bileşeni ile `flutter build windows`
komutu çalıştırılır.
