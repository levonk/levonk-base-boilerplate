---
type: Practice
title: gh --body-file
description: Never use gh --body with inline strings; always write to a file and use --body-file to avoid two corruption modes.
tags: [github, cli, pr, issue, corruption, body-file]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-validate-pr-issue-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/validate-pr-issue.sh
    title: "nixify validate-pr-issue.sh"
---

# gh --body-file

## Rule

Always post GitHub issue and PR bodies via `--body-file`, never `--body`
with an inline string. Write the body to a temp file, then post:

```bash
gh pr create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/pr-body.md
gh issue create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/issue-body.md
```

## Failure Modes

Two corruption modes have shipped broken PRs/issues in the wild:

### 1. Literal `\n` instead of newlines

Happens when the body is reconstructed as a single-line string with `\n`
escape sequences (e.g. an LLM-emitted string literal) and passed to
`gh --body "..."`. The `\n` is stored verbatim as two characters, not a
newline. The entire post becomes one unreadable line.

### 2. Stripped backticks and empty variables

Happens when the body goes through an unquoted shell heredoc
(`cat <<EOF` instead of `cat <<'EOF'`) or `echo "..."`. Backticks get
command-substituted (`` `flake.nix` `` runs as a command → empty), and
`$UPSTREAM_OWNER` is expanded by the shell to empty.

## Prevention

1. Substitute placeholders (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, etc.)
   by **text replacement** (sed, perl, or editor), never shell expansion.
2. Write the final body to a **file**.
3. Post with `--body-file`.
4. Before posting, sanity-check:
   ```bash
   grep -c '\\n' /tmp/pr-body.md   # must return 0
   grep -n '`' /tmp/pr-body.md     # backtick code spans must be intact
   ```

## Validation

After posting, validate the body was not corrupted:

```bash
scripts/validate-pr-issue.sh <owner>/<repo> (pr|issue) <number>
```

If it exits non-zero, the body is corrupted. Re-fetch the template, fix
the posting method, and `gh pr/issue edit --body-file` until the
validator passes.

## Related

* [Upstream Identity](upstream-identity.md) — the placeholders that get
  corrupted if shell-expanded instead of text-replaced
