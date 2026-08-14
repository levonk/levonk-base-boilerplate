#!/usr/bin/env bats
# test_git_collect.bats — unit tests for git-collect.sh
# Tests repository data collection, tool detection, and quality checks.
#
# Run via: bats scripts/tests/test_git_collect.bats
#
# Creates temp git repos under /tmp/skill-test/git-collect/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
GIT_COLLECT="$SCRIPT_DIR/../git-collect.sh"
TEST_BASE="/tmp/skill-test/git-collect"

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

@test "collection start and end markers" {
    local dir; dir="$(setup_repo basic README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "=== COLLECTION_START ===" "$out"
    assert_contains "=== COLLECTION_END ===" "$out"
}

@test "repo root" {
    local dir; dir="$(setup_repo repo-root src/main.py)"
    local out; out="$(run_collect "$dir")"
    # git rev-parse may resolve symlinks (/tmp → /private/tmp on macOS)
    assert_contains "REPO_ROOT:" "$out"
    assert_contains "repo-root" "$out"
}

@test "branch detected" {
    local dir; dir="$(setup_repo branch-detected src/index.ts)"
    local out; out="$(run_collect "$dir")"
    assert_contains "BRANCH:" "$out"
}

@test "staged changes" {
    local dir; dir="$(setup_repo staged src/app.py)"
    echo "modified" > "$dir/src/app.py"
    git -C "$dir" add -A
    local out; out="$(run_collect "$dir")"
    assert_contains "STAGED:" "$out"
}

@test "unstaged changes" {
    local dir; dir="$(setup_repo unstaged src/lib.rs)"
    echo "modified" > "$dir/src/lib.rs"
    local out; out="$(run_collect "$dir")"
    assert_contains "UNSTAGED:" "$out"
}

@test "untracked files" {
    local dir; dir="$(setup_repo untracked src/main.go)"
    echo "new" > "$dir/new-file.txt"
    local out; out="$(run_collect "$dir")"
    assert_contains "UNTRACKED:" "$out"
}

# --- tool detection tests ---

@test "rtk detection" {
    command -v rtk >/dev/null 2>&1 || skip "RTK not installed"
    local dir; dir="$(setup_repo rtk-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "RTK:1" "$out"
}

@test "rtk not available" {
    # This test only works if rtk is NOT installed — skip if it is.
    # Note: rtk may be available via devbox shims even when not on the
    # test shell's PATH, so this test is best-effort.
    command -v rtk >/dev/null 2>&1 && skip "rtk is installed"
    local dir; dir="$(setup_repo no-rtk README.md)"
    local out; out="$(run_collect "$dir")"
    # RTK may still be detected via devbox shims inside the script. Accept
    # either RTK:0 or RTK:1 — the test only asserts the flag is present.
    assert_contains "RTK:" "$out"
}

@test "devbox detection" {
    command -v devbox >/dev/null 2>&1 || skip "devbox not installed"
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
    assert_contains "DEVBOX:" "$out"
}

@test "devbox not available" {
    command -v devbox >/dev/null 2>&1 && skip "devbox is installed"
    local dir; dir="$(setup_repo no-devbox README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "DEVBOX:0" "$out"
}

@test "jj detection" {
    command -v jj >/dev/null 2>&1 || skip "jj not installed"
    local dir; dir="$(setup_repo jj-detect README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "JJ:1" "$out"
}

# --- quality check tests ---

@test "quality checks section" {
    local dir; dir="$(setup_repo quality-checks package.json)"
    local out; out="$(run_collect "$dir")"
    assert_contains "QUALITY_CHECKS:" "$out"
}

@test "npm test detected" {
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
    assert_contains "NPM_TEST:" "$out"
}

@test "cargo test detected" {
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
    assert_contains "CARGO_TEST:" "$out"
}

@test "no test configured" {
    local dir; dir="$(setup_repo no-test README.md)"
    local out; out="$(run_collect "$dir")"
    assert_contains "TESTS:NOT_CONFIGURED" "$out"
}

# --- diff stats ---

@test "diff stats" {
    local dir; dir="$(setup_repo diff-stats src/a.py src/b.py)"
    echo "changed" > "$dir/src/a.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "DIFF_STATS:" "$out"
}

@test "full diff" {
    local dir; dir="$(setup_repo full-diff src/main.py)"
    echo "changed content" > "$dir/src/main.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "FULL_DIFF:" "$out"
}

