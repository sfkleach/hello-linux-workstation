#!/usr/bin/env bash
# modules/60-node.sh — fnm + Node LTS, needed only to run the Claude Code CLI installer.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v fnm &>/dev/null; then
    info "Installing fnm…"
    INSTALLER="$(mktemp --suffix=.sh)"
    trap 'rm -f "$INSTALLER"' EXIT
    curl --proto '=https' --proto-redir '=https' -fsSL https://fnm.vercel.app/install -o "$INSTALLER"
    bash "$INSTALLER" --skip-shell
    success "fnm installed."
else
    success "fnm already installed."
fi

export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &>/dev/null; then
    eval "$(fnm env 2>/dev/null)" || true
fi

if ! fnm list | grep -q lts-latest 2>/dev/null; then
    info "Installing Node LTS via fnm…"
    fnm install --lts
    fnm default lts-latest
fi
success "Node (LTS) via fnm ready."
