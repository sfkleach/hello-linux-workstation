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
INSTALL_SHELL="${INSTALL_SHELL:-yes}"         # zsh + oh-my-zsh
INSTALL_GIT="${INSTALL_GIT:-yes}"
INSTALL_EDITORS="${INSTALL_EDITORS:-yes}"     # neovim + VS Code
INSTALL_PYTHON="${INSTALL_PYTHON:-yes}"
INSTALL_NODE="${INSTALL_NODE:-yes}"           # via nvm
INSTALL_RUST="${INSTALL_RUST:-yes}"
INSTALL_GO="${INSTALL_GO:-no}"
INSTALL_DOCKER="${INSTALL_DOCKER:-yes}"
INSTALL_CLI_TOOLS="${INSTALL_CLI_TOOLS:-yes}" # fzf, ripgrep, bat, eza, etc.
INSTALL_FONTS="${INSTALL_FONTS:-yes}"         # Nerd Fonts

# ── 1. System update ──────────────────────────────────────────────────────────
if [[ "$INSTALL_SYSTEM_UPDATES" == yes ]]; then
    info "Updating system packages…"
    pkg_update
    success "System up to date."
fi

# ── 2. Essential build tools ──────────────────────────────────────────────────
if [[ "$INSTALL_ESSENTIALS" == yes ]]; then
    info "Installing essential tools…"
    case "$PM" in
        apt)
            pkg_install \
                build-essential curl wget ca-certificates gnupg \
                software-properties-common apt-transport-https \
                unzip zip tar xz-utils jq htop tree stow
            ;;
        dnf)
            pkg_install \
                gcc gcc-c++ make curl wget ca-certificates gnupg2 \
                unzip zip tar xz jq htop tree stow
            ;;
        pacman)
            pkg_install \
                base-devel curl wget ca-certificates gnupg \
                unzip zip tar xz jq htop tree stow
            ;;
    esac
    success "Essential tools installed."
fi

# ── 3. Zsh + Oh My Zsh ───────────────────────────────────────────────────────
if [[ "$INSTALL_SHELL" == yes ]]; then
    if ! cmd_exists zsh; then
        info "Installing zsh…"
        pkg_install zsh
    fi
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh My Zsh…"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended
    fi
    # Set zsh as default shell
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
        info "Setting zsh as default shell…"
        chsh -s "$(command -v zsh)" "$USER"
    fi
    success "Shell: zsh + Oh My Zsh."
fi

# ── 4. Git ────────────────────────────────────────────────────────────────────
if [[ "$INSTALL_GIT" == yes ]]; then
    if ! cmd_exists git; then
        info "Installing git…"
        pkg_install git
    fi
    # Prompt for identity only if not already set
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
    git config --global core.autocrlf input
    # Install gh CLI
    if ! cmd_exists gh; then
        info "Installing GitHub CLI (gh)…"
        case "$PM" in
            apt)
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
                    | sudo tee /etc/apt/sources.list.d/github-cli.list
                sudo apt-get update -q && pkg_install gh
                ;;
            dnf)    pkg_install gh ;;
            pacman) pkg_install github-cli ;;
        esac
    fi
    success "Git configured; gh CLI available."
fi

# ── 5. Editors ────────────────────────────────────────────────────────────────
if [[ "$INSTALL_EDITORS" == yes ]]; then
    # Neovim
    if ! cmd_exists nvim; then
        info "Installing neovim…"
        case "$PM" in
            apt)
                # Use the appimage to get a recent version
                NVIM_VER="v0.10.4"
                curl -fLo /tmp/nvim.appimage \
                    "https://github.com/neovim/neovim/releases/download/${NVIM_VER}/nvim-linux-x86_64.appimage"
                chmod +x /tmp/nvim.appimage
                sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
                ;;
            dnf)    pkg_install neovim ;;
            pacman) pkg_install neovim ;;
        esac
    fi
    # VS Code
    if ! cmd_exists code; then
        info "Installing VS Code…"
        case "$PM" in
            apt)
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
                    | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
                echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
                    | sudo tee /etc/apt/sources.list.d/vscode.list
                sudo apt-get update -q && pkg_install code
                ;;
            dnf)
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
                pkg_install code
                ;;
            pacman) pkg_install code ;;
        esac
    fi
    success "Editors: neovim, VS Code."
fi

# ── 6. Python ─────────────────────────────────────────────────────────────────
if [[ "$INSTALL_PYTHON" == yes ]]; then
    if ! cmd_exists python3; then
        info "Installing Python 3…"
        case "$PM" in
            apt)    pkg_install python3 python3-pip python3-venv python3-dev ;;
            dnf)    pkg_install python3 python3-pip python3-devel ;;
            pacman) pkg_install python python-pip ;;
        esac
    fi
    # pipx — isolated tool installs
    if ! cmd_exists pipx; then
        info "Installing pipx…"
        case "$PM" in
            apt)    pkg_install pipx ;;
            dnf)    pkg_install pipx ;;
            pacman) pkg_install python-pipx ;;
        esac
        pipx ensurepath
    fi
    # uv — fast Python toolchain manager
    if ! cmd_exists uv; then
        info "Installing uv…"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    success "Python toolchain ready."
