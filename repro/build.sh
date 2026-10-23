#!/usr/bin/env bash
# Builds and checks Kilit inside the pinned container (repro/Dockerfile).
#
#   ./repro/build.sh test      fmt, clippy and tests for core/ (default)
#   ./repro/build.sh shell     a shell in the core image, repository at /src
#   ./repro/build.sh android   build the android image (Aşama 1 onwards)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cmd=${1:-test}

image() { # target
  docker build --target "$1" -t "kilit-$1" -f "$root/repro/Dockerfile" "$root"
}

run() { # image, command...
  local img=$1; shift
  # runs as the calling user, so core/target and Cargo.lock stay theirs
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$root:/src" \
    -w /src/core "$img" "$@"
}

case "$cmd" in
  test)
    image core
    run kilit-core sh -c 'cargo fmt --all --check && cargo clippy --workspace --all-targets -- -D warnings && cargo test --workspace'
    ;;
  shell)
    image core
    run kilit-core bash
    ;;
  android)
    image android
    ;;
  *)
    echo "usage: $0 [test|shell|android]" >&2
    exit 2
    ;;
esac
