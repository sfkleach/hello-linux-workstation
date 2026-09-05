#!/usr/bin/env bash
# setup.sh — set up a Linux Mint workstation from a fresh install.
# Run as a normal user (sudo is invoked internally where needed).
# Safe to re-run: every module skips work that's already done.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

FAILED_MODULES=()
for module in "$ROOT_DIR"/modules/*.sh; do
    info "── Running $(basename "$module") ──"
    if ! bash "$module"; then
        warn "$(basename "$module") failed — continuing with the remaining modules."
        FAILED_MODULES+=("$(basename "$module")")
    fi
done

info "Wiring up ~/.bashrc…"
add_to_bashrc "# --- hello-linux-workstation ---" "source \"$ROOT_DIR/dotfiles/bashrc.d/path.sh\""

echo
if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
    warn "Setup finished, but these modules failed: ${FAILED_MODULES[*]}"
    warn "Re-run ./setup.sh (or just the failed module) after investigating — everything else already ran."
else
    success "Workstation setup complete!"
fi
warn "Start a new shell (or run: source ~/.bashrc) to pick up PATH changes."
