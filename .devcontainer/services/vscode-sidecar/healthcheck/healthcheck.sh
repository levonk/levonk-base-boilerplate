#!/bin/bash
set -euo pipefail

if [ ! -d "/root/.vscode-server" ]; then
  echo ".vscode-server dir missing"
  exit 1
fi
exit 0
