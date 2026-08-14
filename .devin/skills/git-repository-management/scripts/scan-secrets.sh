#!/usr/bin/env bash
# scan-secrets.sh — scan staged files for secret patterns using git-secrets
#
# Uses cli-tool-discovery.sh to find git-secrets (awslabs/git-secrets) through
# environment wrappers (devbox, mise, flox, direnv, nix) and standard PATH
# locations. If git-secrets is available, runs `git secrets --scan --cached`
# against the staged diff to detect AWS keys, API tokens, and other prohibited
# patterns registered in the repo or global git config.
#
# If git-secrets is NOT found, the script exits 0 with an informational notice
# — secret scanning is opt-in and must not block commits when the tool is not
# installed. The AI should inform the user that git-secrets was not found and
# recommend installing it (e.g. `devbox add git-secrets` or `brew install
# git-secrets`).
#
# This complements scan-artifacts.sh (identity-leak detection) — scan-artifacts
# catches resolved $HOME paths, usernames, hostnames, WiFi SSIDs; scan-secrets
# catches actual secret patterns (AWS access keys, secret keys, account IDs).
#
# Usage:
#   scan-secrets.sh                          # scan staged files (git diff --cached)
#   scan-secrets.sh --register-aws           # register AWS patterns before scanning
#   scan-secrets.sh --private                # private repo: findings are informational only (exit 0)
#   scan-secrets.sh --verbose                # show full git-secrets output
#
# Exit 0 = clean or git-secrets not installed. Exit 1 = secrets detected (blocks commit).
#
# Environment variables:
#   SCAN_SECRETS_PRIVATE=1   — same as --private (informational only, exit 0)
#   SCAN_SECRETS_SKIP=1      — skip secret scanning entirely (exit 0 immediately)
#
# Consumers:
#   - git-repository-management (git-commit-batch.sh calls this after scan-artifacts.sh)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

REGISTER_AWS=0
PRIVATE=0
VERBOSE=0
SKIP=0

# Parse args
for arg in "$@"; do
  case "$arg" in
    --register-aws) REGISTER_AWS=1 ;;
    --private) PRIVATE=1 ;;
    --verbose) VERBOSE=1 ;;
    --skip) SKIP=1 ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# //; s/^#//'
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Honor environment variable overrides
[[ "${SCAN_SECRETS_PRIVATE:-0}" == "1" ]] && PRIVATE=1
[[ "${SCAN_SECRETS_SKIP:-0}" == "1" ]] && SKIP=1

if [[ "$SKIP" -eq 1 ]]; then
  echo "scan-secrets: skipped (SCAN_SECRETS_SKIP=1)"
  exit 0
fi

# --- Resolve git-secrets via cli-tool-discovery ---
#
# Fast path: check if git-secrets is already on PATH (command -v) before
# falling back to the full cli-tool-discovery chain. The full chain probes
# devbox with a 150s timeout, which is very slow when devbox is contended.
# Since git-secrets is a git subcommand, `git secrets --list` is the fastest
# way to check if it's available — it returns 0 if installed, non-zero if not.

GIT_SECRETS_CMD=()

# Fast path 1: inside a devbox shell — devbox binaries are on PATH
if [[ -n "${DEVBOX_SHELL:-}${IN_DEVBOX_SHELL:-}" ]]; then
  if git secrets --list >/dev/null 2>&1; then
    GIT_SECRETS_CMD=(git secrets)
  fi
fi

# Fast path 2: not in devbox shell, but git-secrets is directly on PATH
if [[ ${#GIT_SECRETS_CMD[@]} -eq 0 ]] && git secrets --list >/dev/null 2>&1; then
  GIT_SECRETS_CMD=(git secrets)
fi

# Slow path: fall back to cli-tool-discovery for wrapper-based resolution
if [[ ${#GIT_SECRETS_CMD[@]} -eq 0 ]]; then
  if [[ ! -f "$CLI_TOOL_DISCOVERY" ]]; then
    echo "scan-secrets: cli-tool-discovery.sh not found at $CLI_TOOL_DISCOVERY — skipping secret scan"
    exit 0
  fi

  # cli-tool-discovery.sh outputs one of:
  #   FOUND: <path>       — tool found at a specific path
  #   WRAPPER: <cmd>      — tool inside an environment wrapper (e.g. "devbox run --")
  #   NOT_FOUND: <tool>   — tool not found anywhere
  DISCOVERY_OUTPUT="$(bash "$CLI_TOOL_DISCOVERY" git-secrets 2>/dev/null || true)"

  if [[ "$DISCOVERY_OUTPUT" == NOT_FOUND:* ]]; then
    echo "scan-secrets: git-secrets not found — secret scanning skipped"
    echo "scan-secrets: to enable, install git-secrets (e.g. devbox add git-secrets or brew install git-secrets)"
    exit 0
  fi

  # Build the git-secrets invocation from discovery output
  if [[ "$DISCOVERY_OUTPUT" == WRAPPER:* ]]; then
    WRAPPER_CMD="${DISCOVERY_OUTPUT#WRAPPER: }"
    # shellcheck disable=SC2206  # intentional word-splitting on wrapper command
    GIT_SECRETS_CMD=($WRAPPER_CMD git secrets)
  elif [[ "$DISCOVERY_OUTPUT" == FOUND:* ]]; then
    GIT_SECRETS_CMD=(git secrets)
  else
    echo "scan-secrets: unexpected cli-tool-discovery output: $DISCOVERY_OUTPUT — skipping"
    exit 0
  fi
fi

# --- Optionally register AWS patterns ---
#
# `git secrets --register-aws` adds common AWS secret patterns to the repo's
# git config. This is idempotent — safe to run even if patterns are already
# registered. Only run it when explicitly requested (--register-aws) to avoid
# modifying repo config without user consent.

if [[ "$REGISTER_AWS" -eq 1 ]]; then
  if [[ "$VERBOSE" -eq 1 ]]; then
    echo "scan-secrets: registering AWS patterns..."
  fi
  "${GIT_SECRETS_CMD[@]}" --register-aws 2>/dev/null || true
fi

# --- Scan staged files ---
#
# `git secrets --scan --cached` scans blobs registered in the index (staged
# files). This is the correct mode for pre-commit scanning — it checks exactly
# what would be committed. Exit code 0 = clean, 1 = secrets found.

if [[ "$VERBOSE" -eq 1 ]]; then
  echo "scan-secrets: running ${GIT_SECRETS_CMD[*]} --scan --cached"
fi

SCAN_OUTPUT="$("${GIT_SECRETS_CMD[@]}" --scan --cached 2>&1)" && SCAN_EXIT=0 || SCAN_EXIT=$?

if [[ "$SCAN_EXIT" -eq 0 ]]; then
  echo "scan-secrets: ok — no prohibited patterns detected in staged files"
  exit 0
fi

# Secrets detected — report findings
echo "scan-secrets: FAIL — prohibited patterns detected in staged files"
echo ""
if [[ -n "$SCAN_OUTPUT" ]]; then
  echo "$SCAN_OUTPUT"
  echo ""
fi

if [[ "$PRIVATE" -eq 1 ]]; then
  echo "scan-secrets: --private mode: findings are informational only (exit 0)"
  echo "scan-secrets: if the repo may be shared or made public, re-run without --private and fix all findings"
  exit 0
fi

echo "scan-secrets: review each finding and remove the secret before committing"
echo "scan-secrets: if the finding is a false positive, add it as an allowed pattern:"
echo "  git secrets --add -a '<pattern>'"
echo ""
echo "scan-secrets: set SCAN_SECRETS_PRIVATE=1 for private repos where findings are informational"

exit 1