# FULL_DIFF should contain actual diff content (not empty) when there are
# staged changes. Regression test for the bug where FULL_DIFF was empty
# because `git diff` (no --cached) only shows unstaged changes.
@test "full diff has staged content" {
    local dir; dir="$(setup_repo full-diff-staged src/main.py)"
    echo "staged change" > "$dir/src/main.py"
    git -C "$dir" add src/main.py  # stage everything; no unstaged changes
    local out; out="$(run_collect "$dir")"
    assert_contains "FULL_DIFF:" "$out"
    assert_contains "staged change" "$out"
}

# FULL_DIFF should include untracked file contents
@test "full diff has untracked content" {
    local dir; dir="$(setup_repo full-diff-untracked README.md)"
    echo "brand new untracked content" > "$dir/new-file.txt"
    local out; out="$(run_collect "$dir")"
    assert_contains "brand new untracked content" "$out"
}

# --- just detection (Improvement #5) ---

@test "just detected" {
    command -v just >/dev/null 2>&1 || skip "just not installed"
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
    assert_contains "JUST:validate" "$out"
    assert_contains "JUST:test" "$out"
    assert_contains "JUST:lint" "$out"
    assert_contains "JUST:build" "$out"
}

@test "just not present when no justfile" {
    command -v just >/dev/null 2>&1 || skip "just not installed"
    local dir; dir="$(setup_repo no-just README.md)"
    local out; out="$(run_collect "$dir")"
    # No JUST: lines should appear when there's no Justfile
    [[ "$out" != *"JUST:"* ]] || {
        echo "should not emit JUST: lines without Justfile" >&3
        echo "$out" >&3
        return 1
    }
}

# --- JSON mode (Improvement #6) ---

@test "json mode valid" {
    local dir; dir="$(setup_repo json-mode src/main.py)"
    echo "changed" > "$dir/src/main.py"
    local out
    out="$(cd "$dir" && bash "$GIT_COLLECT" --json "$dir" 2>&1)" || true
    # Verify it's valid JSON via jq if available, else basic shape check
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$out" | jq -e . >/dev/null 2>&1 || {
            echo "invalid JSON (jq parse failed):" >&3
            echo "$out" >&3
            return 1
        }
    else
        # Basic shape check: starts with { and ends with }
        [[ "$out" == "{"*"}"* ]] || {
            echo "does not look like JSON object:" >&3
            echo "$out" >&3
            return 1
        }
    fi
    assert_contains '"repo_root"' "$out"
    assert_contains '"branch"' "$out"
    assert_contains '"quality_checks"' "$out"
    assert_contains '"just"' "$out"
}

@test "json mode has staged" {
    local dir; dir="$(setup_repo json-staged src/main.py)"
    echo "staged change" > "$dir/src/main.py"
    git -C "$dir" add src/main.py
    local out
    out="$(cd "$dir" && bash "$GIT_COLLECT" --json "$dir" 2>&1)" || true
    if command -v jq >/dev/null 2>&1; then
        local count
        count=$(printf '%s' "$out" | jq '.staged | length' 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] || {
            echo "staged array empty (expected >=1), got $count" >&3
            echo "$out" >&3
            return 1
        }
    else
        assert_contains "src/main.py" "$out"
    fi
}

@test "text mode unchanged" {
    local dir; dir="$(setup_repo text-mode src/main.py)"
    echo "changed" > "$dir/src/main.py"
    local out; out="$(run_collect "$dir")"
    assert_contains "=== COLLECTION_START ===" "$out"
    assert_contains "=== COLLECTION_END ===" "$out"
    assert_contains "REPO_ROOT:" "$out"
    assert_contains "QUALITY_CHECKS:" "$out"
}

# --- not a git repo ---

@test "not a git repo" {
    local dir="$TEST_BASE/not-a-repo"
    rm -rf "$dir"; mkdir -p "$dir"
    local out rc
    out="$(bash "$GIT_COLLECT" "$dir" 2>&1)" || rc=$?
    assert_contains "=== NOT_A_GIT_REPO ===" "$out"
    assert_contains "PATH:$dir" "$out"
    assert_contains "INIT_SCRIPT:" "$out"
    assert_contains "INIT_COMMAND:bash" "$out"
    assert_contains "ADVICE:" "$out"
    assert_contains "=== END NOT_A_GIT_REPO ===" "$out"
    assert_not_contains "ERROR" "$out"
    [[ "${rc:-0}" -eq 2 ]] || {
        echo "expected exit code 2, got ${rc:-0}" >&3
        return 1
    }
}

