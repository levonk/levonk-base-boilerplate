#!/bin/bash
set -euo pipefail

if ! command -v dart >/dev/null 2>&1; then
  echo "dart not available"
  exit 1
fi

dart --version >/dev/null 2>&1
