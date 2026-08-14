#!/usr/bin/env bash

# git-collect.sh - Collect all repository data for AI analysis
# Purpose: Single handoff to collect changes, run quality checks, and gather all needed data
# Usage: git-collect.sh [repo_root]
# Output: Structured data for AI decision-making

set -euo pipefail

# RTK (Rust Token Killer) — use rtk as a proxy for git and supported
# commands when available to reduce LLM token consumption by 60-90%.
# See: https://github.com/rtk-ai/rtk
# Detection is handled by the shared rtk-helpers.sh include below.
# RTK_AVAILABLE is set for the AVAILABLE_TOOLS output and probe_devbox.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

# Optional tool availability flags (for AVAILABLE_TOOLS output).
# The actual wrapping logic is handled by the shared includes below.
if command -v jj >/dev/null 2>&1; then JJ_AVAILABLE=1; else JJ_AVAILABLE=0; fi
if command -v difft >/dev/null 2>&1; then DIFFT_AVAILABLE=1; else DIFFT_AVAILABLE=0; fi
if command -v delta >/dev/null 2>&1; then DELTA_AVAILABLE=1; else DELTA_AVAILABLE=0; fi
if command -v hunk >/dev/null 2>&1; then HUNK_AVAILABLE=1; else HUNK_AVAILABLE=0; fi
if command -v git-summary >/dev/null 2>&1; then GIT_EXTRAS_AVAILABLE=1; else GIT_EXTRAS_AVAILABLE=0; fi

# Include shared wrapper helpers (probe_devbox, wrapper_prefix, devbox_run, run_command).
# wrapper-helpers.sh — shared functions for environment wrapper detection
#
# Included by skills that need to wrap commands with environment wrappers
# (devbox, mise, flox, direnv, nix). Provides:
#   - probe_devbox():    hang-safe probe that disables devbox if it doesn't respond
#   - wrapper_prefix():  resolve the wrapper prefix (e.g. "devbox run --")
#   - devbox_run():      run a command through devbox when available, else directly
#   - run_command():     run a command through the detected wrapper, else directly
#
# Depends on: cli-tool-discovery.sh materialized in the same scripts/ directory.
#
# Consumers:
#   - shell-wrapper/scripts/wrap_command.sh.tmpl
#   - git-repository-management/scripts/git-collect.sh.tmpl
#   - git-repository-management/scripts/git-commit-batch.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - git-repository-management/scripts/git-rollback.sh.tmpl
#
# Usage (in a .tmpl script, after defining SCRIPT_DIR and CLI_TOOL_DISCOVERY):
#   Include this file via the templater's include directive.
#
# Optional override: set WRAPPER_DEVBOX_DISABLED=1 before including to make
# wrapper_prefix() skip the devbox wrapper (also set by probe_devbox on hang).

