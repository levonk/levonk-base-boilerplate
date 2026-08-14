#!/usr/bin/env bash
# Check whether the nixpkgs packaging of a project is a superset of what a
# from-source in-repo flake would provide. A superset means the nixpkgs
# derivation includes all the features our from-source build would have,
# PLUS additional patches, postInstall hooks, wrapper scripts, or runtime
# dependencies that a naive from-source flake would miss.
#
# When nixpkgs is a superset AND the version is current (within one minor
# release of the latest upstream release), the in-repo flake should expose
# a #nixpkgs output so users can access the more complete packaging.
#
# Usage: check-nixpkgs-superset.sh <project-name> <latest-release> <nixpkgs-version> [nixpkgs-derivation-json]
#   project-name: the nixpkgs attribute name (from check-nixpkgs.sh)
#   latest-release: the latest GitHub release tag (from check-releases.sh, e.g. "v1.2.3")
#   nixpkgs-version: the version nixpkgs ships (from check-nixpkgs.sh, e.g. "1.2.3")
#   nixpkgs-derivation-json: optional path to inspect-nixpkgs-derivation.sh JSON output
#     (if omitted, the script re-runs inspect-nixpkgs-derivation.sh)
#
# Output: JSON with:
#   project_in_nixpkgs      — bool (echoed from input for convenience)
#   version_current         — bool: is nixpkgs version within one minor release of latest?
#   has_patches             — bool: does the nixpkgs derivation apply patches?
#   has_postinstall         — bool: does the nixpkgs derivation have postInstall/preInstall hooks?
#   has_make_wrapper        — bool: does the nixpkgs derivation use makeWrapper?
#   has_runtime_deps        — bool: does the nixpkgs derivation declare runtimeDependencies?
#   extra_build_inputs      — array of buildInputs that a naive from-source flake might miss
#   is_superset             — bool: nixpkgs packaging is at least as complete as from-source
#   add_nixpkgs_output      — bool: should the in-repo flake expose a #nixpkgs output?
#   rationale               — human-readable summary of the decision
#
# The agent uses add_nixpkgs_output to decide whether to add a #nixpkgs output
# to the in-repo flake.nix (Step 12). The qualitative comparison of whether
# nixpkgs is a superset is done by the agent reading the derivation source from
# Step 11 — this script provides the deterministic signals (version currency,
# presence of patches/hooks/wrappers/runtime deps) that feed that comparison.
#
# Requires: nix (with flakes), jq, curl. Falls back gracefully if nix is absent.

set -euo pipefail

PROJECT="${1:?Usage: check-nixpkgs-superset.sh <project-name> <latest-release> <nixpkgs-version> [nixpkgs-derivation-json]}"
LATEST_RELEASE="${2:?Usage: check-nixpkgs-superset.sh <project-name> <latest-release> <nixpkgs-version> [nixpkgs-derivation-json]}"
NIXPKGS_VERSION="${3:?Usage: check-nixpkgs-superset.sh <project-name> <latest-release> <nixpkgs-version> [nixpkgs-derivation-json]}"
DERIVATION_JSON="${4:-}"

# Strip leading 'v' from release tags for comparison
LATEST_VER="${LATEST_RELEASE#v}"
NIXPKGS_VER="${NIXPKGS_VERSION//\"/}"

# --- Version currency check -------------------------------------------------
# nixpkgs version is "current" if it's within one minor release of the latest
# upstream release. We compare major.minor — if they match, or if nixpkgs is
# only one minor behind, it's current enough that wrapping nixpkgs gives users
# a recent version without a huge lag.
version_current=false
if [ "$NIXPKGS_VER" != "null" ] && [ -n "$NIXPKGS_VER" ]; then
  LATEST_MAJOR=$(echo "$LATEST_VER" | cut -d. -f1)
  LATEST_MINOR=$(echo "$LATEST_VER" | cut -d. -f2)
  NIXPKGS_MAJOR=$(echo "$NIXPKGS_VER" | cut -d. -f1)
  NIXPKGS_MINOR=$(echo "$NIXPKGS_VER" | cut -d. -f2)

  if [ "$LATEST_MAJOR" = "$NIXPKGS_MAJOR" ]; then
    # Same major — check minor delta
    MINOR_DELTA=$(( LATEST_MINOR - NIXPKGS_MINOR ))
    if [ "$MINOR_DELTA" -le 1 ]; then
      version_current=true
    fi
  fi
fi

