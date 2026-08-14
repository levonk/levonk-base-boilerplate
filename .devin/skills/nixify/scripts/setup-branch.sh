#!/usr/bin/env bash
# Create feature branch and verify git author configuration
# Usage: setup-branch.sh [upstream_branch]
# Output: branch name and git author status
# Use --verbose for full output

set -euo pipefail

UPSTREAM_BRANCH="${1:-main}"
VERBOSE="${2:-}"
BRANCH="feat-nix-package-manager-install"

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Creating branch: $BRANCH"
fi

# Sync from upstream before branching — the clone-time rebase in
# fork-and-clone.sh is stale by the time we get here (steps 7-8 ran tests,
# analysis took wall-clock time). Starting the branch from fresh upstream
# shrinks the conflict surface for the late sync at step 17.
if git remote get-url upstream >/dev/null 2>&1; then
  if [ "$VERBOSE" = "--verbose" ]; then echo "Fetching upstream and rebasing onto upstream/$UPSTREAM_BRANCH..."; fi
  git fetch upstream
  git rebase "upstream/$UPSTREAM_BRANCH"
else
  # Direct-access clone (no fork) — upstream remote isn't set; origin IS upstream.
  if [ "$VERBOSE" = "--verbose" ]; then echo "No upstream remote; fetching origin and rebasing onto origin/$UPSTREAM_BRANCH..."; fi
  git fetch origin
  git rebase "origin/$UPSTREAM_BRANCH"
fi

git checkout -b "$BRANCH"

# Verify git author
NAME=$(git config user.name 2>/dev/null || echo "")
EMAIL=$(git config user.email 2>/dev/null || echo "")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Current git author: $NAME <$EMAIL>"
fi

# Check for forbidden patterns in author info
FORBIDDEN=false
if [ -n "$NAME" ] && echo "$NAME" | grep -qiE "$(hostname|sed 's/\..*//')|$(whoami)"; then
  FORBIDDEN=true
fi

if [ "$FORBIDDEN" = "true" ]; then
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "WARNING: Git author contains private identity info. Setting public author..."
  fi
  git config user.name "levonk"
  git config user.email "277861+levonk@users.noreply.github.com"
  NAME="levonk"
  EMAIL="277861+levonk@users.noreply.github.com"
fi

echo "{\"branch\": \"$BRANCH\", \"author_name\": \"$NAME\", \"author_email\": \"$EMAIL\", \"author_ok\": $([ -n "$NAME" ] && [ -n "$EMAIL" ] && echo true || echo false)}"
