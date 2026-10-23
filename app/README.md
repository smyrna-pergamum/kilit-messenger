# app

Flutter arayüzü. Aşama 1'de `flutter create --platforms=android,windows` ile oluşturulacak.

- `lib/`: ekranlar ve tema (gece mavisi ve pirinç paleti)
- `android/`: Kotlin. Keystore/StrongBox, CameraX, `isolatedProcess` servisleri
- `windows/`: C++. TPM 2.0, Windows Hello, AppContainer, sistem tepsisi

Arayüz anahtar görmez. Rust çekirdeğiyle yalnızca `core/crates/kilit-ffi` üzerinden, tutamaçlarla (handle) konuşur.
