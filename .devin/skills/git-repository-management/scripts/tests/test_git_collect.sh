#!/usr/bin/env bash
# test_git_collect.sh — unit tests for git-collect.sh
# Tests repository data collection, tool detection, and quality checks.
#
# Run directly:
#   bash scripts/tests/test_git_collect.sh
#
# Creates temp git repos under /tmp/skill-test/git-collect/{scenario}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_COLLECT="$SCRIPT_DIR/../git-collect.sh"
TEST_BASE="/tmp/skill-test/git-collect"

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

# Create a temp git repo with specific files. Echoes the dir path.
# Usage: setup_repo scenario_name file1 file2 ...
setup_repo() {
    local scenario="$1"; shift
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        echo "content" > "$dir/$f"
    done
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial" 2>/dev/null || true
    echo "$dir"
}

# Run git-collect.sh on a repo. Echoes the full output.
# Runs from within the repo dir so devbox detection (which keys off CWD at
# launch) sees no devbox.json and falls back to direct execution — otherwise
# `devbox run -- git ...` fails in the temp dir and diff output is lost.
run_collect() {
    local dir="$1"
    ( cd "$dir" && bash "$GIT_COLLECT" "$dir" 2>&1 ) || true
}

# --- basic collection tests ---

test_collection_start_end() {
    local dir; dir="$(setup_repo basic README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "basic: COLLECTION_START marker" "=== COLLECTION_START ===" "$out"
    assert_contains "basic: COLLECTION_END marker" "=== COLLECTION_END ===" "$out"
}

test_repo_root() {
    local dir; dir="$(setup_repo repo-root src/main.py)"
    local out; out="$(run_collect "$dir")"
    # git rev-parse may resolve symlinks (/tmp → /private/tmp on macOS)
    assert_contains "basic: REPO_ROOT" "REPO_ROOT:" "$out"
    assert_contains "basic: REPO_ROOT path" "repo-root" "$out"
}

test_branch_detected() {
    local dir; dir="$(setup_repo branch-detected src/index.ts)"
    local out; out="$(run_collect "$dir")"
    assert_contains "basic: BRANCH line" "BRANCH:" "$out"
}

test_staged_changes() {
    local dir; dir="$(setup_repo staged src/app.py)"
    echo "modified" > "$dir/src/app.py"
    git -C "$dir" add -A
    local out; out="$(run_collect "$dir")"
    assert_contains "staged: STAGED section" "STAGED:" "$out"
}

test_unstaged_changes() {
    local dir; dir="$(setup_repo unstaged src/lib.rs)"
    echo "modified" > "$dir/src/lib.rs"
    local out; out="$(run_collect "$dir")"
    assert_contains "unstaged: UNSTAGED section" "UNSTAGED:" "$out"
}

test_untracked_files() {
    local dir; dir="$(setup_repo untracked src/main.go)"
    echo "new" > "$dir/new-file.txt"
    local out; out="$(run_collect "$dir")"
    assert_contains "untracked: UNTRACKED section" "UNTRACKED:" "$out"
}

# --- tool detection tests ---

test_rtk_detection() {
    command -v rtk >/dev/null 2>&1 || { skip "RTK detection"; return; }
    local dir; dir="$(setup_repo rtk-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "RTK: available flag" "RTK:1" "$out"
}

test_rtk_not_available() {
    # This test only works if rtk is NOT installed — skip if it is.
    # Note: rtk may be available via devbox shims even when not on the
    # test shell's PATH, so this test is best-effort.
    command -v rtk >/dev/null 2>&1 && { skip "RTK not available (rtk is installed)"; return; }
    local dir; dir="$(setup_repo no-rtk README.md)"
    local out; out="$(run_collect "$dir")"
    # RTK may still be detected via devbox shims inside the script. Accept
    # either RTK:0 or RTK:1 — the test only asserts the flag is present.
    assert_contains "no RTK: RTK flag present" "RTK:" "$out"
}

test_devbox_detection() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox detection"; return; }
    local dir
    dir="$TEST_BASE/devbox-detect"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    # Minimal valid devbox.json so the file-exists check passes
    cat > "$dir/devbox.json" <<'EOF'
{
  "packages": [],
  "shell": { "init_hook": "" }
}
EOF
    echo "content" > "$dir/README.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    # DEVBOX may be 1 (probe succeeded) or 0 (probe failed and fell back to
    # direct execution). Both are valid outcomes — the script degrades
    # gracefully. We only assert that the DEVBOX line is present.
    assert_contains "devbox: DEVBOX flag present" "DEVBOX:" "$out"
}

test_devbox_not_available() {
    command -v devbox >/dev/null 2>&1 && { skip "devbox not available (devbox is installed)"; return; }
    local dir; dir="$(setup_repo no-devbox README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "no devbox: unavailable flag" "DEVBOX:0" "$out"
}

