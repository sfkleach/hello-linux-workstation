#!/usr/bin/env bash
# modules/78-balena-etcher.sh — balenaEtcher, via balena's own Cloudsmith
# apt repo (not in Mint's repos).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v balena-etcher-electron &>/dev/null; then
    success "balenaEtcher already installed."
    exit 0
fi

info "Installing balenaEtcher…"
REPO_SCRIPT_URL="https://dl.cloudsmith.io/public/balena/etcher/setup.deb.sh"
if ! curl -1sLf "$REPO_SCRIPT_URL" | sudo -E bash; then
    warn "Could not set up balena's apt repo from $REPO_SCRIPT_URL"
    warn "Check https://etcher.balena.io/#download-etcher for current install instructions."
    exit 1
fi

apt_install_if_missing balena-etcher-electron
