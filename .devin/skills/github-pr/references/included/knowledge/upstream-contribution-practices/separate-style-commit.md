---
type: Practice
title: Separate Style Commit
description: Keep format and lint fixes in a single separate commit from the feature commit. Reviewers need to see what the tools changed independently, not hidden inside the larger feature diff. Prevents review friction from opaque style changes.
tags: [format, lint, commit, review, diff, separation, transparency, style]
date:
  created: "2026-07-16"
  knowledge-basis: "2026-07-16"
  last-used: "2026-07-16"
sources:
  - id: nixify-skill-md-steps-17-20
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Steps 17-20"
---

# Separate Style Commit

## Rule

Commit feature changes and style fixes (format + lint) as **two separate
commits**:

1. **Commit 1 (feature)**: the artifacts you created — flake.nix,
   workflows, docs, config files. No format or lint fixes.
2. **Commit 2 (style, conditional)**: changes produced by the formatter
   and linter combined (`style: format and lint <description>`). Skipped
   if neither tool produced changes.

Format and lint go in **one commit**, not two. They're both style-only
changes — splitting them further adds noise without value.

## Why

When style changes are squashed into the feature commit, they're
invisible to reviewers. A reviewer looking at a 200-line feature diff
can't tell which lines are the actual feature and which are the
formatter or linter reformatting things. This creates two problems:

- **Review friction**: the reviewer asks "why did you change this line?"
  on a line the formatter modified, not you. You have to explain it was
  the formatter, wasting a review cycle.
- **Bisect ambiguity**: if a future bug is traced back to this commit,
  `git bisect` lands on a commit that mixes feature logic with style
  changes — it's unclear which change caused the issue.

A separate style commit makes the tools' changes explicitly visible.
The reviewer can review the feature commit clean, then review the style
commit and see exactly what the tools changed. If the style commit
looks wrong, it can be reverted without reverting the feature.

## When to Skip

If neither the formatter nor the linter produces changes (everything
was already clean), skip the style commit silently. Don't create an
empty commit.

## Commit Message

Use a clear prefix that distinguishes the style commit from the feature
commit:

```
style: format and lint nixify artifacts
```

The `style:` prefix follows Conventional Commits convention and signals
to the reviewer that this commit contains only style changes (format +
lint), not logic.

## Order of Operations

Format runs **before** lint so the linter sees already-formatted files
and doesn't report style issues the formatter would have caught. Both
run **before** build/test so the build cycle isn't wasted on files that
would fail style CI.

```
create files → commit feature → format → lint → commit style → scan → build → test → push
```

## Relationship to Linear History

This practice seems to conflict with [Linear History](linear-history.md),
which says to squash iterative commits into one. The distinction:

- **Iterative commits** (fix typo, fix build, fix test) → squash into
  one. They're all part of the same logical change.
- **Style commit** → keep separate. It's a different *kind* of change
  (style vs feature) that the reviewer needs to see independently.

The PR still has clean linear history — it's just two commits instead
of one, each serving a different purpose.

## Related

* [Format Artifacts](format-artifacts.md) — the format step that
  produces formatting changes
* [Lint Artifacts](lint-artifacts.md) — the lint step that produces
  lint changes
* [Linear History](linear-history.md) — squash iterative commits, but
  keep the style commit separate
* [Massive-Change Guard](massive-change-guard.md) — guards against the
  style commit containing too many changes on modified files
