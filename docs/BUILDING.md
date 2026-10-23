# Derleme

Android, Linux ve tekrarlanabilir derlemeler WSL2 içindeki Docker'da yapılır.
Windows uygulaması ise Aşama 3'te doğrudan Windows'ta derlenecek
(Flutter ve Visual Studio C++ araçlarıyla).

## 1. WSL2 (Windows'ta, bir kez)

Yönetici olarak açılmış bir PowerShell'de:

    powershell -ExecutionPolicy Bypass -File scripts\setup-wsl.ps1

Windows'u yeniden başlatın. Başlat menüsünden **Ubuntu 24.04**'ü bir kez açıp
Linux kullanıcınızı oluşturun.

## 2. Docker Engine (Ubuntu içinde, bir kez)

Repoyu Linux dosya sisteminin içine klonlayın. `/mnt/c` altı çok yavaştır.

    git clone <repo-url> ~/kilit-messenger
    cd ~/kilit-messenger
    bash scripts/setup-dev.sh

Betik, Docker'ın apt deposunu imza anahtarının parmak iziyle doğruladıktan
sonra ekler. Bittiğinde terminali kapatıp yeniden açın.

`docker` grubuna eklenen kullanıcı fiilen root yetkisine sahip olur. Bu
yüzden ortamı yalnızca geliştirme için kullanın.

## 3. Derleme ve testler

    ./repro/build.sh test       # Rust: fmt, clippy, testler
    ./repro/build.sh shell      # konteyner içinde bir kabuk
    ./repro/build.sh android    # Android imajı (Aşama 1'den itibaren)

## Sabitlenmiş sürümler

| Araç | Sürüm | Doğrulama |
| --- | --- | --- |
| Temel imaj | debian trixie-20261020-slim | özet (digest) |
| rustup | 1.29.2 | SHA-256 |
| Rust | 1.99.1 | `core/rust-toolchain.toml` |
| Go (engine-tor) | 1.26.9 | SHA-256 |
| Android cmdline-tools | 11076708 | SHA-256 |
| Android NDK | 28.2.13676358 (r28c) | sdkmanager |
| Flutter | 3.47.7 | commit `abaf9c5` |
| JDK | 21 (Debian) | apt |

Bir sürüm güncellenirken bu tabloyla birlikte `repro/Dockerfile` dosyası da
aynı commit'te güncellenir.
