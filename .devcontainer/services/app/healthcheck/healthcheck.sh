#!/bin/bash
# shellcheck disable=SC1091
set -euo pipefail

# Check if setup marker exists (container initialized)
if [[ ! -f "${HOME}/.cache/.container_initialized" ]]; then
    echo "Setup not yet initialized"
    exit 1
fi

# Use devbox run to verify tool responsiveness and project status
if ! devbox run -- pnpm store status &> /dev/null; then
    echo "PNPM store integrity check failed"
    exit 1
fi

if ! devbox run -- nix-store --verify &> /dev/null; then
    echo "Nix store verification failed"
    exit 1
fi

exit 0
