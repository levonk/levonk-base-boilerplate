#!/usr/bin/env bats
# test_git_archive.bats — unit tests for git-archive.sh
# Tests identify (with squash-merge detection), archive, prune, --skip, --yes,
# post-action guidance, and protected-branch handling.
#
# Run via: bats scripts/tests/test_git_archive.bats
#
# Creates temp git repos under /tmp/skill-test/git-archive/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
ARCHIVE="$SCRIPT_DIR/../git-archive.sh"
TEST_BASE="/tmp/skill-test/git-archive"

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

# Create a temp git repo with a main branch and initial commit. Echoes the dir path.
# Usage: setup_repo scenario_name [main_branch]
setup_repo() {
    local scenario="$1"
    local main_branch="${2:-main}"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q -b "$main_branch" "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# Create a branch with a commit, then merge it into main (true merge).
# Usage: make_merged_branch <dir> <branch_name>
make_merged_branch() {
    local dir="$1"
    local branch="$2"
    local slug="${branch//\//-}"
    git -C "$dir" checkout -q -b "$branch"
    echo "content for $branch" > "$dir/file-${slug}.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "work on $branch"
    git -C "$dir" checkout -q main
    git -C "$dir" merge -q --no-ff "$branch" -m "Merge $branch"
}

# Create a branch with a commit, then squash-merge it into main.
# The branch commits will NOT be ancestors of main (no merge-base link),
# but the patch content will be in main (git cherry detects this).
# Usage: make_squash_merged_branch <dir> <branch_name>
make_squash_merged_branch() {
    local dir="$1"
    local branch="$2"
    local slug="${branch//\//-}"
    git -C "$dir" checkout -q -b "$branch"
    echo "content for $branch" > "$dir/file-${slug}.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "work on $branch"
    git -C "$dir" checkout -q main
    git -C "$dir" merge -q --squash "$branch"
    git -C "$dir" commit -q -m "Squash merge $branch"
}

# Create an unmerged branch (no merge, no squash — still has unique commits).
# Usage: make_unmerged_branch <dir> <branch_name>
make_unmerged_branch() {
    local dir="$1"
    local branch="$2"
    local slug="${branch//\//-}"
    git -C "$dir" checkout -q -b "$branch"
    echo "unique content for $branch" > "$dir/file-${slug}.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "unique work on $branch"
    git -C "$dir" checkout -q main
}

# Run git-archive.sh on a repo. Echoes the full output.
# Usage: run_archive <dir> <args...>
# WRAPPER_DEVBOX_DISABLED=1 and RTK_SKIP=1 bypass the devbox/rtk probes so
# tests don't hang on the 15s devbox probe in temp dirs without devbox.json.
run_archive() {
    local dir="$1"; shift
    ( cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$ARCHIVE" "$@" "$dir" 2>&1 ) || true
}

# --- Identify: basic ---

@test "identify produces BRANCHES and TAGS sections" {
    local dir; dir="$(setup_repo identify-sections)"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "=== BRANCHES ===" "$out"
    assert_contains "=== TAGS ===" "$out"
}

@test "identify marks protected branches as KEEP" {
    local dir; dir="$(setup_repo identify-protected)"
    # main is the default branch, should be kept
    local out; out="$(run_archive "$dir" --identify --force)"
    # main won't appear in branch list (it's the current branch, filtered by grep -v '*')
    # but env/dev should be protected if we create it
    git -C "$dir" checkout -q -b env/dev
    git -C "$dir" checkout -q main
    out="$(run_archive "$dir" --identify --force)"
    assert_contains "KEEP:env/dev" "$out"
}

# --- Identify: squash-merge detection (the key git-sweep lesson) ---

@test "identify detects squash-merged branches as ARCHIVE_CANDIDATE" {
    local dir; dir="$(setup_repo squash-detect)"
    make_squash_merged_branch "$dir" "feat/squashed-feature"
    local out; out="$(run_archive "$dir" --identify --force)"
    # Without squash detection, this would show REVIEW (unmerged).
    # With git cherry, it should show ARCHIVE_CANDIDATE with merged status.
    assert_contains "ARCHIVE_CANDIDATE:feat/squashed-feature" "$out"
    assert_contains ":merged" "$out"
}

@test "identify detects true-merged branches as ARCHIVE_CANDIDATE" {
    local dir; dir="$(setup_repo true-merge-detect)"
    make_merged_branch "$dir" "feat/merged-feature"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "ARCHIVE_CANDIDATE:feat/merged-feature" "$out"
    assert_contains ":merged" "$out"
}

@test "identify marks unmerged branches as REVIEW" {
    local dir; dir="$(setup_repo unmerged-review)"
    make_unmerged_branch "$dir" "feat/active-work"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "REVIEW:feat/active-work" "$out"
    assert_contains ":unmerged" "$out"
}

# --- Identify: --skip flag ---

@test "identify respects --skip flag" {
    local dir; dir="$(setup_repo skip-flag)"
    make_merged_branch "$dir" "feat/skip-me"
    make_merged_branch "$dir" "feat/dont-skip"
    local out; out="$(run_archive "$dir" --identify --force --skip "feat/skip-me")"
    assert_contains "KEEP:feat/skip-me:skip-list" "$out"
    assert_contains "ARCHIVE_CANDIDATE:feat/dont-skip" "$out"
}

# --- Identify: cascade and scratch branches ---

@test "identify always archives cascade branches" {
    local dir; dir="$(setup_repo cascade-always)"
    git -C "$dir" checkout -q -b "cascade/test-branch"
    echo "cascade content" > "$dir/cascade-file.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "cascade work"
    git -C "$dir" checkout -q main
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "ARCHIVE_CANDIDATE:cascade/test-branch" "$out"
    assert_contains ":auto-generated:" "$out"
}

@test "identify archives merged scratch branches" {
    local dir; dir="$(setup_repo scratch-merged)"
    git -C "$dir" checkout -q -b "scratch/test"
    echo "scratch content" > "$dir/scratch-file.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "scratch work"
    git -C "$dir" checkout -q main
    git -C "$dir" merge -q --no-ff "scratch/test" -m "Merge scratch"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "ARCHIVE_CANDIDATE:scratch/test" "$out"
    assert_contains ":scratch-snapshot:" "$out"
}

@test "identify keeps unmerged scratch branches" {
    local dir; dir="$(setup_repo scratch-unmerged)"
    git -C "$dir" checkout -q -b "scratch/unmerged-test"
    echo "scratch content" > "$dir/scratch-unmerged-file.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "scratch work"
    git -C "$dir" checkout -q main
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "KEEP:scratch/unmerged-test" "$out"
    assert_contains ":unmerged-scratch" "$out"
}

# --- Archive: --yes and confirmation ---

@test "archive with --yes archives a merged branch" {
    local dir; dir="$(setup_repo archive-yes)"
    make_merged_branch "$dir" "feat/to-archive"
    local out; out="$(run_archive "$dir" --archive --ref "feat/to-archive" --yes --force)"
    assert_contains "ARCHIVED:feat/to-archive" "$out"
    # Branch should be renamed to archive/...
    assert_contains "archive/branches/" "$out"
}

@test "archive with --dry-run does not modify refs" {
    local dir; dir="$(setup_repo archive-dryrun)"
    make_merged_branch "$dir" "feat/dry-run-test"
    local out; out="$(run_archive "$dir" --archive --ref "feat/dry-run-test" --yes --dry-run --force)"
    assert_contains "DRY_RUN:ARCHIVE:feat/dry-run-test" "$out"
    # Branch should still exist
    git -C "$dir" show-ref --verify --quiet "refs/heads/feat/dry-run-test" || {
        echo "Branch was deleted in dry-run!" >&3
        return 1
    }
}

@test "archive without --yes prompts and aborts on negative answer" {
    local dir; dir="$(setup_repo archive-no-yes)"
    make_merged_branch "$dir" "feat/no-auto-archive"
    # Pipe "n" to stdin to simulate a user declining the confirmation prompt.
    local out; out="$( printf 'n\n' | { cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$ARCHIVE" --archive --ref "feat/no-auto-archive" --force "$dir"; } 2>&1 )" || true
    assert_contains "SKIPPED:USER_ABORTED" "$out"
    # Branch should still exist
    git -C "$dir" show-ref --verify --quiet "refs/heads/feat/no-auto-archive" || {
        echo "Branch was deleted despite negative answer!" >&3
        return 1
    }
}

