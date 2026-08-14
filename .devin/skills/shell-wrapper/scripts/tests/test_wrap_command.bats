#!/usr/bin/env bats
# test_wrap_command.bats — unit tests for wrap_command.sh
# Tests wrapper detection (devbox, mise, nix, etc.) and rtk wrapping logic.
#
# Run via:
#   bats scripts/tests/test_wrap_command.bats
#
# Creates temp scenarios under /tmp/skill-test/shell-wrapper/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
WRAP_CMD="$SCRIPT_DIR/../wrap_command.sh"
TEST_BASE="/tmp/skill-test/shell-wrapper"

# --- test helpers ---
assert_equals() {
    local expected="$1" actual="$2"
    [[ "$expected" == "$actual" ]] || {
        echo "expected: '$expected'" >&3
        echo "actual:   '$actual'" >&3
        return 1
    }
}
assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in: '$haystack'" >&3
        return 1
    }
}
assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in: '$haystack'" >&3
        return 1
    }
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

@test "devbox+rtk git status" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario devbox-rtk devbox.json)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "devbox run -- rtk git status" "$out"
}

@test "devbox only: vim (rtk excluded)" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    local dir
    dir="$(setup_scenario devbox-vim devbox.json)"
    local out
    out="$(run_resolve "$dir" vim file.txt)"
    assert_equals "devbox run -- vim file.txt" "$out"
}

@test "devbox only: just build (rtk unsupported)" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    local dir
    dir="$(setup_scenario devbox-unsupported devbox.json)"
    local out
    out="$(run_resolve "$dir" just build)"
    assert_equals "just build" "$out"
}

@test "--raw: git status (no rtk)" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario raw-flag devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git status)"
    assert_equals "devbox run -- git status" "$out"
}

@test "chained commands" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario chained devbox.json)"
    local out
    out="$(run_resolve "$dir" git fetch '&&' git status)"
    # Output uses %q quoting (backslash-escaped spaces): rtk\ git\ fetch
    assert_contains "rtk\ git\ fetch" "$out"
    assert_contains "rtk\ git\ status" "$out"
    assert_contains "bash -c" "$out"
}

@test "--raw chained" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    local dir
    dir="$(setup_scenario raw-chained devbox.json)"
    local out
    out="$(run_resolve "$dir" --raw git fetch '&&' git status)"
    assert_not_contains "rtk" "$out"
    assert_contains "bash -c" "$out"
}

@test "no wrapper: rtk git status" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario no-wrapper)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_equals "rtk git status" "$out"
}

@test "no wrapper: echo hello (no rtk)" {
    local dir
    dir="$(setup_scenario no-wrapper-no-rtk)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    # echo is not rtk-supported, no devbox → just echo hello
    assert_equals "echo hello" "$out"
}

@test "inside devbox: rtk git status (no devbox prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-devbox devbox.json)"
    local out
    out="$(DEVBOX_SHELL=1 run_resolve "$dir" git status)"
    # Already inside devbox → no devbox prefix, just rtk
    assert_equals "rtk git status" "$out"
}

@test "inside mise: rtk git status (no mise prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-mise mise.toml)"
    local out
    out="$(MISE_SHELL=1 run_resolve "$dir" git status)"
    assert_equals "rtk git status" "$out"
}

@test "mise detection" {
    command -v mise >/dev/null 2>&1 || skip "mise not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario mise-present mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise exec --" "$out"
    assert_contains "rtk git status" "$out"
}

@test "mise: detects .mise.toml" {
    command -v mise >/dev/null 2>&1 || skip "mise not installed"
    local dir
    dir="$(setup_scenario mise-dot .mise.toml)"
    local out
    out="$(run_resolve "$dir" git status)"
    assert_contains "mise exec --" "$out"
}

@test "nix flake detection" {
    command -v nix >/dev/null 2>&1 || skip "nix not installed"
    local dir
    dir="$(setup_scenario nix-flake flake.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix develop --command" "$out"
}

@test "nix shell.nix detection" {
    command -v nix >/dev/null 2>&1 || skip "nix not installed"
    local dir
    dir="$(setup_scenario nix-shell shell.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "nix-shell --run" "$out"
}

@test "inside nix: rtk git status (no nix prefix)" {
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario inside-nix flake.nix)"
    local out
    out="$(IN_NIX_SHELL=1 run_resolve "$dir" git status)"
    assert_equals "rtk git status" "$out"
}

@test "flox detection" {
    command -v flox >/dev/null 2>&1 || skip "flox not installed"
    local dir
    dir="$(setup_scenario flox-present flox.nix)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "flox activate --" "$out"
}

@test "direnv detection" {
    command -v direnv >/dev/null 2>&1 || skip "direnv not installed"
    local dir
    dir="$(setup_scenario direnv-present .envrc)"
    local out
    out="$(run_resolve "$dir" echo hello)"
    assert_contains "direnv" "$out"
}

@test "pipe command" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
    command -v rtk >/dev/null 2>&1 || skip "rtk not installed"
    local dir
    dir="$(setup_scenario pipe-cmd devbox.json)"
    local out
    out="$(run_resolve "$dir" git log '|' head -5)"
    # Output uses %q quoting: rtk\ git\ log
    assert_contains "rtk\ git\ log" "$out"
    assert_contains "bash -c" "$out"
}
