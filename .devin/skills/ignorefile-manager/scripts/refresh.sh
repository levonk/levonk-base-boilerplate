#!/usr/bin/env bash
# refresh.sh — ensure this skill is current, then print its body (INSTRUCTIONS.md).
#
# Does, in order, deterministically:
#   1. Resolve own directory and skill name
#   2. Check skip conditions (SKIP_SKILL_REFRESH, inside skills-src)
#   3. Check daily-refresh cache (once per day per skill)
#   4. Find pnpm via cli-tool-discovery
#   5. Detect existing nono session (skip sandbox if already inside one)
#   6. Run `pnpm dlx skills update <skill-name>` — sandboxed via nono if available
#   7. Write today's date to the cache file regardless of outcome
#   8. Cat INSTRUCTIONS.md to stdout
#
# Sandbox: uses nono (https://github.com/nolabs-ai/nono) with a bundled profile
# at references/nono-profile.json. If nono is not installed, or we are already
# inside a nono session, or on native Windows, the update runs unsandboxed.
# The trust model treats levonk/skills-releases as a trusted source — the
# sandbox is defense-in-depth, not a primary security boundary.
#
# See: internal-docs/adr/2026/08/adr-202608030953-skill-refresh-sandbox-selection.md
#
# Exit codes:
#   0 = INSTRUCTIONS.md printed to stdout
#   1 = INSTRUCTIONS.md not found
#   2 = pnpm not found (stderr warns; stdout still gets on-disk INSTRUCTIONS.md)

set -euo pipefail

# --- 1. Resolve own location ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
INSTRUCTIONS="$SKILL_DIR/INSTRUCTIONS.md"

# --- Helper: print INSTRUCTIONS.md and exit ---
print_body() {
  if [ -f "$INSTRUCTIONS" ]; then
    cat "$INSTRUCTIONS"
    exit 0
  fi
  echo "refresh.sh: INSTRUCTIONS.md not found at $INSTRUCTIONS" >&2
  exit 1
}

# --- 2. Skip conditions ---
# SKIP_SKILL_REFRESH=1 — environment variable to skip refresh entirely
if [ "${SKIP_SKILL_REFRESH:-0}" = "1" ]; then
  print_body
fi

