#!/usr/bin/env bash
# classify-node-complexity.sh — deterministically detect Node.js build complexity
# Usage: classify-node-complexity.sh [project-dir] [--verbose]
#
# Detects the four complexity factors that distinguish a "simple" Node.js
# project (use source-build/node.md → buildNpmPackage) from a "complex" one
# (use source-build/node-complex.md → stdenv.mkDerivation + fetchNpmDeps):
#
#   1. monorepo_separate_lockfiles — subdirectories with their own package.json
#   2. custom_build_scripts — build script does more than a standard command
#   3. postinstall_complications — native addons or postinstall home-dir writes
#   4. build_time_network_fetches — next/font/google, telemetry, curl in build
#
# Output: JSON with:
#   - language:                   "node" (always, for this script)
#   - complexity_factors:         array of detected factor names (may be empty)
#   - recommended_template:       "source-build/node.md" or "source-build/node-complex.md"
#   - is_complex:                 true if any complexity factor is detected
#   - signals:                    array of { factor, signal, source, detail }
#   - needs_subagent_validation:  true if non-deterministic checks are required
#   - subagent_checks:            array of strings describing what the subagent must verify
#   - rationale:                  short human-readable summary
#
# The script is conservative: it only reports a factor when it finds a
# concrete signal in the repo. A factor with no signal is not reported.
# When is_complex=true, the agent MUST use node-complex.md. When
# is_complex=false, the agent MAY use node.md but should still review
# the subagent_checks list for factors the script cannot detect
# deterministically (needs_subagent_validation=true).
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

signals_file=$(mktemp)
trap 'rm -f "$signals_file"' EXIT

# Format: factor|signal|source|detail
add_signal() {
  echo "$1|$2|$3|$4" >> "$signals_file"
}

# ── 1. Monorepo with separate lockfiles ──────────────────────────────────────
# Detect subdirectories that have their own package.json (not just
# node_modules). Common patterns: cli/, packages/*/, apps/*/, server/.
# A root package.json with workspaces does NOT count as "separate lockfiles"
# unless the subdirectory also has its own package.json file.
monorepo_found=0

# Find package.json files at depth 2 (not root, not deeply nested)
while IFS= read -r pkgjson; do
  # Skip node_modules, .next, dist, build, .git
  case "$pkgjson" in
    */node_modules/*) continue ;;
    */.next/*) continue ;;
    */dist/*) continue ;;
    */build/*) continue ;;
    */.git/*) continue ;;
  esac
  sub_dir=$(dirname "$pkgjson")
  sub_name=$(basename "$sub_dir")
  # Only consider direct subdirectories (depth 1 from root)
  if [ "$sub_dir" != "$DIR" ] && [ "$(dirname "$sub_dir")" = "$DIR" ]; then
    add_signal "monorepo_separate_lockfiles" "subdirectory package.json" "$pkgjson" "$sub_name/ has its own package.json"
    monorepo_found=1
  fi
done < <(find "$DIR" -maxdepth 2 -name "package.json" -not -path "*/node_modules/*" 2>/dev/null || true)

if [ "$monorepo_found" -eq 0 ]; then
  # Also check for npm/pnpm workspaces in root package.json
  root_pkg="$DIR/package.json"
  if [ -f "$root_pkg" ]; then
    if grep -qE '"workspaces"\s*:' "$root_pkg" 2>/dev/null; then
      # Workspaces declared — check if workspace dirs have their own package.json
      # Use grep -oE on the entire file (handles single-line JSON)
      # Workspace patterns like "packages/*" mean subdirs of packages/, not
      # packages/ itself — find one level deeper.
      workspace_dirs=$(grep -oE '"[a-z][a-z0-9_-]*/\*"' "$root_pkg" 2>/dev/null | tr -d '"* ' || true)
      for ws in $workspace_dirs; do
        ws_dir="$DIR/${ws%/}"
        if [ -d "$ws_dir" ]; then
          # Look for package.json in immediate subdirectories of the workspace dir
          ws_pkg=$(find "$ws_dir" -mindepth 2 -maxdepth 2 -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | head -1 || true)
          if [ -n "$ws_pkg" ]; then
            add_signal "monorepo_separate_lockfiles" "workspace package.json" "$ws_pkg" "npm workspace $ws has its own package.json"
            monorepo_found=1
            break
          fi
        fi
      done
    fi
  fi
fi

# ── 2. Custom build scripts ──────────────────────────────────────────────────
# A "custom build script" is one that does more than a standard single
# command (next build, tsc, vite build, webpack, rollup). We detect:
#   - build script that references a .js/.mjs/.ts file in scripts/ or build/
#   - build script with multiple commands (&& chains with copy/move/bundle)
#   - build script that calls esbuild, bundle, copy, mkdir, cp, mv
custom_build_found=0
root_pkg="$DIR/package.json"

