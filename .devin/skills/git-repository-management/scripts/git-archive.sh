#!/usr/bin/env bash

# git-archive.sh - Archive stale branches and tags with structured naming
# Purpose: Single handoff to identify, archive, and prune branches/tags.
#          Renames refs to archive/{branches,tags}/{type}/YYYY/MM/YYYYMMDD-{slug}[-pre|-post].
#          Defers to repo conventions when the upstream is not owned by the
#          configured primary account (default: levonk).
# Usage:
#   git-archive.sh --identify [--main-branch <branch>] [--skip <b1,b2,...>] [--fetch|--no-fetch] [repo_root]
#   git-archive.sh --archive [--ref <name>]... [--yes] [--main-branch <branch>] [repo_root]
#   git-archive.sh --prune [--retention-months N] [--confirm] [repo_root]
#   All modes support --dry-run and --primary-owner <owner>
# Output: Structured lines for AI analysis (ARCHIVE_CANDIDATE:, ARCHIVED:, PRUNED:, SKIPPED:)
# Merge detection: Uses both `git merge-base --is-ancestor` (fast-path for
#   true merges) and `git cherry` (catches squash-merged branches whose commits
#   are not ancestors of main but whose patch content is already in main).

set -euo pipefail

# Initialize flags that may be referenced before CLI parsing sets them.
DRY_RUN="${DRY_RUN:-}"

# Tool detection and wrapper helpers are shared via includes.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

if command -v rtk >/dev/null 2>&1; then RTK_AVAILABLE=1; else RTK_AVAILABLE=0; fi

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


probe_devbox || true

# Conventional-commit types plus extensions for auto-generated and scratch refs.
VALID_TYPES="feat fix chore doc refactor perf test build ci style revert auto scratch"

# Branches that must never be archived.
PROTECTED_BRANCHES="env/dev main master develop dev staging"

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

validate_type() {
    local t="$1"
    for valid in $VALID_TYPES; do
        [[ "$t" == "$valid" ]] && return 0
    done
    echo "ERROR: Invalid type '$t'. Valid: $VALID_TYPES" >&2
    exit 1
}

# Get the upstream owner from the remote URL.
get_upstream_owner() {
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -z "$remote_url" ]; then
        echo ""
        return
    fi
    # Handle SSH (git@host:owner/repo), HTTPS (https://host/owner/repo),
    # and SSH aliases (git@github-l:owner/repo). Extract the path component
    # after the last colon or slash, then take the first segment as the owner.
    # Use grep + cut for BSD/macOS compatibility.
    local path_component
    # Strip protocol and host: get everything after the last ':' or '/'
    path_component=$(echo "$remote_url" | sed 's|.*[:/]||' | head -1)
    # Actually, we need the owner which is the first path segment after the host
    # For git@github.com:levonk/dotfiles.git → levonk
    # For https://github.com/levonk/dotfiles.git → levonk
    # For git@github-l:levonk/dotfiles.git → levonk
    # Strip .git suffix, then take the segment after the last colon or the
    # third slash (for HTTPS URLs)
    local cleaned
    cleaned=$(echo "$remote_url" | sed 's/\.git$//')
    # For SSH URLs (git@host:owner/repo), extract after colon.
    # Check for '@' before ':' to distinguish SSH (git@host:path) from
    # HTTPS (https://host/path) which also contains ':' after the protocol.
    if echo "$cleaned" | grep -q '@.*:'; then
        echo "$cleaned" | sed 's/.*://' | cut -d/ -f1 | tr '[:upper:]' '[:lower:]'
    else
        # For HTTPS URLs (https://host/owner/repo), extract after host
        echo "$cleaned" | cut -d/ -f4 | tr '[:upper:]' '[:lower:]'
    fi
}

# Derive the last commit date of a ref as YYYYMMDD.
get_ref_date() {
    local ref="$1"
    git_cmd log -1 --format=%cd --date=format:%Y%m%d "$ref" 2>/dev/null || date +%Y%m%d
}

# Derive year/month from a YYYYMMDD string.
get_year_month() {
    local date_str="$1"
    echo "${date_str:0:4}/${date_str:4:2}"
}

