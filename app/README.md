# app

Kilit'in Flutter arayüzü: Android ve Windows.

> **Durum:** Uygulama Rust çekirdeğiyle (`core/crates/kilit-ffi`) çalışır;
> bütün şifreleme Rust'ta yapılır. PIN henüz bir donanım anahtarına bağlı
> değil (StrongBox/TPM sonraki adım); Ayarlar ekranı bunu söyler.
> `lib/core/dev_core.dart` yalnızca widget testleri içindir ve hiçbir şeyi
> şifrelemez.

## Yapı

| Yol | İçerik |
| --- | --- |
| `lib/core/kilit_core.dart` | Arayüzün çekirdekten isteyebileceği her şey. Anahtarlar bu sınırı geçmez. |
| `lib/core/rust_core.dart` | Bu arayüzün Rust çekirdeğine bağlı hali |
| `lib/src/rust/` | flutter_rust_bridge'in ürettiği Dart kodu (elle düzenlenmez) |
| `rust_builder/` | Rust çekirdeğini her platform için derleyen cargokit iskeleti |
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

`core/crates/kilit-ffi/src/api.rs` değişince bağlayıcılar yeniden üretilir.
İmajda flutter_rust_bridge_codegen 2.13.0 ve cargo-expand 1.0.127 sürümleri
sabitlenmiş olarak bulunur:

    docker run --rm -v "$PWD:/src" -w /src/app kilit-android \
      flutter_rust_bridge_codegen generate

Köprüyü gerçek Rust çekirdeğiyle test etmek için:

    docker run --rm -v "$PWD:/src" -w /src/app kilit-android sh -c \
      'cd ../core && cargo build -p kilit-ffi && cd ../app &&
       KILIT_FFI_LIB=../core/target/debug/libkilit_ffi.so flutter test test/rust_core_test.dart'

Windows uygulaması Docker'da derlenemez. Windows'ta Flutter 3.47.7 ve Visual
Studio'nun "Desktop development with C++" bileşeni ile `flutter build windows`
komutu çalıştırılır.