if [ -f "$root_pkg" ]; then
  # Extract the "build" script value
  build_script=$(grep -E '"build"\s*:' "$root_pkg" 2>/dev/null | sed -E 's/.*"build"\s*:\s*"([^"]*)".*/\1/' || true)

  if [ -n "$build_script" ]; then
    # Check for references to custom script files
    if echo "$build_script" | grep -qE 'scripts/|build/|\.js|\.mjs|\.ts'; then
      add_signal "custom_build_scripts" "build script references custom file" "$root_pkg" "build: $build_script"
      custom_build_found=1
    fi
    # Check for multi-step commands with copy/bundle/mkdir
    if echo "$build_script" | grep -qiE 'esbuild|bundle|&&.*(cp |mkdir |mv |copy |rsync )'; then
      add_signal "custom_build_scripts" "build script has multi-step commands" "$root_pkg" "build: $build_script"
      custom_build_found=1
    fi
    # Check for cli:pack or similar wrapper build scripts
    for script_name in cli:pack cli:build prebuild postbuild; do
      if grep -qE "\"$script_name\"\s*:" "$root_pkg" 2>/dev/null; then
        add_signal "custom_build_scripts" "wrapper build script present" "$root_pkg" "has $script_name script"
        custom_build_found=1
      fi
    done
  fi
fi

# ── 3. Postinstall complications ─────────────────────────────────────────────
# Detect packages known to have postinstall scripts that write outside the
# build tree or compile native addons.
postinstall_found=0

# Known offenders that cause Nix sandbox issues
KNOWN_OFFENDERS="better-sqlite3|systray|@systray|node-sass|sharp|@swc/core|esbuild|node-gyp|prebuild-install|node-pre-gyp"

if [ -f "$root_pkg" ]; then
  # Grep the entire package.json content — works for both single-line and
  # multi-line JSON. We search for "depname" as a key (with quotes) to avoid
  # matching it in other string values.
  pkg_content=$(cat "$root_pkg" 2>/dev/null || true)

  for offender in $(echo "$KNOWN_OFFENDERS" | tr '|' ' '); do
    if echo "$pkg_content" | grep -q "\"$offender\""; then
      add_signal "postinstall_complications" "known native addon dependency" "$root_pkg" "depends on $offender"
      postinstall_found=1
    fi
  done

  # Check for explicit postinstall script
  if echo "$pkg_content" | grep -qE '"postinstall"\s*:' 2>/dev/null; then
    postinstall_val=$(echo "$pkg_content" | grep -oE '"postinstall"\s*:\s*"[^"]*"' | sed -E 's/.*"postinstall"\s*:\s*"([^"]*)".*/\1/' | head -1 || true)
    add_signal "postinstall_complications" "postinstall script in package.json" "$root_pkg" "postinstall: $postinstall_val"
    postinstall_found=1
  fi
fi

# ── 4. Build-time network fetches ────────────────────────────────────────────
# Detect next/font/google, telemetry config, and curl/wget in build scripts.
network_fetch_found=0

# next/font/google — scan source files
next_font_hits=$(grep -rl "next/font/google" "$DIR" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | grep -v node_modules | head -5 || true)
if [ -n "$next_font_hits" ]; then
  first_hit=$(echo "$next_font_hits" | head -1)
  add_signal "build_time_network_fetches" "next/font/google import" "$first_hit" "Google Fonts fetch at build time"
  network_fetch_found=1
fi

# Next.js telemetry (NEXT_TELEMETRY) — check for next.config with telemetry
if [ -f "$DIR/next.config.mjs" ] || [ -f "$DIR/next.config.js" ] || [ -f "$DIR/next.config.ts" ]; then
  # Next.js projects always have telemetry unless disabled — flag it
  add_signal "build_time_network_fetches" "Next.js telemetry" "next.config.*" "Next.js may make telemetry network call during build"
  network_fetch_found=1
fi

# curl/wget in build scripts or scripts/ directory
if [ -f "$root_pkg" ]; then
  build_related=$(grep -E '"(build|prebuild|postbuild|prepare)"\s*:' "$root_pkg" 2>/dev/null || true)
  if echo "$build_related" | grep -qiE 'curl |wget '; then
    add_signal "build_time_network_fetches" "curl/wget in build script" "$root_pkg" "build script fetches from network"
    network_fetch_found=1
  fi
fi

# scripts/ directory with curl/wget
if [ -d "$DIR/scripts" ]; then
  curl_hits=$(grep -rlE 'curl |wget ' "$DIR/scripts" --include="*.js" --include="*.sh" --include="*.mjs" 2>/dev/null | head -3 || true)
  if [ -n "$curl_hits" ]; then
    first_hit=$(echo "$curl_hits" | head -1)
    add_signal "build_time_network_fetches" "curl/wget in scripts/" "$first_hit" "build helper script fetches from network"
    network_fetch_found=1
  fi
fi

# ── Aggregate ────────────────────────────────────────────────────────────────

# Build complexity_factors array
factors=""
factor_count=0
if [ "$monorepo_found" -eq 1 ]; then
  factors="\"monorepo_separate_lockfiles\""
  factor_count=$((factor_count + 1))
