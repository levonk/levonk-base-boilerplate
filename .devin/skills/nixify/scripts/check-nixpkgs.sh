#!/usr/bin/env bash
# Check if a project or its dependencies are already in nixpkgs, and surface
# the version + platform-support gaps that justify a repo-owned flake even when
# nixpkgs already packages the project.
#
# Usage: check-nixpkgs.sh <project-name> [dependency1 dependency2 ...] [--verbose]
# Output: JSON with:
#   project_in_nixpkgs            — bool (existing field, backward compat)
#   dependencies_in_nixpkgs       — {dep: bool} (existing field, backward compat)
#   nixpkgs_version               — version string from nixpkgs-unstable (null if not found)
#   nixpkgs_platforms             — array of platforms from meta.platforms ([] if not found)
#   x86_64_darwin_in_meta         — bool: is x86_64-darwin declared in meta.platforms?
#   x86_64_darwin_installable     — bool: does nixpkgs-26.05-darwin actually build it?
#   nixpkgs_darwin_stable_version — version from nixpkgs-26.05-darwin (null if not installable)
#   nixpkgs_ref_used              — which ref succeeded for version ("unstable" | "darwin-stable" | null)
#
# The agent compares nixpkgs_version against the latest GitHub release (from
# check-releases.sh) and uses the platform fields to fill the "Relationship to
# nixpkgs" section of the issue/PR templates.
#
# Requires: nix (with flakes), jq, curl. Falls back gracefully if nix is absent
# (reports project_in_nixpkgs=false, version/platforms null/[]).

set -euo pipefail

PROJECT="${1:?Usage: check-nixpkgs.sh <project-name> [dependency1 dependency2 ...] [--verbose]}"
shift

