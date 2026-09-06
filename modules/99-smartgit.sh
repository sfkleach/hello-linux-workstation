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
SMARTGIT_ARCHIVE="$(mktemp --suffix=.tar.gz)"
EXTRACT_DIR="$(mktemp -d)"
trap 'rm -f "$SMARTGIT_ARCHIVE"; rm -rf "$EXTRACT_DIR"' EXIT
curl -fLo "$SMARTGIT_ARCHIVE" \
    "https://download.smartgit.dev/smartgit/smartgit-${SMARTGIT_VERSION}-linux-amd64.tar.gz"
tar -C "$EXTRACT_DIR" -xzf "$SMARTGIT_ARCHIVE"

# Don't assume the archive's internal layout — find the launcher wherever it lands.
LAUNCHER=$(find "$EXTRACT_DIR" -maxdepth 3 -name "smartgit.sh" -path "*/bin/*" | head -1)
if [[ -z "$LAUNCHER" ]]; then
    warn "Extracted SmartGit but couldn't find bin/smartgit.sh under $EXTRACT_DIR — check the archive layout manually."
    exit 1
fi
UNPACKED_ROOT=$(dirname "$(dirname "$LAUNCHER")")

sudo rm -rf "$INSTALL_DIR"
sudo mv "$UNPACKED_ROOT" "$INSTALL_DIR"
sudo ln -sf "$INSTALL_DIR/bin/smartgit.sh" /usr/local/bin/smartgit
success "SmartGit ${SMARTGIT_VERSION} installed to $INSTALL_DIR (launch: smartgit)."

if [[ -x "$INSTALL_DIR/bin/add-menuitem.sh" ]]; then
    info "Creating SmartGit menu item…"
    "$INSTALL_DIR/bin/add-menuitem.sh"
    success "SmartGit menu item created."
else
    warn "No bin/add-menuitem.sh found under $INSTALL_DIR — skipping menu item."
fi
