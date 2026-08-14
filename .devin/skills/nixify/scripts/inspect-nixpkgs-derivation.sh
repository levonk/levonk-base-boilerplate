#!/usr/bin/env bash
# Inspect the nixpkgs derivation for a package to surface all deployment
# dependencies, patches, postInstall hooks, wrapper scripts, and runtime
# setup that a from-scratch flake.nix must replicate. Run this BEFORE
# generating flake.nix to avoid missing something the existing nixpkgs
# packaging already handles.
#
# Usage: inspect-nixpkgs-derivation.sh <package-name>
# Output: JSON with:
#   found                    — whether the package exists in nixpkgs
#   url                      — raw GitHub URL of the derivation source file
#   path                     — path within nixpkgs repo
#   content                  — full source of the derivation file (for the agent to read)
#   build_inputs             — resolved buildInputs dependency names (best-effort)
#   native_build_inputs      — resolved nativeBuildInputs dependency names (best-effort)
#   propagated_build_inputs  — resolved propagatedBuildInputs dependency names (best-effort)
#   runtime_deps             — resolved runtimeDependencies names (best-effort)
#
# Requires: nix (with flakes), curl, jq

set -euo pipefail

PKG="${1:?Usage: inspect-nixpkgs-derivation.sh <package-name>}"

# Step 1: Get the source file position via meta.position.
# This returns "/nix/store/.../source/<relative-path>:<line-number>".
POSITION=$(nix eval --raw "nixpkgs#${PKG}.meta.position" 2>/dev/null || echo "")

if [ -z "$POSITION" ]; then
  echo "{\"found\": false, \"reason\": \"package '${PKG}' not in nixpkgs or meta.position unavailable\"}"
  exit 0
fi

# Extract relative path (strip /nix/store/<hash>-source/ prefix and :line suffix).
FILE_PATH=$(echo "$POSITION" | cut -d: -f1 | sed 's|^/nix/store/[^/]*-source/||')

if [ -z "$FILE_PATH" ]; then
  echo "{\"found\": false, \"reason\": \"could not parse meta.position: ${POSITION}\"}"
  exit 0
fi

URL="https://raw.githubusercontent.com/NixOS/nixpkgs/master/${FILE_PATH}"

# Step 2: Fetch the derivation source.
CONTENT=$(curl -sf "$URL" 2>/dev/null || echo "")
CONTENT_JSON=$(printf '%s' "$CONTENT" | jq -Rs .)

# Step 3: Get resolved dependency names (best-effort, each independent).
# Each call is guarded so a missing/unevaluable attribute produces [] not an error.
get_inputs() {
  local attr="$1"
  nix eval --json "nixpkgs#${PKG}.${attr}" \
    --apply 'map (x: x.pname or x.name)' 2>/dev/null || echo "[]"
}

BUILD_INPUTS=$(get_inputs buildInputs)
NATIVE_BUILD_INPUTS=$(get_inputs nativeBuildInputs)
PROPAGATED_BUILD_INPUTS=$(get_inputs propagatedBuildInputs)
RUNTIME_DEPS=$(get_inputs runtimeDependencies)

jq -n \
  --arg url "$URL" \
  --arg path "$FILE_PATH" \
  --argjson content "$CONTENT_JSON" \
  --argjson build_inputs "$BUILD_INPUTS" \
  --argjson native_build_inputs "$NATIVE_BUILD_INPUTS" \
  --argjson propagated_build_inputs "$PROPAGATED_BUILD_INPUTS" \
  --argjson runtime_deps "$RUNTIME_DEPS" \
  '{found: true, url: $url, path: $path, content: $content,
    build_inputs: $build_inputs, native_build_inputs: $native_build_inputs,
    propagated_build_inputs: $propagated_build_inputs, runtime_deps: $runtime_deps}'
