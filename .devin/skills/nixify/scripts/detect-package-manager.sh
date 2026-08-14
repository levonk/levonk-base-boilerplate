#!/usr/bin/env bash
# detect-package-manager.sh — detect the JS package manager from lockfile presence
# Usage: detect-package-manager.sh [project-dir] [--verbose]
#
# Detects which package manager a Node.js project uses by checking for
# lockfiles in priority order. This prevents the failure mode where a flake
# or devbox template hardcodes pnpm but the project uses npm (package-lock.json),
# or vice versa. See OmniRoute PR #2806 — the initial flake used pnpm install
# but the project uses npm, requiring a fix-up commit.
#
# Detection priority (first match wins):
#   1. bun.lock      → bun
#   2. bun.lockb     → bun
#   3. pnpm-lock.yaml → pnpm
#   4. yarn.lock     → yarn
#   5. package-lock.json → npm
#
# If no lockfile is found, falls back to package.json#packageManager field
# (if present), then to npm as the default.
#
# Output: JSON with:
#   - package_manager:  "npm" | "pnpm" | "yarn" | "bun"
#   - lockfile:         the lockfile filename that was found (or null)
#   - install_cmd:      the install command (e.g. "npm install")
#   - build_cmd:        the build command prefix (e.g. "npm run build")
#   - test_cmd:         the test command prefix (e.g. "npm test")
#   - dev_cmd:          the dev command prefix (e.g. "npm run dev")
#   - devbox_package:   the nix package to add to devbox for this PM (or null for npm)
#   - nix_builder:      the Nix builder function (buildNpmPackage | buildPnpmPackage | buildYarnPackage | bun)
#   - source:           "lockfile" | "packageManager-field" | "default"
#   - confidence:       "high" (lockfile found) | "medium" (packageManager field) | "low" (default)
#
# Use --verbose for full scan details.

set -euo pipefail

DIR="${1:-.}"
VERBOSE=""
if [ "${2:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
fi

if [ ! -d "$DIR" ]; then
  echo "error: directory '$DIR' not found" >&2
  exit 1
fi

# ── Helper: emit JSON ────────────────────────────────────────────────────────
emit_json() {
  local pm="$1" lockfile="$2" install="$3" build="$4" test="$5" dev="$6"
  local devbox_pkg="$7" nix_builder="$8" source="$9" confidence="${10}"

  # Build JSON-safe values for nullable fields
  local lockfile_json devbox_json
  if [ -n "$lockfile" ]; then
    lockfile_json="\"$lockfile\""
  else
    lockfile_json="null"
  fi
  if [ -n "$devbox_pkg" ] && [ "$devbox_pkg" != "null" ]; then
    devbox_json="\"$devbox_pkg\""
  else
    devbox_json="null"
  fi

  cat <<EOF
{
  "package_manager": "$pm",
  "lockfile": $lockfile_json,
  "install_cmd": "$install",
  "build_cmd": "$build",
  "test_cmd": "$test",
  "dev_cmd": "$dev",
  "devbox_package": $devbox_json,
  "nix_builder": "$nix_builder",
  "source": "$source",
  "confidence": "$confidence"
}
EOF
}

# ── 1. Check lockfiles (high confidence) ────────────────────────────────────
if [ -f "$DIR/bun.lock" ] || [ -f "$DIR/bun.lockb" ]; then
  lockfile=""
  [ -f "$DIR/bun.lock" ] && lockfile="bun.lock"
  [ -f "$DIR/bun.lockb" ] && lockfile="bun.lockb"
  [ -n "$VERBOSE" ] && echo "  detected: bun (lockfile: $lockfile)" >&2
  emit_json "bun" "$lockfile" "bun install" "bun run build" "bun test" "bun run dev" \
    "bun" "bun" "lockfile" "high"
  exit 0
fi

if [ -f "$DIR/pnpm-lock.yaml" ]; then
  [ -n "$VERBOSE" ] && echo "  detected: pnpm (lockfile: pnpm-lock.yaml)" >&2
  emit_json "pnpm" "pnpm-lock.yaml" "pnpm install" "pnpm build" "pnpm test" "pnpm dev" \
    "pnpm" "buildPnpmPackage" "lockfile" "high"
  exit 0
fi

if [ -f "$DIR/yarn.lock" ]; then
  [ -n "$VERBOSE" ] && echo "  detected: yarn (lockfile: yarn.lock)" >&2
  emit_json "yarn" "yarn.lock" "yarn install" "yarn build" "yarn test" "yarn dev" \
    "yarn" "buildYarnPackage" "lockfile" "high"
  exit 0
fi

if [ -f "$DIR/package-lock.json" ]; then
  [ -n "$VERBOSE" ] && echo "  detected: npm (lockfile: package-lock.json)" >&2
  emit_json "npm" "package-lock.json" "npm install" "npm run build" "npm test" "npm run dev" \
    "null" "buildNpmPackage" "lockfile" "high"
  exit 0
fi

# ── 2. Check package.json#packageManager field (medium confidence) ──────────
pkg_json="$DIR/package.json"
if [ -f "$pkg_json" ]; then
  pm_field=$(grep -oE '"packageManager"\s*:\s*"[^"]*"' "$pkg_json" 2>/dev/null | \
    sed -E 's/.*"packageManager"\s*:\s*"([^"]*)".*/\1/' || true)
  if [ -n "$pm_field" ]; then
    # packageManager field format: "pnpm@9.15.0", "npm@10.2.3", "yarn@4.0.0", "bun@1.3.11"
    case "$pm_field" in
      pnpm@*)
        [ -n "$VERBOSE" ] && echo "  detected: pnpm (packageManager: $pm_field)" >&2
        emit_json "pnpm" "" "pnpm install" "pnpm build" "pnpm test" "pnpm dev" \
          "pnpm" "buildPnpmPackage" "packageManager-field" "medium"
        exit 0
        ;;
      yarn@*)
        [ -n "$VERBOSE" ] && echo "  detected: yarn (packageManager: $pm_field)" >&2
        emit_json "yarn" "" "yarn install" "yarn build" "yarn test" "yarn dev" \
          "yarn" "buildYarnPackage" "packageManager-field" "medium"
        exit 0
        ;;
      bun@*)
        [ -n "$VERBOSE" ] && echo "  detected: bun (packageManager: $pm_field)" >&2
        emit_json "bun" "" "bun install" "bun run build" "bun test" "bun run dev" \
          "bun" "bun" "packageManager-field" "medium"
        exit 0
        ;;
      npm@*)
        [ -n "$VERBOSE" ] && echo "  detected: npm (packageManager: $pm_field)" >&2
        emit_json "npm" "" "npm install" "npm run build" "npm test" "npm run dev" \
          "null" "buildNpmPackage" "packageManager-field" "medium"
        exit 0
        ;;
    esac
  fi
fi

# ── 3. Default: npm (low confidence — no lockfile, no packageManager field) ─
[ -n "$VERBOSE" ] && echo "  detected: npm (default — no lockfile or packageManager field found)" >&2
emit_json "npm" "" "npm install" "npm run build" "npm test" "npm run dev" \
  "null" "buildNpmPackage" "default" "low"
