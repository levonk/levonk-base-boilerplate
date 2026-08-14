#!/usr/bin/env bash
# test_wrap_command.sh — unit tests for wrap_command.sh
# Tests wrapper detection (devbox, mise, nix, etc.) and rtk wrapping logic.
#
# Run directly:
#   bash scripts/tests/test_wrap_command.sh
#
# Creates temp scenarios under /tmp/skill-test/shell-wrapper/{scenario}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAP_CMD="$SCRIPT_DIR/../wrap_command.sh"
TEST_BASE="/tmp/skill-test/shell-wrapper"

FAILED=0
PASSED=0
SKIPPED=0

# --- test helpers ---
pass() { echo "  PASS: $1"; PASSED=$((PASSED + 1)); }
fail() { echo "  FAIL: $1"; FAILED=$((FAILED + 1)); }
skip() { echo "  SKIP: $1 (tool not installed)"; SKIPPED=$((SKIPPED + 1)); }
assert_equals() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        pass "$desc"
    else
        fail "$desc — expected: '$expected', got: '$actual'"
    fi
}
assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — expected '$needle' in '$haystack'"
    fi
}
assert_not_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        pass "$desc"
    else
        fail "$desc — did not expect '$needle' in '$haystack'"
    fi
}

# Create a scenario dir with specific files. Echoes the dir path.
# Usage: setup_scenario scenario_name file1 file2 ...
setup_scenario() {
    local scenario="$1"; shift
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        touch "$dir/$f"
    done
    echo "$dir"
}

# Run wrap_command.sh in resolve mode from a given dir.
# Echoes the wrapped command string.
run_resolve() {
    local dir="$1"; shift
    (cd "$dir" && bash "$WRAP_CMD" "$@") 2>/dev/null || true
}

# --- tests ---

test_devbox_rtk_git_status() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox+rtk git status"; return; }
    command -v rtk >/dev/null 2>&1 || { skip "devbox+rtk git status"; return; }
    local dir
    dir="$(setup_scenario devbox-rtk devbox.json)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "devbox+rtk: git status" "devbox run -- rtk git status" "$out"
}

test_devbox_no_rtk_vim() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox vim (excluded from rtk)"; return; }
    local dir
    dir="$(setup_scenario devbox-vim devbox.json)"
    local out
    out="$(run_resolve "$dir" vim file.txt)"
    assert_equals "devbox only: vim (rtk excluded)" "devbox run -- vim file.txt" "$out"
}

test_devbox_no_rtk_unsupported() {
    command -v devbox >/dev/null 2>&1 || { skip "devbox unsupported cmd"; return; }
    local dir
    dir="$(setup_scenario devbox-unsupported devbox.json)"
    local out
    out="$(run_resolve "$dir" just build)"
    assert_equals "devbox only: just build (rtk unsupported)" "devbox run -- just build" "$out"
}

test_raw_flag_skips_rtk() {
    command -v devbox >/dev/null 2>&1 || { skip "--raw flag"; return; }
    command -v rtk >/dev/null 2>&1 || { skip "--raw flag"; return; }
    local dir
    dir="$(setup_scenario raw-flag devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git status)"
    assert_equals "--raw: git status (no rtk)" "devbox run -- git status" "$out"
}

test_chained_commands() {
    command -v devbox >/dev/null 2>&1 || { skip "chained commands"; return; }
    command -v rtk >/dev/null 2>&1 || { skip "chained commands"; return; }
    local dir
    dir="$(setup_scenario chained devbox.json)"
    local out
    out="$(run_resolve "$dir" git fetch '&&' git status)"
    # Output uses %q quoting (backslash-escaped spaces): rtk\ git\ fetch
    assert_contains "chained: rtk rewrites both commands" "rtk\ git\ fetch" "$out"
    assert_contains "chained: rtk rewrites second command" "rtk\ git\ status" "$out"
    assert_contains "chained: uses bash -c" "bash -c" "$out"
}

test_raw_chained_commands() {
    command -v devbox >/dev/null 2>&1 || { skip "--raw chained"; return; }
    local dir
    dir="$(setup_scenario raw-chained devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git fetch '&&' git status)"
    assert_not_contains "--raw chained: no rtk prefix" "rtk" "$out"
    assert_contains "--raw chained: uses bash -c" "bash -c" "$out"
}

test_no_wrapper_rtk() {
    command -v rtk >/dev/null 2>&1 || { skip "no-wrapper rtk"; return; }
    local dir
    dir="$(setup_scenario no-wrapper)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "no wrapper: rtk git status" "rtk git status" "$out"
}

