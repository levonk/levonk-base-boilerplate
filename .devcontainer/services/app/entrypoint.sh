#!/bin/bash
# 🤖 Container Bootstrap Entrypoint

set -eo pipefail

HOME_DIR="/home/developer"
PROJECT_ROOT="${HOME_DIR}/project"
export USER=$(id -un)
export HOME="${HOME_DIR}"

COLORS_BLUE='\033[0;34m'
COLORS_GREEN='\033[0;32m'
COLORS_YELLOW='\033[0;33m'
COLORS_RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${COLORS_BLUE}🤖 [bootstrap] $1${NC}"; }
warn() { echo -e "${COLORS_YELLOW}⚠️ [bootstrap] $1${NC}"; }
error() { echo -e "${COLORS_RED}❌ [bootstrap] $1${NC}"; }

# 1. Wait for Nix volume
log "Waiting for Nix store to be available..."
TIMEOUT=60
while [ ! -d /nix/store ] || [ ! -d /nix/var/nix/profiles ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT-1))
    if [ $TIMEOUT -le 0 ]; then
        error "Timeout waiting for Nix store volume"
        exit 1
    fi
done

# 2. Discover Nix
log "Discovering Nix environment..."
NIX_BIN=$(find /nix/store -maxdepth 4 -path "*/bin/nix" -type f -executable 2>/dev/null | head -n 1)
if [ -z "$NIX_BIN" ]; then
    if [ -f "/nix/var/nix/profiles/default/bin/nix" ]; then
        NIX_BIN="/nix/var/nix/profiles/default/bin/nix"
    fi
fi

if [ -z "$NIX_BIN" ]; then
    error "Nix binary not found in /nix/store. Check shared volumes."
    exit 1
fi

NIX_DIR=$(dirname "$NIX_BIN")
export PATH="$NIX_DIR:$PATH"
log "Found Nix at: $NIX_BIN"

# Set up environment
export NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
CERT=$(find /nix/store -maxdepth 4 -name ca-bundle.crt 2>/dev/null | head -n 1)
if [ -n "$CERT" ]; then
    export NIX_SSL_CERT_FILE="$CERT"
fi

# Source nix.sh from default profile (where nix-sidecar installed tools)
if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix.sh" ]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
    log "Sourced Nix from default profile"
fi

# 3. Final PATH setup
# Sidecar installs tools into default profile, so prioritize it
export PATH="/nix/var/nix/profiles/default/bin:${HOME_DIR}/.nix-profile/bin:${HOME_DIR}/.local/bin:$PATH"

# 4. Ensure tsx exists (fallback to npm install if missing)
TSX_BIN=$(command -v tsx || true)
if [ -z "$TSX_BIN" ]; then
    for p in "/nix/var/nix/profiles/default/bin/tsx" "${HOME_DIR}/.nix-profile/bin/tsx"; do
        if [ -x "$p" ]; then TSX_BIN="$p"; break; fi
    done
fi

if [ -z "$TSX_BIN" ]; then
    log "tsx missing; installing via npm as user..."
    mkdir -p "${HOME_DIR}/.npm-global"
    export NPM_CONFIG_PREFIX="${HOME_DIR}/.npm-global"
    export PATH="${HOME_DIR}/.npm-global/bin:$PATH"
    if ! command -v npm >/dev/null 2>&1; then
        error "npm not found; nodejs from sidecar is required for bootstrap."
        exit 1
    fi
    npm install -g tsx >/dev/null 2>&1 || true
    TSX_BIN=$(command -v tsx || true)
fi

if [ -z "$TSX_BIN" ]; then
    error "tsx not found after npm fallback. Check sidecar tooling."
    log "PATH: $PATH"
    ls -la /nix/var/nix/profiles/default/bin 2>/dev/null || true
    ls -la "${HOME_DIR}/.npm-global/bin" 2>/dev/null || true
    exit 1
fi

log "Final PATH before handoff: $PATH"
log "Using TSX: $TSX_BIN"
exec "$TSX_BIN" /usr/local/bin/entrypoint.ts "$@"
