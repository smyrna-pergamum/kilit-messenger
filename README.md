<p align="center">
  <img src="docs/assets/icon.png" width="128" alt="Kilit icon: a brass padlock">
</p>

<h1 align="center">Kilit</h1>

<p align="center">
  <b>A private messenger and encrypted vault.</b><br>
  No account, no phone number, no server. Post-quantum Signal protocol, over Tor only.
</p>

<p align="center">
  <a href="https://github.com/smyrna-pergamum/kilit-messenger/releases"><img alt="Release" src="https://img.shields.io/github/v/release/smyrna-pergamum/kilit-messenger?include_prereleases&label=release&color=E0A84A"></a>
  <a href="https://github.com/smyrna-pergamum/kilit-messenger/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/smyrna-pergamum/kilit-messenger/actions/workflows/ci.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="License: GPL-3.0-or-later" src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue"></a>
  <img alt="Android 7.0+" src="https://img.shields.io/badge/Android-7.0%2B-3DDC84?logo=android&logoColor=white">
</p>

<p align="center">
  <a href="https://github.com/smyrna-pergamum/kilit-messenger/releases"><b>Download the APK</b></a>
  ·
  <a href="README.tr.md">Türkçe</a>
</p>

A messenger and encrypted file vault with no account, no phone number and no
server of its own. Messages are end-to-end encrypted with the Signal protocol
in its post-quantum form, and they leave the phone only through Tor, to public
Nostr relays.

<p align="center">
  <img src="docs/screenshots/01-chats.png" width="24%" alt="Chats: contacts, a group and a request">
  <img src="docs/screenshots/02-chat.png" width="24%" alt="A conversation with delivery ticks and a file">
  <img src="docs/screenshots/03-group.png" width="24%" alt="A group with three people">
  <img src="docs/screenshots/04-my-kilit.png" width="24%" alt="Your code: QR, link and @ID">
</p>
<p align="center">
  <img src="docs/screenshots/05-bridges.png" width="24%" alt="Tor connection: automatic, obfs4, Snowflake or your own bridges">
  <img src="docs/screenshots/06-lock.png" width="24%" alt="The lock screen: the digits are shuffled every time">
</p>
<p align="center"><sub>The people and messages are made up. Kilit blocks screenshots on the phone, so these are drawn from the real screens by <code>app/tool/screenshots</code>.</sub></p>

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
It runs on Android 7.0 or later. Kilit asks for two permissions: the network,
which only its embedded Tor uses, and the camera, for photos you take in a
chat.

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
