#!/usr/bin/env bash
# modules/99-smartgit.sh — SmartGit, installed from the official tarball
# (syntevo explicitly doesn't recommend the .deb bundle). Runs last, after
# everything else, since a version bump here is a manual edit rather than
# something a package manager tracks automatically.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Bump from https://www.syntevo.com/smartgit/download/ when a newer release is wanted.
SMARTGIT_VERSION="26_1_052"
INSTALL_DIR="/opt/smartgit"

if command -v smartgit &>/dev/null; then
    success "SmartGit already installed."
    exit 0
fi

info "Installing SmartGit ${SMARTGIT_VERSION}…"
curl -fLo /tmp/smartgit.tar.gz \
    "https://download.smartgit.dev/smartgit/smartgit-${SMARTGIT_VERSION}-linux-amd64.tar.gz"

EXTRACT_DIR=$(mktemp -d)
tar -C "$EXTRACT_DIR" -xzf /tmp/smartgit.tar.gz
rm -f /tmp/smartgit.tar.gz

# Don't assume the archive's internal layout — find the launcher wherever it lands.
LAUNCHER=$(find "$EXTRACT_DIR" -maxdepth 3 -name "smartgit.sh" -path "*/bin/*" | head -1)
if [[ -z "$LAUNCHER" ]]; then
    warn "Extracted SmartGit but couldn't find bin/smartgit.sh under $EXTRACT_DIR — check the archive layout manually."
    exit 1
fi
UNPACKED_ROOT=$(dirname "$(dirname "$LAUNCHER")")

sudo rm -rf "$INSTALL_DIR"
sudo mv "$UNPACKED_ROOT" "$INSTALL_DIR"
rm -rf "$EXTRACT_DIR"
sudo ln -sf "$INSTALL_DIR/bin/smartgit.sh" /usr/local/bin/smartgit
success "SmartGit ${SMARTGIT_VERSION} installed to $INSTALL_DIR (launch: smartgit)."
