#!/bin/bash
set -euo pipefail

if ! command -v ghc >/dev/null 2>&1; then
  echo "ghc not available"
  exit 1
fi

ghc --version >/dev/null 2>&1
cabal --version >/dev/null 2>&1 || true
stack --version >/dev/null 2>&1 || true
