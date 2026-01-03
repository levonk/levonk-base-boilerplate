#!/bin/bash
set -euo pipefail

if ! command -v micromamba >/dev/null 2>&1; then
  echo "micromamba not available"
  exit 1
fi

micromamba --version >/dev/null 2>&1
