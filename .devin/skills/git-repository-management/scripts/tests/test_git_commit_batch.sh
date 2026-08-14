#!/usr/bin/env bash
# test_git_commit_batch.sh — unit tests for git-commit-batch.sh
# Tests pre-staged file handling, dry-run mode, and body-quality validation.
#
# Run directly:
#   bash scripts/tests/test_git_commit_batch.sh
#
# Creates temp git repos under /tmp/skill-test/git-commit-batch/{scenario}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATCH="$SCRIPT_DIR/../git-commit-batch.sh"
TEST_BASE="/tmp/skill-test/git-commit-batch"

FAILED=0
PASSED=0
SKIPPED=0

pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }
skip() { echo "  SKIP: $1 (tool not installed)"; SKIPPED=$((SKIPPED + 1)); }

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — expected '$needle' in output"
    fi
}

assert_not_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — did not expect '$needle' in output"
    fi
}

# Create a temp git repo. Echoes the dir path.
# Usage: setup_repo scenario_name
setup_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# Create a temp git repo with NO initial commit (unborn HEAD). Echoes the dir path.
# Usage: setup_unborn_repo scenario_name
setup_unborn_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    echo "$dir"
}

# --- pre-staged file handling (Improvement #1) ---

test_prestaged_files_not_absorbed() {
    local dir; dir="$(setup_repo prestaged)"
    # Create and commit two independent files
    echo "a" > "$dir/a.txt"
    echo "b" > "$dir/b.txt"
    git -C "$dir" add a.txt b.txt
    git -C "$dir" commit -qm "init files"

    # Modify both, then stage a.txt (pre-staged) while leaving b.txt unstaged
    echo "a-modified" > "$dir/a.txt"
    echo "b-modified" > "$dir/b.txt"
    git -C "$dir" add a.txt  # pre-staged: this should NOT leak into commit 2

    # Batch: commit 1 should contain ONLY b.txt; a.txt must not be absorbed
    local batch
    batch=$(printf 'COMMIT:Update b only\\n\\n- Modify b.txt content\nFILES:b.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug prestaged "$dir" ) 2>&1)" || true

    assert_contains "prestaged: INDEX_RESET marker" "INDEX_RESET:mixed" "$out"
    assert_contains "prestaged: commit success" "COMMIT_SUCCESS" "$out"

    # The commit should contain ONLY b.txt, not a.txt
    local files_in_commit
    files_in_commit=$(git -C "$dir" show --stat --name-only HEAD --pretty=format: | tr -d ' ' | sort)
    if echo "$files_in_commit" | grep -q '^b.txt$' && ! echo "$files_in_commit" | grep -q '^a.txt$'; then
        pass "prestaged: commit contains only b.txt (a.txt not absorbed)"
    else
        fail "prestaged: commit should contain only b.txt, got: $files_in_commit"
    fi

    # a.txt should still be staged (its pre-staged state preserved after reset+commit)
    # Actually after reset --mixed, a.txt becomes unstaged. After committing b.txt,
    # a.txt remains modified in worktree but unstaged. Verify it's still dirty.
    if ! git -C "$dir" diff --cached --name-only | grep -q '^a.txt$'; then
        pass "prestaged: a.txt not silently committed"
    else
        fail "prestaged: a.txt was left staged (should have been unstaged by reset)"
    fi
}

# --- dry-run mode (Improvement #3) ---

test_dry_run_no_commits() {
    local dir; dir="$(setup_repo dryrun)"
    echo "new" > "$dir/file1.txt"
    echo "new" > "$dir/file2.txt"

    local batch
    batch=$(printf 'COMMIT:Add two files\\n\\n- Add file1 and file2\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug dryrun "$dir" ) 2>&1)" || true

    assert_contains "dryrun: PROCESSING_COMMIT marker" "PROCESSING_COMMIT:1" "$out"
    assert_contains "dryrun: MESSAGE marker" "MESSAGE:Add two files" "$out"
    assert_contains "dryrun: FILES marker" "FILES:file1.txt file2.txt" "$out"
    assert_not_contains "dryrun: no COMMIT_SUCCESS" "COMMIT_SUCCESS" "$out"
    assert_not_contains "dryrun: no AUTO_TAG_PRE" "AUTO_TAG_PRE" "$out"
    assert_not_contains "dryrun: no AUTO_TAG_POST" "AUTO_TAG_POST" "$out"

    # Repo state: no new commits beyond the initial empty one
    local count
    count=$(git -C "$dir" rev-list --count HEAD)
    if [[ "$count" -eq 1 ]]; then
        pass "dryrun: no commits created"
    else
        fail "dryrun: expected 1 commit, got $count"
    fi
}

test_dry_run_rejects_bodyless() {
    local dir; dir="$(setup_repo dryrun-nobody)"
    echo "new" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:No body here\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --dry-run --slug dryrun-nobody "$dir" ) 2>&1)" || true

    assert_contains "dryrun-nobody: NO_BODY rejection" "COMMIT_FAILED:NO_BODY" "$out"
    assert_not_contains "dryrun-nobody: no COMMIT_SUCCESS" "COMMIT_SUCCESS" "$out"
}