# Classify a branch name into an archive type.
classify_branch() {
    local branch="$1"
    case "$branch" in
        cascade/*) echo "auto" ;;
        scratch/*) echo "scratch" ;;
        feat/*|feature/*) echo "feat" ;;
        fix/*) echo "fix" ;;
        chore/*) echo "chore" ;;
        doc/*|docs/*) echo "doc" ;;
        refactor/*) echo "refactor" ;;
        perf/*) echo "perf" ;;
        test/*|tests/*) echo "test" ;;
        build/*) echo "build" ;;
        ci/*) echo "ci" ;;
        style/*) echo "style" ;;
        revert/*) echo "revert" ;;
        *) echo "chore" ;;  # default to chore for unclassified branches
    esac
}

# Classify a tag name into an archive type.
classify_tag() {
    local tag="$1"
    case "$tag" in
        tags/auto/*) echo "auto" ;;
        tags/feat/*) echo "feat" ;;
        tags/fix/*) echo "fix" ;;
        tags/chore/*) echo "chore" ;;
        tags/doc/*) echo "doc" ;;
        tags/refactor/*) echo "refactor" ;;
        tags/tasks/*) echo "chore" ;;
        feature/archive/*) echo "feat" ;;
        *) echo "chore" ;;
    esac
}

# Strip prefixes and collapse into a kebab-case slug (max 50 chars).
slugify() {
    local name="$1"
    # Strip common prefixes
    name="${name#cascade/}"
    name="${name#scratch/merge/}"
    name="${name#scratch/}"
    name="${name#tags/auto/grm/}"
    name="${name#tags/auto/}"
    name="${name#tags/feat/}"
    name="${name#tags/fix/}"
    name="${name#tags/chore/}"
    name="${name#tags/tasks/}"
    name="${name#tags/}"
    name="${name#feature/archive/}"
    name="${name#feature/}"
    name="${name#feat/}"
    name="${name#fix/}"
    name="${name#chore/}"
    name="${name#doc/}"
    name="${name#docs/}"
    name="${name#refactor/}"
    # Remove date path prefixes (YYYY/MM/ or YYYY/MM/DD/)
    name="${name#[0-9][0-9][0-9][0-9]/[0-9][0-9]/}"
    name="${name#[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]/}"
    # Remove standalone day prefixes (DD/ after YYYY/MM/ was stripped)
    name="${name#[0-9][0-9]/}"
    # Remove date prefixes (YYYYMMDDHHMMSS- or YYYYMMDD-)
    name="${name#[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-}"
    name="${name#[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-}"
    name="${name#[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-}"
    # Collapse slashes to hyphens
    name="${name//\//-}"
    # Lowercase
    name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
    # Remove non-alphanumeric except hyphens
    name="$(echo "$name" | sed 's/[^a-z0-9-]//g')"
    # Collapse multiple hyphens
    name="$(echo "$name" | sed 's/--*/-/g')"
    # Strip leading/trailing hyphens
    name="${name#-}"
    name="${name%-}"
    # Truncate to 50 chars (try to break at a hyphen)
    if [ ${#name} -gt 50 ]; then
        name="${name:0:50}"
        name="${name%-*}"
        name="${name#-}"
    fi
    echo "$name"
}

# Check if a branch is protected.
is_protected_branch() {
    local branch="$1"
    for protected in $PROTECTED_BRANCHES; do
        [[ "$branch" == "$protected" ]] && return 0
    done
    return 1
}

# Check if a ref is merged into the main branch.
is_merged() {
    local ref="$1"
    local main_branch="$2"
    git_cmd merge-base --is-ancestor "$ref" "$main_branch" 2>/dev/null
}

# Check if a ref's commits are squash-merged into the main branch.
# `git cherry` compares by patch content (not ancestry), so it detects
# squash-merged branches that `merge-base --is-ancestor` misses.
# Returns 0 (true) if all commits in $ref have equivalent patches in $main_branch.
# git cherry output: lines starting with `-` = already in upstream (by patch),
#   lines starting with `+` = not in upstream. If all lines are `-` (or output
#   is empty), the branch is fully squash-merged.
# Pattern borrowed from arc90/git-sweep (inspector.py: git cherry upstream head).
is_squash_merged() {
    local ref="$1"
    local main_branch="$2"
    local cherry_out
    cherry_out=$(git_cmd cherry "$main_branch" "$ref" 2>/dev/null || true)
    # Empty output = no commits to compare (branch is at same point as main)
    [ -z "$cherry_out" ] && return 0
    # If any line starts with '+', there are commits not in main by patch equivalence
    echo "$cherry_out" | grep -q '^+' && return 1
    return 0
}

# Combined merge check: true merge (ancestor) OR squash merge (cherry equivalence).
# This is the function callers should use instead of is_merged alone.
is_fully_merged() {
    local ref="$1"
    local main_branch="$2"
    is_merged "$ref" "$main_branch" || is_squash_merged "$ref" "$main_branch"
}

# Build the archive path for a branch.
build_archive_branch_path() {
    local branch="$1"
    local archive_type
    archive_type=$(classify_branch "$branch")
    local date_str
    date_str=$(get_ref_date "$branch")
    local year_month
    year_month=$(get_year_month "$date_str")
    local slug
    slug=$(slugify "$branch")
    # Preserve -pre/-post suffix if present
    local suffix=""
    case "$branch" in
        *-pre) suffix="-pre" ;;
        *-post) suffix="-post" ;;
    esac
    echo "archive/branches/${archive_type}/${year_month}/${date_str}-${slug}${suffix}"
}

