#!/usr/bin/env bash

# mine-bug-fixes.sh - Mine git history for bug-fix commits
# Purpose: Single AI→script handoff that collects bug-fix commits from git log
#          so the AI can classify them and dispatch unit-test-writing for the
#          ones that lack a regression test.
# Usage: mine-bug-fixes.sh [--since <date>] [--max-count <N>] [--blame]
#                          [--bisect <sha>] [--from-file <path>] [--json]
#                          [--repo-root <path>]
# Output: One commit per line (TSV by default): <sha>\t<date>\t<subject>\t<trailers>
#         JSON when --json is passed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

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
probe_devbox || true

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
SINCE=""
MAX_COUNT="1000"
BLAME=0
BISECT_SHA=""
FROM_FILE=""
JSON_OUTPUT=0
REPO_ROOT=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
mine-bug-fixes.sh — mine git history for bug-fix commits

Usage:
  mine-bug-fixes.sh [options]

Options:
  --since <date>       Only commits more recent than <date> (git log --since).
                       Accepts git date formats: "90 days ago", "2026-01-01", etc.
  --max-count <N>      Maximum commits to scan per source (default: 1000).
                       Set to 0 for unbounded.
  --blame              Also run git blame to find bug-introducing commits.
                       Slow on large repos — opt-in.
  --bisect <sha>       Skip mining; process a single known bug-introducing
                       commit (e.g., from git bisect output).
  --from-file <path>   Skip mining; read commit SHAs from <path> (one per line).
  --json               Emit JSON instead of TSV.
  --repo-root <path>   Path to the repository root (default: cwd).
  -h, --help           Show this help.

Output (TSV, one commit per line):
  <sha>\t<author-date>\t<subject>\t<trailers>

Output (JSON, when --json is passed):
  [{"sha": "...", "date": "...", "subject": "...", "trailers": "...", "source": "..."}]

Sources:
  conventional  fix: / fix(scope): commit prefixes
  trailer       Fixes #N / Closes #N / Resolves #N trailers
  revert        Revert "..." commits
  blame         git blame-identified bug-introducing commits (--blame only)
  bisect        single commit from --bisect
  file          commits from --from-file
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)
      SINCE="$2"; shift 2 ;;
    --max-count)
      MAX_COUNT="$2"; shift 2 ;;
    --blame)
      BLAME=1; shift ;;
    --bisect)
      BISECT_SHA="$2"; shift 2 ;;
    --from-file)
      FROM_FILE="$2"; shift 2 ;;
    --json)
      JSON_OUTPUT=1; shift ;;
    --repo-root)
      REPO_ROOT="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Resolve repo root
# ---------------------------------------------------------------------------
if [[ -z "$REPO_ROOT" ]]; then
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
fi

cd "$REPO_ROOT"

# ---------------------------------------------------------------------------
# git wrapper: use rtk if available, else plain git, all through devbox if needed
# ---------------------------------------------------------------------------
git_log() {
  # $@ = extra git log args
  if [[ -n "$(rtk_available)" ]]; then
    rtk_wrap git log "$@"
  else
    devbox_run git log "$@"
  fi
}

git_show() {
  if [[ -n "$(rtk_available)" ]]; then
    rtk_wrap git show "$@"
  else
    devbox_run git show "$@"
  fi
}

# ---------------------------------------------------------------------------
# Build the --since and --max-count args
# ---------------------------------------------------------------------------
SINCE_ARG=()
if [[ -n "$SINCE" ]]; then
  SINCE_ARG=(--since="$SINCE")
fi

MAX_ARG=()
if [[ "$MAX_COUNT" != "0" ]]; then
  MAX_ARG=(-n "$MAX_COUNT")
fi

# ---------------------------------------------------------------------------
# Collect commits from each source
# ---------------------------------------------------------------------------
# Each source emits lines: <sha>\t<date>\t<subject>\t<trailers>\t<source>
# We dedupe by SHA at the end (a commit may match multiple sources).

RAW_FILE="$(mktemp)"
trap 'rm -f "$RAW_FILE"' EXIT

emit_conventional() {
  # Conventional fix: prefix — fix: or fix(scope): ...
  # Use --grep with extended regex; -i for case-insensitivity.
  git_log --pretty=format:'%H%x09%ad%x09%s%x09%x09conventional' \
    --date=short --grep='^fix:' --grep='^fix([[:alnum:]-]+):' \
    -i --all-match "${SINCE_ARG[@]}" "${MAX_ARG[@]}" 2>/dev/null >>"$RAW_FILE" || true
  echo >>"$RAW_FILE"
}

