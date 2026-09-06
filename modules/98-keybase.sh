#!/usr/bin/env bash
# modules/98-keybase.sh — Keybase, from the official .deb, per
# https://keybase.io/docs/the_app/install_linux. Runs right before
# SmartGit (99-smartgit.sh) as requested.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v keybase &>/dev/null; then
    success "Keybase already installed."
    exit 0
fi

info "Installing Keybase…"
KEYBASE_DEB="$(mktemp --suffix=.deb)"
trap 'rm -f "$KEYBASE_DEB"' EXIT
curl -fLo "$KEYBASE_DEB" https://prerelease.keybase.io/keybase_amd64.deb
sudo apt-get install -y "$KEYBASE_DEB"
success "Keybase installed."

info "Launching run_keybase to finish setup (this opens the app for account setup)…"
run_keybase
