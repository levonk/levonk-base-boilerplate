#!/bin/bash
set -euo pipefail

if ! command -v bazel >/dev/null 2>&1 && ! command -v bazelisk >/dev/null 2>&1; then
  echo "bazel/bazelisk not available"
  exit 1
fi

bazel --version >/dev/null 2>&1 || bazelisk --version >/dev/null 2>&1 || true
