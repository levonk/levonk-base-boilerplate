#!/usr/bin/env bash
# Search for existing issues and PRs about Nix flake support
# Usage: search-existing-work.sh <owner> <repo>
# Output: JSON with issues_found, prs_found, contributing_guidelines
# Use --verbose for full search results

set -euo pipefail

OWNER="${1:?Usage: search-existing-work.sh <owner> <repo>}"
REPO="${2:?Usage: search-existing-work.sh <owner> <repo>}"
VERBOSE="${3:-}"

SEARCH_TERMS=("flake" "nix" "devbox" "nixify OR nixos OR nixpkgs OR home-manager")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Searching $OWNER/$REPO for existing Nix-related issues and PRs..."
fi

ISSUES_FOUND=""
PRS_FOUND=""

for term in "${SEARCH_TERMS[@]}"; do
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "  Searching issues for: $term"
  fi
  RESULT=$(gh issue list --repo "$OWNER/$REPO" --search "$term" --state all --limit 5 --json number,title,state 2>/dev/null || echo "[]")
  if [ "$RESULT" != "[]" ]; then
    ISSUES_FOUND="${ISSUES_FOUND}${RESULT}"
  fi
done

for term in "${SEARCH_TERMS[@]}"; do
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "  Searching PRs for: $term"
  fi
  RESULT=$(gh pr list --repo "$OWNER/$REPO" --search "$term" --state all --limit 5 --json number,title,state 2>/dev/null || echo "[]")
  if [ "$RESULT" != "[]" ]; then
    PRS_FOUND="${PRS_FOUND}${RESULT}"
  fi
done

# Check for contribution guidelines
CONTRIBUTING=""
for path in "CONTRIBUTING.md" ".github/CONTRIBUTING.md" "AGENTS.md" "CLAUDE.md" "docs/CONTRIBUTING.md"; do
  CONTENT=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/$path" | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
  if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
    CONTRIBUTING="$path"
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  Found contribution guidelines at: $path"
    fi
    break
  fi
done

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Issues found: $ISSUES_FOUND"
  echo "PRs found: $PRS_FOUND"
  echo "Contributing guidelines: $CONTRIBUTING"
fi

echo "{\"issues_found\": ${ISSUES_FOUND:-[]}, \"prs_found\": ${PRS_FOUND:-[]}, \"contributing_guidelines\": \"$CONTRIBUTING\"}"
