#!/usr/bin/env bash
# wrap_command.sh — wrap a bash command with an environment wrapper and rtk
#
# Usage:
#   wrap_command.sh <cmd> [args...]              # resolve mode — print the wrapped command
#   wrap_command.sh -- <cmd> [args...]           # exec mode — resolve and run
#   wrap_command.sh --raw <cmd> [args...]        # resolve mode, skip rtk (user wants raw output)
#   wrap_command.sh --raw -- <cmd> [args...]     # exec mode, skip rtk
#
# Resolve mode prints the wrapped command to stdout and exits 0.
# Exec mode replaces this process with the wrapped command (exit code passes through).
#
# Wrapping layers (each conditional, applied in order):
#   1. Environment wrapper   if cli-tool-discovery.sh detects one (devbox, mise,
#      flox, direnv, nix) — walks up from cwd looking for the wrapper's config
#      file, AND we're not already inside that wrapper's shell
#   2. rtk                    if cli-tool-discovery.sh resolves rtk AND `rtk
#      rewrite` reports the command as supported AND --raw was not passed
#
# rtk coverage is determined by `rtk rewrite` — the single source of truth
# that rtk's own hooks use. It knows which commands are supported, which are
# excluded (vim, top, tmux, etc.), and how to handle chains and pipes. No
# hardcoded list is maintained in this script.
#
# Tool resolution (devbox, rtk) uses cli-tool-discovery.sh — the shared script
# materialized in scripts/. It checks PATH, environment wrappers, 30+ standard
# locations, and package managers (brew, mise, asdf). See
# references/wrapper-detection.md.
#
# Chained commands (&&, ||, |, ;, &) are detected and wrapped as
# `<wrapper> bash -c '<cmd>'` so the operators are interpreted inside the
# wrapper environment. rtk rewrite handles inserting `rtk ` before each
# supported command in the chain (including pipe-aware behavior — only the
# first command in a pipe is rewritten, per rtk's design).
#
# Exit codes:
#   0       resolve mode succeeded (wrapped command on stdout)
#   1       no command supplied
#   127     exec mode: wrapped command not found
#   others  exec mode: passthrough from the wrapped command
#
# See references/wrapper-detection.md for the wrapper detection algorithm.

set -euo pipefail

# ---------------------------------------------------------------------------
# Shell operator detection — chained commands need bash -c wrapping
# ---------------------------------------------------------------------------
# Tokens that indicate shell chaining. Checked as standalone args (the shell
# tokenizes &&, ||, |, ; before passing them to this script).
SHELL_OPERATOR_RE='^(&&|\|\||\||;|&)$'

has_shell_operators() {
    local arg
    for arg in "$@"; do
        if [[ "$arg" =~ $SHELL_OPERATOR_RE ]]; then
            return 0
        fi
    done
    return 1
}

# Reconstruct a command string from args for `bash -c`.
# Shell operators (&&, ||, |, ;, &) are passed through UNQUOTED so bash
# interprets them as operators inside `bash -c`. All other args are %q-quoted
# for safety. This is the key difference from naive %q-everything: operators
# must stay raw for the chain to work.
reconstruct_cmd_string() {
    local out=""
    local arg
    for arg in "$@"; do
        if [[ "$arg" =~ $SHELL_OPERATOR_RE ]]; then
            # Shell operator — pass through raw, no quoting
            out+="$arg "
        else
            # Regular arg — %q-quote it
            # shellcheck disable=SC2001
            out+="$(printf '%q' "$arg") "
        fi
    done
    # Trim trailing space
    printf '%s' "${out% }"
}

# ---------------------------------------------------------------------------
# cli-tool-discovery.sh — the shared resolution backend
# ---------------------------------------------------------------------------
# Materialized in the same scripts/ directory at build time via
# scripts/cli-tool-discovery.sh.tmpl. It detects environment wrappers
# (devbox, mise, flox, direnv, nix), searches 30+ standard PATH locations,
# and checks package managers (brew, mise, asdf).
#
# We use it for two things:
#   1. Wrapper detection — resolve the environment wrapper for cwd
#   2. rtk resolution — find rtk even if it's not on the bare PATH
#
# Per script-materialization best practice, the script is materialized into
# this skill's scripts/ dir (not referenced from an external location), so
# the skill is self-contained after installation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

