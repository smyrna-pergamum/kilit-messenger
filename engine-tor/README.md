# engine-tor

The embedded Tor for Android. Tor runs inside the app's own process:
go-libtor links Tor, OpenSSL, libevent and zlib into this library, and bine
drives Tor over its control port. The rest of the app talks to Tor only
through the SOCKS5 port this library reports. Message cryptography is not
here; it lives in the Rust core.

This module is derived from Kryfo's Go engine (see `NOTICE`). Kryfo's engine
also does Nostr, the vault and messaging; Kilit takes from it only starting,
watching and stopping Tor, and the bridges.

## Bridges

Where the Tor network is blocked, Tor can go out through bridges:

| Mode | What it is |
| --- | --- |
| `direct` | Straight to the Tor network |
| `obfs4` | Tor Browser's built-in obfs4 bridges (`builtin.json`); the traffic looks like random bytes |
| `snowflake` | Short WebRTC hops that volunteers run; slower, for heavy censorship |
| `custom` | The user's own bridge lines (obfs4, webtunnel, snowflake), from bridges.torproject.org or someone they trust |

The pluggable transports are built in: obfs4 and webtunnel come from
lyrebird, and snowflake from a client-only copy in `third_party/snowflake`.
Tor reaches each transport through a SOCKS5 listener on localhost.

Anything on the phone can connect to a localhost port. So every bridge line
Kilit gives Tor carries a random token, and a connection that does not
bring it is closed without a word.

Tor is started once per process and never closed, because it cannot be
started again in the same process. Changing the bridge mode reconfigures the
running Tor over its control port. Stopping takes it off the network
(`DisableNetwork 1`).

The app's automatic mode (`app/lib/platform/tor.dart`) tries `direct` for
45 seconds, then `obfs4` for 90, then `snowflake` for 120, and goes round
again until one comes up.

## C functions (`libkilittor.so`)

| Function | What it does |
| --- | --- |
| `KilitTorStart(dataDir, config)` | Starts Tor in `dataDir/tor`, or changes how a running one goes out. `config` is JSON: `{"mode":"obfs4"}`, or `{"mode":"custom","bridges":[…]}`. Returns an empty string or an error. |
| `KilitTorState()` | The state as JSON: `phase` (off, starting, ready, failed), `progress`, `summary`, `socks`, `error`, `mode`. |
| `KilitTorStop()` | Takes Tor off the network. |
| `KilitTorFree(s)` | Frees a string this library returned. |

The app side is `app/lib/platform/tor.dart` (Dart FFI).

## Building

```bash
docker run --rm -v "$PWD:/src" -v kilit-gomod:/root/go/pkg/mod -v kilit-gocache:/root/.cache/go-build -w /src/engine-tor kilit-android sh build.sh
```

It writes `app/android/app/src/main/jniLibs/<abi>/libkilittor.so` for
arm64-v8a, armeabi-v7a and x86_64, for Android 7.0 (API 24) and later. The
libraries are not kept in the repository, so run this before building the
APK. go-libtor and anet are built from patched copies (see
`patches/README.md`).

## Tests

```bash
go test ./...
```

That runs the parsers, the bridge lines and the token check.

```bash
KILIT_TOR_LIVE=1 KILIT_TOR_MODE=obfs4 go test -v -run Bootstrap ./...
```

That connects to the real Tor network, through the mode given (`direct`,
`obfs4` or `snowflake`), then stops and starts again.

Windows does not use this engine. There, the network compartment will run
`tor.exe` from the Tor Project's Expert Bundle as a separate process.
