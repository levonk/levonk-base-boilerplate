#!/usr/bin/env bash
# Detect GitHub user and repository access level
# Usage: detect-access.sh <owner> <repo>
# Output: JSON with current_user, access_level, has_direct_access, fork_url
# Use --verbose for full API responses

set -euo pipefail

OWNER="${1:?Usage: detect-access.sh <owner> <repo>}"
REPO="${2:?Usage: detect-access.sh <owner> <repo>}"
VERBOSE="${3:-}"

CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
if [ -z "$CURRENT_USER" ]; then
  echo '{"error": "Could not detect GitHub user. Is gh CLI authenticated?"}'
  exit 1
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Current user: $CURRENT_USER"
  echo "Checking collaborator access on $OWNER/$REPO..."
fi

ACCESS_LEVEL=$(gh api "repos/$OWNER/$REPO/collaborators/$CURRENT_USER/permission" --jq '.permission' 2>/dev/null || echo "none")

if [ "$ACCESS_LEVEL" != "none" ] && [ "$ACCESS_LEVEL" != "" ]; then
  HAS_DIRECT_ACCESS=true
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "User has direct access: $ACCESS_LEVEL"
  fi
else
  HAS_DIRECT_ACCESS=false
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "User does not have direct access"
  fi
fi

FORK_URL="https://github.com/$CURRENT_USER/$REPO"

echo "{\"current_user\": \"$CURRENT_USER\", \"access_level\": \"$ACCESS_LEVEL\", \"has_direct_access\": $HAS_DIRECT_ACCESS, \"fork_url\": \"$FORK_URL\", \"upstream_owner\": \"$OWNER\", \"upstream_repo\": \"$REPO\"}"
