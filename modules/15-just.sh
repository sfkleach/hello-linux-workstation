#!/usr/bin/env bash
# modules/15-just.sh — the `just` command runner, via the official prebuilt
# binaries. To build from source instead, `cargo install just` works once
# 50-rust.sh has run.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v just &>/dev/null; then
    success "just already installed."
else
    info "Installing just…"
    mkdir -p "$HOME/.local/bin"
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"
    success "just installed to ~/.local/bin."
fi
