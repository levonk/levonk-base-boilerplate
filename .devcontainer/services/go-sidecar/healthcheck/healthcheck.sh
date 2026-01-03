#!/bin/bash
set -euo pipefail

if ! command -v go >/dev/null 2>&1; then
  echo "go not available"
  exit 1
fi

go version >/dev/null 2>&1
