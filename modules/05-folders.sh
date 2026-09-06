#!/usr/bin/env bash
# modules/05-folders.sh — standard top-level folder layout.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

mkdir -p "$HOME/org" "$HOME/com" "$HOME/projects"
success "Top-level folders ready: ~/org ~/com ~/projects"
