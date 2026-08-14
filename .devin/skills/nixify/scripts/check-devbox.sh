#!/usr/bin/env bash
# Check for existing devbox.json in a repository
# Usage: check-devbox.sh <owner> <repo>
# Output: "devbox exists" or "no devbox found"
# Use --verbose for full API response

set -euo pipefail

OWNER="${1:?Usage: check-devbox.sh <owner> <repo>}"
REPO="${2:?Usage: check-devbox.sh <owner> <repo>}"
VERBOSE="${3:-}"

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Checking https://api.github.com/repos/$OWNER/$REPO/contents/devbox.json"
  RESPONSE=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/devbox.json")
  echo "API response: $RESPONSE"
  NAME=$(echo "$RESPONSE" | jq -r '.name' 2>/dev/null || echo "")
else
  NAME=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/devbox.json" | jq -r '.name' 2>/dev/null || echo "")
fi

if [ "$NAME" = "devbox.json" ]; then
  echo "devbox exists"
else
  echo "no devbox found"
fi