fi
if [ "$custom_build_found" -eq 1 ]; then
  if [ "$factor_count" -gt 0 ]; then factors="$factors,"; fi
  factors="$factors\"custom_build_scripts\""
  factor_count=$((factor_count + 1))
fi
if [ "$postinstall_found" -eq 1 ]; then
  if [ "$factor_count" -gt 0 ]; then factors="$factors,"; fi
  factors="$factors\"postinstall_complications\""
  factor_count=$((factor_count + 1))
fi
if [ "$network_fetch_found" -eq 1 ]; then
  if [ "$factor_count" -gt 0 ]; then factors="$factors,"; fi
  factors="$factors\"build_time_network_fetches\""
  factor_count=$((factor_count + 1))
fi

is_complex="false"
recommended_template="source-build/node.md"
if [ "$factor_count" -gt 0 ]; then
  is_complex="true"
  recommended_template="source-build/node-complex.md"
fi

# Build signals JSON array
signals_json="[]"
if [ -s "$signals_file" ]; then
  signals_json="["
  first=1
  while IFS='|' read -r factor signal source detail; do
    if [ "$first" -eq 0 ]; then signals_json="$signals_json,"; fi
    first=0
    # Escape detail for JSON (basic: replace " with \")
    detail_esc="${detail//\"/\\\"}"
    signals_json="$signals_json{\"factor\":\"$factor\",\"signal\":\"$signal\",\"source\":\"$source\",\"detail\":\"$detail_esc\"}"
  done < "$signals_file"
  signals_json="$signals_json]"
fi

# Subagent checks — non-deterministic things the script cannot decide
needs_subagent="false"
subagent_checks="[]"
if [ "$factor_count" -gt 0 ]; then
  needs_subagent="true"
  subagent_checks="["
  sub_first=1

  if [ "$custom_build_found" -eq 1 ]; then
    if [ "$sub_first" -eq 0 ]; then subagent_checks="$subagent_checks,"; fi
    sub_first=0
    subagent_checks="$subagent_checks\"Verify the custom build script is compatible with npm ci --offline + npm run build in a sandbox (no network, read-only store). Check if the build script copies files or bundles that would need manual replication in installPhase.\""
  fi

  if [ "$postinstall_found" -eq 1 ]; then
    if [ "$sub_first" -eq 0 ]; then subagent_checks="$subagent_checks,"; fi
    sub_first=0
    subagent_checks="$subagent_checks\"Verify the project has a runtime fallback when postinstall assets are absent (e.g. better-sqlite3 → sql.js). If no fallback exists, the from-source build will produce a binary that crashes at runtime.\""
  fi

  if [ "$network_fetch_found" -eq 1 ]; then
    if [ "$sub_first" -eq 0 ]; then subagent_checks="$subagent_checks,"; fi
    sub_first=0
    subagent_checks="$subagent_checks\"Verify the build-time network fetch can be neutralized via postPatch without breaking the build output. Confirm the Docker/npm build path is not affected.\""
  fi

  if [ "$monorepo_found" -eq 1 ]; then
    if [ "$sub_first" -eq 0 ]; then subagent_checks="$subagent_checks,"; fi
    sub_first=0
    subagent_checks="$subagent_checks\"Verify which subdirectory's build script drives the full build (e.g. cli/ build that runs next build + copies standalone). The entry point for makeWrapper should be the CLI launcher, not the raw server.\""
  fi

  subagent_checks="$subagent_checks]"
fi

# Rationale
if [ "$factor_count" -eq 0 ]; then
  rationale="No complexity factors detected. Project appears to be a simple single-package Node.js project. Use buildNpmPackage (source-build/node.md)."
else
  rationale="Detected $factor_count complexity factor(s): $(echo "$factors" | tr -d '"'). Use stdenv.mkDerivation + fetchNpmDeps (source-build/node-complex.md). Subagent validation required for non-deterministic checks."
fi

# Output JSON
cat <<EOF
{
  "language": "node",
  "complexity_factors": [$factors],
  "recommended_template": "$recommended_template",
  "is_complex": $is_complex,
  "signals": $signals_json,
  "needs_subagent_validation": $needs_subagent,
  "subagent_checks": $subagent_checks,
  "rationale": "$rationale"
}
EOF

if [ -n "$VERBOSE" ]; then
  echo "---" >&2
  echo "Scan details:" >&2
  echo "  monorepo_separate_lockfiles: $monorepo_found" >&2
  echo "  custom_build_scripts: $custom_build_found" >&2
  echo "  postinstall_complications: $postinstall_found" >&2
  echo "  build_time_network_fetches: $network_fetch_found" >&2
  echo "  factor_count: $factor_count" >&2
  echo "  is_complex: $is_complex" >&2
  if [ -s "$signals_file" ]; then
    echo "  signals:" >&2
    while IFS='|' read -r factor signal source detail; do
      echo "    - $factor: $signal ($source) — $detail" >&2
    done < "$signals_file"
  fi
fi
