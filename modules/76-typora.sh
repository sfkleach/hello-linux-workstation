#!/usr/bin/env bash
# modules/76-typora.sh — Typora, via its own apt repo (not in Mint's repos).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v typora &>/dev/null; then
    success "Typora already installed."
    exit 0
fi

info "Installing Typora…"
if ! curl -fsSL https://typora.io/linux/public-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/typora-archive-keyring.gpg; then
    warn "Could not fetch Typora's signing key — check https://typora.io/#linux for current install instructions."
    exit 1
fi

echo "deb [signed-by=/usr/share/keyrings/typora-archive-keyring.gpg] https://typora.io/linux ./" \
    | sudo tee /etc/apt/sources.list.d/typora.list >/dev/null
sudo apt-get update -q
apt_install_if_missing typora
