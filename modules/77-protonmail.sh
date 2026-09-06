#!/usr/bin/env bash
# modules/77-protonmail.sh — Proton Mail desktop app, from the official
# .deb (no apt repo is published). Replaces an earlier attempt at Proton
# Mail Bridge, which kept breaking itself via its own auto-updater.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v proton-mail &>/dev/null; then
    success "Proton Mail already installed."
    exit 0
fi

# Bump from https://proton.me/mail/download when a newer release is wanted.
# The filename itself is fixed ("-beta" and all); only the version in the path changes.
PROTONMAIL_VERSION="1.13.4"
DEB_URL="https://proton.me/download/mail/linux/${PROTONMAIL_VERSION}/ProtonMail-desktop-beta.deb"

info "Installing Proton Mail ${PROTONMAIL_VERSION}…"
if ! curl -fLo /tmp/protonmail.deb "$DEB_URL"; then
    warn "Could not fetch Proton Mail from $DEB_URL"
    warn "Check https://proton.me/mail/download for the current version/URL and update this module."
    exit 1
fi

sudo apt-get install -y /tmp/protonmail.deb
rm -f /tmp/protonmail.deb
success "Proton Mail ${PROTONMAIL_VERSION} installed."
