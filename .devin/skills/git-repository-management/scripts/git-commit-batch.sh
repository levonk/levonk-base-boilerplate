#!/usr/bin/env bash

# git-commit-batch.sh - Execute batch of commits with AI-provided decisions
# Purpose: Single handoff to execute multiple commits with their messages and file groups
# Usage: git-commit-batch.sh [--amend] [--dry-run] [--slug <slug>] [repo_root]
# Input: STDIN with commit specifications in EITHER of two equivalent formats:
#
#   Format A — multi-line (natural, recommended for heredocs and files):
#     COMMIT:Subject line
#
#     Body paragraph explaining the why.
#     - bullet 1
#     - bullet 2
#     FILES:src/path/to/file1
#     FILES:src/path/to/file2
#     COMMIT:Next subject
#     ...
#
#   Format B — \n literals (compact, for printf one-liners):
#     COMMIT:Subject line\n\nBody paragraph\n- bullet 1\nFILES:src/path/to/file1
#
# Both formats produce the same commit message. Format A captures every
# non-COMMIT:/non-FILES: line after a COMMIT: line (including blank lines)
# as part of the message, then expand_message() converts any \n literals
# to real newlines (a no-op for Format A). Format B puts the entire
# message on the COMMIT: line with \n literals that expand_message()
# converts.
#
# One file per FILES: line — paths containing spaces are preserved
# because the entire line after "FILES:" is treated as a single path.
# With --amend: exactly one COMMIT block; stages files and amends HEAD
# instead of creating a new commit. Pre/post auto-tags still fire.
# With --dry-run: parse and validate the batch WITHOUT committing or
# creating tags. Prints PROCESSING_COMMIT/MESSAGE/FILES/WOULD_STAGE per
# commit. Exits 0 if all blocks validate, non-zero on any validation error.
# Output: Execution results for each commit

set -euo pipefail

# Tool detection and wrapper helpers are shared via includes.
# These provide: probe_devbox(), wrapper_prefix(), devbox_run(), run_command(),
# rtk_available(), rtk_prefix(), git_cmd(), rtk_wrap().
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

# Optional tool availability flags (for AVAILABLE_TOOLS output if needed).
# These are simple presence checks; the wrapper helpers handle the actual
# wrapping logic via cli-tool-discovery.sh.
if command -v jj >/dev/null 2>&1; then JJ_AVAILABLE=1; else JJ_AVAILABLE=0; fi
if command -v difft >/dev/null 2>&1; then DIFFT_AVAILABLE=1; else DIFFT_AVAILABLE=0; fi
if command -v delta >/dev/null 2>&1; then DELTA_AVAILABLE=1; else DELTA_AVAILABLE=0; fi
if command -v hunk >/dev/null 2>&1; then HUNK_AVAILABLE=1; else HUNK_AVAILABLE=0; fi
if command -v git-summary >/dev/null 2>&1; then GIT_EXTRAS_AVAILABLE=1; else GIT_EXTRAS_AVAILABLE=0; fi

# Set RTK_AVAILABLE for the AVAILABLE_TOOLS output. The actual rtk wrapping
# is handled by rtk-helpers.sh's git_cmd() / rtk_wrap() below.
if command -v rtk >/dev/null 2>&1; then RTK_AVAILABLE=1; else RTK_AVAILABLE=0; fi

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


# Probe devbox after function definitions so it can test the real command chain.
# This sets WRAPPER_DEVBOX_DISABLED=1 if devbox hangs, which wrapper_prefix()
# and devbox_run() honor for the rest of the script.
probe_devbox || true

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "ERROR: $target_path is not inside a git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

# Expand \n literals in commit message to real newlines
expand_message() {
    local msg="$1"
    printf '%s' "${msg//\\n/$'\n'}"
}

# Commit with a multi-line message via -F instead of -m.
# devbox run serializes argv in a way that re-escapes newlines in -m args,
# turning real newlines into literal "\n" in the resulting commit message.
# Writing the message to a temp file and using -F sidesteps argv entirely.
# ponytail: ceiling — temp file per commit; fine for batch sizes of dozens.
# When AMEND=1, amends HEAD instead of creating a new commit.
_COMMIT_MSG_FILE=""
commit_with_message() {
    local msg="$1"
    if [[ -z "$_COMMIT_MSG_FILE" ]]; then
        _COMMIT_MSG_FILE=$(mktemp -t git-commit-batch.XXXXXX)
        trap 'rm -f "$_COMMIT_MSG_FILE"' EXIT
    fi
    printf '%s' "$msg" > "$_COMMIT_MSG_FILE"
    if [[ "${AMEND:-0}" -eq 1 ]]; then
        git_cmd commit --amend -F "$_COMMIT_MSG_FILE"
    else
        git_cmd commit -F "$_COMMIT_MSG_FILE"
    fi
}

