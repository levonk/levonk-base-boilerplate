#!/usr/bin/env bash
set -euo pipefail

# Placeholder: rendered project should enhance this script.
# Installs mise and basic deps based on Copier inputs.

echo "[setup_container] Starting container setup..."

# Install mise (lightweight placeholder; actual install may differ)
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.jdx.dev/install.sh | bash -s -- -y || true
fi

# Ensure ~/.local/bin on PATH for mise
export PATH="$HOME/.local/bin:$PATH"

echo "[setup_container] Done."
