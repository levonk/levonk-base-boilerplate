#!/bin/bash
set -euo pipefail

if ! command -v turbo >/dev/null 2>&1; then
  echo "turbo not available"
  exit 1
fi

turbo --version >/dev/null 2>&1 || true
