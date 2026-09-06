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
    FILENAME="go${GO_VERSION}.linux-${ARCH}.tar.gz"
    info "Installing Go ${GO_VERSION}…"
    GO_ARCHIVE="$(mktemp --suffix=.tar.gz)"
    trap 'rm -f "$GO_ARCHIVE"' EXIT
    curl -fsSL "https://go.dev/dl/${FILENAME}" -o "$GO_ARCHIVE"

    EXPECTED_SHA=$(curl -fsSL 'https://go.dev/dl/?mode=json' \
        | grep -A4 "\"filename\": *\"${FILENAME}\"" \
        | grep -Po '"sha256": *"\K[^"]*' | head -1) || true
    if [[ -n "$EXPECTED_SHA" ]]; then
        echo "${EXPECTED_SHA}  ${GO_ARCHIVE}" | sha256sum -c - \
            || die "Go archive checksum mismatch — aborting."
    else
        warn "Could not fetch Go's official checksum for ${FILENAME} — installing unverified."
    fi

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$GO_ARCHIVE"
    success "Go ${GO_VERSION} installed at /usr/local/go."
else
    success "Go already installed."
fi
