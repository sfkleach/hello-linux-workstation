#!/usr/bin/env bash
# lib/common.sh — shared helpers sourced by every module.

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# apt_install_if_missing PKG[:SIGNATURE_CMD] ...
#
# Installs each PKG via apt, but skips any whose signature command already
# exists on PATH. Defaults the signature command to the package name when no
# ":cmd" override is given (most packages match their binary name; a few
# don't — e.g. ripgrep:rg, fd-find:fdfind, bat:batcat).
apt_install_if_missing() {
    local -a to_install=()
    local spec pkg sig
    for spec in "$@"; do
        pkg="${spec%%:*}"
        sig="${spec#*:}"
        [[ "$spec" == "$pkg" ]] && sig="$pkg"
        if command -v "$sig" &>/dev/null; then
            info "Skipping $pkg (found: $sig)"
        else
            to_install+=("$pkg")
        fi
    done
    if [[ ${#to_install[@]} -gt 0 ]]; then
        info "Installing: ${to_install[*]}"
        sudo apt-get install -y "${to_install[@]}"
    else
        success "Nothing to install — all present."
    fi
}

# add_to_bashrc MARKER LINE
#
# Appends LINE to ~/.bashrc exactly once, guarded by MARKER (a comment).
add_to_bashrc() {
    local marker="$1" line="$2"
    grep -qF "$marker" "$HOME/.bashrc" 2>/dev/null || \
        printf '\n%s\n%s\n' "$marker" "$line" >> "$HOME/.bashrc"
}
