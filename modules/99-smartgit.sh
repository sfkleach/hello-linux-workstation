#!/usr/bin/env bash
# modules/99-smartgit.sh — SmartGit, last of all: it depends on syntevo's own
# apt repo, which has proven flaky (their published key URL 404'd once
# already). Isolated here so a failure never blocks the rest of the setup —
# setup.sh treats a module failing as a warning, not a fatal error.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if command -v smartgit &>/dev/null; then
    success "SmartGit already installed."
    exit 0
fi

info "Installing SmartGit…"
KEY_URL="https://www.syntevo.com/downloads/smartgit/smartgit-repository.pub"

if ! curl -fsSL "$KEY_URL" -o /tmp/smartgit-repository.pub; then
    warn "Could not fetch SmartGit's signing key from $KEY_URL (syntevo may have moved it)."
    warn "Check https://www.syntevo.com/smartgit/download/ for current install instructions and update this module."
    exit 1
fi

sudo gpg --dearmor -o /usr/share/keyrings/smartgit-archive-keyring.gpg /tmp/smartgit-repository.pub
rm -f /tmp/smartgit-repository.pub

echo "deb [signed-by=/usr/share/keyrings/smartgit-archive-keyring.gpg] https://www.syntevo.com/downloads/smartgit/deb/ generic main" \
    | sudo tee /etc/apt/sources.list.d/smartgit.list >/dev/null
sudo apt-get update -q
apt_install_if_missing smartgit