# Inside skills-src itself — source IS the latest version by definition
case "$SKILL_DIR" in
  */skills-src/src/*) print_body ;;
esac

# --- 3. Check daily-refresh cache ---
# Cache path follows the XDG convention used by skill-config.sh:
#   ${XDG_CACHE_HOME:-~/.cache}/skills/levonk/skills-releases/skills/<skill-path>/
CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_DIR="$CACHE_BASE/skills/levonk/skills-releases/skills/$SKILL_NAME"
mkdir -p "$CACHE_DIR" 2>/dev/null || true
DATE_FILE="$CACHE_DIR/refresh.date"
TODAY="$(date +%Y-%m-%d)"

if [ -f "$DATE_FILE" ] && [ "$(cat "$DATE_FILE" 2>/dev/null)" = "$TODAY" ]; then
  # Already refreshed today — skip update, print body
  print_body
fi

# --- 4. Find pnpm via cli-tool-discovery ---
CLI_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"
PNPM_RUNNER=""

if [ -x "$CLI_DISCOVERY" ]; then
  # Use runner mode to get the canonical node ecosystem runner
  RUNNER_JSON="$("$CLI_DISCOVERY" --runner node --json 2>/dev/null || echo "")"
  if [ -n "$RUNNER_JSON" ]; then
    # Extract the script field (e.g., "pnpm dlx") — try jq, fall back to grep
    if command -v jq >/dev/null 2>&1; then
      PNPM_RUNNER="$(echo "$RUNNER_JSON" | jq -r '.script // empty' 2>/dev/null || echo "")"
    fi
    if [ -z "$PNPM_RUNNER" ]; then
      # Fallback: grep for "script" field
      PNPM_RUNNER="$(echo "$RUNNER_JSON" | grep -o '"script"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/' 2>/dev/null || echo "")"
    fi
  fi
fi

# Fallback: check for pnpm directly
if [ -z "$PNPM_RUNNER" ]; then
  if command -v pnpm >/dev/null 2>&1; then
    PNPM_RUNNER="pnpm dlx"
  elif command -v devbox >/dev/null 2>&1 && devbox run -- command -v pnpm >/dev/null 2>&1; then
    PNPM_RUNNER="devbox run -- pnpm dlx"
  else
    # pnpm not found — print body with on-disk version
    echo "refresh.sh: pnpm not found — using on-disk version" >&2
    echo "$TODAY" > "$DATE_FILE" 2>/dev/null || true
    print_body
  fi
fi

# --- 5. Detect existing nono session ---
# If already inside a nono session, the parent's per-tool policy handles
# sandboxing. Skip our sandbox layer and run the update directly.
ALREADY_SANDBOXED=0
if [ -n "${NONO_SESSION:-}" ]; then
  ALREADY_SANDBOXED=1
fi

# --- 6. Run update (sandboxed if available) ---
SANDBOX_CMD=""
NONO_PROFILE="$SKILL_DIR/references/nono-profile.json"

if [ "$ALREADY_SANDBOXED" -eq 0 ]; then
  # Use cli-tool-discovery to find nono through the full resolution chain
  # (devbox shell → devbox run → mise → nix → PATH → package managers).
  # This respects the devbox.json environment and the mandatory devbox rule
  # in skills-src AGENTS.md.
  if [ -x "$CLI_DISCOVERY" ]; then
    NONO_RESOLVE="$("$CLI_DISCOVERY" nono --json 2>/dev/null || echo "")"
    if [ -n "$NONO_RESOLVE" ]; then
      NONO_STATUS=""
      if command -v jq >/dev/null 2>&1; then
        NONO_STATUS="$(echo "$NONO_RESOLVE" | jq -r '.status // empty' 2>/dev/null || echo "")"
      fi
      if [ -z "$NONO_STATUS" ]; then
        NONO_STATUS="$(echo "$NONO_RESOLVE" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/' 2>/dev/null || echo "")"
      fi
      case "$NONO_STATUS" in
        found)
          SANDBOX_CMD="nono"
          ;;
        wrapper)
          # Extract wrapper command (e.g., "devbox run --")
          if command -v jq >/dev/null 2>&1; then
            NONO_WRAPPER="$(echo "$NONO_RESOLVE" | jq -r '.wrapper // empty' 2>/dev/null || echo "")"
          fi
          if [ -z "$NONO_WRAPPER" ]; then
            NONO_WRAPPER="$(echo "$NONO_RESOLVE" | grep -o '"wrapper"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\(.*\)"/\1/' 2>/dev/null || echo "")"
          fi
          SANDBOX_CMD="$NONO_WRAPPER nono"
          ;;
      esac
    fi
  fi
  # Fallback: bare command -v if cli-tool-discovery is unavailable
  if [ -z "$SANDBOX_CMD" ] && command -v nono >/dev/null 2>&1; then
    SANDBOX_CMD="nono"
  fi
fi

run_update() {
  if [ -n "$SANDBOX_CMD" ] && [ -f "$NONO_PROFILE" ]; then
    # Sandboxed update via nono with bundled profile
    # shellcheck disable=SC2086 — SANDBOX_CMD and PNPM_RUNNER are intentionally
    # unquoted: they may contain multi-word commands like "devbox run -- nono"
    # or "pnpm dlx" that must word-split into separate arguments.
    $SANDBOX_CMD run --profile "$NONO_PROFILE" -- \
      $PNPM_RUNNER skills update "$SKILL_NAME"
  else
    # Unsandboxed update:
    # - nono not installed, or
    # - already inside a nono session (parent handles it), or
    # - native Windows (no lightweight sandbox available)
    # The trust model treats levonk/skills-releases as a trusted source.
    # shellcheck disable=SC2086 — PNPM_RUNNER may be a multi-word command.
    $PNPM_RUNNER skills update "$SKILL_NAME"
  fi
}

# Run the update, write date regardless of outcome
run_update >&2 || true
echo "$TODAY" > "$DATE_FILE" 2>/dev/null || true

# --- 8. Print the (now current) body ---
print_body

