// SPDX-License-Identifier: GPL-3.0-or-later
package main

import (
	"net"
	"os"
	"strconv"
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
	if err := Start(dir); err != nil {
		t.Fatal(err)
	}
	defer Stop()
	// a second start of a running tor changes nothing
	if err := Start(dir); err != nil {
		t.Fatal(err)
	}
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
}