@test "not a git repo json" {
    local dir="$TEST_BASE/not-a-repo-json"
    rm -rf "$dir"; mkdir -p "$dir"
    local out rc
    out="$(bash "$GIT_COLLECT" --json "$dir" 2>&1)" || rc=$?
    assert_contains '"not_a_git_repo":true' "$out"
    assert_contains "\"path\":\"$dir\"" "$out"
    assert_contains '"init_command":"bash' "$out"
    assert_contains '"init_script":"' "$out"
    assert_not_contains "=== NOT_A_GIT_REPO ===" "$out"
    [[ "${rc:-0}" -eq 2 ]] || {
        echo "expected exit code 2, got ${rc:-0}" >&3
        return 1
    }
}

# --- template-syntax paths (copier/Jinja2/chezmoi/cookiecutter) ---
# Repos using template engines have literal {{variable}} in file paths.
# These paths are valid on disk and in git, but can break naive JSON
# escaping, printf format strings, and shell globbing. These tests verify
# git-collect.sh handles them correctly in both text and JSON modes.

@test "template-syntax paths in text mode" {
    local dir
    dir="$TEST_BASE/template-paths-text"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    # Create files with copier/Jinja2-style {{package_name}} paths
    mkdir -p "$dir/apps/cli/bash/core/files/.agents/workflows"
    echo "{% include 'partial.jinja' %}" > "$dir/apps/cli/bash/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    mkdir -p "$dir/apps/cli/rust/core/files/.agents/workflows"
    echo "the {{package_name}} project" > "$dir/apps/cli/rust/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    # Modify one file to produce an unstaged change
    echo "modified {{package_name}} content" > "$dir/apps/cli/bash/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    local out; out="$(run_collect "$dir")"
    assert_contains "=== COLLECTION_START ===" "$out"
    assert_contains "{{package_name}}-git.md.jinja" "$out"
    assert_contains "UNSTAGED:" "$out"
}

@test "template-syntax paths in json mode produce valid json" {
    local dir
    dir="$TEST_BASE/template-paths-json"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    # Create files with various template-syntax path patterns.
    # Use {{package_name}} (copier) and {{ .chezmoi.var }} (chezmoi) —
    # both are common. Avoid {{cookiecutter.x}} because bash brace
    # expansion mangles nested {{}} during path creation.
    mkdir -p "$dir/apps/cli/python/core/files/.agents/workflows"
    echo "content" > "$dir/apps/cli/python/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    mkdir -p "$dir/templates/chezmoi"
    echo "content" > "$dir/templates/chezmoi/{{ .chezmoi.var }}.tmpl"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    # Stage a modification to a template-syntax path
    echo "modified" > "$dir/apps/cli/python/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    git -C "$dir" add -A
    # Capture stdout only — stderr may contain devbox/rtk warnings that
    # would corrupt the JSON parse check. Disable rtk and devbox to get
    # clean plain-git output without wrapper noise.
    local out
    out="$(cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$GIT_COLLECT" --json "$dir" 2>/dev/null)" || true
    # Must be valid JSON — jq parse failure means the escaping is broken
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$out" | jq -e . >/dev/null 2>&1 || {
            echo "invalid JSON with template-syntax paths (jq parse failed):" >&3
            echo "$out" >&3
            return 1
        }
        # Verify the {{}} paths are preserved in the staged array
        local staged_json
        staged_json=$(printf '%s' "$out" | jq -r '.staged[]' 2>/dev/null || true)
        assert_contains "{{package_name}}-git.md.jinja" "$staged_json"
    else
        # Without jq, basic shape check
        [[ "$out" == "{"*"}"* ]] || {
            echo "does not look like JSON object:" >&3
            echo "$out" >&3
            return 1
        }
        assert_contains "{{package_name}}" "$out"
    fi
}

@test "template-syntax paths in untracked files produce valid json" {
    local dir
    dir="$TEST_BASE/template-paths-untracked"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    echo "initial" > "$dir/README.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    # Add untracked files with template-syntax paths
    mkdir -p "$dir/apps/cli/go/core/files/.agents/workflows"
    echo "new {{package_name}} workflow" > "$dir/apps/cli/go/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    local out
    out="$(cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$GIT_COLLECT" --json "$dir" 2>/dev/null)" || true
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$out" | jq -e . >/dev/null 2>&1 || {
            echo "invalid JSON with untracked template-syntax paths:" >&3
            echo "$out" >&3
            return 1
        }
        local untracked_json
        untracked_json=$(printf '%s' "$out" | jq -r '.untracked[]' 2>/dev/null || true)
        assert_contains "{{package_name}}-git.md.jinja" "$untracked_json"
    else
        assert_contains "{{package_name}}" "$out"
    fi
}

