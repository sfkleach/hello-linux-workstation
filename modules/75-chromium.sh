#!/usr/bin/env bash
# modules/75-chromium.sh — Chromium, the de-Googled base Chrome is built
# from. Linux Mint ships a genuine native package (unlike Ubuntu's, which
# is a Snap wrapper), so a plain apt install is all this needs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

apt_install_if_missing chromium
success "Chromium ready."