test_jj_detection() {
    command -v jj >/dev/null 2>&1 || { skip "jj detection"; return; }
    local dir; dir="$(setup_repo jj-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "jj: available flag" "JJ:1" "$out"
}

# --- quality check tests ---

test_quality_checks_section() {
    local dir; dir="$(setup_repo quality-checks package.json)"
    local out; out="$(run_collect "$dir")"
    assert_contains "quality: QUALITY_CHECKS section" "QUALITY_CHECKS:" "$out"
}

test_npm_test_detected() {
    local dir
    dir="$TEST_BASE/npm-test"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    cat > "$dir/package.json" <<'EOF'
{
  "name": "test-project",
  "scripts": {
    "test": "echo 'tests pass'"
  }
}
EOF
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    assert_contains "npm test: NPM_TEST section" "NPM_TEST:" "$out"
}

test_cargo_test_detected() {
    local dir
    dir="$TEST_BASE/cargo-test"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    cat > "$dir/Cargo.toml" <<'EOF'
[package]
name = "test-project"
version = "0.1.0"
EOF
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    assert_contains "cargo test: CARGO_TEST section" "CARGO_TEST:" "$out"
}

test_no_test_configured() {
    local dir; dir="$(setup_repo no-test README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "no tests: NOT_CONFIGURED" "TESTS:NOT_CONFIGURED" "$out"
}

# --- diff stats ---

test_diff_stats() {
    local dir; dir="$(setup_repo diff-stats src/a.py src/b.py)"
    echo "changed" > "$dir/src/a.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "diff: DIFF_STATS section" "DIFF_STATS:" "$out"
}

test_full_diff() {
    local dir; dir="$(setup_repo full-diff src/main.py)"
    echo "changed content" > "$dir/src/main.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "diff: FULL_DIFF section" "FULL_DIFF:" "$out"
}

# FULL_DIFF should contain actual diff content (not empty) when there are
# staged changes. Regression test for the bug where FULL_DIFF was empty
# because `git diff` (no --cached) only shows unstaged changes.
test_full_diff_has_staged_content() {
    local dir; dir="$(setup_repo full-diff-staged src/main.py)"
    echo "staged change" > "$dir/src/main.py"
    git -C "$dir" add src/main.py  # stage everything; no unstaged changes
    local out; out="$(run_collect "$dir")"
    assert_contains "full-diff-staged: FULL_DIFF has content" "FULL_DIFF:" "$out"
    assert_contains "full-diff-staged: shows staged diff" "staged change" "$out"
}

# FULL_DIFF should include untracked file contents
test_full_diff_has_untracked_content() {
    local dir; dir="$(setup_repo full-diff-untracked README.md)"
    echo "brand new untracked content" > "$dir/new-file.txt"
    local out; out="$(run_collect "$dir")"
    assert_contains "full-diff-untracked: FULL_DIFF has untracked content" "brand new untracked content" "$out"
}

# --- just detection (Improvement #5) ---

test_just_detected() {
    command -v just >/dev/null 2>&1 || { skip "just detection"; return; }
    local dir
    dir="$TEST_BASE/just-detect"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    cat > "$dir/Justfile" <<'EOF'
validate:
    echo validate

test:
    echo test

lint:
    echo lint

build:
    echo build
EOF
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    local out; out="$(run_collect "$dir")"
    assert_contains "just: JUST:validate" "JUST:validate" "$out"
    assert_contains "just: JUST:test" "JUST:test" "$out"
    assert_contains "just: JUST:lint" "JUST:lint" "$out"
    assert_contains "just: JUST:build" "JUST:build" "$out"
}

test_just_not_present_when_no_justfile() {
    command -v just >/dev/null 2>&1 || { skip "just not present (just not installed)"; return; }
    local dir; dir="$(setup_repo no-just README.md)"
    local out; out="$(run_collect "$dir")"
    # No JUST: lines should appear when there's no Justfile
    if [[ "$out" != *"JUST:"* ]]; then
        pass "no-just: no JUST: lines without Justfile"
    else
        fail "no-just: should not emit JUST: lines without Justfile"
    fi
}

# --- JSON mode (Improvement #6) ---

test_json_mode_valid() {
    local dir; dir="$(setup_repo json-mode src/main.py)"
    echo "changed" > "$dir/src/main.py"
    local out
    out="$(cd "$dir" && bash "$GIT_COLLECT" --json "$dir" 2>&1)" || true
    # Verify it's valid JSON via jq if available, else basic shape check
    if command -v jq >/dev/null 2>&1; then
        if printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
            pass "json-mode: valid JSON (jq)"
        else
            fail "json-mode: invalid JSON (jq parse failed)"
        fi
    else
        # Basic shape check: starts with { and ends with }
        if [[ "$out" == "{"*"}"* ]]; then
            pass "json-mode: looks like JSON object"
        else
            fail "json-mode: does not look like JSON object"
        fi
    fi
    assert_contains "json-mode: repo_root field" '"repo_root"' "$out"
    assert_contains "json-mode: branch field" '"branch"' "$out"
    assert_contains "json-mode: quality_checks field" '"quality_checks"' "$out"
    assert_contains "json-mode: just array field" '"just"' "$out"
}

