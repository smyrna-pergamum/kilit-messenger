#!/bin/sh
# Builds libkilittor.so for Android into the app's jniLibs. Runs in the
# kilit-android image (Go and the NDK pinned there):
#
#   docker run --rm -v "$PWD:/src" -v kilit-gomod:/root/go/pkg/mod \
#     -v kilit-gocache:/root/.cache/go-build -w /src/engine-tor \
#     kilit-android sh build.sh
#
# Modules come from the Go proxy and are checked against go.sum. go-libtor
# is built from a patched copy (patches/README.md).
set -eu
cd "$(dirname "$0")"
HERE=$(pwd)

NDK="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
OUT="${JNI_LIBS_DIR:-../app/android/app/src/main/jniLibs}"

# go-libtor, verified, copied and patched outside the repository
go mod download github.com/alexballas/go-libtor
SRC=$(go list -m -f '{{.Dir}}' github.com/alexballas/go-libtor)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cp -r "$SRC" "$WORK/go-libtor"
chmod -R u+w "$WORK/go-libtor"
patch -s -p1 -d "$WORK/go-libtor" < patches/go-libtor.patch
cat > "$WORK/go.work" <<EOF
go 1.26.9

use $HERE

replace github.com/alexballas/go-libtor => $WORK/go-libtor
EOF
export GOWORK="$WORK/go.work"

export GOFLAGS="-trimpath -buildvcs=false"
export CGO_ENABLED=1
# tor, OpenSSL, libevent and zlib are C that parses bytes from the network
export CGO_CFLAGS="-O2 -g -fstack-protector-strong -D_FORTIFY_SOURCE=2"
export CGO_LDFLAGS="-Wl,--build-id=none"
LDFLAGS="-buildid= -w -s"

build() { # abi goarch clang [goarm]
  mkdir -p "$OUT/$1"
  # the patched headers are not seen by Go's cache: always rebuild
  CC="$NDK/$3" GOOS=android GOARCH="$2" GOARM="${4:-}" \
    go build -a -buildmode=c-shared -ldflags "$LDFLAGS" -o "$OUT/$1/libkilittor.so" .
  rm -f "$OUT/$1/libkilittor.h"
  echo "built $1"
}

build arm64-v8a arm64 aarch64-linux-android24-clang
build armeabi-v7a arm armv7a-linux-androideabi24-clang 7
build x86_64 amd64 x86_64-linux-android24-clang
ls -la "$OUT"/*/libkilittor.so
