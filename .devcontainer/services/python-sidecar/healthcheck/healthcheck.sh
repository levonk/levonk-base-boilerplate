#!/bin/bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "python not available"
  exit 1
fi

python3 --version >/dev/null 2>&1
