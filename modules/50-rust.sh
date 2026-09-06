#!/usr/bin/env bash
# modules/50-rust.sh — Rust via rustup.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v rustup &>/dev/null; then
    info "Installing Rust via rustup…"
    INSTALLER="$(mktemp --suffix=.sh)"
    trap 'rm -f "$INSTALLER"' EXIT
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$INSTALLER"
    sh "$INSTALLER" -y --no-modify-path
    success "Rust installed."
else
    success "Rust already installed."
fi

# shellcheck source=/dev/null
source "$HOME/.cargo/env" 2>/dev/null || true
rustup update stable --no-self-update
