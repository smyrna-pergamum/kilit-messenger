#!/usr/bin/env bash
# Kilit: step 2 of the build environment, inside WSL2 Ubuntu 24.04.
# Installs Docker Engine from Docker's own apt repository (no Docker Desktop)
# and checks the repository's signing key fingerprint before trusting it.
#   bash scripts/setup-dev.sh
set -euo pipefail

DOCKER_KEY_FPR="9DC858229FC7DD38854AE2D88D81803C0EBFCD88"

if ! grep -qi microsoft /proc/version; then
  echo "this script is meant for WSL2 Ubuntu" >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git

tmp=$(mktemp)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$tmp"
got=$(gpg --show-keys --with-colons "$tmp" | awk -F: '/^fpr:/{print $10; exit}')
if [ "$got" != "$DOCKER_KEY_FPR" ]; then
  echo "docker signing key fingerprint mismatch: $got" >&2
  exit 1
fi
sudo install -m 0755 -d /etc/apt/keyrings
sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg "$tmp"
rm -f "$tmp"

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# WSL2 Ubuntu 24.04 boots with systemd, so the service starts on its own.
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo
echo "Docker is installed. Close this terminal and open a new one so the"
echo "docker group applies, then from the repository run:  ./repro/build.sh test"
