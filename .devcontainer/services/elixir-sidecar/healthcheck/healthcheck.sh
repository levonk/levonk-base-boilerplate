#!/bin/bash
set -euo pipefail

if ! command -v elixir >/dev/null 2>&1; then
  echo "elixir not available"
  exit 1
fi

elixir --version >/dev/null 2>&1