test_no_wrapper_no_rtk() {
    local dir
    dir="$(setup_scenario no-wrapper-no-rtk)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    # echo is not rtk-supported, no devbox → just echo hello
    assert_equals "no wrapper: echo hello (no rtk)" "echo hello" "$out"
}

test_already_inside_devbox() {
    command -v rtk >/dev/null 2>&1 || { skip "already inside devbox"; return; }
    local dir
    dir="$(setup_scenario inside-devbox devbox.json)"
    local out
    out="$(DEVBOX_SHELL=1 run_resolve "$dir" git status)"
    # Already inside devbox → no devbox prefix, just rtk
    assert_equals "inside devbox: rtk git status (no devbox prefix)" "rtk git status" "$out"
}

test_already_inside_mise() {
    command -v rtk >/dev/null 2>&1 || { skip "already inside mise"; return; }
    local dir
    dir="$(setup_scenario inside-mise mise.toml)"
    local out
    out="$(MISE_SHELL=1 run_resolve "$dir" git status)"
    assert_equals "inside mise: rtk git status (no mise prefix)" "rtk git status" "$out"
}

test_mise_detection() {
    command -v mise >/dev/null 2>&1 || { skip "mise detection"; return; }
    command -v rtk >/dev/null 2>&1 || { skip "mise detection"; return; }
    local dir
    dir="$(setup_scenario mise-present mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise: detects mise.toml" "mise exec --" "$out"
    assert_contains "mise: rtk wraps git" "rtk git status" "$out"
}

test_mise_dot_mise_toml() {
    command -v mise >/dev/null 2>&1 || { skip "mise .mise.toml"; return; }
    local dir
    dir="$(setup_scenario mise-dot .mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise: detects .mise.toml" "mise exec --" "$out"
}

test_nix_flake() {
    command -v nix >/dev/null 2>&1 || { skip "nix flake detection"; return; }
    local dir
    dir="$(setup_scenario nix-flake flake.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix: detects flake.nix" "nix develop --command" "$out"
}

test_nix_shell_nix() {
    command -v nix >/dev/null 2>&1 || { skip "nix shell.nix detection"; return; }
    local dir
    dir="$(setup_scenario nix-shell shell.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix: detects shell.nix" "nix-shell --run" "$out"
}

test_already_inside_nix() {
    command -v rtk >/dev/null 2>&1 || { skip "already inside nix"; return; }
    local dir
    dir="$(setup_scenario inside-nix flake.nix)"
    local out
    out="$(IN_NIX_SHELL=1 run_resolve "$dir" git status)"
    assert_equals "inside nix: rtk git status (no nix prefix)" "rtk git status" "$out"
}

test_flox_detection() {
    command -v flox >/dev/null 2>&1 || { skip "flox detection"; return; }
    local dir
    dir="$(setup_scenario flox-present flox.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "flox: detects flox.nix" "flox activate --" "$out"
}

test_direnv_detection() {
    command -v direnv >/dev/null 2>&1 || { skip "direnv detection"; return; }
    local dir
    dir="$(setup_scenario direnv-present .envrc)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "direnv: detects .envrc" "direnv" "$out"
}

test_pipe_in_command() {
    command -v devbox >/dev/null 2>&1 || { skip "pipe command"; return; }
    command -v rtk >/dev/null 2>&1 || { skip "pipe command"; return; }
    local dir
    dir="$(setup_scenario pipe-cmd devbox.json)"
    local out
    out="$(run_resolve "$dir" git log '|' head -5)"
    # Output uses %q quoting: rtk\ git\ log
    assert_contains "pipe: rtk wraps first command" "rtk\ git\ log" "$out"
    assert_contains "pipe: uses bash -c" "bash -c" "$out"
}

# --- main ---
main() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"

    echo "=== shell-wrapper: wrap_command.sh tests ==="
    echo ""

    test_devbox_rtk_git_status
    test_devbox_no_rtk_vim
    test_devbox_no_rtk_unsupported
    test_raw_flag_skips_rtk
    test_chained_commands
    test_raw_chained_commands
    test_no_wrapper_rtk
    test_no_wrapper_no_rtk
    test_already_inside_devbox
    test_already_inside_mise
    test_mise_detection
    test_mise_dot_mise_toml
    test_nix_flake
    test_nix_shell_nix
    test_already_inside_nix
    test_flox_detection
    test_direnv_detection
    test_pipe_in_command

    echo ""
    echo "=== Results: $PASSED passed, $FAILED failed, $SKIPPED skipped ==="

    rm -rf "$TEST_BASE"
    exit "$FAILED"
}

main "$@"
