#!/usr/bin/env bash
# modules/78-balena-etcher.sh — balenaEtcher, from the official Linux zip.
# The .deb route (balena's own Cloudsmith apt repo) depends on gconf2,
# which no longer exists in current Debian/Ubuntu/Mint repos at all, and
# recent releases don't publish an AppImage either — just this zipped,
# pre-extracted Electron app. Same idea as 99-smartgit.sh: unpack and
# discover the binary rather than assume a package format that doesn't
# actually exist for this tool anymore.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

INSTALL_DIR="/opt/balenaEtcher"

if command -v balena-etcher &>/dev/null; then
    success "balenaEtcher already installed."
    exit 0
fi

info "Fetching latest balenaEtcher release info…"
if ! RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/balena-io/etcher/releases/latest"); then
    warn "Could not reach GitHub's API to look up the latest balenaEtcher release."
    warn "Check https://github.com/balena-io/etcher/releases and update this module."
    exit 1
fi

# grep exits 1 on no match, which would otherwise trip set -e/pipefail before
# we get a chance to report a useful error — so don't let that kill the script.
ZIP_URL=$(echo "$RELEASE_JSON" \
    | grep -o '"browser_download_url": *"[^"]*balenaEtcher-linux-x64-[^"]*\.zip"' \
    | grep -o 'https://[^"]*' \
    | head -1) || true

if [[ -z "$ZIP_URL" ]]; then
    warn "Could not find a balenaEtcher Linux zip in the latest GitHub release."
    warn "Check https://github.com/balena-io/etcher/releases and update this module."
    exit 1
fi

info "Installing balenaEtcher from $ZIP_URL…"
curl -fLo /tmp/balena-etcher.zip "$ZIP_URL"

EXTRACT_DIR=$(mktemp -d)
unzip -q /tmp/balena-etcher.zip -d "$EXTRACT_DIR"
rm -f /tmp/balena-etcher.zip

# Don't assume the archive's internal layout — find the main executable
# wherever it lands (case-insensitive: "balenaEtcher" or "balena-etcher").
BINARY=$(find "$EXTRACT_DIR" -maxdepth 2 -type f -iname "balena*etcher*" -perm -u+x | head -1)
if [[ -z "$BINARY" ]]; then
    warn "Extracted balenaEtcher but couldn't find its executable under $EXTRACT_DIR — check the archive layout manually."
    exit 1
fi
UNPACKED_ROOT=$(dirname "$BINARY")

sudo rm -rf "$INSTALL_DIR"
sudo mv "$UNPACKED_ROOT" "$INSTALL_DIR"
rm -rf "$EXTRACT_DIR"
sudo ln -sf "$INSTALL_DIR/$(basename "$BINARY")" /usr/local/bin/balena-etcher
success "balenaEtcher installed to $INSTALL_DIR (launch: balena-etcher)."