@test "archive emits post-action guidance" {
    local dir; dir="$(setup_repo archive-guidance)"
    make_merged_branch "$dir" "feat/guidance-test"
    local out; out="$(run_archive "$dir" --archive --ref "feat/guidance-test" --yes --force)"
    assert_contains "NOTICE:" "$out"
    assert_contains "git fetch --prune" "$out"
}

@test "archive fails on non-existent ref" {
    local dir; dir="$(setup_repo archive-notfound)"
    local out; out="$(run_archive "$dir" --archive --ref "nonexistent/branch" --yes --force)"
    assert_contains "ARCHIVE_FAILED:NOT_FOUND:nonexistent/branch" "$out"
}

# --- Prune ---

@test "prune --dry-run shows candidates without deleting" {
    local dir; dir="$(setup_repo prune-dryrun)"
    # Create an old archive branch (date in the path will be old)
    make_merged_branch "$dir" "feat/old-feature"
    # Archive it first
    run_archive "$dir" --archive --ref "feat/old-feature" --yes --force >/dev/null 2>&1
    # Create a branch with an old-dated archive path manually for pruning.
    git -C "$dir" branch "archive/branches/feat/2020/01/20200101-very-old" main 2>/dev/null || true
    local out; out="$(run_archive "$dir" --prune --retention-months 6 --dry-run --force)"
    assert_contains "PRUNE_CANDIDATE:" "$out"
    assert_contains "20200101-very-old" "$out"
}

