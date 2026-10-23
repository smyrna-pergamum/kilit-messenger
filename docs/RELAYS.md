# Relay'ler

2026-10-23'te seçildi. Hepsi ücretsiz ve okuma için kimlik doğrulaması (NIP-42) istemiyor.
NIP-11 bilgi belgesindeki anahtarı aynı olan relay'ler aynı işletmeciye ait sayıldı ve
her işletmeciden yalnızca biri seçildi.

| Relay | Yazılım (NIP-11) |
| --- | --- |
| `wss://nos.lol` | strfry 1.1.3 |
| `wss://relay.primal.net` | strfry 1.1.3 |
| `wss://nostr.oxtr.dev` | strfry 1.0.4 |
| `wss://offchain.pub` | strfry 1.1.0 |
| `wss://nostr-pub.wellorder.net` | nostr-rs-relay 0.9.0 |
| `wss://nostr.data.haus` | strfry 1.1.3 |

Yedekler: `nostr.mom` (nos.lol ile aynı işletmeci), `nostr.bitcoiner.social`
(offchain.pub ile aynı işletmeci), `relay.snort.social` (memlay yazılımı,
saklama durumu bilinmiyor).

Aşama 2'de test edilecekler: tek kullanımlık anahtarlardan gelen yazmaların
kabul edilmesi, Tor çıkış düğümlerinden erişim, saklama süresi.