# --- Derivation analysis ----------------------------------------------------
# If the caller provided derivation JSON (from Step 11's inspect-nixpkgs-derivation.sh),
# use it. Otherwise, run inspect-nixpkgs-derivation.sh ourselves.
if [ -z "$DERIVATION_JSON" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/inspect-nixpkgs-derivation.sh" ]; then
    DERIVATION_JSON=$(bash "$SCRIPT_DIR/inspect-nixpkgs-derivation.sh" "$PROJECT" 2>/dev/null || echo '{"found": false}')
  else
    DERIVATION_JSON='{"found": false}'
  fi
fi

PROJECT_IN_NIXPKGS=$(echo "$DERIVATION_JSON" | jq -r '.found // false')

# Initialize flags
HAS_PATCHES=false
HAS_POSTINSTALL=false
HAS_MAKE_WRAPPER=false
HAS_RUNTIME_DEPS=false
EXTRA_BUILD_INPUTS="[]"

if [ "$PROJECT_IN_NIXPKGS" = "true" ]; then
  CONTENT=$(echo "$DERIVATION_JSON" | jq -r '.content // ""')

  # Check for patches — look for patches = [ ... ] or fetchPatch patterns
  if echo "$CONTENT" | grep -qE 'patches\s*='; then
    HAS_PATCHES=true
  fi

  # Check for postInstall / preInstall hooks
  if echo "$CONTENT" | grep -qE '(postInstall|preInstall|postPatch)\s*='; then
    HAS_POSTINSTALL=true
  fi

  # Check for makeWrapper usage
  if echo "$CONTENT" | grep -qE 'makeWrapper'; then
    HAS_MAKE_WRAPPER=true
  fi

  # Check for runtimeDependencies
  RUNTIME_DEPS=$(echo "$DERIVATION_JSON" | jq -r '.runtime_deps // []')
  if [ "$RUNTIME_DEPS" != "[]" ] && [ -n "$RUNTIME_DEPS" ]; then
    HAS_RUNTIME_DEPS=true
  fi

  # Extract buildInputs that a naive from-source flake might miss
  EXTRA_BUILD_INPUTS=$(echo "$DERIVATION_JSON" | jq -r '.build_inputs // []')
fi

# --- Superset determination -------------------------------------------------
# nixpkgs is a superset if it has ANY of: patches, postInstall hooks,
# makeWrapper, or runtime deps — these are the things a naive from-source
# flake would miss. The agent does the full qualitative comparison; this
# script provides the deterministic signals.
IS_SUPERSET=false
if [ "$HAS_PATCHES" = true ] || [ "$HAS_POSTINSTALL" = true ] || \
   [ "$HAS_MAKE_WRAPPER" = true ] || [ "$HAS_RUNTIME_DEPS" = true ]; then
  IS_SUPERSET=true
fi

# --- Add #nixpkgs output decision -------------------------------------------
# Add the #nixpkgs output when:
# 1. The project is in nixpkgs
# 2. nixpkgs is a superset (has patches/hooks/wrappers/runtime deps)
# 3. The nixpkgs version is current (within one minor release of latest)
#
# Even when the version is not current, the agent may still add #nixpkgs
# if the superset packaging is valuable enough — the version_current flag
# is a signal, not a hard gate. The agent makes the final call.
ADD_NIXPKGS_OUTPUT=false
if [ "$PROJECT_IN_NIXPKGS" = "true" ] && [ "$IS_SUPERSET" = "true" ]; then
  ADD_NIXPKGS_OUTPUT=true
fi

# --- Rationale --------------------------------------------------------------
RATIONALE=""
if [ "$PROJECT_IN_NIXPKGS" = "false" ]; then
  RATIONALE="Project is not in nixpkgs — no #nixpkgs output to add."
elif [ "$IS_SUPERSET" = "false" ]; then
  RATIONALE="nixpkgs packaging is not a superset (no patches, hooks, wrappers, or runtime deps detected) — a from-source flake provides equivalent functionality."
elif [ "$version_current" = "false" ]; then
  RATIONALE="nixpkgs packaging is a superset but version is not current (nixpkgs: ${NIXPKGS_VER}, latest: ${LATEST_VER}). The agent should decide whether the superset packaging outweighs the version lag."
else
  RATIONALE="nixpkgs packaging is a superset and version is current (nixpkgs: ${NIXPKGS_VER}, latest: ${LATEST_VER}). Add #nixpkgs output to give users access to the more complete packaging."
fi

# --- Output -----------------------------------------------------------------

jq -n \
  --argjson project_in_nixpkgs "$PROJECT_IN_NIXPKGS" \
  --argjson version_current "$version_current" \
  --argjson has_patches "$HAS_PATCHES" \
  --argjson has_postinstall "$HAS_POSTINSTALL" \
  --argjson has_make_wrapper "$HAS_MAKE_WRAPPER" \
  --argjson has_runtime_deps "$HAS_RUNTIME_DEPS" \
  --argjson extra_build_inputs "$EXTRA_BUILD_INPUTS" \
  --argjson is_superset "$IS_SUPERSET" \
  --argjson add_nixpkgs_output "$ADD_NIXPKGS_OUTPUT" \
  --arg rationale "$RATIONALE" \
  '{project_in_nixpkgs: $project_in_nixpkgs,
    version_current: $version_current,
    has_patches: $has_patches,
    has_postinstall: $has_postinstall,
    has_make_wrapper: $has_make_wrapper,
    has_runtime_deps: $has_runtime_deps,
    extra_build_inputs: $extra_build_inputs,
    is_superset: $is_superset,
    add_nixpkgs_output: $add_nixpkgs_output,
    rationale: $rationale}'
