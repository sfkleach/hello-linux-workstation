#!/usr/bin/env bash
# modules/30-python.sh — uv, the fast Python toolchain manager.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v uv &>/dev/null; then
    info "Installing uv…"
    INSTALLER="$(mktemp --suffix=.sh)"
    trap 'rm -f "$INSTALLER"' EXIT
    curl --proto '=https' --proto-redir '=https' -LsSf https://astral.sh/uv/install.sh -o "$INSTALLER"
    sh "$INSTALLER"
    success "uv installed."
else
    success "uv already installed."
fi
