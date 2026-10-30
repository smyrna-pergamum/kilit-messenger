# Kilit

[Türkçe](README.tr.md)

A messenger and encrypted file vault with no account, no phone number and no
server of its own. Messages are end-to-end encrypted with the Signal protocol
in its post-quantum form, and they leave the phone only through Tor, to public
Nostr relays.

> **Alpha. Not audited.** Kilit has had no independent security review. Do
> not rely on it where your life or freedom depends on it.

## What it does

**Chats**
- No sign-up. Your Kilit ID is four words, for example
  `@abandon-ability-able-about`. You share it as a QR code or a
  `kilit://add?…` link, and the link opens Kilit directly.
- Messages use [libsignal](https://github.com/signalapp/libsignal): PQXDH
  with Kyber1024 for the first contact, and the post-quantum ratchet (SPQR)
  after that.
- Strangers who write first land in **Requests**, and they must pay a small
  proof of work to do so. Kilit sends them no read receipt until you accept
  them.
- Delivery ticks: one tick means a relay holds the message, two ticks mean
  their phone opened it. A message that was not delivered is sent again once
  a day for a week. You can also send it again by tapping its tick.
- Photos and files up to 5 MB. Each file is encrypted with a key of its own,
  and pictures lose their metadata (location, camera) before they are sent.
  Camera photos are taken in memory and never written to disk.
- Disappearing messages, set per chat.
- Groups of up to 20 people. Each message is encrypted separately for every
  member, so on the relays a group message looks like any other message. The
  person who makes a group is its admin.
- You can renew your ID: you get new words, and the old ID and link stop
  working while your contacts stay.

**Network**
- Kilit has an embedded Tor and no server of its own. Messages wait on
  public Nostr relays, under mailbox tags that change every day.
- Where Tor is blocked, Kilit can use bridges: built-in obfs4 or Snowflake,
  or bridge lines you add yourself. In automatic mode it tries a direct
  connection first, then obfs4, then Snowflake.

**Vault**
- An encrypted vault for notes and files (the `.klt` format, built on age
  with hybrid post-quantum X-Wing keys).
- Carrier mode: you can seal a message as `KLT1:` text and send it through
  any other messenger.
- The PIN is bound to the phone's hardware key (StrongBox or TEE), so a copy
  of the app's data cannot be tried on another device.
- Panic code: a separate 4-digit code wipes everything and resets Kilit to a
  fresh install.

**Also:** 15 languages. No analytics, no crash reports, no ads.

## Install

Download the APK from [Releases](https://github.com/smyrna-pergamum/kilit-messenger/releases).
It runs on Android 7.0 or later.

Before installing, check two things:

1. The file's SHA-256 matches the one in the release notes.
2. The signing certificate is Kilit's:

   ```
   SHA-256: DE:B8:42:2C:53:F6:FB:C3:34:7C:5C:0B:84:31:61:17:D2:C9:4A:53:CD:70:FA:6A:B4:E9:50:16:DA:9D:B1:E1
   ```

   You can see it with `apksigner verify --print-certs Kilit-*.apk`.

There is no Windows build yet.

## How it works

| Document | Contents |
| --- | --- |
| [spec/KILIT-NET.md](spec/KILIT-NET.md) | Network protocol: IDs, cards, mailboxes, receipts, files, groups (Turkish) |
| [spec/KLT1.md](spec/KLT1.md) | The `.klt` vault and carrier format |
| [THREAT_MODEL.md](THREAT_MODEL.md) | What Kilit protects against and what it does not |
| [PRIVACY.md](PRIVACY.md) | What is collected (nothing) and what relays can see |
| [docs/RELAYS.md](docs/RELAYS.md) | The relays Kilit uses |

## Layout

| Folder | Contents |
| --- | --- |
| `core/` | Rust core: vault, messaging, network, file parsing; one crate per compartment |
| `app/` | Flutter app (Android; Windows later) |
| `engine-tor/` | Embedded Tor and pluggable transports for Android (Go) |
| `spec/` | Protocol and file format specifications |
| `repro/` | Pinned, reproducible build containers |
| `docs/` | Building, relay list |

## Building

See [docs/BUILDING.md](docs/BUILDING.md) (Turkish). Everything builds inside
pinned Docker images:

```bash
./repro/build.sh test
```

## Security

Please report vulnerabilities privately through **Security → Report a
vulnerability** on this repository, not as public issues. See
[SECURITY.md](SECURITY.md).

## License

GPL-3.0-or-later. Kilit is derived in part from
[Kryfo](https://github.com/GnosiWorks/Kryfo) (GPL-3.0-or-later). It links
libsignal (AGPL-3.0), so the combined program carries the AGPL-3.0
network-interaction terms. [NOTICE](NOTICE) lists every third-party
component. Kilit is not Kryfo and is not endorsed by its authors.
