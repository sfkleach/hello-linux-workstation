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
curl -fLo /tmp/keybase_amd64.deb https://prerelease.keybase.io/keybase_amd64.deb
sudo apt-get install -y /tmp/keybase_amd64.deb
rm -f /tmp/keybase_amd64.deb
success "Keybase installed."

info "Launching run_keybase to finish setup (this opens the app for account setup)…"
run_keybase
