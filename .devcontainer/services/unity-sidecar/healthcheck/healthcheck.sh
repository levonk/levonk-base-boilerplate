#!/bin/bash
set -euo pipefail

if [ ! -d "/home/developer/.cache/unity" ]; then
  echo "unity cache dir missing"
  exit 1
fi
exit 0
