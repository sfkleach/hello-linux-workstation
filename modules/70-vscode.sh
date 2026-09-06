#!/usr/bin/env bash
# modules/70-vscode.sh — VS Code. Extensions are managed by the user, not this script.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v code &>/dev/null; then
    info "Installing VS Code…"
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo apt-get update -q
    apt_install_if_missing code
else
    success "VS Code already installed."
fi
