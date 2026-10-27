module kilit.app/engine-tor

go 1.26.9

require (
	github.com/alexballas/go-libtor v1.0.8
	github.com/cretz/bine v0.2.0
	gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/goptlib v1.6.0
	gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird v0.0.0-20260115133752-0b10edbb61e0
	gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/ptutil v0.0.0-20250815012447-418f76dcf315
	gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2 v2.14.1
)

// a client-only snowflake: no SQS (and no AWS SDK), errors instead of
// log.Fatal; taken from Kryfo, see third_party/snowflake
replace gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2 => ./third_party/snowflake

require (
	filippo.io/edwards25519 v1.1.0 // indirect
	github.com/alexballas/bine v0.0.0-20260617175114-f63422fc9667 // indirect
	github.com/andybalholm/brotli v1.1.1 // indirect
	github.com/dchest/siphash v1.2.3 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/klauspost/compress v1.18.0 // indirect
	github.com/klauspost/cpuid/v2 v2.2.9 // indirect
	github.com/klauspost/reedsolomon v1.12.4 // indirect
	github.com/miekg/dns v1.1.65 // indirect
	github.com/patrickmn/go-cache v2.1.0+incompatible // indirect
	github.com/pion/datachannel v1.6.0 // indirect
	github.com/pion/dtls/v3 v3.1.2 // indirect
	github.com/pion/ice/v4 v4.2.0 // indirect
	github.com/pion/interceptor v0.1.43 // indirect
	github.com/pion/logging v0.2.4 // indirect
	github.com/pion/mdns/v2 v2.1.0 // indirect
	github.com/pion/randutil v0.1.0 // indirect
	github.com/pion/rtcp v1.2.16 // indirect
	github.com/pion/rtp v1.10.1 // indirect
	github.com/pion/sctp v1.9.2 // indirect
	github.com/pion/sdp/v3 v3.0.17 // indirect
	github.com/pion/srtp/v3 v3.0.10 // indirect
	github.com/pion/stun/v3 v3.1.1 // indirect
	github.com/pion/transport/v4 v4.0.1 // indirect
	github.com/pion/turn/v4 v4.1.4 // indirect
	github.com/pion/webrtc/v4 v4.2.3-securityfix // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/realclientip/realclientip-go v1.0.0 // indirect
	github.com/refraction-networking/utls v1.8.2 // indirect
	github.com/theodorsm/covert-dtls v1.5.0 // indirect
	github.com/tjfoc/gmsm v1.4.1 // indirect
	github.com/txthinking/runnergroup v0.0.0-20241229123329-7b873ad00768 // indirect
	github.com/txthinking/socks5 v0.0.0-20251011041537-5c31f201a10e // indirect
	github.com/wlynxg/anet v0.0.5 // indirect
	github.com/xtaci/kcp-go/v5 v5.6.24 // indirect
	github.com/xtaci/smux v1.5.56 // indirect
	gitlab.com/yawning/edwards25519-extra v0.0.0-20231005122941-2149dcafc266 // indirect
	gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel v0.0.3-0.20250724131018-aab00213ba56 // indirect
	golang.org/x/crypto v0.53.0 // indirect
	golang.org/x/mod v0.36.0 // indirect
	golang.org/x/net v0.56.0 // indirect
	golang.org/x/sync v0.21.0 // indirect
	golang.org/x/sys v0.46.0 // indirect
	golang.org/x/text v0.38.0 // indirect
	golang.org/x/time v0.10.0 // indirect
	golang.org/x/tools v0.45.0 // indirect
)