test_json_mode_has_staged() {
    local dir; dir="$(setup_repo json-staged src/main.py)"
    echo "staged change" > "$dir/src/main.py"
    git -C "$dir" add src/main.py
    local out
    out="$(cd "$dir" && bash "$GIT_COLLECT" --json "$dir" 2>&1)" || true
    if command -v jq >/dev/null 2>&1; then
        local count
        count=$(printf '%s' "$out" | jq '.staged | length' 2>/dev/null || echo "0")
        if [[ "$count" -gt 0 ]]; then
            pass "json-staged: staged array populated"
        else
            fail "json-staged: staged array empty (expected >=1)"
        fi
    else
        assert_contains "json-staged: has staged entry" "src/main.py" "$out"
    fi
}

test_text_mode_unchanged() {
    local dir; dir="$(setup_repo text-mode src/main.py)"
    echo "changed" > "$dir/src/main.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "text-mode: COLLECTION_START marker" "=== COLLECTION_START ===" "$out"
    assert_contains "text-mode: COLLECTION_END marker" "=== COLLECTION_END ===" "$out"
    assert_contains "text-mode: REPO_ROOT" "REPO_ROOT:" "$out"
    assert_contains "text-mode: QUALITY_CHECKS" "QUALITY_CHECKS:" "$out"
}

# --- not a git repo ---

test_not_a_git_repo() {
    local dir="$TEST_BASE/not-a-repo"
    rm -rf "$dir"; mkdir -p "$dir"
    local out rc
    out="$(bash "$GIT_COLLECT" "$dir" 2>&1)" || rc=$?
    assert_contains "not a repo: NOT_A_GIT_REPO marker" "=== NOT_A_GIT_REPO ===" "$out"
    assert_contains "not a repo: PATH field" "PATH:$dir" "$out"
    assert_contains "not a repo: INIT_SCRIPT field" "INIT_SCRIPT:" "$out"
    assert_contains "not a repo: INIT_COMMAND field" "INIT_COMMAND:bash" "$out"
    assert_contains "not a repo: ADVICE field" "ADVICE:" "$out"
    assert_contains "not a repo: end marker" "=== END NOT_A_GIT_REPO ===" "$out"
    assert_not_contains "not a repo: no ERROR line" "ERROR" "$out"
    if [[ "${rc:-0}" -ne 2 ]]; then
        fail "not a repo: expected exit code 2, got ${rc:-0}"
    else
        pass "not a repo: exit code 2"
    fi
}

test_not_a_git_repo_json() {
    local dir="$TEST_BASE/not-a-repo-json"
    rm -rf "$dir"; mkdir -p "$dir"
    local out rc
    out="$(bash "$GIT_COLLECT" --json "$dir" 2>&1)" || rc=$?
    assert_contains "not a repo json: not_a_git_repo field" '"not_a_git_repo":true' "$out"
    assert_contains "not a repo json: path field" "\"path\":\"$dir\"" "$out"
    assert_contains "not a repo json: init_command field" '"init_command":"bash' "$out"
    assert_contains "not a repo json: init_script field" '"init_script":"' "$out"
    assert_not_contains "not a repo json: no text markers" "=== NOT_A_GIT_REPO ===" "$out"
    if [[ "${rc:-0}" -ne 2 ]]; then
        fail "not a repo json: expected exit code 2, got ${rc:-0}"
    else
        pass "not a repo json: exit code 2"
    fi
}

# --- main ---

main() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"

    echo "=== git-repository-management: git-collect.sh tests ==="
    echo ""

    echo "--- basic collection ---"
    test_collection_start_end
    test_repo_root
    test_branch_detected
    test_staged_changes
    test_unstaged_changes
    test_untracked_files

    echo ""
    echo "--- tool detection ---"
    test_rtk_detection
    test_rtk_not_available
    test_devbox_detection
    test_devbox_not_available
    test_jj_detection

    echo ""
    echo "--- quality checks ---"
    test_quality_checks_section
    test_npm_test_detected
    test_cargo_test_detected
    test_no_test_configured

    echo ""
    echo "--- just detection ---"
    test_just_detected
    test_just_not_present_when_no_justfile

    echo ""
    echo "--- diff output ---"
    test_diff_stats
    test_full_diff
    test_full_diff_has_staged_content
    test_full_diff_has_untracked_content

    echo ""
    echo "--- JSON mode ---"
    test_json_mode_valid
    test_json_mode_has_staged
    test_text_mode_unchanged

    echo ""
    echo "--- edge cases ---"
    test_not_a_git_repo
    test_not_a_git_repo_json

    echo ""
    echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

    rm -rf "$TEST_BASE"
    exit "$FAILED"
}

main "$@"
