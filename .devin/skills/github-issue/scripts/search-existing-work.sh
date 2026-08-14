#!/usr/bin/env bash
# Search for existing issues and PRs in a repository using caller-supplied search terms.
# Generalized from nixify/scripts/search-existing-work.sh — accepts search terms as
# arguments instead of hardcoding Nix-specific terms.
#
# Usage: search-existing-work.sh <owner> <repo> <search-terms...>
#   search-existing-work.sh microsoft vscode "chat panel" "chat API" "extension API"
# Output: JSON with issues_found, prs_found, contributing_guidelines, issue_templates, pr_template
# Use --verbose as the third arg for full search results (before the search terms).
#
# Exit codes: 0 = search completed (results may be empty), 1 = usage error

set -euo pipefail

OWNER="${1:?Usage: search-existing-work.sh <owner> <repo> [--verbose] <search-terms...>}"
REPO="${2:?Usage: search-existing-work.sh <owner> <repo> [--verbose] <search-terms...>}"
shift 2

VERBOSE=""
if [ "${1:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
  shift
fi

if [ "$#" -eq 0 ]; then
  echo "Usage: search-existing-work.sh <owner> <repo> [--verbose] <search-terms...>" >&2
  echo "At least one search term is required" >&2
  exit 1
fi

SEARCH_TERMS=("$@")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Searching $OWNER/$REPO for existing issues and PRs..."
  echo "  Search terms: ${SEARCH_TERMS[*]}"
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

# Check for contribution guidelines across common locations
CONTRIBUTING=""
for path in "CONTRIBUTING.md" ".github/CONTRIBUTING.md" "AGENTS.md" "CLAUDE.md" "docs/CONTRIBUTING.md" ".gitlab/CONTRIBUTING.md" ".forgejo/CONTRIBUTING.md" ".gitea/CONTRIBUTING.md"; do
  CONTENT=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/$path" | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
  if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
    CONTRIBUTING="$path"
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  Found contribution guidelines at: $path"
    fi
    break
  fi
done

# Check for issue templates (GitHub-style)
ISSUE_TEMPLATES=""
for path in ".github/ISSUE_TEMPLATE" "ISSUE_TEMPLATE" "docs/ISSUE_TEMPLATE" ".gitlab/ISSUE_TEMPLATE" ".forgejo/ISSUE_TEMPLATE" ".gitea/ISSUE_TEMPLATE"; do
  CONTENT=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/$path" | jq -r '.[].name' 2>/dev/null || echo "")
  if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
    ISSUE_TEMPLATES="$path"
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  Found issue templates at: $path"
    fi
    break
  fi
done

# Check for PR template (GitHub-style)
PR_TEMPLATE=""
for path in ".github/PULL_REQUEST_TEMPLATE.md" ".github/pull_request_template.md" "PULL_REQUEST_TEMPLATE.md" "docs/PULL_REQUEST_TEMPLATE.md" ".forgejo/pull_request_template.md" ".gitea/pull_request_template.md"; do
  CONTENT=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/$path" | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
  if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
    PR_TEMPLATE="$path"
    if [ "$VERBOSE" = "--verbose" ]; then
      echo "  Found PR template at: $path"
    fi
    break
  fi
done

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Issues found: ${ISSUES_FOUND:-[]}"
  echo "PRs found: ${PRS_FOUND:-[]}"
  echo "Contributing guidelines: $CONTRIBUTING"
  echo "Issue templates: $ISSUE_TEMPLATES"
  echo "PR template: $PR_TEMPLATE"
fi

echo "{\"issues_found\": ${ISSUES_FOUND:-[]}, \"prs_found\": ${PRS_FOUND:-[]}, \"contributing_guidelines\": \"$CONTRIBUTING\", \"issue_templates\": \"$ISSUE_TEMPLATES\", \"pr_template\": \"$PR_TEMPLATE\"}"

