#!/usr/bin/env bash
# modules/80-podman.sh — Podman + podman-compose.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

apt_install_if_missing podman podman-compose
success "Podman ready."
