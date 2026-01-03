#!/bin/bash
set -euo pipefail

if ! command -v rustc >/dev/null 2>&1; then
  echo "rustc not available"
  exit 1
fi

rustc --version >/dev/null 2>&1