fi

# ── 7. Node.js via nvm ────────────────────────────────────────────────────────
if [[ "$INSTALL_NODE" == yes ]]; then
    if [[ ! -d "$HOME/.nvm" ]]; then
        info "Installing nvm…"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    # Source nvm in this shell so we can use it immediately
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    if ! nvm ls --no-alias lts/* &>/dev/null 2>&1; then
        info "Installing Node.js LTS…"
        nvm install --lts
        nvm alias default lts/*
    fi
    success "Node.js (LTS) via nvm."
fi

# ── 8. Rust ───────────────────────────────────────────────────────────────────
if [[ "$INSTALL_RUST" == yes ]]; then
    if ! cmd_exists rustup; then
        info "Installing Rust via rustup…"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    fi
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env" 2>/dev/null || true
    rustup update stable --no-self-update
    success "Rust toolchain ready."
fi

# ── 9. Go ─────────────────────────────────────────────────────────────────────
if [[ "$INSTALL_GO" == yes ]]; then
    if ! cmd_exists go; then
        GO_VER="1.23.6"
        ARCH=$(uname -m); [[ "$ARCH" == x86_64 ]] && ARCH=amd64
        info "Installing Go ${GO_VER}…"
        curl -fsSL "https://go.dev/dl/go${GO_VER}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        # PATH entry added by dotfiles section below
    fi
    success "Go installed at /usr/local/go."
fi

# ── 10. Docker ────────────────────────────────────────────────────────────────
if [[ "$INSTALL_DOCKER" == yes ]]; then
    if ! cmd_exists docker; then
        info "Installing Docker…"
        case "$PM" in
            apt)
                curl -fsSL https://get.docker.com | sudo sh
                ;;
            dnf)
                pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo systemctl enable --now docker
                ;;
            pacman)
                pkg_install docker docker-compose
                sudo systemctl enable --now docker
                ;;
        esac
    fi
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER"
        warn "Added $USER to docker group. Log out and back in to use docker without sudo."
    fi
    success "Docker ready."
fi

# ── 11. CLI power tools ───────────────────────────────────────────────────────
if [[ "$INSTALL_CLI_TOOLS" == yes ]]; then
    info "Installing CLI power tools…"
    case "$PM" in
        apt)
            # fzf, ripgrep, bat, eza from apt where available; fall back to cargo
            pkg_install fzf ripgrep bat fd-find
            cmd_exists eza || cargo install eza 2>/dev/null || true
            cmd_exists delta || cargo install git-delta 2>/dev/null || true
            ;;
        dnf)
            pkg_install fzf ripgrep bat fd-find eza
            cmd_exists delta || cargo install git-delta 2>/dev/null || true
            ;;
        pacman)
            pkg_install fzf ripgrep bat fd eza git-delta
            ;;
    esac
    # tmux
    cmd_exists tmux || pkg_install tmux
    # starship prompt
    if ! cmd_exists starship; then
        info "Installing starship prompt…"
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
    success "CLI tools installed."
fi

# ── 12. Nerd Fonts (JetBrainsMono) ───────────────────────────────────────────
if [[ "$INSTALL_FONTS" == yes ]]; then
    FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
    if [[ ! -d "$FONT_DIR" ]]; then
        info "Installing JetBrainsMono Nerd Font…"
        mkdir -p "$FONT_DIR"
        curl -fLo /tmp/JetBrainsMono.zip \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        unzip -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
        rm /tmp/JetBrainsMono.zip
        fc-cache -fv "$FONT_DIR" >/dev/null
        success "JetBrainsMono Nerd Font installed."
    else
        success "Nerd Fonts already present."
    fi
fi

# ── 13. Shell dotfile snippets ────────────────────────────────────────────────
PROFILE="$HOME/.zshrc"
[[ "$INSTALL_SHELL" != yes ]] && PROFILE="$HOME/.bashrc"

add_to_profile() {
    local marker="$1" line="$2"
    grep -qF "$marker" "$PROFILE" 2>/dev/null || echo "$line" >> "$PROFILE"
}

add_to_profile "# nvm"       'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
add_to_profile "# cargo"     'source "$HOME/.cargo/env" 2>/dev/null || true'
add_to_profile "# go"        'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"'
add_to_profile "# pipx"      'export PATH="$PATH:$HOME/.local/bin"'
add_to_profile "# uv"        'export PATH="$PATH:$HOME/.local/bin"'
add_to_profile "# starship"  'eval "$(starship init zsh)" 2>/dev/null || eval "$(starship init bash)"'
add_to_profile "# fzf"       '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh'
add_to_profile "# bat alias" 'alias cat="bat --paging=never" 2>/dev/null || true'
add_to_profile "# eza alias" 'alias ls="eza --icons" ll="eza -lh --icons" la="eza -lah --icons" 2>/dev/null || true'

success "Shell profile updated."

# ── Done ──────────────────────────────────────────────────────────────────────
echo
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Workstation setup complete!            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo
warn "Start a new shell (or run: source ~/${PROFILE##*/}) to activate all PATH changes."
[[ "$INSTALL_DOCKER" == yes ]] && warn "Log out and back in to use Docker without sudo."
