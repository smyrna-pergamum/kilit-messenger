// SPDX-License-Identifier: GPL-3.0-or-later
//
// Embedded Tor for Kilit on Android. Tor runs inside the app's process
// (go-libtor links tor, OpenSSL, libevent and zlib in) and bine drives it
// over its control port. The rest of Kilit talks to it only through the
// SOCKS port this reports.
//
// Derived from Kryfo (https://github.com/GnosiWorks/Kryfo, GPL-3.0-or-later),
// engine/tor_process.go and the start path of engine/bridge.go
// (startListener, commit 2660ae8). Kilit keeps only starting, watching and
// stopping tor; messaging lives in the Rust core.
package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"

	libtor "github.com/alexballas/go-libtor"
	"github.com/cretz/bine/process"
	"github.com/cretz/bine/tor"
)

// go-libtor types its processes with its own copy of bine's process
// package; the methods are the same, so they go to bine as they are.
type libtorCreator struct{}

func (libtorCreator) New(ctx context.Context, args ...string) (process.Process, error) {
	return libtor.Creator.New(ctx, args...)
}

// Phase is where tor is.
type Phase string

const (
	Off      Phase = "off"
	Starting Phase = "starting"
	Ready    Phase = "ready"
	Failed   Phase = "failed"
)

// State is what the app shows and what the network compartment needs.
type State struct {
	Phase Phase `json:"phase"`
	// Progress is tor's bootstrap percentage, 0 to 100.
	Progress int `json:"progress"`
	// Summary is tor's own words for the current bootstrap step.
	Summary string `json:"summary"`
	// Socks is the local SOCKS5 port, 0 until tor listens.
	Socks int `json:"socks"`
	// Error is set when Phase is Failed. Never holds anything secret.
	Error string `json:"error,omitempty"`
}

var (
	// startMu serialises start and stop; mu guards the fields below, so a
	// state read never waits for a start.
	startMu sync.Mutex
	mu      sync.Mutex
	node    *tor.Tor
	cancel  context.CancelFunc
	current = State{Phase: Off}
)

func set(f func(*State)) {
	mu.Lock()
	defer mu.Unlock()
	f(&current)
}

// Snapshot is the current state.
func Snapshot() State {
	mu.Lock()
	defer mu.Unlock()
	return current
}

// args are tor's options on top of bine's (control port, cookie auth,
// "--SocksPort auto" on 127.0.0.1, "--hush").
func args() []string {
	return []string{
		// a client only: never a relay, never an exit
		"--ClientOnly", "1",
		// fewer writes to flash, where deleting is not erasing
		"--AvoidDiskWrites", "1",
		"--ClientUseIPv6", "1",
		// refuse SOCKS requests that carry a bare IP: a sign that the
		// caller resolved a name outside tor and leaked it
		"--SafeSocks", "1",
	}
}

// a hard-killed earlier run can leave tor's lock behind, which fails the
// next start in the same directory; tor is one instance per directory and
// startMu is held, so removing it is safe
func cleanRunFiles(dir string) {
	for _, name := range []string{"lock", "control-port", "control_auth_cookie"} {
		_ = os.Remove(filepath.Join(dir, name))
	}
}

// Start brings tor up in dataDir/tor and returns once it is starting; the
// bootstrap is watched in the background. Starting a running tor is a no-op.
func Start(dataDir string) error {
	startMu.Lock()
	defer startMu.Unlock()
	if node != nil {
		return nil
	}
	if dataDir == "" {
		return errors.New("empty data dir")
	}
	dir := filepath.Join(dataDir, "tor")
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return fmt.Errorf("data dir: %w", err)
	}
	cleanRunFiles(dir)
	set(func(s *State) { *s = State{Phase: Starting, Summary: "starting"} })

	t, err := tor.Start(context.Background(), &tor.StartConf{
		ProcessCreator: libtorCreator{},
		DataDir:        dir,
		ExtraArgs:      args(),
		EnableNetwork:  true,
	})
	if err != nil {
		fail(fmt.Errorf("tor start: %w", err))
		return err
	}
	ctx, stop := context.WithCancel(context.Background())
	node, cancel = t, stop
	go watch(ctx, t)
	return nil
}

func fail(err error) {
	set(func(s *State) {
		s.Phase = Failed
		s.Error = err.Error()
	})
}

var bootstrapRe = regexp.MustCompile(`PROGRESS=(\d+).*?SUMMARY="([^"]*)"`)

// parseBootstrap reads tor's status/bootstrap-phase line.
func parseBootstrap(line string) (int, string, bool) {
	m := bootstrapRe.FindStringSubmatch(line)
	if m == nil {
		return 0, "", false
	}
	p, err := strconv.Atoi(m[1])
	if err != nil || p < 0 || p > 100 {
		return 0, "", false
	}
	return p, m[2], true
}

// parseSocks reads tor's net/listeners/socks: `"127.0.0.1:41234"`, maybe
// more than one.
func parseSocks(v string) int {
	for _, f := range strings.Fields(v) {
		f = strings.Trim(f, `"`)
		i := strings.LastIndexByte(f, ':')
		if i < 0 {
			continue
		}
		if p, err := strconv.Atoi(f[i+1:]); err == nil && p > 0 && p < 65536 {
			return p
		}
	}
	return 0
}

// watch polls tor until it is stopped: bootstrap progress, then that it is
// still there. Polling, not events, keeps it simple; twice a second costs
// nothing next to tor itself.
func watch(ctx context.Context, t *tor.Tor) {
	tick := time.NewTicker(500 * time.Millisecond)
	defer tick.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-tick.C:
		}
		socks := 0
		if vals, err := t.Control.GetInfo("net/listeners/socks"); err == nil && len(vals) > 0 {
			socks = parseSocks(vals[0].Val)
		}
		vals, err := t.Control.GetInfo("status/bootstrap-phase")
		if err != nil {
			if ctx.Err() == nil {
				fail(fmt.Errorf("control port: %w", err))
			}
			return
		}
		if len(vals) == 0 {
			continue
		}
		p, summary, ok := parseBootstrap(vals[0].Val)
		if !ok {
			continue
		}
		set(func(s *State) {
			s.Progress, s.Summary, s.Socks = p, summary, socks
			s.Error = ""
			if p == 100 && socks > 0 {
				s.Phase = Ready
			} else {
				s.Phase = Starting
			}
		})
	}
}

// Stop shuts tor down. Stopping a stopped tor is a no-op.
func Stop() {
	startMu.Lock()
	defer startMu.Unlock()
	if node == nil {
		return
	}
	cancel()
	_ = node.Close()
	node, cancel = nil, nil
	set(func(s *State) { *s = State{Phase: Off} })
}
