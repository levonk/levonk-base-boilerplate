#!/usr/bin/env bash
# Self-check: git-commit-batch.sh must stage and commit deleted-but-tracked files.
# Creates a throwaway git repo, deletes a tracked file, feeds a COMMIT/FILES spec
# on stdin, and asserts the commit succeeds (script must not abort with
# COMMIT_FAILED:FILE_NOT_FOUND).
#
# Run: ./scripts/self-check-deleted-files.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATCH="$SCRIPT_DIR/git-commit-batch.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$TMP"
git init -q
git config user.email "self-check@test"
git config user.name "self-check"

# Create and commit a file so it's tracked
echo "hello" > tracked.txt
git add tracked.txt
git commit -qm "init"

# Delete the tracked file from the worktree (still tracked by git)
rm tracked.txt

# Feed a commit spec for the deleted file
out=$(printf 'COMMIT:Delete tracked file\\n\\n- Remove tracked.txt from repo\nFILES:tracked.txt\n' | "$BATCH" "$TMP" 2>&1) || {
    echo "FAIL: script exited non-zero on deleted-but-tracked file"
    echo "$out"
    exit 1
}

if echo "$out" | grep -q "COMMIT_FAILED:FILE_NOT_FOUND"; then
    echo "FAIL: script rejected deleted-but-tracked file with FILE_NOT_FOUND"
    echo "$out"
    exit 1
fi

if echo "$out" | grep -q "COMMIT_SUCCESS"; then
    echo "PASS: deleted-but-tracked file committed"
    exit 0
fi

echo "FAIL: no COMMIT_SUCCESS in output"
echo "$out"
exit 1