# wrapper_prefix() and run_command() — shared via include, no duplicate logic.
# See includes/wrapper-helpers.sh.tmpl for the implementation.
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


# rtk_available(), rtk_prefix(), rtk_wrap_command() — shared via include.
# See includes/rtk-helpers.sh.tmpl for the implementation.
# RTK_SKIP is set by the --raw arg parser (below) to disable rtk wrapping.
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


# ---------------------------------------------------------------------------
# arg parsing — separate flags from the command
# ---------------------------------------------------------------------------
WRAP_RAW=0
WRAP_EXEC=0
CMD_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --raw)
            WRAP_RAW=1
            RTK_SKIP=1
            shift
            ;;
        --)
            WRAP_EXEC=1
            shift
            # Everything after -- is the command
            CMD_ARGS=("$@")
            break
            ;;
        --help|-h)
            sed -n '2,20p' "$0"
            exit 0
            ;;
        *)
            # First non-flag token starts the command (resolve mode)
            CMD_ARGS=("$@")
            break
            ;;
    esac
done

if [[ ${#CMD_ARGS[@]} -eq 0 ]]; then
    echo "Usage: wrap_command.sh [--raw] <cmd> [args...]    (resolve mode)" >&2
    echo "       wrap_command.sh [--raw] -- <cmd> [args...] (exec mode)" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# compose the wrapped command
# ---------------------------------------------------------------------------
# Two paths: simple (single command) or chained (shell operators present).
# Chained commands are wrapped as `bash -c '<string>'` so operators are
# interpreted inside the devbox environment, and rtk rewrite handles inserting
# `rtk ` before each supported command in the chain.

if has_shell_operators "${CMD_ARGS[@]}"; then
    # --- chained command path ---
    CMD_STRING="$(reconstruct_cmd_string "${CMD_ARGS[@]}")"

    # Apply rtk rewrite to the command string (unless --raw).
    # rtk rewrite handles chains (&&, ||, ;) and pipes (|) natively — it
    # inserts `rtk ` before each supported command, respects exclusions, and
    # only rewrites the first command in a pipe (per rtk's design).
    if [[ "${WRAP_RAW:-0}" -ne 1 ]] && [[ -n "$(rtk_available)" ]]; then
        rewritten="$(rtk rewrite -- "${CMD_ARGS[@]}" 2>/dev/null)" || true
        rewrite_rc=$?
        if [[ $rewrite_rc -eq 0 || $rewrite_rc -eq 3 ]]; then
            CMD_STRING="$rewritten"
        fi
    fi

    WRAP="$(wrapper_prefix)"
    if [[ -n "$WRAP" ]]; then
        # <wrapper> bash -c '<rewritten string>'
        WRAPPED=($WRAP bash -c "$CMD_STRING")
    else
        # bash -c '<rewritten string>'
        WRAPPED=(bash -c "$CMD_STRING")
    fi
else
    # --- simple command path (no shell operators) ---
    PREFIX=""
    WRAP="$(wrapper_prefix)"
    if [[ -n "$WRAP" ]]; then
        PREFIX="$WRAP"
    fi

    RTK="$(rtk_prefix "${CMD_ARGS[@]}")"
    if [[ -n "$RTK" ]]; then
        if [[ -n "$PREFIX" ]]; then
            PREFIX="$PREFIX $RTK"
        else
            PREFIX="$RTK"
        fi
    fi

    if [[ -n "$PREFIX" ]]; then
        WRAPPED=($PREFIX "${CMD_ARGS[@]}")
    else
        WRAPPED=("${CMD_ARGS[@]}")
    fi
fi

# ---------------------------------------------------------------------------
# output
# ---------------------------------------------------------------------------
if [[ "$WRAP_EXEC" -eq 1 ]]; then
    # exec mode — replace this process
    exec "${WRAPPED[@]}"
else
    # resolve mode — print the wrapped command as a shell-safe string
    # shellcheck disable=SC2001
    printf '%s\n' "$(printf '%q ' "${WRAPPED[@]}" | sed 's/ $//')"
    exit 0
fi
