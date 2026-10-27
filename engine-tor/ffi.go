// SPDX-License-Identifier: GPL-3.0-or-later
//
// The C surface the app loads (libkilittor.so) through Dart's FFI. Every
// string returned is malloc'ed here and freed with KilitTorFree.
package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"encoding/json"
	"unsafe"
)

// KilitTorStart starts tor in dataDir/tor, or changes how a running one
// goes out. config is JSON (see Config): {"mode":"obfs4"}. Returns "" or an
// error.
//
//export KilitTorStart
func KilitTorStart(dataDir *C.char, config *C.char) *C.char {
	var cfg Config
	if err := json.Unmarshal([]byte(C.GoString(config)), &cfg); err != nil {
		return C.CString("config: " + err.Error())
	}
	if err := Start(C.GoString(dataDir), cfg); err != nil {
		return C.CString(err.Error())
	}
	return C.CString("")
}

// KilitTorState returns the state as JSON (see State).
//
//export KilitTorState
func KilitTorState() *C.char {
	b, err := json.Marshal(Snapshot())
	if err != nil {
		return C.CString(`{"phase":"failed","error":"state"}`)
	}
	return C.CString(string(b))
}

// KilitTorStop stops tor.
//
//export KilitTorStop
func KilitTorStop() {
	Stop()
}

// KilitTorFree frees a string this library returned.
//
//export KilitTorFree
func KilitTorFree(s *C.char) {
	C.free(unsafe.Pointer(s))
}

// a c-shared library still needs a main package with a main
func main() {}
