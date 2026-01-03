#!/bin/bash
set -euo pipefail

# Check if nix is operational
if ! nix-env --version &> /dev/null; then
    echo "Nix not responsive"
    exit 1
fi

# Verify store integrity
if ! nix-store --verify &> /dev/null; then
    echo "Nix store verification failed"
    exit 1
fi

# Check if flakes are accessible
if ! nix flake --version &> /dev/null; then
    echo "Nix flakes not responsive"
    exit 1
fi

exit 0
