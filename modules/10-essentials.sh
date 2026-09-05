#!/usr/bin/env bash
# modules/10-essentials.sh — system update + core CLI tools.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

info "Updating package lists and upgrading system…"
sudo apt-get update -q
sudo apt-get upgrade -y

apt_install_if_missing \
    build-essential \
    curl \
    wget \
    ca-certificates \
    gnupg \
    unzip \
    jq \
    htop \
    tree \
    ripgrep:rg \
    fd-find:fdfind \
    bat:batcat

success "Essentials installed."
