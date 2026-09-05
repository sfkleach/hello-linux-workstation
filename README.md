# hello-linux-workstation

Automates setting up a Linux workstation from a fresh install.

## Supported distros

| Family | Package manager |
|--------|----------------|
| Debian / Ubuntu | `apt` |
| Fedora / RHEL | `dnf` |
| Arch Linux | `pacman` |

## Quick start

```bash
git clone https://github.com/sfkleach/hello-linux-workstation.git
cd hello-linux-workstation
chmod +x setup.sh
./setup.sh
```

The script is **idempotent** — safe to re-run after a failed step or to apply updates.

## What it installs

| Section | Tools |
|---------|-------|
| System update | Full package upgrade |
| Essentials | `build-essential`, `curl`, `wget`, `jq`, `htop`, `tree`, `stow`, … |
| Shell | `zsh` + Oh My Zsh |
| Git | `git`, global config, `gh` CLI |
| Editors | Neovim, VS Code |
| Python | `python3`, `pip`, `pipx`, `uv` |
| Node.js | Latest LTS via `nvm` |
| Rust | Stable toolchain via `rustup` |
| Go | Latest stable (opt-in, off by default) |
| Docker | Docker Engine + `docker compose`, user added to `docker` group |
| CLI tools | `fzf`, `ripgrep`, `bat`, `fd`, `eza`, `git-delta`, `tmux`, Starship prompt |
| Fonts | JetBrainsMono Nerd Font |

## Skipping sections

Any section can be disabled by setting its environment variable to `no` before running:

```bash
INSTALL_GO=yes INSTALL_RUST=no ./setup.sh
```

| Variable | Default |
|----------|---------|
| `INSTALL_SYSTEM_UPDATES` | `yes` |
| `INSTALL_ESSENTIALS` | `yes` |
| `INSTALL_SHELL` | `yes` |
| `INSTALL_GIT` | `yes` |
| `INSTALL_EDITORS` | `yes` |
| `INSTALL_PYTHON` | `yes` |
| `INSTALL_NODE` | `yes` |
| `INSTALL_RUST` | `yes` |
| `INSTALL_GO` | `no` |
| `INSTALL_DOCKER` | `yes` |
| `INSTALL_CLI_TOOLS` | `yes` |
| `INSTALL_FONTS` | `yes` |

## After first run

- Start a new shell (or `source ~/.zshrc`) to pick up updated `PATH` entries.
- Log out and back in to use Docker without `sudo`.
- For Git, the script prompts for `user.name` and `user.email` the first time only.
