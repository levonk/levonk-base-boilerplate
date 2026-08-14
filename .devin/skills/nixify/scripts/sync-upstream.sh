#!/usr/bin/env bash
# Fetch and rebase onto upstream/main (or origin/main for direct-access clones).
# Usage: sync-upstream.sh [upstream_branch]
# Run this right before pushing — it's the safety net that catches upstream
# movement during the work phase (steps 7-16). The early sync in setup-branch.sh
# shrinks the conflict surface; this one guarantees the push is from a fresh base.
# Exits non-zero on rebase failure (conflicts or dirty tree) so the caller
# can resolve before pushing.

set -euo pipefail

UPSTREAM_BRANCH="${1:-main}"
VERBOSE="${2:-}"

if git remote get-url upstream >/dev/null 2>&1; then
  REMOTE=upstream
else
  REMOTE=origin
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Fetching $REMOTE and rebasing onto $REMOTE/$UPSTREAM_BRANCH..."
fi

git fetch "$REMOTE"

if ! git rebase "$REMOTE/$UPSTREAM_BRANCH"; then
  # ponytail: git rebase fails for two distinct reasons — dirty tree (needs
  # commit/stash) and merge conflicts (needs resolve + --continue). git prints
  # the specific error to stderr; we add the two recovery paths so the agent
  # doesn't try --continue on a dirty tree (no-op) or stash on conflicts (loses
  # the rebase state).
  echo "error: rebase onto $REMOTE/$UPSTREAM_BRANCH failed." >&2
  echo "  - Dirty tree (unstaged changes): commit or stash, then re-run this script." >&2
  echo "  - Merge conflicts: resolve them, then 'git rebase --continue' and re-run." >&2
  exit 1
fi

# Report how many commits we are ahead of the upstream tip.
AHEAD=$(git rev-list --count "$REMOTE/$UPSTREAM_BRANCH"..HEAD || echo "?")
echo "{\"remote\": \"$REMOTE\", \"branch\": \"$UPSTREAM_BRANCH\", \"ahead\": $AHEAD, \"synced\": true}"
