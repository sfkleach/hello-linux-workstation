#!/usr/bin/env bash
# modules/90-claude-code.sh — Claude Code CLI (needs Node/npm from 60-node.sh).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &>/dev/null; then
    eval "$(fnm env 2>/dev/null)" || true
fi

if ! command -v claude &>/dev/null; then
    info "Installing Claude Code CLI…"
    npm install -g @anthropic-ai/claude-code
    success "Claude Code CLI installed."
else
    success "Claude Code CLI already installed."
fi
