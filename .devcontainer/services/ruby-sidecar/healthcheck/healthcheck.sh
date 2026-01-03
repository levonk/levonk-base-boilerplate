#!/bin/bash
set -euo pipefail

if ! command -v ruby >/dev/null 2>&1; then
  echo "ruby not available"
  exit 1
fi

ruby --version >/dev/null 2>&1
bundle --version >/dev/null 2>&1 || true