emit_trailer() {
  # Fixes #N / Closes #N / Resolves #N trailers
  git_log --pretty=format:'%H%x09%ad%x09%s%x09%b%x09trailer' \
    --date=short --grep='Fixes #' --grep='Closes #' --grep='Resolves #' \
    -i --all-match "${SINCE_ARG[@]}" "${MAX_ARG[@]}" 2>/dev/null >>"$RAW_FILE" || true
  echo >>"$RAW_FILE"
}

emit_revert() {
  # Revert "..." commits
  git_log --pretty=format:'%H%x09%ad%x09%s%x09%x09revert' \
    --date=short --grep='^Revert "' -i "${SINCE_ARG[@]}" "${MAX_ARG[@]}" 2>/dev/null >>"$RAW_FILE" || true
  echo >>"$RAW_FILE"
}

emit_blame() {
  # Blame-based mining is opt-in and slow. We do NOT run a full
  # git-blame-based bug-introducing-commit detection here (that requires
  # git-blamez or a similar tool). Instead, we emit a marker line so the
  # AI knows blame mode was requested but the heavy analysis is the AI's
  # job — the AI runs `git blame` on specific files identified by the
  # other sources and reasons about bug-introducing commits.
  #
  # See references/blame-mining.md for the full blame-based workflow.
  echo "# blame mode requested — see references/blame-mining.md" >>"$RAW_FILE"
}

emit_bisect() {
  # Single commit from git bisect
  local sha="$1"
  local subject date body
  subject="$(git_show -s --pretty=format:'%s' "$sha" 2>/dev/null || echo '')"
  date="$(git_show -s --pretty=format:'%ad' --date=short "$sha" 2>/dev/null || echo '')"
  body="$(git_show -s --pretty=format:'%b' "$sha" 2>/dev/null || echo '')"
  printf '%s\t%s\t%s\t%s\tbisect\n' "$sha" "$date" "$subject" "$body" >>"$RAW_FILE"
}

emit_from_file() {
  # One SHA per line from a file
  local file="$1"
  [[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 1; }
  while IFS= read -r sha; do
    [[ -z "$sha" ]] && continue
    [[ "$sha" =~ ^# ]] && continue
    local subject date body
    subject="$(git_show -s --pretty=format:'%s' "$sha" 2>/dev/null || echo '')"
    date="$(git_show -s --pretty=format:'%ad' --date=short "$sha" 2>/dev/null || echo '')"
    body="$(git_show -s --pretty=format:'%b' "$sha" 2>/dev/null || echo '')"
    printf '%s\t%s\t%s\t%s\tfile\n' "$sha" "$date" "$subject" "$body" >>"$RAW_FILE"
  done <"$file"
}

# ---------------------------------------------------------------------------
# Run the requested source(s)
# ---------------------------------------------------------------------------
if [[ -n "$BISECT_SHA" ]]; then
  emit_bisect "$BISECT_SHA"
elif [[ -n "$FROM_FILE" ]]; then
  emit_from_file "$FROM_FILE"
else
  emit_conventional
  emit_trailer
  emit_revert
  if [[ "$BLAME" -eq 1 ]]; then
    emit_blame
  fi
fi

# ---------------------------------------------------------------------------
# Dedupe by SHA and emit output
# ---------------------------------------------------------------------------
# Sort by SHA (field 1), unique, then sort by date (field 2) descending.
# Skip comment lines (starting with #).
process_output() {
  grep -v '^#' "$RAW_FILE" 2>/dev/null || true
}

if [[ "$JSON_OUTPUT" -eq 1 ]]; then
  # Emit JSON array
  printf '['
  first=1
  process_output | sort -u -t$'\t' -k1,1 | sort -r -t$'\t' -k2,2 | while IFS=$'\t' read -r sha date subject trailers source; do
    [[ -z "$sha" ]] && continue
    if [[ $first -eq 1 ]]; then
      first=0
    else
      printf ','
    fi
    # Escape double quotes and backslashes in JSON strings
    esc_subject="$(printf '%s' "$subject" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    esc_trailers="$(printf '%s' "$trailers" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')"
    printf '{"sha":"%s","date":"%s","subject":"%s","trailers":"%s","source":"%s"}' \
      "$sha" "$date" "$esc_subject" "$esc_trailers" "$source"
  done
  printf ']\n'
else
  # Emit TSV: sha\tdate\tsubject\ttrailers (drop the source column for the
  # default output — the AI knows which source it asked for)
  process_output | sort -u -t$'\t' -k1,1 | sort -r -t$'\t' -k2,2 | \
    awk -F'\t' 'NF>=4 {printf "%s\t%s\t%s\t%s\n", $1, $2, $3, $4}'
fi
