#!/usr/bin/env bash
# modules/73-keepassxc.sh — KeePassXC, native Mint/Debian package.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

apt_install_if_missing keepassxc
success "KeePassXC ready."
