#!/usr/bin/env bash
# modules/40-golang.sh — official Go toolchain.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v go &>/dev/null; then
    GO_VERSION="1.27.1"
    case "$(uname -m)" in
        x86_64)          ARCH=amd64 ;;
        aarch64|arm64)   ARCH=arm64 ;;
        armv6l|armv7l)   ARCH=armv6l ;;
        i386|i686)       ARCH=386 ;;
        *)               die "Unsupported architecture: $(uname -m)" ;;
    esac
    info "Installing Go ${GO_VERSION}…"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm -f /tmp/go.tar.gz
    success "Go ${GO_VERSION} installed at /usr/local/go."
else
    success "Go already installed."
fi
