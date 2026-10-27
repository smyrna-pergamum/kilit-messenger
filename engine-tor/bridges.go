// SPDX-License-Identifier: GPL-3.0-or-later
//
// Which way tor goes out: straight to the Tor network, or through bridges.
// The built-in lines are Tor Browser's (builtin.json, as Kryfo carries
// them); a user may also give lines of their own, from bridges.torproject.org
// or a friend.
package main

import (
	_ "embed"
	"encoding/json"
	"errors"
	"regexp"
	"strings"
)

//go:embed builtin.json
var builtinJSON []byte

// Config is how tor should reach the network.
type Config struct {
	// Mode is "direct", "obfs4", "snowflake" or "custom".
	Mode string `json:"mode"`
	// Bridges are the user's own lines, for "custom".
	Bridges []string `json:"bridges,omitempty"`
}

func builtin(transport string) []string {
	var all map[string][]string
	if err := json.Unmarshal(builtinJSON, &all); err != nil {
		return nil
	}
	return all[transport]
}

// a bridge line: transport, address, optional fingerprint, key=value pairs
var bridgeRe = regexp.MustCompile(
	`^(obfs4|webtunnel|snowflake) ` +
		`(\[[0-9a-fA-F:]+\]|[0-9]{1,3}(\.[0-9]{1,3}){3}):[0-9]{1,5}` +
		`( [0-9A-Fa-f]{40})?` +
		`( [A-Za-z0-9_-]+=[^ ]+)*$`)

// cleanLine trims a line someone pasted ("Bridge " in front, spaces) and
// checks its shape. Only the transports built in are accepted.
func cleanLine(s string) (string, bool) {
	s = strings.Join(strings.Fields(s), " ")
	s = strings.TrimPrefix(s, "Bridge ")
	if len(s) > 2048 || strings.Contains(s, tokenArg+"=") {
		return "", false
	}
	return s, bridgeRe.MatchString(s)
}

// Lines are the bridge lines for a config; nil means direct.
func Lines(c Config) ([]string, error) {
	switch c.Mode {
	case "", "direct":
		return nil, nil
	case "obfs4", "snowflake":
		l := builtin(c.Mode)
		if len(l) == 0 {
			return nil, errors.New("no built-in " + c.Mode + " bridges")
		}
		return l, nil
	case "custom":
		var out []string
		for _, b := range c.Bridges {
			if l, ok := cleanLine(b); ok {
				out = append(out, l)
			}
		}
		if len(out) == 0 {
			return nil, errors.New("no usable bridge line")
		}
		return out, nil
	}
	return nil, errors.New("unknown mode " + c.Mode)
}
