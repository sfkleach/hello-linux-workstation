#!/usr/bin/env bash
# modules/30-python.sh — uv, the fast Python toolchain manager.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v uv &>/dev/null; then
    info "Installing uv…"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    success "uv installed."
else
    success "uv already installed."
fi
