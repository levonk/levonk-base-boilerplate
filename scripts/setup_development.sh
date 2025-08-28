#!/usr/bin/env bash
set -euo pipefail

# Placeholder: rendered project should enhance this script.

echo "[setup_development] Preparing development environment..."

# Seed .envs for agents if missing
AGENTS=${NUMBER_OF_WORKTREES:-2}
mkdir -p .envs
for i in $(seq 1 "$AGENTS"); do
  mkdir -p ".envs/agent${i}"
  ENV_FILE=".envs/agent${i}/.env"
  if [[ ! -f "$ENV_FILE" ]]; then
    cat > "$ENV_FILE" <<'EOF'
# Agent environment variables
# AGENT_PORT=0
# IDE_PORTS= # computed via compose template
EOF
  fi
done

echo "[setup_development] Done."
