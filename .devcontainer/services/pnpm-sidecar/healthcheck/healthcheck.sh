#!/bin/bash
set -euo pipefail

# Verify pnpm command exists
if ! pnpm --version &> /dev/null; then
    echo "pnpm not found"
    exit 1
fi

# Verify pnpm store integrity
if ! pnpm store status &> /dev/null; then
    echo "PNPM store integrity check failed"
    exit 1
fi

# Basic responsiveness check
if ! node --version &> /dev/null; then
    echo "Node.js not responsive"
    exit 1
fi

exit 0
