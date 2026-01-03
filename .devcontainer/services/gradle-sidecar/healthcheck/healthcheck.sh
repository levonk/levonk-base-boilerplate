#!/bin/bash
set -euo pipefail

if ! command -v gradle >/dev/null 2>&1; then
  echo "gradle not available"
  exit 1
fi

gradle --version >/dev/null 2>&1 || true
