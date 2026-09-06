#!/usr/bin/env bash
# modules/77-protonmail-bridge.sh — Proton Mail Bridge, from the official
# .deb (no apt repo is published). Lets IMAP/SMTP clients like Thunderbird
# talk to Proton Mail locally.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v protonmail-bridge &>/dev/null; then
    success "Proton Mail Bridge already installed."
    exit 0
fi

# Bump from https://proton.me/mail/bridge#download when a newer release is wanted.
BRIDGE_VERSION="3.14.0"
DEB_URL="https://proton.me/download/bridge/protonmail-bridge_${BRIDGE_VERSION}-1_amd64.deb"

info "Installing Proton Mail Bridge ${BRIDGE_VERSION}…"
if ! curl -fLo /tmp/protonmail-bridge.deb "$DEB_URL"; then
    warn "Could not fetch Proton Mail Bridge from $DEB_URL"
    warn "Check https://proton.me/mail/bridge#download for the current version/URL and update this module."
    exit 1
fi

sudo apt-get install -y /tmp/protonmail-bridge.deb
rm -f /tmp/protonmail-bridge.deb
success "Proton Mail Bridge ${BRIDGE_VERSION} installed. Run 'protonmail-bridge' to set it up."