# --- body-quality validation (Improvement #8) ---

test_body_quality_warning_for_file_listing() {
    local dir; dir="$(setup_repo bodywarning)"
    echo "new" > "$dir/file1.txt"
    echo "new" > "$dir/file2.txt"

    # Body is just file paths — should trigger WARNING but still commit
    local batch
    batch=$(printf 'COMMIT:Add files\\n\\nfile1.txt\nfile2.txt\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug bodywarning "$dir" ) 2>&1)" || true

    assert_contains "bodywarning: WARNING_FILE_LISTING" "WARNING:BODY_LOOKS_LIKE_FILE_LISTING" "$out"
    assert_contains "bodywarning: still commits (warning, not failure)" "COMMIT_SUCCESS" "$out"
}

test_body_quality_no_warning_for_prose() {
    local dir; dir="$(setup_repo bodyprose)"
    echo "new" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:Add file1 with rationale\\n\\n- Add file1 to support new feature X\n- Needed because the prior approach did not handle edge case Y\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug bodyprose "$dir" ) 2>&1)" || true

    assert_not_contains "bodyprose: no WARNING for prose body" "WARNING:BODY_LOOKS_LIKE_FILE_LISTING" "$out"
    assert_contains "bodyprose: commit success" "COMMIT_SUCCESS" "$out"
}

# --- unborn HEAD / root-commit case ---
# Regression: git-commit-batch.sh used to fail with exit 128 on a repo with
# no commits yet because `git rev-parse HEAD` (for the pre-tag) and
# `git reset --mixed HEAD` (for index reset) both require an existing HEAD.
# The script must skip the pre-tag, clear the index via `git read-tree --empty`,
# land the root commit, and still emit the post-tag.

test_unborn_head_root_commit() {
    local dir; dir="$(setup_unborn_repo unborn)"
    echo "content" > "$dir/file1.txt"
    echo "content" > "$dir/file2.txt"

    local batch
    batch=$(printf 'COMMIT:Initial commit\\n\\n- Add file1 and file2\n- Seed the repository\nFILES:file1.txt\nFILES:file2.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug initial "$dir" ) 2>&1)" || true

    assert_contains "unborn: SKIPPED_UNBORN_HEAD marker" "AUTO_TAG_PRE:SKIPPED_UNBORN_HEAD" "$out"
    assert_not_contains "unborn: no pre-tag created" "AUTO_TAG_PRE:tags/auto/" "$out"
    assert_contains "unborn: INDEX_RESET marker" "INDEX_RESET:mixed" "$out"
    assert_contains "unborn: commit success" "COMMIT_SUCCESS" "$out"
    assert_contains "unborn: post-tag created" "AUTO_TAG_POST:tags/auto/" "$out"

    # Exactly one commit (the root commit) should now exist
    local count
    count=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo 0)
    if [[ "$count" -eq 1 ]]; then
        pass "unborn: exactly one root commit created"
    else
        fail "unborn: expected 1 commit, got $count"
    fi

    # Post-tag should point at the new root commit
    local post_tag
    post_tag=$(git -C "$dir" tag -l 'tags/auto/*-initial-post' | head -1)
    if [[ -n "$post_tag" ]]; then
        local tag_commit_sha commit_sha
        tag_commit_sha=$(git -C "$dir" rev-parse "${post_tag}^{commit}" 2>/dev/null || echo "")
        commit_sha=$(git -C "$dir" rev-parse HEAD)
        if [[ "$tag_commit_sha" == "$commit_sha" ]]; then
            pass "unborn: post-tag points at root commit"
        else
            fail "unborn: post-tag commit ($tag_commit_sha) != HEAD ($commit_sha)"
        fi
    else
        fail "unborn: no post-tag found"
    fi
}