# Probe devbox: verify `devbox run` actually responds within a timeout.
# Tests with the real command chain (rtk git / git) to catch wrapper recursion.
# If it hangs (e.g. broken wrapper recursion, nix store issues), disable
# devbox wrapping for the rest of the script and fall back to direct execution.
#
# Optional: set PROBE_DEVBOX_TIMEOUT_SECS to override the default 15s timeout.
# Optional: set PROBE_DEVBOX_TEST_CMD to override the test command (default:
#   "rtk git --version" if rtk is available, else "git --version").
#
# This function is idempotent — calling it multiple times is safe. After the
# first call, WRAPPER_DEVBOX_DISABLED reflects the probe result and subsequent
# calls return immediately.
probe_devbox() {
    # If devbox was already disabled by a prior probe or caller, nothing to do.
    if [[ "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
        return 0
    fi
    # If cli-tool-discovery says we're already inside a devbox shell, no probe
    # needed — devbox binaries are on PATH and no wrapper detection is required.
    if [[ -n "${DEVBOX_SHELL:-}${IN_DEVBOX_SHELL:-}" ]]; then
        return 0
    fi
    # If no devbox.json up the tree, no point probing.
    if ! command -v devbox >/dev/null 2>&1; then
        WRAPPER_DEVBOX_DISABLED=1
        return 0
    fi
    local _timeout="${PROBE_DEVBOX_TIMEOUT_SECS:-15}"
    local _test_cmd=(git --version)
    if command -v rtk >/dev/null 2>&1; then
        _test_cmd=(rtk git --version)
    fi
    # Honor caller override for the test command.
    if [[ -n "${PROBE_DEVBOX_TEST_CMD:-}" ]]; then
        # shellcheck disable=SC2206  # intentional word-splitting on caller's command
        _test_cmd=(${PROBE_DEVBOX_TEST_CMD})
    fi
    devbox run -- "${_test_cmd[@]}" >/dev/null 2>&1 &
    local _pid=$!
    local _elapsed=0
    while kill -0 "$_pid" 2>/dev/null; do
        if [[ "$_elapsed" -ge "$_timeout" ]]; then
            kill -9 "$_pid" 2>/dev/null
            wait "$_pid" 2>/dev/null || true
            echo "⚠️ devbox run hung after ${_timeout}s (likely broken wrapper), falling back to direct execution" >&2
            WRAPPER_DEVBOX_DISABLED=1
            return 1
        fi
        sleep 1
        _elapsed=$((_elapsed + 1))
    done
    local _exit=0
    wait "$_pid" || _exit=$?
    if [[ "$_exit" -ne 0 ]]; then
        echo "⚠️ devbox run failed (exit $_exit), falling back to direct execution" >&2
        WRAPPER_DEVBOX_DISABLED=1
        return 1
    fi
    return 0
}

# Resolve the environment wrapper for the current directory.
# Prints the wrapper prefix (e.g. "devbox run --") or empty if none.
# Delegates entirely to cli-tool-discovery.sh, which checks "already inside"
# env vars (DEVBOX_SHELL, MISE_SHELL, FLOX_ACTIVE, DIRENV_DIR, IN_NIX_SHELL)
# and walks up from cwd for config files. No duplicate detection logic here.
#
# CACHING: The result is cached in WRAPPER_PREFIX_CACHE for the lifetime of the
# script. cli-tool-discovery.sh can take up to 15s per call (devbox probe
# timeout), and wrapper_prefix() is called on every devbox_run() — without
# caching, a script that makes 20 git_cmd() calls would block for 300s.
# The cache is invalidated if WRAPPER_DEVBOX_DISABLED changes after the first
# call (probe_devbox may set it). Set WRAPPER_PREFIX_REFRESH=1 to force a
# re-probe.
wrapper_prefix() {
    # Return cached result if available and the devbox-disabled flag hasn't changed.
    if [[ -n "${WRAPPER_PREFIX_CACHE+x}" && "${WRAPPER_PREFIX_REFRESH:-0}" -eq 0 ]]; then
        if [[ "${WRAPPER_PREFIX_CACHE_DISABLED:-0}" -eq "${WRAPPER_DEVBOX_DISABLED:-0}" ]]; then
            printf '%s' "$WRAPPER_PREFIX_CACHE"
            return
        fi
    fi

    # Fast path: if devbox was disabled by probe_devbox (hang/failure) or by
    # the caller, skip the cli-tool-discovery.sh probe entirely. The probe
    # internally calls `devbox run --` which can take 15s to timeout — calling
    # it when devbox is already known-broken defeats the purpose of the probe.
    # Check for other wrappers (mise, flox, direnv, nix) only when devbox is
    # NOT the disabled one — but in practice, if devbox.json exists and devbox
    # is disabled, the other wrappers are not relevant for this repo.
    if [[ "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
        # Still check for non-devbox wrappers via cli-tool-discovery, but only
        # if there's no devbox.json up the tree (if there IS one, devbox was
        # the intended wrapper and it's broken — don't waste 15s re-probing).
        local _has_devbox_json=0
        local _dir="$PWD"
        while [[ "$_dir" != "/" ]]; do
            if [[ -f "$_dir/devbox.json" ]]; then
                _has_devbox_json=1
                break
            fi
            _dir="$(dirname "$_dir")"
        done
        if [[ "$_has_devbox_json" -eq 1 ]]; then
            WRAPPER_PREFIX_CACHE=""
            WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
            printf ''
            return
        fi
    fi

    if [[ ! -f "${CLI_TOOL_DISCOVERY:-}" ]]; then
        WRAPPER_PREFIX_CACHE=""
        WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
        printf ''
        return
    fi

    # Probe with a nonexistent tool name — cli-tool-discovery.sh checks PATH
    # first (skipped for nonexistent tools), then wrappers. The output format is
    # "WRAPPER: <wrapper-cmd> __wrapper_probe__" — strip the probe tool name.
    local result
    result="$(bash "$CLI_TOOL_DISCOVERY" __wrapper_probe__ 2>/dev/null || true)"
    local prefix=""
    case "$result" in
        WRAPPER:\ *)
            local wrapper_full="${result#WRAPPER: }"
            prefix="${wrapper_full% __wrapper_probe__}"
            # Allow callers to disable devbox at runtime (e.g. probe_devbox)
            if [[ "$prefix" == "devbox run --" && "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
                prefix=""
            fi
            ;;
        *)
            prefix=""
            ;;
    esac

    WRAPPER_PREFIX_CACHE="$prefix"
    WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
    printf '%s' "$prefix"
}

# Run a command through devbox when available, otherwise directly.
# This is the simple wrapper — it does NOT probe. Call probe_devbox first if
# you want hang-safety. wrapper_prefix() honors WRAPPER_DEVBOX_DISABLED.
devbox_run() {
    local wrapper
    wrapper="$(wrapper_prefix)"
    if [[ -n "$wrapper" ]]; then
        $wrapper "$@"
    else
        "$@"
    fi
}

# Run a command through the detected environment wrapper (if any), otherwise directly.
# Alias for devbox_run — kept for backward compatibility with existing callers.
run_command() {
    devbox_run "$@"
}


# Include shared rtk helpers (rtk_available, rtk_prefix, git_cmd, rtk_wrap).
# Must come after wrapper-helpers.sh since it depends on devbox_run/wrapper_prefix.
# rtk-helpers.sh — shared functions for rtk (Rust Token Killer) wrapping
#
# Provides rtk_available(), rtk_prefix(), rtk_wrap_command(), git_cmd(), and rtk_wrap().
# rtk compresses CLI output by 60-90% for LLM context. Coverage is determined
# by `rtk rewrite` — the single source of truth that rtk's own hooks use.
# No hardcoded list of supported commands is maintained here.
#
# Depends on: cli-tool-discovery.sh and wrapper-helpers.sh materialized in the
# same scripts/ directory. Include wrapper-helpers.sh BEFORE this file.
#
# Consumers:
#   - shell-wrapper/scripts/wrap_command.sh.tmpl
#   - git-repository-management/scripts/git-collect.sh.tmpl
#   - git-repository-management/scripts/git-commit-batch.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - git-repository-management/scripts/git-rollback.sh.tmpl
#
# Optional: set RTK_SKIP=1 before including to disable all rtk wrapping
# (used by shell-wrapper's --raw flag and git-collect's probe failure).

# Resolve rtk via cli-tool-discovery.sh (finds it even in non-standard locations).
# Prints "rtk" if available, empty otherwise.
rtk_available() {
    if [[ "${RTK_SKIP:-0}" -eq 1 ]]; then
        printf ''
        return
    fi
    if [[ ! -f "${CLI_TOOL_DISCOVERY:-}" ]]; then
        command -v rtk >/dev/null 2>&1 && printf 'rtk'
        return
    fi
    local result
    result="$(bash "$CLI_TOOL_DISCOVERY" rtk 2>/dev/null || true)"
    case "$result" in
        FOUND:*|WRAPPER:*)
            printf 'rtk'
            ;;
        *)
            printf ''
            ;;
    esac
}

# Check if rtk supports a command by probing `rtk rewrite`.
# Exit codes from rtk rewrite: 0=allow, 1=not supported, 2=deny, 3=ask.
# 0 and 3 both mean "rtk supports this command".
# Prints "rtk" if the command should be wrapped, empty otherwise.
rtk_prefix() {
    if [[ "${RTK_SKIP:-0}" -eq 1 ]]; then
        printf ''
        return
    fi
    if [[ -z "$(rtk_available)" ]]; then
        printf ''
        return
    fi
    # Probe with the full command — rtk rewrite needs the subcommand to
    # determine coverage (e.g. `git` alone is rc=1, but `git status` is rc=3).
    rtk rewrite -- "$@" >/dev/null 2>&1
    local rc=$?
    if [[ $rc -eq 0 || $rc -eq 3 ]]; then
        printf 'rtk'
    fi
}

# Wrap a command with rtk if supported, run through environment wrapper if present.
# Usage: rtk_wrap_command <tool> [args...]
# If rtk supports the command, runs: <env-wrapper> rtk <tool> [args...]
# Otherwise runs:                   <env-wrapper> <tool> [args...]
rtk_wrap_command() {
    local tool="$1"
    shift
    local rtk_prefix_val
    rtk_prefix_val="$(rtk_prefix "$tool" "$@" 2>/dev/null || true)"
    local wrapper
    wrapper="$(wrapper_prefix)"
    if [[ -n "$rtk_prefix_val" ]]; then
        if [[ -n "$wrapper" ]]; then
            $wrapper rtk "$tool" "$@"
        else
            rtk "$tool" "$@"
        fi
    else
        if [[ -n "$wrapper" ]]; then
            $wrapper "$tool" "$@"
        else
            "$tool" "$@"
        fi
    fi
}

# Wrapper: use 'rtk git' instead of 'git' when rtk supports it,
# and run through devbox when available. Uses rtk_prefix() for coverage check.
# This is the canonical git command wrapper — all git-repository-management
# scripts use this instead of redefining their own git_cmd().
git_cmd() {
    local rtk_p
    rtk_p="$(rtk_prefix git "$@" 2>/dev/null || true)"
    if [[ -n "$rtk_p" ]]; then
        devbox_run rtk git "$@"
    else
        devbox_run git "$@"
    fi
}

# Wrapper: use 'rtk <tool>' for supported commands, run through devbox when available.
# Uses rtk_prefix() for coverage check — no longer wraps unconditionally.
# This is the generic tool wrapper — all git-repository-management scripts use
# this instead of redefining their own rtk_wrap().
rtk_wrap() {
    local tool="$1"
    shift
    local rtk_p
    rtk_p="$(rtk_prefix "$tool" "$@" 2>/dev/null || true)"
    if [[ -n "$rtk_p" ]]; then
        devbox_run rtk "$tool" "$@"
    else
        devbox_run "$tool" "$@"
    fi
}


# Set RTK_AVAILABLE for the AVAILABLE_TOOLS output.
# rtk_available() is provided by rtk-helpers.sh above.
if [[ -n "$(rtk_available)" ]]; then
    RTK_AVAILABLE=1
else
    RTK_AVAILABLE=0
fi

# Probe devbox after function definitions so it can test the real command chain.
# This sets WRAPPER_DEVBOX_DISABLED=1 if devbox hangs, which wrapper_prefix()
# and devbox_run() honor for the rest of the script.
probe_devbox || true

# Set DEVBOX_AVAILABLE for the AVAILABLE_TOOLS output based on probe result.
if [[ "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 0 ]] && command -v devbox >/dev/null 2>&1; then
    DEVBOX_AVAILABLE=1
else
    DEVBOX_AVAILABLE=0
fi

# Wrapper: use 'jj log' when jj is available, otherwise 'git log'
# Produces cleaner, more structured log output for AI analysis
jj_log() {
    if [[ "$JJ_AVAILABLE" -eq 1 ]]; then
        devbox_run jj log "$@"
    else
        git_cmd log "$@"
    fi
}

# Wrapper: enhanced full diff using difftastic > delta > raw
# Use for full diffs only (not --name-status or --stat which are structured data)
diff_cmd() {
    if [[ "$DIFFT_AVAILABLE" -eq 1 ]]; then
        git_cmd -c diff.tool=difft -c difftool.difft.cmd='difft "$LOCAL" "$REMOTE"' difftool --no-prompt "$@" 2>/dev/null || git_cmd diff "$@"
    elif [[ "$DELTA_AVAILABLE" -eq 1 ]]; then
        git_cmd diff "$@" | delta 2>/dev/null || git_cmd diff "$@"
    else
        git_cmd diff "$@"
    fi
}

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo ""
    else
        echo "$repo_root"
    fi
}

# Emit a structured NOT_A_GIT_REPO signal so the AI agent can decide whether to
# initialize the directory via scripts/git-repo-init.bash before re-running
# collection. Honors json_mode to match the rest of the script's output format.
# Exit code is 2 (distinguishable from generic errors at exit 1).
emit_not_a_git_repo() {
    local abs_path="$1"
    local init_script="$SCRIPT_DIR/git-repo-init.bash"
    local init_cmd="bash \"$init_script\" \"$abs_path\""
    if [[ "$json_mode" -eq 1 ]]; then
        printf '{"not_a_git_repo":true,"path":"%s","init_command":"%s","init_script":"%s"}\n' \
            "$(printf '%s' "$abs_path" | json_escape)" \
            "$(printf '%s' "$init_cmd" | json_escape)" \
            "$(printf '%s' "$init_script" | json_escape)"
    else
        echo "=== NOT_A_GIT_REPO ==="
        echo "PATH:$abs_path"
        echo "INIT_SCRIPT:$init_script"
        echo "INIT_COMMAND:$init_cmd"
        echo "ADVICE:Run the init command above to create a git repository here, then re-run git-collect.sh. See references/repository-initialization.md for scope choices (full CREATE mode vs init-only)."
        echo "=== END NOT_A_GIT_REPO ==="
    fi
}

main() {
    local target_path="." json_mode=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json) json_mode=1; shift ;;
            --help|-h)
                echo "Usage: git-collect.sh [--json] [repo_root]"
                echo "  --json  Emit a single JSON object instead of the text marker format"
                exit 0
                ;;
            *) target_path="$1"; shift ;;
        esac
    done

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    if [ -z "$repo_root" ]; then
        # Not a git repo: emit the structured signal directly to stdout (not
        # captured by command substitution since we're in main, not a subshell)
        # and exit 2 so the AI agent can distinguish this from generic errors.
        local abs_path
        abs_path=$(cd "$target_path" && pwd 2>/dev/null || echo "$target_path")
        emit_not_a_git_repo "$abs_path"
        exit 2
    fi
    cd "$repo_root"

    # Gather all data into variables so both text and JSON modes can use them.
    local branch upstream
    branch=$(git_cmd rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    upstream=$(git_cmd rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none")

    local recent_log
    recent_log=$(jj_log -n 10 --no-graph 2>/dev/null || echo "<none>")

    local staged unstaged untracked diff_stats
    staged=$(git_cmd diff --cached --name-status 2>/dev/null || echo "<none>")
    unstaged=$(git_cmd diff --name-status 2>/dev/null || echo "<none>")
    untracked=$(git_cmd ls-files --others --exclude-standard 2>/dev/null || echo "<none>")
    diff_stats=$(git_cmd diff --stat 2>/dev/null || echo "<none>")

    # Full diff: staged + unstaged + untracked file contents, bounded by
    # FULL_DIFF_MAX_BYTES (default 200KB) to avoid token explosions on huge
    # changes. A truncation notice is emitted when the bound is hit.
    # Previously this only ran `git diff` (unstaged-only), which was empty
    # when all changes were staged or untracked — leaving the FULL_DIFF
    # marker with no content. Now it covers all three categories.
    local full_diff
    full_diff=$(collect_full_diff)

    # Quality checks (eslint, prettier, tests, just)
    local qc_eslint qc_prettier qc_tests qc_just
    qc_eslint=$(detect_eslint)
    qc_prettier=$(detect_prettier)
    qc_tests=$(detect_tests)
    qc_just=$(detect_just)

    if [[ "$json_mode" -eq 1 ]]; then
        emit_json "$repo_root" "$branch" "$upstream" "$recent_log" \
            "$staged" "$unstaged" "$untracked" "$diff_stats" "$full_diff" \
            "$qc_eslint" "$qc_prettier" "$qc_tests" "$qc_just"
        return
    fi

    echo "=== COLLECTION_START ==="

    echo "REPO_ROOT:$repo_root"
    echo "BRANCH:$branch"
    echo "UPSTREAM:$upstream"

    echo "AVAILABLE_TOOLS:"
    echo "RTK:$RTK_AVAILABLE"
    echo "DEVBOX:$DEVBOX_AVAILABLE"
    echo "JJ:$JJ_AVAILABLE"
    echo "DIFFT:$DIFFT_AVAILABLE"
    echo "DELTA:$DELTA_AVAILABLE"
    echo "HUNK:$HUNK_AVAILABLE"
    echo "GIT_EXTRAS:$GIT_EXTRAS_AVAILABLE"

    echo "RECENT_LOG:"
    printf '%s\n' "$recent_log"

    echo "STAGED:"
    printf '%s\n' "$staged"

    echo "UNSTAGED:"
    printf '%s\n' "$unstaged"

    echo "UNTRACKED:"
    printf '%s\n' "$untracked"

    echo "DIFF_STATS:"
    printf '%s\n' "$diff_stats"

    echo "FULL_DIFF:"
    printf '%s\n' "$full_diff"

    echo "QUALITY_CHECKS:"
    printf '%s\n' "$qc_eslint"
    printf '%s\n' "$qc_prettier"
    printf '%s\n' "$qc_tests"
    if [[ -n "$qc_just" ]]; then
        printf '%s\n' "$qc_just"
    fi

    echo "=== COLLECTION_END ==="
}

# Collect a bounded full diff covering staged, unstaged, and untracked files.
# Emits the combined diff content. When the total exceeds FULL_DIFF_MAX_BYTES
# (default 204800 = 200KB), stops and appends a truncation notice.
collect_full_diff() {
    local max_bytes="${FULL_DIFF_MAX_BYTES:-204800}"
    local out=""
    local section

    # Staged changes
    section=$(git_cmd diff --cached 2>/dev/null || true)
    if [[ -n "$section" ]]; then
        out+="$section"
    fi

    # Unstaged changes
    section=$(git_cmd diff 2>/dev/null || true)
    if [[ -n "$section" ]]; then
        out+="$section"
    fi

    # Untracked files: emit their full contents as pseudo-diff new-file blocks
    local untracked_files
    untracked_files=$(git_cmd ls-files --others --exclude-standard 2>/dev/null || true)
    if [[ -n "$untracked_files" ]] && [[ "$untracked_files" != "<none>" ]]; then
        while IFS= read -r f; do
            [[ -z "$f" ]] && continue
            if [[ -f "$f" ]]; then
                out+=$'\n'"diff --git a/$f b/$f"$'\n'"new file mode 100644"$'\n'"--- /dev/null"$'\n'"+++ b/$f"$'\n'
                # Bound per-file content to avoid one huge file blowing the budget
                local file_content
                file_content=$(head -c "$max_bytes" -- "$f" 2>/dev/null || cat -- "$f" 2>/dev/null || true)
                out+="$file_content"
            fi
        done <<< "$untracked_files"
    fi

    if [[ -z "$out" ]]; then
        echo "<none>"
        return
    fi

    # Bound the total output
    local total=${#out}
    if [[ "$total" -gt "$max_bytes" ]]; then
        printf '%s' "${out:0:$max_bytes}"
        printf '\n[TRUNCATED: full diff exceeded %s bytes, showing first %s bytes]\n' "$max_bytes" "$max_bytes"
    else
        printf '%s' "$out"
    fi
}

detect_eslint() {
    if command -v eslint >/dev/null 2>&1; then
        echo "ESLINT:"
        if run_command rtk_wrap eslint . 2>&1; then
            echo "ESLINT_STATUS:PASS"
        else
            echo "ESLINT_STATUS:FAIL"
        fi
    else
        echo "ESLINT:NOT_AVAILABLE"
    fi
}

detect_prettier() {
    if command -v prettier >/dev/null 2>&1; then
        echo "PRETTIER:"
        if run_command rtk_wrap prettier --check . 2>&1; then
            echo "PRETTIER_STATUS:PASS"
        else
            echo "PRETTIER_STATUS:FAIL"
        fi
    else
        echo "PRETTIER:NOT_AVAILABLE"
    fi
}

detect_tests() {
    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        # Resolve the active package manager via the shared detect-package-manager.sh
        # include (materialized into this skill's scripts/ dir at build time).
        # This respects `packageManager` in package.json and lockfile presence,
        # so pnpm/yarn/bun repos no longer get a false-positive `npm test` failure.
        # Fallback is pnpm (not npm) — if pnpm isn't available, emit NOT_AVAILABLE
        # with the recommendation rather than trying to run a missing command.
        local pkg_manager="pnpm"
        local pkg_available="true"
        local pkg_recommendation=""
        if [[ -x "$SCRIPT_DIR/detect-package-manager.sh" ]]; then
            local pkg_json
            pkg_json="$("$SCRIPT_DIR/detect-package-manager.sh" "$PWD" --json 2>/dev/null || true)"
            if [[ -n "$pkg_json" ]]; then
                pkg_manager="$(printf '%s' "$pkg_json" | grep -oE '"manager":"[^"]*"' | head -1 | sed 's/"manager":"//;s/"//')"
                pkg_available="$(printf '%s' "$pkg_json" | grep -oE '"available":(true|false)' | head -1 | sed 's/"available"://')"
                pkg_recommendation="$(printf '%s' "$pkg_json" | grep -oE '"recommendation":"[^"]*"' | head -1 | sed 's/"recommendation":"//;s/"//')"
            fi
        fi
        echo "NPM_TEST:"
        echo "NPM_TEST_PACKAGE_MANAGER:${pkg_manager}"
        if [[ "$pkg_available" == "false" ]]; then
            echo "NPM_TEST_STATUS:NOT_AVAILABLE"
            echo "NPM_TEST_RECOMMENDATION:${pkg_recommendation}"
        elif run_command rtk_wrap "${pkg_manager}" test 2>&1; then
            echo "NPM_TEST_STATUS:PASS"
        else
            echo "NPM_TEST_STATUS:FAIL"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "CARGO_TEST:"
        if run_command rtk_wrap cargo test 2>&1; then
            echo "CARGO_TEST_STATUS:PASS"
        else
            echo "CARGO_TEST_STATUS:FAIL"
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        echo "PYTHON_TEST:"
        if run_command python -m pytest 2>&1; then
            echo "PYTHON_TEST_STATUS:PASS"
        else
            echo "PYTHON_TEST_STATUS:FAIL"
        fi
    else
        echo "TESTS:NOT_CONFIGURED"
    fi
}

# Detect `just` task runner targets. `just` is a generic task runner (like
# make but simpler). If a Justfile/justfile exists at repo root, probe for
# common targets (validate, test, lint, build, check, format) and emit a
# JUST:<target> line for each found. This is the same pattern the script
# uses for npm/make/cargo — just is generic, not project-specific.
detect_just() {
    command -v just >/dev/null 2>&1 || return 0
    local justfile=""
    for f in Justfile justfile JUSTFILE; do
        if [[ -f "$f" ]]; then
            justfile="$f"
            break
        fi
    done
    [[ -z "$justfile" ]] && return 0

    # Cache `just --list` output once — calling it once per target is slow
    # and can produce inconsistent results when grep -q exits early.
    local just_list
    just_list=$(just --list 2>/dev/null || true)
    [[ -z "$just_list" ]] && return 0

    local targets="validate test lint build check format"
    local found=()
    local t
    for t in $targets; do
        if printf '%s\n' "$just_list" | grep -qE "^[[:space:]]*${t}([[:space:]]|$)"; then
            found+=("$t")
        fi
    done

    if [[ ${#found[@]} -gt 0 ]]; then
        local line
        for t in "${found[@]}"; do
            line+="JUST:${t}"$'\n'
        done
        # Strip trailing newline
        printf '%s' "${line%$'\n'}"
    fi
}

# Escape a string for JSON output. Reads from stdin, writes escaped JSON
# string to stdout (without surrounding quotes).
#
# Uses jq when available for bulletproof escaping — jq handles ALL control
# characters (U+0000–U+001F), Unicode, and edge cases that the bash fallback
# misses. The bash fallback handles backslash, double-quote, newline, tab, and
# carriage return, which covers most git output but can produce invalid JSON
# when diff content contains other control chars (e.g. terminal escape
# sequences from misdetected TTY, binary file markers).
#
# Repos with template-syntax paths (copier/jinja: {{package_name}}, chezmoi:
# {{ .var }}) are safe in both paths — { and } are valid in JSON strings and
# need no escaping.
json_escape() {
    local s
    s=$(cat)
    if command -v jq >/dev/null 2>&1; then
        # jq -Rs reads all input as a single JSON string with full escaping
        # (all control chars U+0000–U+001F, Unicode, backslash, double-quote).
        # Output includes surrounding double-quotes — strip them to get the
        # escaped string content for use in printf '"%s"' ... patterns.
        local quoted
        quoted=$(printf '%s' "$s" | jq -Rs 'rtrimstr("\n")')
        printf '%s' "${quoted:1:${#quoted}-2}"
    else
        s="${s//\\/\\\\}"
        s="${s//\"/\\\"}"
        s="${s//$'\n'/\\n}"
        s="${s//$'\t'/\\t}"
        s="${s//$'\r'/\\r}"
        printf '%s' "$s"
    fi
}

# Emit a single JSON object with a stable schema. Arguments are the gathered
# data values. Arrays are split from newline-delimited strings.
emit_json() {
    local repo_root="$1" branch="$2" upstream="$3" recent_log="$4" \
          staged="$5" unstaged="$6" untracked="$7" diff_stats="$8" \
          full_diff="$9" qc_eslint="${10}" qc_prettier="${11}" \
          qc_tests="${12}" qc_just="${13}"

    # Helper: emit a JSON array from a newline-delimited string.
    # Uses jq for the whole array at once when available (1 process instead
    # of N processes for N lines — critical for performance on large diffs).
    # Falls back to the per-line bash loop with json_escape when jq is absent.
    json_array() {
        local s="$1"
        if [[ -z "$s" || "$s" == "<none>" ]]; then
            printf '[]'
            return
        fi
        if command -v jq >/dev/null 2>&1; then
            printf '%s' "$s" | jq -Rsc 'split("\n") | map(select(length > 0))'
            return
        fi
        local first=1
        printf '['
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            if [[ "$first" -eq 0 ]]; then printf ','; fi
            first=0
            printf '"%s"' "$(printf '%s' "$line" | json_escape)"
        done <<< "$s"
        printf ']'
    }

    # Parse just targets from qc_just (lines like "JUST:validate")
    local just_arr="[]"
    if [[ -n "$qc_just" ]]; then
        local just_first=1 just_items=""
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local t="${line#JUST:}"
            if [[ "$just_first" -eq 0 ]]; then just_items+=","; fi
            just_first=0
            just_items+="\"$(printf '%s' "$t" | json_escape)\""
        done <<< "$qc_just"
        just_arr="[$just_items]"
    fi

    # Parse eslint/prettier/tests status from the multi-line qc strings
    parse_status() {
        local s="$1"
        if [[ "$s" == *"STATUS:PASS"* ]]; then printf 'PASS'
        elif [[ "$s" == *"STATUS:FAIL"* ]]; then printf 'FAIL'
        elif [[ "$s" == *"NOT_AVAILABLE"* ]]; then printf 'NOT_AVAILABLE'
        elif [[ "$s" == *"NOT_CONFIGURED"* ]]; then printf 'NOT_CONFIGURED'
        else printf 'UNKNOWN'; fi
    }

    local eslint_status prettier_status tests_status
    eslint_status=$(parse_status "$qc_eslint")
    prettier_status=$(parse_status "$qc_prettier")
    tests_status=$(parse_status "$qc_tests")

    printf '{'
    printf '"repo_root":"%s"' "$(printf '%s' "$repo_root" | json_escape)"
    printf ',"branch":"%s"' "$(printf '%s' "$branch" | json_escape)"
    printf ',"upstream":"%s"' "$(printf '%s' "$upstream" | json_escape)"
    printf ',"available_tools":{'
    printf '"rtk":%s,"devbox":%s,"jj":%s,"difft":%s,"delta":%s,"hunk":%s,"git_extras":%s' \
        "$RTK_AVAILABLE" "$DEVBOX_AVAILABLE" "$JJ_AVAILABLE" \
        "$DIFFT_AVAILABLE" "$DELTA_AVAILABLE" "$HUNK_AVAILABLE" "$GIT_EXTRAS_AVAILABLE"
    printf '}'
    printf ',"recent_log":%s' "$(json_array "$recent_log")"
    printf ',"staged":%s' "$(json_array "$staged")"
    printf ',"unstaged":%s' "$(json_array "$unstaged")"
    printf ',"untracked":%s' "$(json_array "$untracked")"
    printf ',"diff_stats":"%s"' "$(printf '%s' "$diff_stats" | json_escape)"
    printf ',"full_diff":"%s"' "$(printf '%s' "$full_diff" | json_escape)"
    printf ',"quality_checks":{'
    printf '"eslint":"%s"' "$eslint_status"
    printf ',"prettier":"%s"' "$prettier_status"
    printf ',"tests":"%s"' "$tests_status"
    printf ',"just":%s' "$just_arr"
    printf '}'
    printf '}\n'
}

main "$@"