# A path is stageable if it exists on disk OR is tracked by git.
# Covers deleted-but-tracked files (git rm'd or removed from worktree)
# which no longer exist on disk but `git add` still stages the deletion.
stageable() {
    local p="$1"
    if [[ -f "$p" ]] || [[ -d "$p" ]]; then
        return 0
    fi
    git_cmd ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || return 1
}

# Validate that a commit message has a body (text after a blank line).
# Returns 0 if valid, 1 if missing body.
# A valid message looks like:
#   Subject line\n\n- Body bullet 1\n- Body bullet 2
# An invalid message is just:
#   Subject line
validate_commit_message() {
    local msg="$1"
    # A body exists if there's a blank line followed by non-empty content
    if [[ "$msg" == *$'\n\n'* ]]; then
        # Has a blank line — check that there's actual body text after it
        local body="${msg#*$'\n\n'}"
        # Remove trailing whitespace and check if body is non-empty
        body="${body%"${body##*[![:space:]]}"}"
        if [[ -n "$body" ]]; then
            return 0
        fi
    fi
    return 1
}

# Check whether commit tagging is disabled by project config.
# Returns 0 (true) if tagging is ENABLED (the default), 1 (false) if disabled.
# The config file path is fixed by the commit-tagging-standard include:
#   .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml
# We do a lightweight grep check (no yq dependency) — the config schema for
# this section is just [commit-tagging] with enabled = true|false.
commit_tagging_enabled() {
    local target_root="${REPO_ROOT:-}"
    [[ -z "$target_root" ]] && target_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
    [[ -z "$target_root" ]] && return 0  # can't resolve repo root — assume enabled
    local cfg="$target_root/.agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml"
    [[ -f "$cfg" ]] || return 0
    # Look for [commit-tagging] table followed by enabled = false
    local section
    section="$(awk '/^\[commit-tagging\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
    if printf '%s' "$section" | grep -Eq 'enabled[[:space:]]*=[[:space:]]*false'; then
        return 1
    fi
    return 0
}

# Validate that a commit message includes a #tag array as the last line of
# the body (before any optional footer). Returns 0 if present, 1 if missing.
# A valid tag line is one or more space-separated #kebab-case tokens, e.g.:
#   #project-auth #module-jwt #type-feat #skill-grm-created
# Footers (Closes #N, Fixes #N, Signed-off-by:, etc.) are skipped when
# locating the tag line — the tag line is the last non-empty, non-footer line.
validate_commit_tag_array() {
    local msg="$1"
    # Body is text after the first blank line
    [[ "$msg" == *$'\n\n'* ]] || return 1
    local body="${msg#*$'\n\n'}"
    # Read body lines into an array
    local -a lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done <<< "$body"
    # Scan from the last line upward to find the last non-empty, non-footer line
    local candidate=""
    local i
    for ((i=${#lines[@]}-1; i>=0; i--)); do
        local line="${lines[$i]}"
        # Trim leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        # Recognized footers — skip past them to find the tag line above.
        # Two footer styles: "Fixes #N" / "Closes #N" (no colon) and
        # "Signed-off-by: ..." / "Co-authored-by: ..." (with colon).
        if [[ "$line" =~ ^(Closes|Fixes|Resolves|Refs)[[:space:]]+#[0-9]+ ]] \
            || [[ "$line" =~ ^(Signed-off-by|Co-authored-by|Reviewed-by|Tested-by): ]]; then
            continue
        fi
        candidate="$line"
        break
    done
    [[ -z "$candidate" ]] && return 1
    # A valid tag line: one or more #kebab-case tokens, space-separated, nothing else
    [[ "$candidate" =~ ^#[a-z0-9]+(-[a-z0-9]+)*([[:space:]]+#[a-z0-9]+(-[a-z0-9]+)*)*$ ]]
}

# Heuristic body-quality check: warn (NOT fail) when the body looks like a
# file listing rather than prose. A body where >50% of non-empty lines look
# like file paths (a path-like token with no verbs) is almost certainly
# restating the diff instead of explaining the why.
#
# Emits "WARNING:BODY_LOOKS_LIKE_FILE_LISTING" to stdout and returns 0
# always — this is advisory, not a hard failure, to preserve back-compat.
#
# Heuristic for "path-like line":
#   - matches ^[a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+$ (a filename with extension), OR
#   - contains "/" and has no spaces (a path with no prose), OR
#   - is a single token with no whitespace and at least one of . or /
validate_commit_message_quality() {
    local msg="$1"
    # Extract body (text after the first blank line)
    [[ "$msg" == *$'\n\n'* ]] || return 0
    local body="${msg#*$'\n\n'}"

    local total=0 pathlike=0
    while IFS= read -r line; do
        # Trim leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue
        total=$((total + 1))
        # Strip leading bullet markers (-, *, •) for the heuristic
        local stripped="${line#-}"
        stripped="${stripped#*}"
        stripped="${stripped#•}"
        stripped="${stripped#"${stripped%%[![:space:]]*}"}"
        # Path-like if: filename-with-extension, or contains "/" with no spaces,
        # or single token with "." and no spaces
        if [[ "$stripped" =~ ^[a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+$ ]] \
            || { [[ "$stripped" == */* ]] && [[ "$stripped" != *' '* ]]; } \
            || { [[ "$stripped" != *' '* ]] && [[ "$stripped" == *.* || "$stripped" == */* ]]; }; then
            pathlike=$((pathlike + 1))
        fi
    done <<< "$body"

    if [[ "$total" -gt 0 ]] && [[ $((pathlike * 2)) -gt $total ]]; then
        echo "WARNING:BODY_LOOKS_LIKE_FILE_LISTING"
        echo "  Body appears to be a file listing rather than prose. Consider" >&2
        echo "  explaining the why (rationale, decisions, context) instead of" >&2
        echo "  restating which files changed — the diff already shows that." >&2
    fi
    return 0
}

# Validate commit subject against banned vague/generic patterns.
# Returns 0 if the subject passes, 1 if it matches a banned pattern.
# Emits COMMIT_FAILED:BAD_SUBJECT + the matched pattern + a suggestion to stderr.
#
# Banned patterns (derived from commit-organization.md lines 167-172):
#   1. Generic counters: "Update N files", "Update N file(s)"
#   2. Version bump as feat: "feat ... bump ... vX.Y.Z" (should be chore)
#   3. Vague improvement phrases: "various improvements", "misc improvements",
#      "PR feedback improvements", "general improvements", "some improvements",
#      "minor improvements", "code improvements"
#   4. Vague change phrases: "various changes", "misc changes", "some changes",
#      "minor changes", "various fixes", "misc fixes"
#   5. Filler words: "oops", "maybe fixed", "stuff", "things", "misc"
#   6. Bare "Update X" with no specifics (X is a single generic word like
#      "code", "files", "stuff", "things")
#
# The check is case-insensitive. Patterns match anywhere in the subject.
validate_commit_subject() {
    local msg="$1"
    local subject="${msg%%$'\n'*}"  # first line only
    local subject_lower="${subject,,}"  # lowercase for case-insensitive matching
    local matched=""
    local suggestion=""

    # 1. Generic counters: "Update N files" / "Update N file"
    if [[ "$subject_lower" =~ update\ +[0-9]+\ +files? ]]; then
        matched="generic counter: 'Update N files'"
        suggestion="Describe what changed, not how many files: 'Fix overflow in sidebar menu' not 'Update 4 files'"
    fi

    # 2. Version bump as feat: "feat ... bump ... v1.2.3" or "feat ... bump ... version"
    if [[ -z "$matched" ]] && [[ "$subject_lower" =~ ^feat.*bump.*v?[0-9]+\.[0-9]+ ]]; then
        matched="version bump as feat: 'feat: bump to vX.Y.Z'"
        suggestion="Version bumps are chore, not feat. If the commit has real functional changes, describe them: 'feat(nixify): harden hash automation with ASSET_MAP reverse-check'"
    fi
    if [[ -z "$matched" ]] && [[ "$subject_lower" =~ ^feat.*bump.*version ]]; then
        matched="version bump as feat: 'feat: bump version'"
        suggestion="Version bumps are chore, not feat. If the commit has real functional changes, describe them: 'feat(nixify): harden hash automation with ASSET_MAP reverse-check'"
    fi

    # 3. Vague improvement phrases
    if [[ -z "$matched" ]]; then
        local vague_improvements="various improvements|misc improvements|miscellaneous improvements|pr feedback improvements|general improvements|some improvements|minor improvements|code improvements|various enhancements|misc enhancements"
        if [[ "$subject_lower" =~ ($vague_improvements) ]]; then
            matched="vague improvement phrase: '${BASH_REMATCH[1]}'"
            suggestion="Name the specific improvement: 'Add ASSET_MAP reverse-check guard to hash automation' not 'PR feedback improvements'"
        fi
    fi

    # 4. Vague change/fix phrases
    if [[ -z "$matched" ]]; then
        local vague_changes="various changes|misc changes|miscellaneous changes|some changes|minor changes|various fixes|misc fixes|miscellaneous fixes"
        if [[ "$subject_lower" =~ ($vague_changes) ]]; then
            matched="vague change phrase: '${BASH_REMATCH[1]}'"
            suggestion="Name the specific change: 'Fix hash mismatch on darwin x86_64' not 'various fixes'"
        fi
    fi

    # 5. Filler words (as whole words, not substrings — "things" in "thingsboard" is fine)
    if [[ -z "$matched" ]]; then
        # Use word-boundary matching via [[ =~ ]] with [[:space:]] or start/end
        if [[ "$subject_lower" =~ (^|[[:space:]])oops($|[[:space:]]|[,.!?]) ]] \
            || [[ "$subject_lower" =~ (^|[[:space:]])maybe\ fixed($|[[:space:]]|[,.!?]) ]] \
            || [[ "$subject_lower" =~ (^|[[:space:]])stuff($|[[:space:]]|[,.!?]) ]] \
            || [[ "$subject_lower" =~ (^|[[:space:]])things($|[[:space:]]|[,.!?]) ]] \
            || [[ "$subject_lower" =~ (^|[[:space:]])misc($|[[:space:]]|[,.!?]) ]]; then
            matched="filler word in subject"
            suggestion="Use specific language: 'Fix overflow in sidebar menu' not 'oops fix stuff'"
        fi
    fi

    # 6. Bare "Update X" where X is a single generic word
    if [[ -z "$matched" ]]; then
        if [[ "$subject_lower" =~ ^update\ +(code|files|stuff|things|misc|repo|repository|project|config|configs|scripts|docs|documentation)$ ]]; then
            matched="bare 'Update X' with generic X: '${BASH_REMATCH[1]}'"
            suggestion="Describe what specifically changed: 'Update README install instructions for Nix flakes' not 'Update docs'"
        fi
    fi

    if [[ -n "$matched" ]]; then
        echo "COMMIT_FAILED:BAD_SUBJECT" >&2
        echo "ERROR: Commit subject matches banned pattern: $matched" >&2
        echo "ERROR: Subject: $subject" >&2
        echo "ERROR: $suggestion" >&2
        echo "ERROR: See commit-organization.md → Message Format → Quality Standards" >&2
        return 1
    fi
    return 0
}

main() {
    local slug="" target_path="." amend=0 dry_run=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --slug) slug="$2"; shift 2 ;;
            --slug=*) slug="${1#--slug=}"; shift ;;
            --amend) amend=1; shift ;;
            --dry-run) dry_run=1; shift ;;
            *) target_path="$1"; shift ;;
        esac
    done
    export AMEND="$amend"
    export DRY_RUN="$dry_run"

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"
    export REPO_ROOT="$repo_root"

    # Derive slug from branch name if not provided (strip path prefix: chore/foo-bar → foo-bar)
    # On an unborn branch (no commits yet), `git rev-parse --abbrev-ref HEAD`
    # fails because HEAD doesn't resolve. Fall back to `git symbolic-ref --short
    # HEAD`, which works on unborn branches and returns the configured branch
    # name (e.g. "main" or "master"). Final fallback is the literal "run".
    if [[ -z "$slug" ]]; then
        slug=$(git_cmd symbolic-ref --short HEAD 2>/dev/null \
               || git_cmd rev-parse --abbrev-ref HEAD 2>/dev/null \
               || echo "run")
        slug="${slug##*/}"
    fi

    # In dry-run mode, do NOT create pre/post tags or modify repo state.
    # Parse the batch, validate messages, and print what WOULD happen.
    if [[ "$dry_run" -eq 1 ]]; then
        echo "=== BATCH_COMMIT_DRY_RUN_START ==="
        local current_message=""
        local current_files=()
        local commit_count=0
        local validation_failed=0

        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^COMMIT:(.*)$ ]]; then
                # Capture the commit message immediately — inner [[ ]] tests
                # below reset BASH_REMATCH, so we must grab it before any
                # subsequent conditional.
                local new_message="${BASH_REMATCH[1]}"
                if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
                    current_message="$(expand_message "$current_message")"
                    if ! validate_commit_message "$current_message"; then
                        echo "COMMIT_FAILED:NO_BODY"
                        echo "ERROR: Commit message must include a body after a blank line." >&2
                        echo "ERROR: Got: $current_message" >&2
                        validation_failed=1
                    elif ! validate_commit_subject "$current_message"; then
                        validation_failed=1
                    elif commit_tagging_enabled && ! validate_commit_tag_array "$current_message"; then
                        echo "COMMIT_FAILED:NO_TAG_ARRAY"
                        echo "ERROR: Commit message must include a #tag array as the last line of the body." >&2
                        echo "ERROR: Format: blank line, then #project-<slug> #module-<slug> #type-<type> #skill-grm-created" >&2
                        echo "ERROR: Example: #project-auth #module-jwt #type-feat #skill-grm-created" >&2
                        echo "ERROR: Disable for this repo via .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml" >&2
                        echo "ERROR: Got: $current_message" >&2
                        validation_failed=1
                    else
                        echo "PROCESSING_COMMIT:$((commit_count + 1))"
                        echo "MESSAGE:$current_message"
                        echo "FILES:${current_files[*]}"
                        validate_commit_message_quality "$current_message" || true
                        # Show what `git add` WOULD stage for each file
                        for file in "${current_files[@]}"; do
                            if stageable "$file"; then
                                local would_stage
                                would_stage=$(git_cmd add --dry-run -- "$file" 2>/dev/null || echo "WOULD_STAGE:$file (untracked or new)")
                                echo "WOULD_STAGE:$file"
                            else
                                echo "ERROR: Path not found and not tracked by git: $file" >&2
                                echo "COMMIT_FAILED:FILE_NOT_FOUND"
                                validation_failed=1
                            fi
                        done
                        commit_count=$((commit_count + 1))
                    fi
                    current_message=""
                    current_files=()
                elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
                    echo "COMMIT_FAILED:NO_FILES"
                    echo "ERROR: Commit block ended with no FILES: lines." >&2
                    validation_failed=1
                    current_message=""
                fi
                current_message="$new_message"
                if [[ "$amend" -eq 1 ]] && [[ "$commit_count" -gt 0 ]]; then
                    echo "COMMIT_FAILED:AMEND_MULTIPLE_COMMITS"
                    validation_failed=1
                fi
            elif [[ "$line" =~ ^FILES:(.*)$ ]]; then
                current_files+=("${BASH_REMATCH[1]}")
            elif [[ -n "$current_message" ]]; then
                # Inside a COMMIT block: append continuation line (including
                # blank lines and lines that look like comments) to the message.
                # This supports the natural multi-line format where the subject
                # and body span separate physical lines. The blank line between
                # subject and body is preserved so validate_commit_message()
                # can find the \n\n separator.
                current_message="$current_message"$'\n'"$line"
            fi
        done

        # Final commit
        if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
            current_message="$(expand_message "$current_message")"
            if ! validate_commit_message "$current_message"; then
                echo "COMMIT_FAILED:NO_BODY"
                echo "ERROR: Commit message must include a body after a blank line." >&2
                echo "ERROR: Got: $current_message" >&2
                validation_failed=1
            elif ! validate_commit_subject "$current_message"; then
                validation_failed=1
            elif commit_tagging_enabled && ! validate_commit_tag_array "$current_message"; then
                echo "COMMIT_FAILED:NO_TAG_ARRAY"
                echo "ERROR: Commit message must include a #tag array as the last line of the body." >&2
                echo "ERROR: Format: blank line, then #project-<slug> #module-<slug> #type-<type> #skill-grm-created" >&2
                echo "ERROR: Example: #project-auth #module-jwt #type-feat #skill-grm-created" >&2
                echo "ERROR: Disable for this repo via .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml" >&2
                echo "ERROR: Got: $current_message" >&2
                validation_failed=1
            else
                echo "PROCESSING_COMMIT:$((commit_count + 1))"
                echo "MESSAGE:$current_message"
                echo "FILES:${current_files[*]}"
                validate_commit_message_quality "$current_message" || true
                for file in "${current_files[@]}"; do
                    if stageable "$file"; then
                        echo "WOULD_STAGE:$file"
                    else
                        echo "ERROR: Path not found and not tracked by git: $file" >&2
                        echo "COMMIT_FAILED:FILE_NOT_FOUND"
                        validation_failed=1
                    fi
                done
                commit_count=$((commit_count + 1))
            fi
        elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
            echo "COMMIT_FAILED:NO_FILES"
            echo "ERROR: Final commit block ended with no FILES: lines." >&2
            validation_failed=1
        fi

        echo "BATCH_COMMIT_DRY_RUN_COMPLETE:$commit_count"
        echo "=== BATCH_COMMIT_DRY_RUN_END ==="
        if [[ "$validation_failed" -ne 0 ]]; then
            exit 1
        fi
        exit 0
    fi

    # Detect unborn HEAD (root-commit / initial-commit case).
    # `git rev-parse --verify HEAD` fails when HEAD points to nothing — i.e.
    # the repo was just `git init`'d and no commit exists yet. In that state:
    #   - `git tag -a <tag> <sha>` cannot work (no commit-ish to tag)
    #   - `git reset --mixed HEAD` cannot work (no HEAD to reset to)
    # We skip the pre-tag (emitting a SKIPPED marker so callers can detect it)
    # and clear the index with `git read-tree --empty` instead of `git reset`.
    # The post-tag still fires — by the time we reach it, the first commit
    # has created HEAD.
    local head_unborn=0
    if ! git_cmd rev-parse --verify HEAD >/dev/null 2>&1; then
        head_unborn=1
    fi

    # Capture pre-run SHA and create pre-tag before any commits
    local tag_prefix
    tag_prefix="tags/auto/grm/$(date -u +%Y/%m)/$(date -u +%Y%m%d%H%M%S)"
    if [[ "$head_unborn" -eq 0 ]]; then
        local pre_sha
        pre_sha=$(git_cmd rev-parse HEAD)
        local pre_tag="${tag_prefix}-${slug}-pre"
        git_cmd tag -a "$pre_tag" "$pre_sha" -m "Pre-run checkpoint: ${slug}"
        echo "AUTO_TAG_PRE:$pre_tag"
    else
        echo "AUTO_TAG_PRE:SKIPPED_UNBORN_HEAD"
    fi

    # Unstage anything currently staged so each commit contains EXACTLY the
    # FILES: listed in its COMMIT block — no more, no less. Without this, a
    # pre-existing index (e.g. from a prior `git mv`, `git add`, or a partial
    # `git add -p`) would be absorbed into commit 1, producing a horizontal-
    # grouping anti-pattern where unrelated staged changes leak into the first
    # commit. The pre-tag above already captured the pre-run SHA (when HEAD
    # exists), so rollback is unaffected. `--mixed` (the default) resets the
    # index but leaves the worktree untouched, so uncommitted file content is
    # preserved. On an unborn HEAD, `git reset --mixed HEAD` fails (no HEAD),
    # so we clear the index with `git read-tree --empty` — same effect (empty
    # index, worktree untouched).
    if [[ "$head_unborn" -eq 0 ]]; then
        git_cmd reset --mixed HEAD >/dev/null
    else
        git_cmd read-tree --empty
    fi
    echo "INDEX_RESET:mixed"

    if [[ "$amend" -eq 1 ]]; then
        echo "AMEND_MODE:enabled"
    fi

    echo "=== BATCH_COMMIT_START ==="

    local current_message=""
    local current_files=()
    local commit_count=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^COMMIT:(.*)$ ]]; then
            # Capture the commit message immediately — validate_commit_message_quality
            # below uses =~ which resets BASH_REMATCH, so grab it before any
            # subsequent regex match.
            local new_message="${BASH_REMATCH[1]}"
            # Process previous commit if exists
            if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
                # Expand \n literals to real newlines (no-op for multi-line format)
                current_message="$(expand_message "$current_message")"

                # Validate: every commit must have a body explaining the why
                if ! validate_commit_message "$current_message"; then
                    echo "COMMIT_FAILED:NO_BODY"
                    echo "ERROR: Commit message must include a body after a blank line." >&2
                    echo "ERROR: Format: \"Subject line\\n\\n- Body bullet 1\\n- Body bullet 2\"" >&2
                    echo "ERROR: Or use multi-line format: COMMIT:Subject\\n\\nBody\\nFILES:..." >&2
                    echo "ERROR: Got: $current_message" >&2
                    exit 1
                fi

                # Validate: subject must not match banned vague/generic patterns
                if ! validate_commit_subject "$current_message"; then
                    exit 1
                fi

                # Validate: every commit must include a #tag array (mandatory,
                # enforced — see commit-tagging-standard include). Bypass only
                # via explicit project config with [commit-tagging] enabled = false.
                if commit_tagging_enabled && ! validate_commit_tag_array "$current_message"; then
                    echo "COMMIT_FAILED:NO_TAG_ARRAY"
                    echo "ERROR: Commit message must include a #tag array as the last line of the body." >&2
                    echo "ERROR: Format: blank line, then #project-<slug> #module-<slug> #type-<type> #skill-grm-created" >&2
                    echo "ERROR: Example: #project-auth #module-jwt #type-feat #skill-grm-created" >&2
                    echo "ERROR: Disable for this repo via .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml" >&2
                    echo "ERROR: Got: $current_message" >&2
                    exit 1
                fi

                echo "PROCESSING_COMMIT:$((commit_count + 1))"
                echo "MESSAGE:$current_message"
                echo "FILES:${current_files[*]}"
                # Advisory body-quality check (warns, does not fail)
                validate_commit_message_quality "$current_message" || true

                # Stage files
                for file in "${current_files[@]}"; do
                    if stageable "$file"; then
                        git_cmd add -- "$file"
                        echo "STAGED:$file"
                    else
                        echo "ERROR: Path not found and not tracked by git: $file" >&2
                        echo "COMMIT_FAILED:FILE_NOT_FOUND"
                        exit 1
                    fi
                done

                # Scan staged files for identity leaks before committing.
                # scan-artifacts.sh resolves the current machine's identity
                # values ($HOME, whoami, hostname, WiFi SSID, DNS domain) and
                # scans the staged diff for those specific strings. HARD leaks
                # (resolved paths, usernames, WiFi SSID) block the commit;
                # REVIEW items (hostname, DNS domain) require AI judgment.
                # Pass --private via SCAN_ARTIFACTS_PRIVATE=1 for private repos
                # where HARD leaks are informational only (exit 0).
                local scan_script="${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/scan-artifacts.sh"
                if [[ -x "$scan_script" ]]; then
                    local scan_args=()
                    [[ "${SCAN_ARTIFACTS_PRIVATE:-0}" == "1" ]] && scan_args+=(--private)
                    if ! "$scan_script" "${scan_args[@]}"; then
                        echo "SCAN_ARTIFACTS_FAILED:identity leaks detected in staged files" >&2
                        echo "ERROR: scan-artifacts.sh found identity leaks. Fix HARD leaks before committing." >&2
                        echo "ERROR: Set SCAN_ARTIFACTS_PRIVATE=1 for private repos where HARD leaks are acceptable." >&2
                        echo "COMMIT_FAILED:SCAN_ARTIFACTS"
                        exit 1
                    fi
                fi

                # Scan staged files for secret patterns using git-secrets.
                # scan-secrets.sh uses cli-tool-discovery.sh to find git-secrets
                # (awslabs/git-secrets) through environment wrappers and PATH
                # locations. If git-secrets is not installed, the scan is
                # skipped (exit 0) — secret scanning is opt-in, not a hard
                # dependency. If git-secrets finds prohibited patterns, the
                # commit is blocked.
                # Pass --private via SCAN_SECRETS_PRIVATE=1 for private repos
                # where findings are informational only (exit 0).
                local secrets_script="${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}/scan-secrets.sh"
                if [[ -x "$secrets_script" ]]; then
                    local secrets_args=()
                    [[ "${SCAN_SECRETS_PRIVATE:-0}" == "1" ]] && secrets_args+=(--private)
                    if ! "$secrets_script" "${secrets_args[@]}"; then
                        echo "SCAN_SECRETS_FAILED:prohibited patterns detected in staged files" >&2
                        echo "ERROR: scan-secrets.sh found secret patterns. Remove secrets before committing." >&2
                        echo "ERROR: If findings are false positives, add allowed patterns: git secrets --add -a '<pattern>'" >&2
                        echo "ERROR: Set SCAN_SECRETS_PRIVATE=1 for private repos where findings are informational." >&2
                        echo "COMMIT_FAILED:SCAN_SECRETS"
                        exit 1
                    fi
                fi

                # Commit
                if commit_with_message "$current_message"; then
                    local commit_hash
                    commit_hash=$(git_cmd rev-parse HEAD)
                    echo "COMMIT_SUCCESS:$commit_hash"
                    commit_count=$((commit_count + 1))
                else
                    echo "COMMIT_FAILED:GIT_ERROR"
                    exit 1
                fi

                # Reset for next commit
                current_message=""
                current_files=()
            elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
                # Guard: a COMMIT: block ended with no FILES: lines. This is
                # almost always a parsing error — typically the caller's
                # FILES: lines got absorbed into the COMMIT: message (e.g. a
                # printf that joined lines with literal \n instead of real
                # newlines, so "COMMIT:subj\n\n- body\nFILES:foo" was read as
                # one physical line). Without this guard the block is silently
                # dropped and the caller believes a commit landed that didn't,
                # producing a split history (some files committed, some left
                # dirty) with no error signal. Fail loudly instead.
                echo "COMMIT_FAILED:NO_FILES"
                echo "ERROR: Commit block ended with no FILES: lines." >&2
                echo "ERROR: This usually means FILES: lines were joined onto the COMMIT: line" >&2
                echo "ERROR: (e.g. printf with literal \\n instead of real newlines)." >&2
                echo "ERROR: Each FILES:<path> must be on its own physical line." >&2
                echo "ERROR: Offending message: $current_message" >&2
                exit 1
            fi

            # Set new message
            current_message="$new_message"

            # In amend mode, only one COMMIT block is allowed
            if [[ "$amend" -eq 1 ]] && [[ "$commit_count" -gt 0 ]]; then
                echo "COMMIT_FAILED:AMEND_MULTIPLE_COMMITS"
                echo "ERROR: --amend mode accepts exactly one COMMIT block, got a second." >&2
                echo "ERROR: Amend modifies HEAD in place; multiple commits don't make sense." >&2
                exit 1
            fi

        elif [[ "$line" =~ ^FILES:(.*)$ ]]; then
            # Add file to current commit — one path per FILES: line
            # so paths containing spaces are preserved intact
            current_files+=("${BASH_REMATCH[1]}")
        elif [[ -n "$current_message" ]]; then
            # Inside a COMMIT block: append continuation line (including
            # blank lines and lines that look like comments) to the message.
            # This supports the natural multi-line format where the subject
            # and body span separate physical lines. The blank line between
            # subject and body is preserved so validate_commit_message()
            # can find the \n\n separator. expand_message() above converts
            # any \n literals to real newlines (a no-op for multi-line input).
            current_message="$current_message"$'\n'"$line"
        fi
    done

    # Process final commit
    if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
        # Expand \n literals to real newlines
        current_message="$(expand_message "$current_message")"

        # Validate: every commit must have a body explaining the why
        if ! validate_commit_message "$current_message"; then
            echo "COMMIT_FAILED:NO_BODY"
            echo "ERROR: Commit message must include a body after a blank line." >&2
            echo "ERROR: Format: \"Subject line\\n\\n- Body bullet 1\\n- Body bullet 2\"" >&2
            echo "ERROR: Got: $current_message" >&2
            exit 1
        fi

        # Validate: subject must not match banned vague/generic patterns
        if ! validate_commit_subject "$current_message"; then
            exit 1
        fi

        # Validate: every commit must include a #tag array (mandatory,
        # enforced — see commit-tagging-standard include). Bypass only
        # via explicit project config with [commit-tagging] enabled = false.
        if commit_tagging_enabled && ! validate_commit_tag_array "$current_message"; then
            echo "COMMIT_FAILED:NO_TAG_ARRAY"
            echo "ERROR: Commit message must include a #tag array as the last line of the body." >&2
            echo "ERROR: Format: blank line, then #project-<slug> #module-<slug> #type-<type> #skill-grm-created" >&2
            echo "ERROR: Example: #project-auth #module-jwt #type-feat #skill-grm-created" >&2
            echo "ERROR: Disable for this repo via .agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml" >&2
            echo "ERROR: Got: $current_message" >&2
            exit 1
        fi

        echo "PROCESSING_COMMIT:$((commit_count + 1))"
        echo "MESSAGE:$current_message"
        echo "FILES:${current_files[*]}"
        validate_commit_message_quality "$current_message" || true

        for file in "${current_files[@]}"; do
            if stageable "$file"; then
                git_cmd add -- "$file"
                echo "STAGED:$file"
            else
                echo "ERROR: Path not found and not tracked by git: $file" >&2
                echo "COMMIT_FAILED:FILE_NOT_FOUND"
                exit 1
            fi
        done

        if commit_with_message "$current_message"; then
            local commit_hash
            commit_hash=$(git_cmd rev-parse HEAD)
            echo "COMMIT_SUCCESS:$commit_hash"
            commit_count=$((commit_count + 1))
        else
            echo "COMMIT_FAILED:GIT_ERROR"
            exit 1
        fi
    elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
        # Guard: final COMMIT: block has no FILES: lines. Same root cause as
        # the in-loop guard above — FILES: lines were absorbed into the
        # COMMIT: message (e.g. printf with literal \n instead of real
        # newlines). Without this guard the trailing block is silently
        # dropped and the caller never learns the last commit didn't land.
        echo "COMMIT_FAILED:NO_FILES"
        echo "ERROR: Final commit block ended with no FILES: lines." >&2
        echo "ERROR: This usually means FILES: lines were joined onto the COMMIT: line" >&2
        echo "ERROR: (e.g. printf with literal \\n instead of real newlines)." >&2
        echo "ERROR: Each FILES:<path> must be on its own physical line." >&2
        echo "ERROR: Offending message: $current_message" >&2
        exit 1
    fi

    echo "BATCH_COMMIT_COMPLETE:$commit_count"

    # Create post-run tag after all commits
    local post_ts
    post_ts=$(date -u +%Y%m%d%H%M%S)
    local post_prefix="tags/auto/grm/$(date -u +%Y/%m)/${post_ts}"
    local post_tag="${post_prefix}-${slug}-post"
    git_cmd tag -a "$post_tag" HEAD -m "Post-run checkpoint: ${slug}"
    echo "AUTO_TAG_POST:$post_tag"

    echo "=== BATCH_COMMIT_END ==="
}

main "$@"
