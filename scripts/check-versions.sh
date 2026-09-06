#!/usr/bin/env bash
# scripts/check-versions.sh — report any hardcoded tool versions in modules/
# that are behind the current upstream release. Read-only: never installs
# or modifies anything, just compares and prints. Run via `just versions`.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

report() {
    local name="$1" current="$2" latest="$3"
    if [[ -z "$latest" ]]; then
        printf "  %-14s current=%-14s latest=?             (couldn't determine — check manually)\n" "$name" "$current"
    elif [[ "$current" == "$latest" ]]; then
        printf "  %-14s current=%-14s up to date\n" "$name" "$current"
    else
        printf "  %-14s current=%-14s latest=%-14s UPDATE AVAILABLE\n" "$name" "$current" "$latest"
    fi
}

echo "Checking hardcoded versions against upstream (best-effort; some of"
echo "these have no real API and are scraped from a download page):"
echo

# Go — has a real JSON API, so this one should be reliable.
GO_CURRENT=$(grep -oP 'GO_VERSION="\K[^"]+' modules/40-golang.sh)
GO_LATEST=$(curl -fsSL 'https://go.dev/dl/?mode=json' 2>/dev/null | grep -oP '"version":\s*"go\K[^"]+' | head -1)
report "Go" "$GO_CURRENT" "$GO_LATEST"

# SmartGit — no API; scrape the download page for a version-shaped string.
SG_CURRENT=$(grep -oP 'SMARTGIT_VERSION="\K[^"]+' modules/99-smartgit.sh)
SG_LATEST=$(curl -fsSL 'https://www.syntevo.com/smartgit/download/' 2>/dev/null | grep -oP 'smartgit-\K[0-9]+_[0-9]+_[0-9]+' | head -1)
report "SmartGit" "$SG_CURRENT" "$SG_LATEST"

# Proton Mail — no API; scrape the download page for a version-shaped path segment.
PM_CURRENT=$(grep -oP 'PROTONMAIL_VERSION="\K[^"]+' modules/77-protonmail.sh)
PM_LATEST=$(curl -fsSL 'https://proton.me/mail/download' 2>/dev/null | grep -oP '/mail/linux/\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
report "Proton Mail" "$PM_CURRENT" "$PM_LATEST"

echo
echo "Everything else (just, lazygit, balenaEtcher, rustup, uv, fnm/Node,"
echo "VS Code, Chromium, Typora, Podman, KeePassXC, Keybase, Claude Code CLI)"
echo "already installs whatever is currently latest — nothing to check."
