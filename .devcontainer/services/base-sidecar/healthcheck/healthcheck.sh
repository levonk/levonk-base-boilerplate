#!/bin/bash
set -euo pipefail

if ! command -v bash >/dev/null 2>&1; then
  echo "bash not available"
  exit 1
fi

bash --version >/dev/null 2>&1
