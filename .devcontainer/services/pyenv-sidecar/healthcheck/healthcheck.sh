#!/bin/bash
set -euo pipefail

if [ ! -d "/home/developer/.pyenv" ]; then
  echo "pyenv dir missing"
  exit 1
fi
exit 0
