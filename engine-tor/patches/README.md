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
