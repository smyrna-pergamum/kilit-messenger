// SPDX-License-Identifier: GPL-3.0-or-later
//
// Pluggable transports, built into the engine: obfs4 and webtunnel from
// lyrebird, snowflake from Tor's own client library. Tor reaches each one
// through a SOCKS5 listener on localhost, as
//
//	ClientTransportPlugin obfs4 socks5 127.0.0.1:<port>
//
// and hands it the bridge line's arguments as the SOCKS username and
// password.
//
// Anything on the phone can connect to a localhost port. So every bridge
// line Kilit gives Tor carries a random token, and a connection that does
// not bring it is closed without a word.
//
// Derived from Kryfo (https://github.com/GnosiWorks/Kryfo, GPL-3.0-or-later),
// engine/pt.go and engine/bridges.go (commit 2660ae8), cut down: no moat, no
// per-bridge health tracking.
package main

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net"
	"strconv"
	"strings"
	"sync"
	"time"

	pt "gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/goptlib"
	"gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird/common/socks5"
	"gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird/transports/base"
	"gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird/transports/obfs4"
	"gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird/transports/webtunnel"
	utlsutil "gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/ptutil/utls"
	sf "gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2/client/lib"
)

// goptlib writes protocol lines to stdout for a parent process that is not
// there
func init() { pt.Stdout = io.Discard }

// the transports, in the order tor is told of them
var ptNames = []string{"obfs4", "webtunnel", "snowflake"}

// Tor Browser's STUN servers for its built-in snowflake lines
var snowflakeICE = []string{
	"stun:stun.epygi.com:3478",
	"stun:stun.uls.co.za:3478",
	"stun:stun.voipgate.com:3478",
	"stun:stun.mixvoip.com:3478",
	"stun:stun.telnyx.com:3478",
	"stun:stun.hot-chilli.net:3478",
	"stun:stun.fitauto.ru:3478",
	"stun:stun.m-online.net:3478",
}

// proxies one snowflake connection gathers at most: each is a WebRTC peer,
// and many only burn battery
const snowflakeMaxPeers = 3

func ptClientFactory(name string) (base.ClientFactory, error) {
	switch name {
	case "obfs4":
		return (&obfs4.Transport{}).ClientFactory("")
	case "webtunnel":
		return webtunnel.Transport.ClientFactory("")
	case "snowflake":
		return snowflakeClient{}, nil
	}
	return nil, fmt.Errorf("unknown transport %q", name)
}

type snowflakeTransport struct{}

func (snowflakeTransport) Name() string { return "snowflake" }

func (snowflakeTransport) ClientFactory(string) (base.ClientFactory, error) {
	return snowflakeClient{}, nil
}

func (snowflakeTransport) ServerFactory(string, *pt.Args) (base.ServerFactory, error) {
	return nil, errors.New("snowflake: no server")
}

type snowflakeClient struct{}

func (snowflakeClient) Transport() base.Transport { return snowflakeTransport{} }

// the broker through CDN fronting only: SQS is not built in, and the AMP
// cache is refused
func (snowflakeClient) ParseArgs(args *pt.Args) (interface{}, error) {
	for _, k := range []string{"sqsqueue", "sqscreds", "ampcache", "proxy"} {
		if _, ok := args.Get(k); ok {
			return nil, fmt.Errorf("snowflake: %s is not supported", k)
		}
	}
	var c sf.ClientConfig
	c.BrokerURL, _ = args.Get("url")
	if !strings.HasPrefix(strings.ToLower(c.BrokerURL), "https://") {
		return nil, errors.New("snowflake: broker url is not https")
	}
	fronts, ok := args.Get("fronts")
	if !ok {
		fronts, _ = args.Get("front")
	}
	if c.FrontDomains = splitList(fronts); len(c.FrontDomains) == 0 {
		return nil, errors.New("snowflake: no front")
	}
	c.ICEAddresses = snowflakeICE
	if ice, ok := args.Get("ice"); ok {
		c.ICEAddresses = splitList(ice)
	}
	c.UTLSClientID, _ = args.Get("utls-imitate")
	if c.UTLSClientID != "" {
		if _, err := utlsutil.NameToUTLSID(c.UTLSClientID); err != nil {
			return nil, errors.New("snowflake: unknown utls-imitate")
		}
	}
	c.BridgeFingerprint, _ = args.Get("fingerprint")
	c.Max = 1
	if m, ok := args.Get("max"); ok {
		n, err := strconv.Atoi(m)
		if err != nil || n < 1 || n > snowflakeMaxPeers {
			return nil, errors.New("snowflake: bad max")
		}
		c.Max = n
	}
	return c, nil
}

// one snowflake client per line: its NAT check and broker channel are set
// up once, not for every connection tor makes
var (
	sfMu      sync.Mutex
	sfClients = map[string]*sf.Transport{}
)

