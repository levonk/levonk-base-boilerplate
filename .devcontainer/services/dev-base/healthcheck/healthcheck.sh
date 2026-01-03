#!/bin/bash
set -euo pipefail

# Set the correct PATH manually to override host PATH interference
export PATH="/nix/var/nix/profiles/default/bin:/home/developer/.local/bin:/home/developer/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Verify Nix command exists
if ! nix --version &> /dev/null; then
    echo "Nix not found"
    exit 1
fi

# Verify essential development tools
if ! git --version &> /dev/null; then
    echo "Git not found"
    exit 1
fi

if ! node --version &> /dev/null; then
    echo "Node.js not found"
    exit 1
fi

# Verify fzf functionality
if ! fzf --version &> /dev/null; then
    echo "fzf not found"
    exit 1
fi

# Basic responsiveness check
if ! jq --version &> /dev/null; then
    echo "jq not responsive"
    exit 1
fi

exit 0
