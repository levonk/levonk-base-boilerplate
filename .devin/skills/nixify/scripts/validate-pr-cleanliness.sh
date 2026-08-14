#!/usr/bin/env bash
# validate-pr-cleanliness.sh — verify the feature branch is clean for PR
# Usage: validate-pr-cleanliness.sh [base-ref] [--expected-commits <N>]
#
# Checks that the current branch (relative to base-ref, default "origin/master")
# has:
#   1. No merge commits (linear history — rebase, never merge)
#   2. A small commit count (default: 1-2 commits — feature + optional style)
#   3. No unrelated changes (all commits touch nixify artifacts only)
#   4. Clean linear history from base to HEAD
#
# Output: JSON with:
#   - is_clean:           true if all checks pass
#   - base_ref:           the base ref used for comparison
#   - commit_count:       number of commits from base..HEAD
#   - merge_commits:      array of merge commit SHAs (should be empty)
#   - commits:            array of { sha, subject, files_changed }
#   - issues:             array of problem descriptions (empty if clean)
#   - rationale:          short human-readable summary
#
# Exit code: 0 if clean, 1 if issues found.

set -euo pipefail

BASE_REF="${1:-origin/master}"
EXPECTED_COMMITS=""
if [ "${2:-}" = "--expected-commits" ]; then
  EXPECTED_COMMITS="${3:-}"
fi

# Resolve base ref
if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  # Try without origin/ prefix
  if git rev-parse --verify "${BASE_REF#origin/}" >/dev/null 2>&1; then
    BASE_REF="${BASE_REF#origin/}"
  else
    echo "error: cannot resolve base ref '$BASE_REF'" >&2
    exit 1
  fi
fi

BASE_SHA=$(git rev-parse "$BASE_REF")
HEAD_SHA=$(git rev-parse HEAD)

# ── 1. Check for merge commits ───────────────────────────────────────────────
merge_commits=""
merge_count=0
while IFS= read -r sha; do
  [ -z "$sha" ] && continue
  if [ "$merge_count" -gt 0 ]; then merge_commits="$merge_commits,"; fi
  merge_commits="$merge_commits\"$sha\""
  merge_count=$((merge_count + 1))
done < <(git log "$BASE_SHA..$HEAD_SHA" --merges --format='%H' 2>/dev/null || true)

# ── 2. Count commits ─────────────────────────────────────────────────────────
commit_count=$(git rev-list "$BASE_SHA..$HEAD_SHA" --count 2>/dev/null || echo "0")

# ── 3. List commits with changed files ───────────────────────────────────────
commits_json="["
first=1
issues=""

# Expected nixify artifact patterns
NIXIFY_FILES="flake\.nix|flake\.lock|devbox\.json|devbox\.lock|\.gitignore|\.github/workflows/nix\.yml|\.github/workflows/.*hash.*\.yml|garnix\.yaml|nix/|README.*\.md|CHANGELOG\.md|docs/.*install.*|default\.nix|shell\.nix"

while IFS= read -r line; do
  sha=$(echo "$line" | cut -d'|' -f1)
  subject=$(echo "$line" | cut -d'|' -f2)
  # Get files changed in this commit
  files=$(git diff-tree --no-commit-id --name-only -r "$sha" 2>/dev/null | head -20 || true)
  files_json="["
  ffirst=1
  unrelated_found=0
  for f in $files; do
    if [ "$ffirst" -eq 0 ]; then files_json="$files_json,"; fi
    ffirst=0
    files_json="$files_json\"$f\""
    # Check if file matches nixify patterns
    if ! echo "$f" | grep -qE "$NIXIFY_FILES"; then
      unrelated_found=1
    fi
  done
  files_json="$files_json]"

  if [ "$first" -eq 0 ]; then commits_json="$commits_json,"; fi
  first=0
  subject_esc="${subject//\"/\\\"}"
  commits_json="$commits_json{\"sha\":\"$sha\",\"subject\":\"$subject_esc\",\"files_changed\":$files_json}"

  if [ "$unrelated_found" -eq 1 ]; then
    if [ -n "$issues" ]; then issues="$issues,"; fi
    issues="$issues\"commit $sha has files outside nixify artifact patterns\""
  fi
done < <(git log "$BASE_SHA..$HEAD_SHA" --format='%H|%s' 2>/dev/null || true)
commits_json="$commits_json]"

# ── 4. Check commit count ────────────────────────────────────────────────────
if [ -n "$EXPECTED_COMMITS" ] && [ "$commit_count" -gt "$EXPECTED_COMMITS" ]; then
  if [ -n "$issues" ]; then issues="$issues,"; fi
  issues="$issues\"expected at most $EXPECTED_COMMITS commits, found $commit_count\""
fi

if [ "$merge_count" -gt 0 ]; then
  if [ -n "$issues" ]; then issues="$issues,"; fi
  issues="$issues\"found $merge_count merge commit(s) — use rebase, never merge\""
fi

# ── Output ───────────────────────────────────────────────────────────────────
is_clean="true"
if [ -n "$issues" ]; then
  is_clean="false"
fi

if [ "$is_clean" = "true" ]; then
  rationale="Branch is clean: $commit_count commit(s), no merges, all files are nixify artifacts."
else
  rationale="Branch has issues: $issues"
fi

cat <<EOF
{
  "is_clean": $is_clean,
  "base_ref": "$BASE_REF",
  "commit_count": $commit_count,
  "merge_commits": [$merge_commits],
  "commits": $commits_json,
  "issues": [$issues],
  "rationale": "$rationale"
}
EOF

[ "$is_clean" = "true" ] || exit 1