# Build the archive path for a tag.
build_archive_tag_path() {
    local tag="$1"
    local archive_type
    archive_type=$(classify_tag "$tag")
    local date_str
    date_str=$(get_ref_date "$tag")
    local year_month
    year_month=$(get_year_month "$date_str")
    local slug
    slug=$(slugify "$tag")
    local suffix=""
    case "$tag" in
        *-pre) suffix="-pre" ;;
        *-post) suffix="-post" ;;
    esac
    echo "archive/tags/${archive_type}/${year_month}/${date_str}-${slug}${suffix}"
}

# Phase 1: Identify archive candidates.
do_identify() {
    local main_branch="$1"
    local primary_owner="$2"
    local skip_branches="$3"
    local do_fetch="$4"

    # Check ownership
    local upstream_owner
    upstream_owner=$(get_upstream_owner)
    if [ -n "$upstream_owner" ] && [ -n "$primary_owner" ] && [ "$upstream_owner" != "$primary_owner" ]; then
        echo "SKIPPED:UPSTREAM_NOT_OWNED"
        echo "NOTICE: Repository upstream owner is '$upstream_owner', not '$primary_owner'." >&2
        echo "NOTICE: Deferring to repo conventions. Pass --force to override." >&2
        return 0
    fi

    # Fetch from remote before identifying (mirrors git-sweep's fetch-before-scan).
    # Ensures remote-tracking refs are current so stale-branch detection is accurate.
    if [ "$do_fetch" = "1" ]; then
        echo "FETCHING:origin" >&2
        git_cmd fetch origin --prune 2>/dev/null || echo "NOTICE: git fetch failed, proceeding with local refs only." >&2
    fi

    # Build skip set from --skip flag (comma-separated) plus protected branches.
    local skip_set=" $PROTECTED_BRANCHES "
    if [ -n "$skip_branches" ]; then
        local IFS=','
        for s in $skip_branches; do
            s=$(echo "$s" | xargs)
            [ -n "$s" ] && skip_set="${skip_set}${s} "
        done
        unset IFS
    fi
    is_skipped() {
        local b="$1"
        [[ "$skip_set" == *" $b "* ]]
    }

    echo "=== BRANCHES ==="
    local branches
    branches=$(git_cmd branch --format='%(refname:short)' 2>/dev/null | grep -v '^\*' || true)
    for branch in $branches; do
        if is_skipped "$branch"; then
            echo "KEEP:${branch}:skip-list"
            continue
        fi

        # Use is_fully_merged (true merge OR squash merge) instead of is_merged alone.
        # Squash-merged branches have no ancestry link but their patch content is in main.
        local merged=""
        if is_fully_merged "$branch" "$main_branch"; then
            merged="merged"
        else
            merged="unmerged"
        fi

        local archive_path
        archive_path=$(build_archive_branch_path "$branch")

        case "$branch" in
            cascade/*)
                echo "ARCHIVE_CANDIDATE:${branch}:${archive_path}:auto-generated:${merged}"
                ;;
            scratch/*)
                if [ "$merged" = "merged" ]; then
                    echo "ARCHIVE_CANDIDATE:${branch}:${archive_path}:scratch-snapshot:${merged}"
                else
                    echo "KEEP:${branch}:unmerged-scratch"
                fi
                ;;
            *)
                if [ "$merged" = "merged" ]; then
                    echo "ARCHIVE_CANDIDATE:${branch}:${archive_path}:merged-branch:${merged}"
                else
                    echo "REVIEW:${branch}:${archive_path}:unmerged:${merged}"
                fi
                ;;
        esac
    done

    # Remote-tracking branches (git-sweep pattern: scan remote refs too).
    # These are branches that exist on the remote but may not have local counterparts.
    # Only scan if origin remote exists.
    local remote_branches
    remote_branches=$(git_cmd branch -r --format='%(refname:short)' 2>/dev/null | grep -v 'HEAD ->' || true)
    if [ -n "$remote_branches" ]; then
        echo ""
        echo "=== REMOTE BRANCHES ==="
        for rbranch in $remote_branches; do
            # Strip origin/ prefix for skip check and display
            local short_name="${rbranch#origin/}"
            [ "$short_name" = "$rbranch" ] && continue  # skip non-origin remotes
            if is_skipped "$short_name"; then
                echo "KEEP:${rbranch}:skip-list"
                continue
            fi
            # Skip if a local branch with the same name exists (already handled above)
            git_cmd show-ref --verify --quiet "refs/heads/$short_name" 2>/dev/null && continue

            local merged=""
            if is_fully_merged "$rbranch" "$main_branch"; then
                merged="merged"
            else
                merged="unmerged"
            fi

            local archive_path
            archive_path=$(build_archive_branch_path "$short_name")

            if [ "$merged" = "merged" ]; then
                echo "ARCHIVE_CANDIDATE:${rbranch}:${archive_path}:remote-merged:${merged}"
            else
                echo "REVIEW:${rbranch}:${archive_path}:remote-unmerged:${merged}"
            fi
        done
    fi

    echo ""
    echo "=== TAGS ==="
    local tags
    tags=$(git_cmd tag 2>/dev/null || true)
    for tag in $tags; do
        # Skip already-archived tags
        case "$tag" in
            archive/*) echo "KEEP:${tag}:already-archived"; continue ;;
        esac

        local tag_in_history=""
        if is_merged "$tag" "$main_branch"; then
            tag_in_history="in-history"
        else
            tag_in_history="orphaned"
        fi

        local archive_path
        archive_path=$(build_archive_tag_path "$tag")

        case "$tag" in
            tags/auto/*)
                echo "ARCHIVE_CANDIDATE:${tag}:${archive_path}:auto-checkpoint:${tag_in_history}"
                ;;
            tags/feat/*|tags/tasks/*)
                echo "REVIEW:${tag}:${archive_path}:user-tag:${tag_in_history}"
                ;;
            feature/archive/*)
                echo "KEEP:${tag}:already-archived"
                ;;
            *)
                echo "REVIEW:${tag}:${archive_path}:other-tag:${tag_in_history}"
                ;;
        esac
    done
}

# Phase 2: Archive specific refs.
do_archive() {
    local main_branch="$1"
    local primary_owner="$2"
    local auto_yes="$3"
    shift 3
    local refs=("$@")

    if [ ${#refs[@]} -eq 0 ]; then
        echo "ERROR: No refs specified. Use --ref <name> to specify refs to archive." >&2
        exit 1
    fi

    # Check ownership
    local upstream_owner
    upstream_owner=$(get_upstream_owner)
    if [ -n "$upstream_owner" ] && [ -n "$primary_owner" ] && [ "$upstream_owner" != "$primary_owner" ]; then
        echo "SKIPPED:UPSTREAM_NOT_OWNED"
        echo "NOTICE: Repository upstream owner is '$upstream_owner', not '$primary_owner'." >&2
        echo "NOTICE: Deferring to repo conventions. Pass --force to override." >&2
        return 0
    fi

    # Confirmation prompt (git-sweep pattern: ask before destructive ops unless --yes/--force).
    # In a non-interactive context (no TTY on stdin), abort unless --yes was passed.
    if [ -z "$DRY_RUN" ] && [ "$auto_yes" != "1" ]; then
        if [ ! -t 0 ]; then
            echo "SKIPPED:NON_INTERACTIVE" >&2
            echo "NOTICE: Refusing to archive without confirmation in non-interactive context. Pass --yes to proceed." >&2
            echo "SKIPPED:USER_ABORTED"
            return 0
        fi
        echo "The following refs will be archived:" >&2
        for ref in "${refs[@]}"; do
            echo "  $ref" >&2
        done
        printf "Archive these refs? (y/N) " >&2
        local answer=""
        read -r answer 2>/dev/null || answer=""
        if ! echo "$answer" | grep -qi '^y'; then
            echo "SKIPPED:USER_ABORTED"
            return 0
        fi
    fi

    local archived_count=0
    for ref in "${refs[@]}"; do
        # Check if it's a branch or tag
        local is_branch=""
        git_cmd show-ref --verify --quiet "refs/heads/$ref" 2>/dev/null && is_branch=1
        local is_tag=""
        git_cmd show-ref --verify --quiet "refs/tags/$ref" 2>/dev/null && is_tag=1

        if [ -z "$is_branch" ] && [ -z "$is_tag" ]; then
            echo "ARCHIVE_FAILED:NOT_FOUND:${ref}"
            continue
        fi

        local archive_path=""
        if [ -n "$is_branch" ]; then
            archive_path=$(build_archive_branch_path "$ref")
        else
            archive_path=$(build_archive_tag_path "$ref")
        fi

        if [ -n "$DRY_RUN" ]; then
            echo "DRY_RUN:ARCHIVE:${ref}→${archive_path}"
            continue
        fi

        if [ -n "$is_branch" ]; then
            # Rename branch locally
            git_cmd branch -m "$ref" "$archive_path" 2>/dev/null || {
                echo "ARCHIVE_FAILED:RENAME:${ref}"
                continue
            }
            # Push archive ref and delete old remote ref
            git_cmd push origin "$archive_path" 2>/dev/null || true
            git_cmd push origin --delete "$ref" 2>/dev/null || true
        else
            # Create archive tag and delete old tag
            git_cmd tag "$archive_path" "$ref" 2>/dev/null || {
                echo "ARCHIVE_FAILED:TAG_CREATE:${ref}"
                continue
            }
            git_cmd tag -d "$ref" 2>/dev/null || true
            git_cmd push origin "$archive_path" 2>/dev/null || true
            git_cmd push origin --delete "$ref" 2>/dev/null || true
        fi

        echo "ARCHIVED:${ref}→${archive_path}"
        archived_count=$((archived_count + 1))
    done

    # Post-action guidance (git-sweep pattern: tell users to sync).
    if [ "$archived_count" -gt 0 ] && [ -z "$DRY_RUN" ]; then
        echo ""
        echo "NOTICE: Archived ${archived_count} ref(s). Collaborators should run 'git fetch --prune' to sync."
    fi
}

# Phase 3: Prune old archive refs.
do_prune() {
    local retention_months="$1"
    local confirm="$2"

    local cutoff_date
    cutoff_date=$(date -v-${retention_months}m +%Y%m%d 2>/dev/null || date -d "-${retention_months} months" +%Y%m%d 2>/dev/null || echo "")

    if [ -z "$cutoff_date" ]; then
        echo "ERROR: Could not compute cutoff date. Unsupported date command." >&2
        exit 1
    fi

    # Collect all archive refs
    local archive_refs
    archive_refs=$(git_cmd branch --format='%(refname:short)' 2>/dev/null | grep '^archive/' || true)
    archive_refs="${archive_refs}
$(git_cmd tag 2>/dev/null | grep '^archive/' || true)"

    local pruned_count=0
    for ref in $archive_refs; do
        [ -z "$ref" ] && continue
        # Extract date from path: archive/{branches,tags}/{type}/YYYY/MM/YYYYMMDD-{slug}
        local ref_date
        ref_date=$(echo "$ref" | sed -n 's|.*archive/[a-z]*/[a-z]*/[0-9]*/[0-9]*/\([0-9]\{8\}\).*|\1|p')
        [ -z "$ref_date" ] && continue

        if [ "$ref_date" -lt "$cutoff_date" ] 2>/dev/null; then
            if [ -n "$DRY_RUN" ] || [ "$confirm" != "1" ]; then
                echo "PRUNE_CANDIDATE:${ref}:date=${ref_date}:cutoff=${cutoff_date}"
            else
                # Delete the ref (branch or tag)
                git_cmd show-ref --verify --quiet "refs/heads/$ref" 2>/dev/null && {
                    git_cmd branch -D "$ref" 2>/dev/null || true
                    git_cmd push origin --delete "$ref" 2>/dev/null || true
                }
                git_cmd show-ref --verify --quiet "refs/tags/$ref" 2>/dev/null && {
                    git_cmd tag -d "$ref" 2>/dev/null || true
                    git_cmd push origin --delete "$ref" 2>/dev/null || true
                }
                echo "PRUNED:${ref}"
                pruned_count=$((pruned_count + 1))
            fi
        fi
    done

    # Post-action guidance (git-sweep pattern).
    if [ "$pruned_count" -gt 0 ] && [ -z "$DRY_RUN" ]; then
        echo ""
        echo "NOTICE: Pruned ${pruned_count} archive ref(s). Collaborators should run 'git fetch --prune' to sync."
    fi
}