func snowflakeFor(c sf.ClientConfig) (*sf.Transport, error) {
	key := fmt.Sprintf("%q %q %q %q %q %d", c.BrokerURL, c.FrontDomains,
		c.ICEAddresses, c.UTLSClientID, c.BridgeFingerprint, c.Max)
	sfMu.Lock()
	defer sfMu.Unlock()
	if t := sfClients[key]; t != nil {
		return t, nil
	}
	t, err := sf.NewSnowflakeClient(c)
	if err != nil {
		return nil, err
	}
	sfClients[key] = t
	return t, nil
}

// the target is a placeholder: the line's url and fronts say where the
// broker is
func (snowflakeClient) Dial(_, _ string, _ base.DialFunc, args interface{}) (net.Conn, error) {
	c, ok := args.(sf.ClientConfig)
	if !ok {
		return nil, errors.New("snowflake: bad args")
	}
	t, err := snowflakeFor(c)
	if err != nil {
		return nil, err
	}
	return t.Dial()
}

func (snowflakeClient) OnEvent(func(base.TransportEvent)) {}

func splitList(s string) []string {
	var out []string
	for _, p := range strings.Split(s, ",") {
		if p = strings.TrimSpace(p); p != "" {
			out = append(out, p)
		}
	}
	return out
}

// ---- the listeners ----

const tokenArg = "kilit-token"

var (
	ptMu    sync.Mutex
	ptPorts = map[string]int{}
	// the token every bridge line given to tor carries, new each run
	ptToken = func() string {
		b := make([]byte, 16)
		if _, err := rand.Read(b); err != nil {
			panic("no system randomness")
		}
		return hex.EncodeToString(b)
	}()
)

// how long a SOCKS handshake and a dial may take
var (
	ptHandshakeTimeout = 5 * time.Second
	ptDialTimeout      = 60 * time.Second
)

// startTransports brings up one localhost SOCKS5 listener per transport,
// once per process: tor keeps the ports it was told about.
func startTransports() error {
	ptMu.Lock()
	defer ptMu.Unlock()
	for _, name := range ptNames {
		if ptPorts[name] != 0 {
			continue
		}
		f, err := ptClientFactory(name)
		if err != nil {
			return err
		}
		ln, err := net.Listen("tcp", "127.0.0.1:0")
		if err != nil {
			return fmt.Errorf("%s listener: %w", name, err)
		}
		ptPorts[name] = ln.Addr().(*net.TCPAddr).Port
		go acceptPT(ln, name, f)
	}
	return nil
}

// the ClientTransportPlugin values for tor
func transportPlugins() []string {
	ptMu.Lock()
	defer ptMu.Unlock()
	var out []string
	for _, n := range ptNames {
		if p := ptPorts[n]; p != 0 {
			out = append(out, fmt.Sprintf("%s socks5 127.0.0.1:%d", n, p))
		}
	}
	return out
}

func acceptPT(ln net.Listener, name string, f base.ClientFactory) {
	for {
		conn, err := ln.Accept()
		if err != nil {
			if errors.Is(err, net.ErrClosed) {
				return
			}
			time.Sleep(50 * time.Millisecond)
			continue
		}
		go func() {
			// a panic in a transport must not take the app down
			defer func() { _ = recover() }()
			servePT(conn, name, f)
		}()
	}
}

// one connection from tor: the SOCKS request, the token, the line's own
// arguments, the dial; then bytes both ways until either side ends
func servePT(conn net.Conn, name string, f base.ClientFactory) {
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(ptHandshakeTimeout))
	req, err := socks5.Handshake(conn)
	if err != nil {
		return
	}
	if tok, ok := req.Args.Get(tokenArg); !ok || tok != ptToken {
		// no reply at all: every answer would say something
		return
	}
	args := pt.Args{}
	for k, v := range req.Args {
		if k != tokenArg {
			args[k] = v
		}
	}
	parsed, err := f.ParseArgs(&args)
	if err != nil {
		_ = req.Reply(socks5.ReplyGeneralFailure)
		return
	}
	_ = conn.SetDeadline(time.Now().Add(ptDialTimeout))
	dialer := net.Dialer{Timeout: ptDialTimeout}
	remote, err := f.Dial("tcp", req.Target, dialer.Dial, parsed)
	if err != nil {
		_ = req.Reply(socks5.ErrorToReplyCode(err))
		return
	}
	defer remote.Close()
	if err := req.Reply(socks5.ReplySucceeded); err != nil {
		return
	}
	_ = conn.SetDeadline(time.Time{})
	// the first side to finish ends both: a snowflake stream never sees EOF
	// from its far end
	done := make(chan struct{}, 2)
	pipe := func(dst io.Writer, src io.Reader) {
		defer func() {
			_ = recover()
			done <- struct{}{}
		}()
		_, _ = io.Copy(dst, src)
	}
	go pipe(remote, conn)
	go pipe(conn, remote)
	<-done
}

// withToken adds the token to a bridge line, as one more key=value
// argument
func withToken(line string) string {
	return line + " " + tokenArg + "=" + ptToken
}
