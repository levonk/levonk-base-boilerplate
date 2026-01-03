#!/bin/bash
set -euo pipefail

if ! command -v dotnet >/dev/null 2>&1; then
  echo "dotnet not available"
  exit 1
fi

dotnet --info >/dev/null 2>&1
