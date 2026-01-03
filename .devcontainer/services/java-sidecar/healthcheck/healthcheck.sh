#!/bin/bash
set -euo pipefail

if ! command -v java >/dev/null 2>&1; then
  echo "java not available"
  exit 1
fi

java -version >/dev/null 2>&1
