#!/bin/bash
# shellcheck disable=SC1091
set -euo pipefail

# Check if setup marker exists (container initialized)
if [[ ! -f "${HOME}/.cache/.container_initialized" ]]; then
    echo "Setup not yet initialized"
    exit 1
fi

# Use pnpm directly since devbox is not available in PATH
if ! pnpm store status &> /dev/null; then
    echo "PNPM store integrity check failed"
    exit 1
fi

# Check nix store directly since devbox is not available in PATH
if ! nix-store --verify &> /dev/null; then
    echo "Nix store verification failed"
    exit 1
fi

exit 0
