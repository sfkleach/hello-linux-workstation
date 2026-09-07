#!/usr/bin/env bash
# modules/20-git.sh — git, SSH key, lazygit.
# SmartGit lives in 99-smartgit.sh: its third-party repo is fragile, so it
# runs last, after everything else has had a chance to install.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

apt_install_if_missing git

if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    read -rp "Git user.name: " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi
if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    read -rp "Git user.email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi
git config --global init.defaultBranch main
success "Git configured."

# Only generate a key on a machine with none at all. Checking for the single
# literal filename id_ed25519 isn't enough — plenty of existing setups keep
# their real key under a different name (e.g. git_ed25519) referenced from
# ~/.ssh/config, and blindly generating id_ed25519 alongside it doesn't
# touch that key, but does add a new, unregistered identity that OpenSSH
# will also offer — which can break auth (e.g. hitting the server's
# MaxAuthTries) even though nothing was actually deleted.
mkdir -p "$HOME/.ssh"
if [[ -z "$(find "$HOME/.ssh" -maxdepth 1 -name '*.pub' -print -quit 2>/dev/null)" ]]; then
    info "No existing SSH keys found — generating one…"
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$HOME/.ssh/id_ed25519" -N ""
    success "SSH key generated at ~/.ssh/id_ed25519 — add ~/.ssh/id_ed25519.pub to GitHub/GitLab."
else
    success "Existing SSH key(s) found in ~/.ssh — leaving them alone."
fi

if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit…"
    if ! LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*'); then
        die "Could not determine the latest lazygit version from GitHub's API."
    fi
    LAZYGIT_ARCHIVE="$(mktemp --suffix=.tar.gz)"
    LAZYGIT_EXTRACT_DIR="$(mktemp -d)"
    trap 'rm -f "$LAZYGIT_ARCHIVE"; rm -rf "$LAZYGIT_EXTRACT_DIR"' EXIT
    curl -fLo "$LAZYGIT_ARCHIVE" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -C "$LAZYGIT_EXTRACT_DIR" -xzf "$LAZYGIT_ARCHIVE" lazygit
    sudo install "$LAZYGIT_EXTRACT_DIR/lazygit" /usr/local/bin/lazygit
    success "lazygit installed."
else
    success "lazygit already installed."
fi
