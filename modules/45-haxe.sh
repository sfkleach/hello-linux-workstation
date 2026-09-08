#!/usr/bin/env bash
# modules/45-haxe.sh — Haxe, via the community-maintained haxe/releases PPA.
# Debian/Ubuntu/Mint's own apt archive lags well behind current Haxe
# releases; this PPA is maintained specifically to track them. Installing
# via apt also pulls in neko (Haxe's companion VM, needed by haxelib and
# some targets) automatically as a dependency — no separate install needed.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v haxe &>/dev/null; then
    apt_install_if_missing software-properties-common:add-apt-repository
    info "Adding the haxe/releases PPA…"
    sudo add-apt-repository -y ppa:haxe/releases
    sudo apt-get update -q
    apt_install_if_missing haxe
    success "Haxe installed."
else
    success "Haxe already installed."
fi

if command -v haxelib &>/dev/null && [[ ! -f "$HOME/.haxelib" ]]; then
    info "Running haxelib setup…"
    mkdir -p "$HOME/haxelib"
    haxelib setup "$HOME/haxelib" || warn "'haxelib setup' didn't complete automatically — run it manually: haxelib setup ~/haxelib"
fi
