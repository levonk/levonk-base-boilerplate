#!/bin/bash
set -euo pipefail

if ! command -v poetry >/dev/null 2>&1; then
  echo "poetry not available"
  exit 1
fi

poetry --version >/dev/null 2>&1
