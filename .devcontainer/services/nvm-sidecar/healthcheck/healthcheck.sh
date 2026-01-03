#!/bin/bash
set -euo pipefail

if [ ! -d "/home/developer/.nvm" ]; then
  echo "nvm dir missing"
  exit 1
fi
exit 0
