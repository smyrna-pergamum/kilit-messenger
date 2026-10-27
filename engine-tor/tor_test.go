// SPDX-License-Identifier: GPL-3.0-or-later
package main

import (
	"fmt"
	"io"
	"net"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"
)

func TestParseBootstrap(t *testing.T) {
	p, s, ok := parseBootstrap(`NOTICE BOOTSTRAP PROGRESS=45 TAG=loading_descriptors SUMMARY="Loading relay descriptors"`)
	if !ok || p != 45 || s != "Loading relay descriptors" {
		t.Fatalf("got %d %q %v", p, s, ok)
	}
	for _, bad := range []string{"", "PROGRESS=abc", `PROGRESS=101 SUMMARY="x"`, `PROGRESS=-1 SUMMARY="x"`} {
		if _, _, ok := parseBootstrap(bad); ok {
			t.Fatalf("accepted %q", bad)
		}
	}
}

func TestParseSocks(t *testing.T) {
	cases := map[string]int{
		`"127.0.0.1:41234"`:             41234,
		`"127.0.0.1:9050" "[::1]:9050"`: 9050,
		``:                              0,
		`"unix:/data/socks"`:            0,
		`"127.0.0.1:99999"`:             0,
	}
	for in, want := range cases {
		if got := parseSocks(in); got != want {
			t.Fatalf("%q: got %d, want %d", in, got, want)
		}
	}
}

// TestBootstrap really connects to the Tor network. It needs the internet,
// so it runs only with KILIT_TOR_LIVE=1.
func TestBootstrap(t *testing.T) {
	if os.Getenv("KILIT_TOR_LIVE") != "1" {
		t.Skip("set KILIT_TOR_LIVE=1 to reach the Tor network")
	}
	dir := t.TempDir()
	// KILIT_TOR_MODE=obfs4 or snowflake: through the built-in bridges
	cfg := Config{Mode: os.Getenv("KILIT_TOR_MODE")}
	if err := Start(dir, cfg); err != nil {
		t.Fatal(err)
	}
	defer Stop()
	deadline := time.Now().Add(4 * time.Minute)
	if os.Getenv("KILIT_TOR_HOLD") != "" {
		deadline = time.Now().Add(30 * time.Minute)
	}
	last := -1
	for {
		s := Snapshot()
		if s.Progress != last {
			t.Logf("%s %d%% %s", s.Phase, s.Progress, s.Summary)
			last = s.Progress
		}
		if s.Phase == Ready {
			c, err := net.DialTimeout("tcp", "127.0.0.1:"+strconv.Itoa(s.Socks), 5*time.Second)
			if err != nil {
				t.Fatalf("socks port %d: %v", s.Socks, err)
			}
			c.Close()
			// KILIT_TOR_HOLD=<file>: write the SOCKS port there and keep tor
			// up until <file>.done appears, so other tests can use it
			if f := os.Getenv("KILIT_TOR_HOLD"); f != "" {
				if err := os.WriteFile(f, []byte(strconv.Itoa(s.Socks)), 0o600); err != nil {
					t.Fatal(err)
				}
				for {
					if _, err := os.Stat(f + ".done"); err == nil {
						break
					}
					time.Sleep(500 * time.Millisecond)
				}
			}
			break
		}
		if s.Phase == Failed {
			t.Fatal(s.Error)
		}
		if time.Now().After(deadline) {
			t.Fatalf("no bootstrap in 4 minutes: %+v", s)
		}
		time.Sleep(time.Second)
	}
	Stop()
	if s := Snapshot(); s.Phase != Off {
		t.Fatalf("after stop: %+v", s)
	}
	// and back: the same tor, on the network again
	if err := Start(dir, cfg); err != nil {
		t.Fatal(err)
	}
	for Snapshot().Phase != Ready {
		if time.Now().After(deadline) {
			t.Fatalf("not back after a stop: %+v", Snapshot())
		}
		time.Sleep(time.Second)
	}
}

func TestBridgeLines(t *testing.T) {
	for _, mode := range []string{"obfs4", "snowflake"} {
		l, err := Lines(Config{Mode: mode})
		if err != nil || len(l) == 0 {
			t.Fatalf("%s: %v", mode, err)
		}
		for _, line := range l {
			if _, ok := cleanLine(line); !ok {
				t.Fatalf("built-in line refused: %s", line)
			}
		}
	}
	if l, err := Lines(Config{}); err != nil || l != nil {
		t.Fatalf("direct: %v %v", l, err)
	}
	own := Config{Mode: "custom", Bridges: []string{
		"Bridge obfs4 192.0.2.1:443 0123456789ABCDEF0123456789ABCDEF01234567 cert=abc iat-mode=0",
		"not a bridge",
		"obfs4 192.0.2.2:443 0123456789ABCDEF0123456789ABCDEF01234567 kilit-token=stolen",
		"meek_lite 192.0.2.3:80 url=https://x",
	}}
	l, err := Lines(own)
	if err != nil || len(l) != 1 || l[0][:6] != "obfs4 " {
		t.Fatalf("custom: %v %v", l, err)
	}
	if _, err := Lines(Config{Mode: "custom"}); err == nil {
		t.Fatal("custom without lines accepted")
	}
}

func TestATransportWantsTheToken(t *testing.T) {
	if err := startTransports(); err != nil {
		t.Fatal(err)
	}
	port := 0
	for _, p := range transportPlugins() {
		if strings.HasPrefix(p, "obfs4 ") {
			fmt.Sscanf(p, "obfs4 socks5 127.0.0.1:%d", &port)
		}
	}
	if port == 0 {
		t.Fatal("no obfs4 listener")
	}
	c, err := net.Dial("tcp", "127.0.0.1:"+strconv.Itoa(port))
	if err != nil {
		t.Fatal(err)
	}
	defer c.Close()
	// SOCKS5 with username/password, the arguments without the token
	user := "cert=x;iat-mode=0"
	_, _ = c.Write([]byte{5, 1, 2})
	reply := make([]byte, 2)
	if _, err := io.ReadFull(c, reply); err != nil || reply[1] != 2 {
		t.Fatalf("method: %v %v", reply, err)
	}
	auth := append([]byte{1, byte(len(user))}, user...)
	auth = append(auth, 1, 0)
	_, _ = c.Write(auth)
	_ = c.SetReadDeadline(time.Now().Add(3 * time.Second))
	rest, _ := io.ReadAll(c)
	// at most the auth answer, then the connection is closed: no CONNECT
	// reply ever comes
	if len(rest) > 2 {
		t.Fatalf("answered without the token: %v", rest)
	}
}
