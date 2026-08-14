#!/usr/bin/env bash
# Check if a GitHub repository already has a flake.nix
# Usage: check-existing-flake.sh <owner> <repo>
# Output: "flake exists" or "no flake found"
# Use --verbose for full API response

set -euo pipefail

OWNER="${1:?Usage: check-existing-flake.sh <owner> <repo>}"
REPO="${2:?Usage: check-existing-flake.sh <owner> <repo>}"
VERBOSE="${3:-}"

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Checking https://api.github.com/repos/$OWNER/$REPO/contents/flake.nix"
  RESPONSE=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/flake.nix")
  echo "API response: $RESPONSE"
  NAME=$(echo "$RESPONSE" | jq -r '.name' 2>/dev/null || echo "")
else
  NAME=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/flake.nix" | jq -r '.name' 2>/dev/null || echo "")
fi

if [ "$NAME" = "flake.nix" ]; then
  echo "flake exists"
else
  echo "no flake found"
fi
