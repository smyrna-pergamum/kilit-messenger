# engine-tor

Android için gömülü Tor. Tor, uygulamanın kendi sürecinin içinde çalışır:
go-libtor; Tor, OpenSSL, libevent ve zlib'i kütüphanenin içine bağlar.
bine de Tor'u kontrol portundan yönetir. Uygulamanın geri kalanı Tor'la
yalnızca bu kütüphanenin bildirdiği SOCKS5 portu üzerinden konuşur. Mesaj
kriptografisi burada değil, Rust çekirdeğindedir.

Kryfo'nun Go motorundan türetilmiştir (bkz. `NOTICE`). Kryfo'nun motoru
Nostr, kasa ve mesajlaşmayı da yapar; Kilit ondan yalnızca Tor'u başlatma,
izleme ve durdurma kısmını alır.

## Dışa açık C işlevleri (`libkilittor.so`)

| İşlev | Ne yapar |
| --- | --- |
| `KilitTorStart(dataDir)` | Tor'u `dataDir/tor` içinde başlatır. Boş metin ya da hata döner. |
| `KilitTorState()` | Durumu JSON olarak döner: `phase` (off, starting, ready, failed), `progress`, `summary`, `socks`, `error`. |
| `KilitTorStop()` | Tor'u durdurur. |
| `KilitTorFree(s)` | Bu kütüphanenin döndürdüğü metni serbest bırakır. |

Uygulama tarafı: `app/lib/platform/tor.dart` (Dart FFI).

## Derleme

    docker run --rm -v "$PWD:/src" -v kilit-gomod:/root/go/pkg/mod \
      -v kilit-gocache:/root/.cache/go-build -w /src/engine-tor \
      kilit-android sh build.sh

Çıktı `app/android/app/src/main/jniLibs/<abi>/libkilittor.so` dosyasıdır
(arm64-v8a, armeabi-v7a, x86_64). Depoya girmez; APK'dan önce bu betik
çalıştırılır. go-libtor, yamalı bir kopyadan derlenir (bkz.
`patches/README.md`).

## Testler

    go test ./...                       # ayrıştırıcılar
    KILIT_TOR_LIVE=1 go test -v ./...   # gerçek Tor ağına bağlanır

Windows'ta bu motor kullanılmaz. Ağ geçidi bölmesi, Tor Project'in Expert
Bundle'ındaki `tor.exe` dosyasını ayrı bir alt süreç olarak çalıştırır
(Aşama 3).

Köprüler (obfs4, snowflake, webtunnel) sonraki adımda eklenecek.
