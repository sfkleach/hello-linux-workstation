# Sourced by setup.sh into ~/.bashrc — PATH/env additions for toolchains installed by this repo.

# cargo (Rust)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# go
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# uv / pipx-style user installs
export PATH="$PATH:$HOME/.local/bin"

# fnm (Node version manager)
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd 2>/dev/null)" || true
fi
