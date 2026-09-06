#!/usr/bin/env bash
# modules/10-essentials.sh — system update + core CLI tools.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

UPGRADE_MARKER="/tmp/.hello-linux-workstation-upgraded-$(date +%F)"
if [[ ! -f "$UPGRADE_MARKER" ]]; then
    info "Updating package lists and upgrading system…"
    sudo apt-get update -q
    sudo apt-get upgrade -y
    touch "$UPGRADE_MARKER"
else
    info "System already upgraded today — skipping (rm $UPGRADE_MARKER to force)."
fi

apt_install_if_missing \
    build-essential:gcc \
    curl \
    wget \
    ca-certificates:update-ca-certificates \
    gnupg:gpg \
    unzip \
    jq \
    htop \
    tree \
    ripgrep:rg \
    fd-find:fdfind \
    bat:batcat

success "Essentials installed."
