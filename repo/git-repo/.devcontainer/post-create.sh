#!/bin/bash
set -e

echo "Setting up development environment..."

# Ensure Nix environment is sourced if available
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
elif [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# Install system-level tools via Devbox
if [ -f .devcontainer/devbox.json ]; then
    echo "Installing Devbox packages..."
    devbox install
fi

# Install global Node.js packages using pnpm
# Note: pnpm is installed via devbox
if command -v pnpm &> /dev/null; then
    echo "Installing global pnpm packages..."
    pnpm add -g openskills
fi

echo "Setup complete!"
