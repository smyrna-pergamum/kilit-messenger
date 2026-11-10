// SPDX-License-Identifier: GPL-3.0-or-later
//
// What the app shows about Tor beyond its state: the circuits it has built
// (for the route diagram), its own log (to see why it does not connect),
// and a way to reconnect.
package main

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"net/textproto"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync/atomic"

	"github.com/cretz/bine/control"
)

// the log tor writes, in its data directory; kept short
const logName = "notices.log"

// a log bigger than this is cut back when tor starts
const logKeep = 256 * 1024

var logPath string

// trimLog keeps the end of an old log, so it never grows without end.
func trimLog(path string) {
	b, err := os.ReadFile(path)
	if err != nil || len(b) <= logKeep {
		return
	}
	_ = os.WriteFile(path, b[len(b)-logKeep/2:], 0o600)
}

// LogTail is the last n lines tor logged.
func LogTail(n int) string {
	mu.Lock()
	p := logPath
	mu.Unlock()
	if p == "" {
		return ""
	}
	f, err := os.Open(p)
	if err != nil {
		return ""
	}
	defer f.Close()
	var lines []string
	s := bufio.NewScanner(f)
	s.Buffer(make([]byte, 64*1024), 64*1024)
	for s.Scan() {
		lines = append(lines, s.Text())
		if len(lines) > n {
			lines = lines[1:]
		}
	}
	return strings.Join(lines, "\n")
}

// Hop is one relay of a circuit. Its country would need tor's GeoIP
// files, which Kilit does not ship.
type Hop struct {
	Nickname string `json:"nickname"`
}

// Circuit is a built circuit's relays, guard first.
type Circuit struct {
	Hops []Hop `json:"hops"`
}

// $FINGERPRINT~nickname or $FINGERPRINT=nickname
var hopRe = regexp.MustCompile(`^\$([0-9A-F]{40})[~=]?([A-Za-z0-9]*)$`)

// Circuits are up to three built general-purpose circuits, with each
// relay's nickname.
func Circuits() ([]Circuit, error) {
	startMu.Lock()
	t := node
	startMu.Unlock()
	if t == nil {
		return nil, errors.New("tor is not running")
	}
	vals, err := t.Control.GetInfo("circuit-status")
	if err != nil || len(vals) == 0 {
		return nil, err
	}
	var out []Circuit
	for _, line := range strings.Split(vals[0].Val, "\n") {
		f := strings.Fields(line)
		if len(f) < 3 || f[1] != "BUILT" || !strings.Contains(line, "PURPOSE=GENERAL") {
			continue
		}
		var c Circuit
		for _, h := range strings.Split(f[2], ",") {
			m := hopRe.FindStringSubmatch(h)
			if m == nil {
				continue
			}
			c.Hops = append(c.Hops, Hop{Nickname: m[2]})
		}
		if len(c.Hops) > 0 {
			out = append(out, c)
		}
		if len(out) == 3 {
			break
		}
	}
	return out, nil
}

// errStopped is what the app shows when tor itself is gone; the app looks
// for "restart Kilit" to offer a restart.
// the control connection the current watch uses
var watching atomic.Pointer[control.Conn]

var errStopped = errors.New("tor stopped: restart Kilit")

// alive makes sure the control connection works, dialing tor's control
// port again when only the connection broke. Called with startMu held. An
// error means tor itself has stopped.
func alive() error {
	if _, err := node.Control.GetInfo("version"); err == nil {
		return nil
	}
	_ = node.Control.Close()
	if node.ControlPort == 0 {
		return errStopped
	}
	tc, err := textproto.Dial("tcp", fmt.Sprintf("127.0.0.1:%d", node.ControlPort))
	if err != nil {
		return errStopped
	}
	c := control.NewConn(tc)
	if err := c.Authenticate(""); err != nil {
		_ = c.Close()
		return errStopped
	}
	node.Control = c
	// the old watch ended with the old connection
	go watch(context.Background(), node)
	return nil
}

// Reconnect asks tor for new circuits and puts it on the network again the
// way it last went out. An error means tor itself is gone: only a restart
// of the app brings it back, since tor runs once per process.
func Reconnect() error {
	startMu.Lock()
	defer startMu.Unlock()
	if node == nil {
		return errors.New("tor is not running")
	}
	if err := alive(); err != nil {
		fail(err)
		return err
	}
	c := node.Control
	mu.Lock()
	enabled = true
	current.Phase = Starting
	current.Error = ""
	mu.Unlock()
	if err := c.SetConf(control.NewKeyVal("DisableNetwork", "1")); err != nil {
		fail(err)
		return err
	}
	_ = c.Signal("NEWNYM")
	if err := c.SetConf(control.NewKeyVal("DisableNetwork", "0")); err != nil {
		fail(err)
		return err
	}
	return nil
}

// logArgs makes tor log notices to dataDir/tor/notices.log.
func logArgs(dir string) []string {
	p := filepath.Join(dir, logName)
	trimLog(p)
	mu.Lock()
	logPath = p
	mu.Unlock()
	return []string{"--Log", "notice file " + p}
}