main() {
    local mode=""
    local main_branch=""
    local primary_owner="levonk"
    local retention_months=6
    local confirm=0
    local auto_yes=0
    local skip_branches=""
    local do_fetch=0
    local target_path="."
    local refs=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --identify) mode="identify"; shift ;;
            --archive) mode="archive"; shift ;;
            --prune) mode="prune"; shift ;;
            --ref) refs+=("$2"); shift 2 ;;
            --ref=*) refs+=("${1#--ref=}"); shift ;;
            --main-branch) main_branch="$2"; shift 2 ;;
            --main-branch=*) main_branch="${1#--main-branch=}"; shift ;;
            --primary-owner) primary_owner="$2"; shift 2 ;;
            --primary-owner=*) primary_owner="${1#--primary-owner=}"; shift ;;
            --retention-months) retention_months="$2"; shift 2 ;;
            --retention-months=*) retention_months="${1#--retention-months=}"; shift ;;
            --confirm) confirm=1; shift ;;
            --yes|-y) auto_yes=1; shift ;;
            --skip) skip_branches="$2"; shift 2 ;;
            --skip=*) skip_branches="${1#--skip=}"; shift ;;
            --fetch) do_fetch=1; shift ;;
            --no-fetch) do_fetch=0; shift ;;
            --dry-run) DRY_RUN=1; shift ;;
            --force) primary_owner=""; shift ;;  # Disable ownership check
            -h|--help)
                sed -n '2,14p' "$0"
                exit 0
                ;;
            *) target_path="$1"; shift ;;
        esac
    done

    if [ -z "$mode" ]; then
        echo "ERROR: --identify, --archive, or --prune is required" >&2
        echo "Usage: git-archive.sh --identify [--main-branch <branch>] [--skip <b1,b2>] [--fetch] [repo_root]" >&2
        echo "       git-archive.sh --archive --ref <name> [--ref <name>]... [--yes] [repo_root]" >&2
        echo "       git-archive.sh --prune [--retention-months N] [--confirm] [repo_root]" >&2
        exit 1
    fi

    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    # Auto-detect main branch if not specified
    if [ -z "$main_branch" ]; then
        for candidate in env/dev main master develop dev; do
            if git_cmd show-ref --verify --quiet "refs/heads/$candidate" 2>/dev/null; then
                main_branch="$candidate"
                break
            fi
        done
    fi

    if [ -z "$main_branch" ]; then
        echo "ERROR: Could not detect main branch. Specify with --main-branch." >&2
        exit 1
    fi

    case "$mode" in
        identify) do_identify "$main_branch" "$primary_owner" "$skip_branches" "$do_fetch" ;;
        archive)  do_archive "$main_branch" "$primary_owner" "$auto_yes" "${refs[@]}" ;;
        prune)    do_prune "$retention_months" "$confirm" ;;
    esac
}

main "$@"
