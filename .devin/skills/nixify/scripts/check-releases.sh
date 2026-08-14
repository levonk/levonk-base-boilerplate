#!/usr/bin/env bash
# Check for prebuilt release tarballs and GitHub binary releases
# Usage: check-releases.sh <owner> <repo> [target_platforms_json] [--verbose]
#   target_platforms_json: optional JSON array of Nix systems to scope coverage
#     against (e.g. '["x86_64-darwin","aarch64-darwin"]'). When omitted, the
#     default 4-system set is used. Pass this from detect-platform-scope.sh
#     output so partial_platform_coverage is computed relative to the project's
#     inherent platform scope, not the full 4-system set.
# Output: JSON with has_tarballs, has_binary_releases, asset_names,
#         platform_coverage (per-system prebuilt asset presence),
#         partial_platform_coverage (true when some but not all target
#         systems have a prebuilt asset), latest_release (version tag),
#         target_platforms (the scope the coverage was computed against)
# Use --verbose for full API responses

set -euo pipefail

OWNER="${1:?Usage: check-releases.sh <owner> <repo> [target_platforms_json] [--verbose]}"
REPO="${2:?Usage: check-releases.sh <owner> <repo> [target_platforms_json] [--verbose]}"
TARGET_PLATFORMS_JSON="${3:-}"
VERBOSE=""
if [ "${3:-}" = "--verbose" ] || [ "${4:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
fi

# Default to the full 4-system set when no target_platforms is provided.
if [ -z "$TARGET_PLATFORMS_JSON" ] || [ "$TARGET_PLATFORMS_JSON" = "--verbose" ]; then
  TARGET_PLATFORMS_JSON='["x86_64-linux","aarch64-linux","x86_64-darwin","aarch64-darwin"]'
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Checking releases for $OWNER/$REPO..."
fi

RELEASES_JSON=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Releases JSON (first 200 chars): ${RELEASES_JSON:0:200}"
fi

ASSETS=$(echo "$RELEASES_JSON" | jq -r '.[].assets[].name' 2>/dev/null || echo "")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "All assets: $ASSETS"
fi

# Check for tarball patterns
TARBALLS=$(echo "$ASSETS" | grep -iE '\.(tar\.gz|tar\.bz2|tar\.xz|tgz)$' || echo "")
HAS_TARBALLS=false
if [ -n "$TARBALLS" ]; then
  HAS_TARBALLS=true
fi

# Check for platform-specific binary patterns
PLATFORM_BINS=$(echo "$ASSETS" | grep -iE '(linux|darwin|windows|musl|macos|arm64|x86_64|aarch64)' || echo "")
HAS_BINARY_RELEASES=false
if [ -n "$PLATFORM_BINS" ]; then
  HAS_BINARY_RELEASES=true
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Has tarballs: $HAS_TARBALLS"
  echo "Has binary releases: $HAS_BINARY_RELEASES"
fi

# Format asset names as JSON array
ASSET_JSON=$(echo "$ASSETS" | jq -R . | jq -s . 2>/dev/null || echo "[]")

# Detect per-platform prebuilt asset coverage.
# Maps each of the 4 Nix target systems to true/false based on whether a
# release asset filename matches that platform's naming patterns. This is
# the data the agent cross-references against the 4-system target set to
# detect partial platform coverage (some platforms have prebuilt binaries,
# others don't — the hybrid fallback template handles this case).
#
# Matching is intentionally broad: a project may name its asset
# "foo-x86_64-darwin.tar.gz", "foo-darwin-x64.tar.gz",
# "foo.macos.x86_64.tar.gz", "foo-osx-x86_64", etc. We match on the union
# of platform identifiers that unambiguously identify a target system.
# False positives are possible but rare — the agent inspects asset_names
# to confirm when coverage is ambiguous.
detect_platform() {
  local assets_lower="$1"
  local system="$2"
  case "$system" in
    x86_64-linux)
      # Match x86_64-linux but NOT x86_64-darwin. Require "linux" AND
      # ("x86_64" OR "x64" OR "amd64") in the filename, excluding darwin/macos/osx.
      echo "$assets_lower" | grep -iqE '(x86_64|x64|amd64).*(linux|gnu)' \
        || echo "$assets_lower" | grep -iqE '(linux|gnu).*(x86_64|x64|amd64)' \
        || echo "$assets_lower" | grep -iqE 'linux.*x86_64' \
        || return 1
      ;;
    aarch64-linux)
      echo "$assets_lower" | grep -iqE '(aarch64|arm64).*(linux|gnu)' \
        || echo "$assets_lower" | grep -iqE '(linux|gnu).*(aarch64|arm64)' \
        || return 1
      ;;
    x86_64-darwin)
      # Match darwin/macos/osx AND (x86_64 OR x64 OR amd64 OR intel).
      # "macos-x64", "darwin-x86_64", "osx-amd64", "x86_64-apple-darwin" all match.
      echo "$assets_lower" | grep -iqE '(darwin|macos|osx|apple).*(x86_64|x64|amd64|intel)' \
        || echo "$assets_lower" | grep -iqE '(x86_64|x64|amd64|intel).*(darwin|macos|osx|apple)' \
        || return 1
      ;;
    aarch64-darwin)
      # Match darwin/macos/osx AND (aarch64 OR arm64 OR apple-silicon OR m1).
      echo "$assets_lower" | grep -iqE '(darwin|macos|osx|apple).*(aarch64|arm64|apple.silicon|m1)' \
        || echo "$assets_lower" | grep -iqE '(aarch64|arm64|apple.silicon|m1).*(darwin|macos|osx|apple)' \
        || return 1
      ;;
    *)
      return 1
      ;;
  esac
}

