#!/usr/bin/env bash
# modules/20-git.sh — git, SSH key, lazygit, SmartGit.
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

if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    info "Generating SSH key…"
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$HOME/.ssh/id_ed25519" -N ""
    success "SSH key generated at ~/.ssh/id_ed25519 — add ~/.ssh/id_ed25519.pub to GitHub/GitLab."
else
    success "SSH key already present."
fi

if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit…"
    LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    curl -fLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar -C /tmp -xzf /tmp/lazygit.tar.gz lazygit
    sudo install /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
    success "lazygit installed."
else
    success "lazygit already installed."
fi

if ! command -v smartgit &>/dev/null; then
    info "Installing SmartGit…"
    curl -fsSL https://www.syntevo.com/downloads/smartgit/smartgit-repository.pub | sudo gpg --dearmor -o /usr/share/keyrings/smartgit-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/smartgit-archive-keyring.gpg] https://www.syntevo.com/downloads/smartgit/deb/ generic main" \
        | sudo tee /etc/apt/sources.list.d/smartgit.list >/dev/null
    sudo apt-get update -q
    apt_install_if_missing smartgit
else
    success "SmartGit already installed."
fi