@test "prune without --confirm shows candidates only" {
    local dir; dir="$(setup_repo prune-no-confirm)"
    make_merged_branch "$dir" "feat/prune-test"
    run_archive "$dir" --archive --ref "feat/prune-test" --yes --force >/dev/null 2>&1
    # Create an old-dated archive ref manually for pruning.
    git -C "$dir" branch "archive/branches/feat/2020/01/20200101-very-old" main 2>/dev/null || true
    local out; out="$(run_archive "$dir" --prune --retention-months 6 --force)"
    assert_contains "PRUNE_CANDIDATE:" "$out"
    assert_not_contains "PRUNED:" "$out"
}

# --- Ownership check ---

@test "identify skips non-owned upstream" {
    local dir; dir="$(setup_repo ownership-skip)"
    # Add a fake remote pointing to a non-levonk owner
    git -C "$dir" remote add origin "https://github.com/someone-else/repo.git"
    local out; out="$(run_archive "$dir" --identify --force)"
    # --force disables the ownership check, so it should proceed
    assert_contains "=== BRANCHES ===" "$out"
}

@test "identify without --force skips non-owned upstream" {
    local dir; dir="$(setup_repo ownership-noforce)"
    git -C "$dir" remote add origin "https://github.com/someone-else/repo.git"
    local out; out="$(run_archive "$dir" --identify)"
    assert_contains "SKIPPED:UPSTREAM_NOT_OWNED" "$out"
}

# --- Tags ---

@test "identify classifies auto-checkpoint tags" {
    local dir; dir="$(setup_repo tags-auto)"
    git -C "$dir" tag "tags/auto/checkpoint-1"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "ARCHIVE_CANDIDATE:tags/auto/checkpoint-1" "$out"
    assert_contains ":auto-checkpoint:" "$out"
}

@test "identify keeps already-archived tags" {
    local dir; dir="$(setup_repo tags-archived)"
    git -C "$dir" tag "archive/tags/auto/2026/01/20260101-old-tag"
    local out; out="$(run_archive "$dir" --identify --force)"
    assert_contains "KEEP:archive/tags/" "$out"
    assert_contains ":already-archived" "$out"
}