ASSETS_LOWER=$(echo "$ASSETS" | tr '[:upper:]' '[:lower:]')

X86_64_LINUX=false
AARCH64_LINUX=false
X86_64_DARWIN=false
AARCH64_DARWIN=false

if detect_platform "$ASSETS_LOWER" "x86_64-linux"; then X86_64_LINUX=true; fi
if detect_platform "$ASSETS_LOWER" "aarch64-linux"; then AARCH64_LINUX=true; fi
if detect_platform "$ASSETS_LOWER" "x86_64-darwin"; then X86_64_DARWIN=true; fi
if detect_platform "$ASSETS_LOWER" "aarch64-darwin"; then AARCH64_DARWIN=true; fi

PLATFORM_COVERAGE=$(cat <<EOF
{"x86_64-linux": $X86_64_LINUX, "aarch64-linux": $AARCH64_LINUX, "x86_64-darwin": $X86_64_DARWIN, "aarch64-darwin": $AARCH64_DARWIN}
EOF
)

# partial_platform_coverage: true when the project ships SOME prebuilt
# binaries (at least one of the target systems) but NOT all of the target
# systems. The target set is $TARGET_PLATFORMS_JSON — when detect-platform-scope.sh
# narrowed the scope (e.g. darwin_only), a project shipping both darwin
# binaries has full coverage (not partial) even though it doesn't ship
# linux binaries. This is correct: the project is darwin-only by design,
# not missing linux coverage.
#
# Count how many of the TARGET_PLATFORMS have a prebuilt asset, using jq
# to cross-reference platform_coverage against target_platforms.
TARGET_COUNT=$(echo "$TARGET_PLATFORMS_JSON" | jq 'length')
COVERED_COUNT=$(echo "$PLATFORM_COVERAGE" | jq --argjson tp "$TARGET_PLATFORMS_JSON" \
  '[.[$tp[]]] | map(select(. == true)) | length')

PARTIAL_PLATFORM_COVERAGE=false
if [ "$COVERED_COUNT" -gt 0 ] && [ "$COVERED_COUNT" -lt "$TARGET_COUNT" ]; then
  PARTIAL_PLATFORM_COVERAGE=true
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Target platforms: $TARGET_PLATFORMS_JSON"
  echo "Platform coverage: $PLATFORM_COVERAGE"
  echo "Partial platform coverage: $PARTIAL_PLATFORM_COVERAGE"
  echo "Covered count: $COVERED_COUNT/$TARGET_COUNT"
fi

# Extract latest release version tag (e.g. "v1.2.3" from "refs/tags/v1.2.3")
LATEST_RELEASE=$(echo "$RELEASES_JSON" | jq -r '.[0].tag_name // empty' 2>/dev/null || echo "")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Latest release tag: $LATEST_RELEASE"
fi

echo "{\"has_tarballs\": $HAS_TARBALLS, \"has_binary_releases\": $HAS_BINARY_RELEASES, \"asset_names\": $ASSET_JSON, \"platform_coverage\": $PLATFORM_COVERAGE, \"partial_platform_coverage\": $PARTIAL_PLATFORM_COVERAGE, \"latest_release\": \"$LATEST_RELEASE\", \"target_platforms\": $TARGET_PLATFORMS_JSON}"