DEPS=()
VERBOSE=""
if [ $# -ge 1 ] && [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
  shift
fi
# Remaining args are dependencies
DEPS=("$@")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Searching nixpkgs for: $PROJECT" >&2
fi

# --- Helpers -----------------------------------------------------------------

# eval_nixpkgs_version <ref> <pkg>
# Prints the version string (quoted) or returns non-zero.
eval_nixpkgs_version() {
  local ref="$1" pkg="$2"
  nix eval --system x86_64-linux "${ref}#${pkg}.version" 2>/dev/null
}

# eval_nixpkgs_platforms <ref> <pkg>
# Prints a JSON array of platforms or returns non-zero.
eval_nixpkgs_platforms() {
  local ref="$1" pkg="$2"
  nix eval --json --system x86_64-linux "${ref}#${pkg}.meta.platforms" 2>/dev/null
}

# --- Project check -----------------------------------------------------------

# Values are kept as JSON literals (null or "x.y.z" quoted) so they can be
# passed directly to jq --argjson. nix eval prints version as a JSON string
# ("1.19.0"); we keep that form rather than stripping quotes.
NIXPKGS_VERSION="null"
NIXPKGS_PLATFORMS="[]"
NIXPKGS_REF_USED="null"  # JSON null; becomes "unstable" or "darwin-stable" (quoted) on success
PROJECT_IN_NIXPKGS=false

# Primary: nixpkgs-unstable (the channel most users get). --system x86_64-linux
# avoids the x86_64-darwin top-level throw on unstable; the "ignoring restricted
# setting" warning is benign — the flag still takes effect on Determinate Nix
# and standard Nix.
VERSION_RAW=""
if command -v nix >/dev/null 2>&1; then
  if VERSION_RAW=$(eval_nixpkgs_version "nixpkgs" "$PROJECT"); then
    NIXPKGS_VERSION="$VERSION_RAW"
    NIXPKGS_REF_USED='"unstable"'
    PROJECT_IN_NIXPKGS=true
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "Found in nixpkgs-unstable: $(printf '%s' "$VERSION_RAW" | jq -r .)" >&2
    fi
  fi
fi

# Fallback: nixpkgs-26.05-darwin (stable darwin channel; works on all hosts
# because it doesn't carry the x86_64-darwin deprecation throw). This is the
# realistic install path for x86_64-darwin users.
DARWIN_STABLE_REF="github:NixOS/nixpkgs/nixpkgs-26.05-darwin"
if [ "$PROJECT_IN_NIXPKGS" = false ] && command -v nix >/dev/null 2>&1; then
  if VERSION_RAW=$(eval_nixpkgs_version "$DARWIN_STABLE_REF" "$PROJECT"); then
    NIXPKGS_VERSION="$VERSION_RAW"
    NIXPKGS_REF_USED='"darwin-stable"'
    PROJECT_IN_NIXPKGS=true
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "Found in nixpkgs-26.05-darwin: $(printf '%s' "$VERSION_RAW" | jq -r .)" >&2
    fi
  fi
fi

# Platforms: only meaningful if we found the project. Use the same ref that
# succeeded for version; if unstable succeeded, prefer it (most current).
X86_64_DARWIN_IN_META=false
if [ "$PROJECT_IN_NIXPKGS" = true ] && command -v nix >/dev/null 2>&1; then
  PLATFORMS_REF="nixpkgs"
  if [ "$NIXPKGS_REF_USED" = "darwin-stable" ]; then
    PLATFORMS_REF="github:NixOS/nixpkgs/nixpkgs-26.05-darwin"
  fi
  if PLATFORMS_RAW=$(eval_nixpkgs_platforms "$PLATFORMS_REF" "$PROJECT"); then
    NIXPKGS_PLATFORMS="$PLATFORMS_RAW"
    if printf '%s' "$PLATFORMS_RAW" | jq -e 'index("x86_64-darwin")' >/dev/null 2>&1; then
      X86_64_DARWIN_IN_META=true
    fi
  fi
fi

# x86_64-darwin install probe: does nixpkgs-26.05-darwin actually build it?
# This catches the case where meta.platforms doesn't list x86_64-darwin but the
# stable darwin channel still ships it (common for Rust/Go packages), AND the
# case where meta.platforms lists it but it's broken on the stable channel.
X86_64_DARWIN_INSTALLABLE=false
NIXPKGS_DARWIN_STABLE_VERSION="null"
if [ "$PROJECT_IN_NIXPKGS" = true ] && command -v nix >/dev/null 2>&1; then
  if DARWIN_VER=$(nix eval "${DARWIN_STABLE_REF}#${PROJECT}.version" 2>/dev/null); then
    X86_64_DARWIN_INSTALLABLE=true
    NIXPKGS_DARWIN_STABLE_VERSION="$DARWIN_VER"
  fi
fi

# --- Dependencies check (existing behavior, preserved) -----------------------

DEPS_JSON="{}"
for dep in "${DEPS[@]:-}"; do
  [ -z "$dep" ] && continue
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "Searching nixpkgs for dependency: $dep" >&2
  fi
  DEP_FOUND=false
  if command -v nix >/dev/null 2>&1; then
    if nix eval --system x86_64-linux "nixpkgs#${dep}.version" >/dev/null 2>&1 \
      || nix eval "${DARWIN_STABLE_REF}#${dep}.version" >/dev/null 2>&1; then
      DEP_FOUND=true
    fi
  fi
  DEPS_JSON=$(echo "$DEPS_JSON" | jq --arg dep "$dep" --argjson found "$DEP_FOUND" '. + {($dep): $found}')
done

# --- Output ------------------------------------------------------------------

jq -n \
  --argjson project_in_nixpkgs "$PROJECT_IN_NIXPKGS" \
  --argjson dependencies_in_nixpkgs "$DEPS_JSON" \
  --argjson nixpkgs_version "$NIXPKGS_VERSION" \
  --argjson nixpkgs_platforms "$NIXPKGS_PLATFORMS" \
  --argjson x86_64_darwin_in_meta "$X86_64_DARWIN_IN_META" \
  --argjson x86_64_darwin_installable "$X86_64_DARWIN_INSTALLABLE" \
  --argjson nixpkgs_darwin_stable_version "$NIXPKGS_DARWIN_STABLE_VERSION" \
  --argjson nixpkgs_ref_used "$NIXPKGS_REF_USED" \
  '{project_in_nixpkgs: $project_in_nixpkgs,
    dependencies_in_nixpkgs: $dependencies_in_nixpkgs,
    nixpkgs_version: $nixpkgs_version,
    nixpkgs_platforms: $nixpkgs_platforms,
    x86_64_darwin_in_meta: $x86_64_darwin_in_meta,
    x86_64_darwin_installable: $x86_64_darwin_installable,
    nixpkgs_darwin_stable_version: $nixpkgs_darwin_stable_version,
    nixpkgs_ref_used: $nixpkgs_ref_used}'
