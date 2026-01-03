#!/bin/bash
set -euo pipefail

if ! command -v php >/dev/null 2>&1; then
  echo "php not available"
  exit 1
fi

php -v >/dev/null 2>&1
