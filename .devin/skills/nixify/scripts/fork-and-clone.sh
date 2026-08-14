#!/usr/bin/env bash
# Fork and clone a repository, add upstream remote, rebase
# Usage: fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>
# Use --dry-run to preview actions without executing
# Use --verbose for full command output

set -euo pipefail

OWNER="${1:?Usage: fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>}"
REPO="${2:?Usage: fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>}"
HAS_DIRECT_ACCESS="${3:?Usage: fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>}"
CURRENT_USER="${4:?Usage: fork-and-clone.sh <owner> <repo> <has_direct_access> <current_user>}"
MODE="${5:-}"

UPSTREAM_URL="https://github.com/$OWNER/$REPO"
FORK_URL="https://github.com/$CURRENT_USER/$REPO"

if [ "$MODE" = "--dry-run" ]; then
  if [ "$HAS_DIRECT_ACCESS" = "false" ]; then
    echo "Would fork $OWNER/$REPO to $FORK_URL"
    echo "Would clone from $FORK_URL"
  else
    echo "Would clone directly from $UPSTREAM_URL"
  fi
  echo "Would add upstream remote: $UPSTREAM_URL"
  echo "Would fetch and rebase from upstream/main"
  exit 0
fi

if [ "$HAS_DIRECT_ACCESS" = "false" ]; then
  if [ "$MODE" = "--verbose" ]; then echo "Forking repository..."; fi
  gh repo fork "$OWNER/$REPO" --clone=false
  if [ "$MODE" = "--verbose" ]; then echo "Fork created at: $FORK_URL"; fi
  git clone "$FORK_URL"
else
  if [ "$MODE" = "--verbose" ]; then echo "Cloning directly from upstream..."; fi
  git clone "$UPSTREAM_URL"
fi

cd "$REPO"

git remote add upstream "$UPSTREAM_URL"
git fetch upstream
git rebase upstream/main

if [ "$MODE" = "--verbose" ]; then
  echo "Clone complete. Upstream remote added and rebased."
fi

echo "cloned at $(pwd)"
