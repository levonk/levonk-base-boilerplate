#!/bin/bash
set -euo pipefail

if [ ! -d "/root/.asdf" ]; then
  echo ".asdf dir missing"
  exit 1
fi
exit 0
