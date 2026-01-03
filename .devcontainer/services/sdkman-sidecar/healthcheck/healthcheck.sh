#!/bin/bash
set -euo pipefail

if [ ! -d "/root/.sdkman" ]; then
  echo "sdkman dir missing"
  exit 1
fi
exit 0
