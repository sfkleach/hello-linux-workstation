#!/usr/bin/env bash
# setup.sh — automate a fresh Linux workstation setup
# Run as a normal user (sudo is invoked internally where needed).
# Safe to re-run; all installs are idempotent.

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Package-manager detection ─────────────────────────────────────────────────
detect_pm() {
    if command -v apt-get &>/dev/null;  then echo apt
    elif command -v dnf &>/dev/null;    then echo dnf
    elif command -v pacman &>/dev/null; then echo pacman
    else die "No supported package manager found (apt/dnf/pacman)."
    fi
}

PM=$(detect_pm)
info "Package manager: $PM"

pkg_install() {
    case "$PM" in
        apt)    sudo apt-get install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
        pacman) sudo pacman -S --noconfirm --needed "$@" ;;
    esac
}

pkg_update() {
    case "$PM" in
        apt)    sudo apt-get update -q && sudo apt-get upgrade -y ;;
        dnf)    sudo dnf upgrade -y ;;
        pacman) sudo pacman -Syu --noconfirm ;;
    esac
}

cmd_exists() { command -v "$1" &>/dev/null; }

# ── Section toggle: set any to "no" to skip ───────────────────────────────────
INSTALL_SYSTEM_UPDATES="${INSTALL_SYSTEM_UPDATES:-yes}"
INSTALL_ESSENTIALS="${INSTALL_ESSENTIALS:-yes}"
INSTALL_SHELL="${INSTALL_SHELL:-yes}"
INSTALL_GIT="${INSTALL_GIT:-yes}"
INSTALL_EDITORS="${INSTALL_EDITORS:-yes}"
INSTALL_PYTHON="${INSTALL_PYTHON:-yes}"
INSTALL_NODE="${INSTALL_NODE:-yes}"
INSTALL_RUST="${INSTALL_RUST:-yes}"
INSTALL_GO="${INSTALL_GO:-no}"
INSTALL_DOCKER="${INSTALL_DOCKER:-yes}"
INSTALL_CLI_TOOLS="${INSTALL_CLI_TOOLS:-yes}"
INSTALL_FONTS="${INSTALL_FONTS:-yes}"

if [[ "$INSTALL_SYSTEM_UPDATES" == yes ]]; then
    info "Updating system packages…"
    pkg_update
    success "System up to date."
fi

if [[ "$INSTALL_ESSENTIALS" == yes ]]; then
    info "Installing essential tools…"
    pkg_install build-essential curl wget ca-certificates gnupg \
        software-properties-common apt-transport-https \
        unzip zip tar xz-utils jq htop tree stow
    success "Essential tools installed."
fi

if [[ "$INSTALL_GIT" == yes ]]; then
    cmd_exists git || pkg_install git
    if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
        read -rp "Git user.name: " GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi
    if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
        read -rp "Git user.email: " GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    success "Git configured."
fi

if [[ "$INSTALL_PYTHON" == yes ]]; then
    cmd_exists uv || curl -LsSf https://astral.sh/uv/install.sh | sh
    success "Python toolchain (uv) ready."
fi

if [[ "$INSTALL_NODE" == yes ]]; then
    if [[ ! -d "$HOME/.nvm" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm alias default lts/*
    success "Node.js (LTS) via nvm."
fi

if [[ "$INSTALL_RUST" == yes ]]; then
    cmd_exists rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env" 2>/dev/null || true
    rustup update stable --no-self-update
    success "Rust toolchain ready."
fi

if [[ "$INSTALL_GO" == yes ]]; then
    if ! cmd_exists go; then
        GO_VER="1.23.6"
        curl -fsSL "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
    fi
    success "Go installed at /usr/local/go."
fi

echo
echo -e "${GREEN}Setup complete!${NC}"
