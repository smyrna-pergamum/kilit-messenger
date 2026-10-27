# Patches to go-libtor

`go-libtor.patch` is taken unchanged from Kryfo
(https://github.com/GnosiWorks/Kryfo, `engine/vendor-patches/go-libtor.patch`,
commit 2660ae8, GPL-3.0-or-later). go-libtor v1.0.8 ships libevent and
OpenSSL headers generated on a 64-bit Linux machine, which breaks Android
builds in two ways:

- libevent's config says `epoll_pwait2` exists. Android's libc has it only
  from API 35, so the build fails for any older target.
- OpenSSL and libevent assume an eight-byte `long`. On 32-bit ARM it is
  four, so a 32-bit build compiles but Tor never connects.

The patch unsets `EVENT__HAVE_EPOLL_PWAIT2` and switches the word sizes on
go-libtor's own `ARCH_*32` defines.

`build.sh` copies the module from Go's module cache (checked against
`go.sum`), applies the patch to the copy and builds against it through a
temporary `go.work`; nothing patched is kept in the repository.

## anet

`anet.patch`, also from Kryfo (`engine/vendor-patches/anet.patch`).
snowflake lists network interfaces on Android through wlynxg/anet, whose
`interface_android.go` reaches into two private caches of `net` and
`x/net` with `go:linkname`. Go 1.23 and later refuse that at link time.
The patch keeps both caches inside anet.

## snowflake

`third_party/snowflake` is Kryfo's client-only copy of snowflake v2.14.1
(BSD-3-Clause, its LICENSE kept): no SQS rendezvous and so no AWS SDK, an
error instead of `log.Fatal` (which would end the app), and no logging of
broker addresses. go.mod points at it with a `replace`.