test_unborn_head_slug_from_branch() {
    # On an unborn branch, slug should still derive from the branch name
    # (e.g. "main") via `git symbolic-ref --short HEAD`, not fall back to "run".
    local dir; dir="$(setup_unborn_repo unborn-slug)"
    echo "content" > "$dir/file1.txt"

    local batch
    batch=$(printf 'COMMIT:Initial commit\\n\\n- Seed the repository\nFILES:file1.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" "$dir" ) 2>&1)" || true

    # The post-tag slug should be the branch name (main or master), not "run".
    # We accept either main or master since the default branch name varies.
    if echo "$out" | grep -qE 'AUTO_TAG_POST:tags/auto/[0-9]{4}/[0-9]{2}/[0-9]+-(main|master)-post'; then
        pass "unborn: slug derived from branch name"
    else
        fail "unborn: slug should be branch name (main/master), got: $out"
    fi
}

test_unborn_head_index_reset_clears_staged() {
    # On an unborn branch, pre-staged files must be unstaged before the batch
    # runs so commit 1 contains ONLY its FILES: list. `git read-tree --empty`
    # is the unborn-HEAD equivalent of `git reset --mixed HEAD`.
    local dir; dir="$(setup_unborn_repo unborn-index)"
    echo "a" > "$dir/a.txt"
    echo "b" > "$dir/b.txt"
    # Pre-stage a.txt — it must NOT leak into the commit that only lists b.txt
    git -C "$dir" add a.txt

    local batch
    batch=$(printf 'COMMIT:Add b only\\n\\n- Add b.txt to the repository\nFILES:b.txt\n')
    local out
    out="$(printf '%s' "$batch" | ( cd "$dir" && bash "$BATCH" --slug unborn-index "$dir" ) 2>&1)" || true

    assert_contains "unborn-index: INDEX_RESET marker" "INDEX_RESET:mixed" "$out"
    assert_contains "unborn-index: commit success" "COMMIT_SUCCESS" "$out"

    # The root commit should contain ONLY b.txt
    local files_in_commit
    files_in_commit=$(git -C "$dir" show --stat --name-only HEAD --pretty=format: | tr -d ' ' | sort)
    if echo "$files_in_commit" | grep -q '^b.txt$' && ! echo "$files_in_commit" | grep -q '^a.txt$'; then
        pass "unborn-index: root commit contains only b.txt (a.txt not absorbed)"
    else
        fail "unborn-index: root commit should contain only b.txt, got: $files_in_commit"
    fi
}

# --- main ---

main() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"

    echo "=== git-repository-management: git-commit-batch.sh tests ==="
    echo ""

    echo "--- pre-staged file handling ---"
    test_prestaged_files_not_absorbed

    echo ""
    echo "--- dry-run mode ---"
    test_dry_run_no_commits
    test_dry_run_rejects_bodyless

    echo ""
    echo "--- body-quality validation ---"
    test_body_quality_warning_for_file_listing
    test_body_quality_no_warning_for_prose

    echo ""
    echo "--- unborn HEAD / root-commit case ---"
    test_unborn_head_root_commit
    test_unborn_head_slug_from_branch
    test_unborn_head_index_reset_clears_staged

    echo ""
    echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

    rm -rf "$TEST_BASE"
    exit "$FAILED"
}

main "$@"
