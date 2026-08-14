---
type: Practice
title: Massive-Change Guard
description: When a linter auto-fixes a file you modified (not created), revert the changes if the lint-induced diff exceeds a threshold. Pre-existing style issues belong to the project, not your PR. Prevents scope creep from aggressive linter auto-fix.
tags: [lint, auto-fix, scope, guard, threshold, revert, review]
date:
  created: "2026-07-16"
  knowledge-basis: "2026-07-16"
  last-used: "2026-07-16"
sources:
  - id: nixify-lint-artifacts-sh-guard-massive-changes
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/lint-artifacts.sh
    title: "nixify lint-artifacts.sh — guard_massive_changes()"
  - id: nixify-skill-md-step-21-massive-change-guard
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 21 — Massive-change guard"
---

# Massive-Change Guard

## Rule

When a formatter or linter auto-fixes files, distinguish between files
you **created** and files you **modified**:

- **Created files** (did not exist before your work): keep all style
  fixes. You own the entire file.
- **Modified files** (existed before your work, e.g. README where you
  added a section): if the combined format+lint-induced diff exceeds a
  threshold (default 20 lines), **revert the file to pre-style state**.
  The pre-existing style issues belong to the project, not your PR.

## Why

A formatter or linter with `--fix` mode will reformat the entire file,
not just the lines you added. If you added a 10-line install section to
a 500-line README, and prettier or markdownlint-cli2 --fix reformats 80
lines of pre-existing content to comply with its rules, your PR diff now
shows 80 lines of changes you didn't intend to make. This creates three
problems:

1. **Scope creep**: the PR is now a "reformat README" PR in addition to
   an "add Nix install instructions" PR. Reviewers reject scope creep.
2. **Review noise**: the reviewer must inspect 80 lines of lint changes
   that have nothing to do with your contribution.
3. **Conflict risk**: the reformatting may conflict with other in-flight
   PRs or branches that touch the same file.

The guard prevents this by reverting files where the combined
format+lint changes exceed the threshold. The pre-existing style issues
are the project's problem — they can be fixed in a separate cleanup PR
if the maintainer wants.

## How It Works

Format runs first (format-artifacts.sh), then lint runs with `--fix`
(lint-artifacts.sh). After both have run, the guard in lint-artifacts.sh
checks each file against the feature commit (`HEAD~1`):

```bash
# Did this file exist before our work?
git show "HEAD~1:$file" >/dev/null 2>&1

# How many lines did the linter change?
git diff --numstat -- "$file" | awk '{print $1+$2}'
```

If the file is modified (not created) and the combined format+lint diff
exceeds the threshold, revert:

```bash
git checkout HEAD -- "$file"
```

## Threshold

The default threshold is 20 lines. This is configurable (`--threshold
N`). The threshold counts total changed lines (added + deleted),
combining both format and lint changes.

A threshold of 20 allows the tools to fix style issues in the lines you
added (a few lines of formatting around your section) while preventing
them from reformatting the entire file.

## Yamllint Special Case

Yamllint has no auto-fix mode. Its findings are always check-only. For
modified files, fix yamllint findings **manually** and only in the
lines you added — do not reformat the rest of the file.

## Related

* [Format Artifacts](format-artifacts.md) — the format step that runs
  before lint; its changes are included in the guard's diff check
* [Lint Artifacts](lint-artifacts.md) — the lint step where the guard
  runs after auto-fix, checking the combined format+lint diff
* [Separate Style Commit](separate-style-commit.md) — the style commit
  should only contain scoped changes, not massive reformatting
* [Minimal Scope](minimal-scope.md) — the same principle applied to
  style output: don't expand scope by fixing unrelated style issues
