#!/usr/bin/env bash
# Validate a posted GitHub issue or PR body for the two corruption modes that
# break generated posts:
#   1. literal "\n" (backslash-n stored as two chars instead of a newline)
#   2. stripped markdown code spans (backticks command-substituted to empty)
# Also checks that $UPSTREAM_OWNER/$UPSTREAM_REPO placeholders were substituted.
#
# Usage: validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>
# Exit 0 = clean, exit 1 = corruption detected.
# Use --verbose for the offending snippets.

set -euo pipefail

REPO="${1:?Usage: validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>}"
KIND="${2:?Usage: validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>}"
NUM="${3:?Usage: validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>}"
VERBOSE="${4:-}"

case "$KIND" in
  pr|issue) ;;
  *) echo "kind must be 'pr' or 'issue', got '$KIND'" >&2; exit 2 ;;
esac

BODY="$(gh "$KIND" view "$NUM" --repo "$REPO" --json body --jq '.body')"

FAIL=0

# 1. literal backslash-n: a real newline shows up as an actual newline in the
# JSON-decoded body, so any remaining two-char "\n" sequence is corruption.
LITERAL_NL_COUNT=$(printf '%s' "$BODY" | grep -c '\\n' || true)
if [ "$LITERAL_NL_COUNT" -gt 0 ]; then
  echo "FAIL: body contains $LITERAL_NL_COUNT literal '\\n' sequence(s) — newlines were escaped, not real"
  FAIL=1
fi

# 2. unsubstituted placeholders — agent skipped the text-replacement step.
if printf '%s' "$BODY" | grep -qE '\$(UPSTREAM_OWNER|UPSTREAM_REPO|CURRENT_USER)\b'; then
  echo "FAIL: body contains unsubstituted \$UPSTREAM_* / \$CURRENT_USER placeholder(s)"
  FAIL=1
fi

# 3. stripped code spans — symptom: a markdown list bullet or sentence ends
# with " a " or " with " where a `code span` should be. Hard to detect perfectly,
# so we flag the known template phrases that lose their code span.
if printf '%s' "$BODY" | grep -qE '(Adds a |Adds ) (so the|for reproducible|wrapping the)'; then
  echo "FAIL: body has a stripped code span (e.g. 'Adds a  so the' — backtick span was command-substituted to empty)"
  FAIL=1
fi

if [ "$FAIL" -eq 0 ]; then
  echo "ok: $KIND #$NUM body is well-formed"
  exit 0
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "--- body ---"
  printf '%s\n' "$BODY"
fi
exit 1

