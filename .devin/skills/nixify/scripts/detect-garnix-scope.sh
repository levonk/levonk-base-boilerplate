#!/usr/bin/env bash
# Generate a garnix.yaml configured for the project's target platforms.
# Usage: detect-garnix-scope.sh [project-dir] --target-platforms '<json>' --flake-type <type> [--output <path>]
#
# Garnix (https://garnix.io) is a hosted CI service for Nix flake repos.
# After the maintainer installs the Garnix GitHub App, every push builds all
# flake outputs and reports checks back to GitHub. This script generates the
# garnix.yaml that configures which outputs Garnix builds.
#
# The script takes the target_platforms JSON from Step 4a (detect-platform-scope.sh)
# and the flake_type from Step 12, and emits a garnix.yaml with:
#   - builds.include scoped to the project's target_platforms (not Garnix's
#     linux-only default — Mac and ARM-linux are opt-in)
#   - fodChecks: true when the flake has FOD outputs (source-build and
#     prebuilt-tarball flakes with a #source output)
#
# The maintainer-opt-in constraint: the contributor cannot install the Garnix
# GitHub App on a repo they don't own. The garnix.yaml is inert until the
# maintainer enables the app — no side effects, no broken checks. See
# references/advanced-features.md — Garnix CI (Hosted Alternative).
#
# Output:
#   - If --output is given: writes garnix.yaml to that path, prints JSON status
#   - If --output is omitted: prints garnix.yaml to stdout
#   - JSON status (when --output is used):
#     {
#       "generated": true,
#       "path": "<output-path>",
#       "platform_scope": "all|darwin_only|linux_only",
#       "target_platforms": [...],
#       "fod_checks": true|false,
#       "include_systems": [...]
#     }
#
# Exit codes:
#   0 — garnix.yaml generated successfully
#   1 — invalid arguments or missing prerequisites

set -euo pipefail

DIR="."
TARGET_PLATFORMS=""
FLAKE_TYPE=""
OUTPUT=""
VERBOSE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --target-platforms) TARGET_PLATFORMS="$2"; shift 2 ;;
    --flake-type)       FLAKE_TYPE="$2"; shift 2 ;;
    --output)           OUTPUT="$2"; shift 2 ;;
    --verbose)          VERBOSE="--verbose"; shift ;;
    -h|--help)
      echo "Usage: $0 [project-dir] --target-platforms '<json>' --flake-type <type> [--output <path>]"
      echo ""
      echo "Generates a garnix.yaml scoped to the project's target platforms."
      echo ""
      echo "Required:"
      echo "  --target-platforms '<json>'  JSON array from detect-platform-scope.sh (Step 4a)"
      echo "  --flake-type <type>          'source_build' or 'prebuilt_tarball' (Step 12)"
      echo ""
      echo "Optional:"
      echo "  --output <path>              Write garnix.yaml to this path (default: <project-dir>/garnix.yaml)"
      echo "  --verbose                    Print details to stderr"
      exit 0
      ;;
    *) DIR="$1"; shift ;;
  esac
done

if [ -z "$TARGET_PLATFORMS" ]; then
  echo "error: --target-platforms is required (pass the JSON from detect-platform-scope.sh)" >&2
  exit 1
fi

if [ -z "$FLAKE_TYPE" ]; then
  echo "error: --flake-type is required ('source_build' or 'prebuilt_tarball')" >&2
  exit 1
fi

# ── Parse target_platforms JSON ──────────────────────────────────────────────
# Extract individual platform strings from the JSON array.
# Expected input: ["x86_64-linux","aarch64-darwin",...]
# We use jq if available, fall back to grep/sed for minimal parsing.
parse_platforms() {
  local json="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$json" | jq -r '.[]' 2>/dev/null || true
  else
    # Minimal fallback: extract quoted strings from the JSON array
    echo "$json" | grep -oE '"[^"]*"' | tr -d '"' || true
  fi
}

# Determine platform_scope from target_platforms
detect_scope() {
  local platforms="$1"
  local has_linux=0
  local has_darwin=0

  for p in $platforms; do
    case "$p" in
      *-linux)  has_linux=1 ;;
      *-darwin) has_darwin=1 ;;
    esac
  done

  if [ "$has_linux" -eq 1 ] && [ "$has_darwin" -eq 0 ]; then
    echo "linux_only"
  elif [ "$has_linux" -eq 0 ] && [ "$has_darwin" -eq 1 ]; then
    echo "darwin_only"
  else
    echo "all"
  fi
}

# Generate the builds.include entries from target_platforms
generate_includes() {
  local platforms="$1"
  for p in $platforms; do
    echo "    - '*.${p}.*'"
  done
}

# Determine whether to enable fodChecks
# Source-build flakes always have FODs (fetchurl, fetchNpmDeps, bun2nix, etc.)
# Prebuilt tarball flakes have FODs in the #source output (if it exists)
should_enable_fod_checks() {
  local flake_type="$1"
  case "$flake_type" in
    source_build|prebuilt_tarball) echo "true" ;;
    nixpkgs_wrapper) echo "false" ;;
    *) echo "true" ;;  # conservative default — enable for unknown types
  esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

PLATFORMS=$(parse_platforms "$TARGET_PLATFORMS")
if [ -z "$PLATFORMS" ]; then
  echo "error: no platforms parsed from --target-platforms '$TARGET_PLATFORMS'" >&2
  exit 1
fi

PLATFORM_SCOPE=$(detect_scope "$PLATFORMS")
FOD_CHECKS=$(should_enable_fod_checks "$FLAKE_TYPE")
INCLUDES=$(generate_includes "$PLATFORMS")

if [ -n "$VERBOSE" ]; then
  echo "[detect-garnix-scope] target_platforms: $TARGET_PLATFORMS" >&2
  echo "[detect-garnix-scope] platform_scope: $PLATFORM_SCOPE" >&2
  echo "[detect-garnix-scope] flake_type: $FLAKE_TYPE" >&2
  echo "[detect-garnix-scope] fod_checks: $FOD_CHECKS" >&2
fi

# Build the garnix.yaml content
GARNIX_YAML="builds:
  exclude: []
  include:
${INCLUDES}
fodChecks: ${FOD_CHECKS}
"

# Collect the include systems for JSON status output
INCLUDE_SYSTEMS=$(echo "$PLATFORMS" | tr '\n' ',' | sed 's/,$//' | sed 's/,/","/g' | sed 's/^/"/;s/$/"/')

if [ -n "$OUTPUT" ]; then
  mkdir -p "$(dirname "$OUTPUT")"
  printf '%s\n' "$GARNIX_YAML" > "$OUTPUT"
  echo "{\"generated\":true,\"path\":\"$OUTPUT\",\"platform_scope\":\"$PLATFORM_SCOPE\",\"target_platforms\":[$INCLUDE_SYSTEMS],\"fod_checks\":$FOD_CHECKS,\"include_systems\":[$INCLUDE_SYSTEMS]}"
else
  # Default output path: <project-dir>/garnix.yaml
  OUTPUT="${DIR}/garnix.yaml"
  mkdir -p "$(dirname "$OUTPUT")"
  printf '%s\n' "$GARNIX_YAML" > "$OUTPUT"
  echo "{\"generated\":true,\"path\":\"$OUTPUT\",\"platform_scope\":\"$PLATFORM_SCOPE\",\"target_platforms\":[$INCLUDE_SYSTEMS],\"fod_checks\":$FOD_CHECKS,\"include_systems\":[$INCLUDE_SYSTEMS]}"
fi