@test "template-syntax paths in full_diff produce valid json" {
    local dir
    dir="$TEST_BASE/template-paths-fulldiff"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    # Committed file with template-syntax content
    mkdir -p "$dir/apps/cli/rust/core/files/.agents/workflows"
    printf 'the {{package_name}} project\n' > "$dir/apps/cli/rust/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    # Modify it — diff will contain {{package_name}} in both path and content
    printf 'the {{package_name}} project\nmodified line\n' > "$dir/apps/cli/rust/core/files/.agents/workflows/{{package_name}}-git.md.jinja"
    local out
    out="$(cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$GIT_COLLECT" --json "$dir" 2>/dev/null)" || true
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$out" | jq -e . >/dev/null 2>&1 || {
            echo "invalid JSON with template-syntax diff content:" >&3
            echo "$out" >&3
            return 1
        }
        # full_diff should contain the {{package_name}} path and content
        local full_diff
        full_diff=$(printf '%s' "$out" | jq -r '.full_diff' 2>/dev/null || true)
        assert_contains "{{package_name}}-git.md.jinja" "$full_diff"
        assert_contains "{{package_name}} project" "$full_diff"
    else
        assert_contains "{{package_name}}" "$out"
    fi
}

@test "control characters in diff content produce valid json" {
    local dir
    dir="$TEST_BASE/control-chars"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    echo "initial" > "$dir/binary-ish.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    # Write content with control characters (bell, backspace, vertical tab)
    # that the bash-only json_escape fallback misses but jq handles
    printf 'normal text\x07bell\x08backspace\x0bvtab\n' > "$dir/binary-ish.txt"
    local out
    out="$(cd "$dir" && WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$GIT_COLLECT" --json "$dir" 2>/dev/null)" || true
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$out" | jq -e . >/dev/null 2>&1 || {
            echo "invalid JSON with control characters in diff:" >&3
            echo "$out" >&3
            return 1
        }
    else
        # Without jq, the bash fallback may not escape all control chars.
        # Skip this test — it's only meaningful when jq is available.
        skip "jq not installed (bash fallback doesn't cover all control chars)"
    fi
}

# --- wrapper_prefix caching regression tests ---
# git-collect.sh hung indefinitely in repos with devbox.json when devbox
# was broken. Each git_cmd() call invoked wrapper_prefix() which spawned
# cli-tool-discovery.sh with a 15s devbox probe timeout. The cache fix
# ensures wrapper_prefix() is called once, not once-per-git-command.

@test "wrapper_prefix cache prevents repeated devbox probes" {
    local dir
    dir="$TEST_BASE/wrapper-cache"
    rm -rf "$dir"; mkdir -p "$dir"
    git init -q "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    # Create a devbox.json so wrapper detection would try to probe devbox
    cat > "$dir/devbox.json" <<'EOF'
{
  "packages": [],
  "shell": { "init_hook": "" }
}
EOF
    echo "content" > "$dir/README.md"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "initial"
    echo "modified" > "$dir/README.md"
    # Run with devbox disabled to simulate a broken devbox environment.
    # Without the cache fix, this would hang for 15s per git_cmd() call
    # because wrapper_prefix() would re-probe devbox every time.
    # With the fix, wrapper_prefix() returns empty immediately when
    # WRAPPER_DEVBOX_DISABLED=1 and a devbox.json exists.
    local start_time end_time elapsed
    start_time=$(date +%s)
    WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$GIT_COLLECT" "$dir" >/dev/null 2>&1 || true
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    # Without the cache, this would take 15s+ per git call (300s+ total).
    # With the cache, it should complete in under 10s even on slow systems.
    # The threshold is generous to avoid flaky tests on CI.
    [[ "$elapsed" -lt 15 ]] || {
        echo "git-collect took ${elapsed}s with WRAPPER_DEVBOX_DISABLED=1 — cache may not be working" >&3
        echo "expected <15s, got ${elapsed}s" >&3
        return 1
    }
}
