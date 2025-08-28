#!/usr/bin/env bash
set -euo pipefail

# Placeholder launcher: ensures envs exist, brings up compose, and prints info.

./scripts/setup_development.sh

echo "[launch] Starting docker compose..."
docker compose up -d

echo "[launch] If using zellij, open your layout (if provided)."
