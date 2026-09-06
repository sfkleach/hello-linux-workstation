#!/usr/bin/env bash
# modules/78-balena-etcher.sh — balenaEtcher, via the official AppImage.
# The .deb route (balena's own Cloudsmith apt repo) depends on gconf2,
# which no longer exists in current Debian/Ubuntu/Mint repos at all — so
# this installs the self-contained AppImage instead, same idea as
# 99-smartgit.sh choosing the tarball over its .deb.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

INSTALL_PATH="/opt/balenaEtcher.AppImage"

if [[ -x "$INSTALL_PATH" ]]; then
    success "balenaEtcher already installed."
    exit 0
fi

# AppImages need FUSE to run; recent Ubuntu/Mint (24.04-based) renamed the
# package to libfuse2t64, older ones still call it libfuse2 — try both.
sudo apt-get install -y libfuse2t64 2>/dev/null || sudo apt-get install -y libfuse2 2>/dev/null \
    || warn "Could not install libfuse2/libfuse2t64 — AppImages may fail to run without FUSE."

info "Fetching latest balenaEtcher release info…"
if ! RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/balena-io/etcher/releases/latest"); then
    warn "Could not reach GitHub's API to look up the latest balenaEtcher release."
    warn "Check https://github.com/balena-io/etcher/releases and update this module."
    exit 1
fi

# grep exits 1 on no match, which would otherwise trip set -e/pipefail before
# we get a chance to report a useful error — so don't let that kill the script.
APPIMAGE_URL=$(echo "$RELEASE_JSON" \
    | grep -o '"browser_download_url": *"[^"]*x64\.AppImage"' \
    | grep -o 'https://[^"]*' \
    | head -1) || true

if [[ -z "$APPIMAGE_URL" ]]; then
    warn "Could not find a balenaEtcher AppImage in the latest GitHub release."
    warn "Check https://github.com/balena-io/etcher/releases and update this module."
    exit 1
fi

info "Installing balenaEtcher from $APPIMAGE_URL…"
sudo curl -fLo "$INSTALL_PATH" "$APPIMAGE_URL"
sudo chmod +x "$INSTALL_PATH"
sudo ln -sf "$INSTALL_PATH" /usr/local/bin/balena-etcher
success "balenaEtcher installed (launch: balena-etcher)."
