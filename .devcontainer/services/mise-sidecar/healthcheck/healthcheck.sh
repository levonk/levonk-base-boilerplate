#!/bin/bash
set -euo pipefail

if [ ! -d "/root/.local/share/mise" ]; then
  echo "mise dir missing"
  exit 1
fi
exit 0
