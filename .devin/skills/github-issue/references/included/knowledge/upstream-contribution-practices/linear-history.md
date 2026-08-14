---
type: Practice
title: Linear History
description: Squash iterative commits into one clean commit. No merge commits. Linear history from upstream HEAD to your branch HEAD.
tags: [git, squash, linear-history, commits, pr]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: git-docs-interactive-rebase
    resource: https://git-scm.com/docs/git-rebase#_interactive_mode
    title: "Git docs: Interactive Rebase"
  - id: nixify-skill-md-step-19-squash
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 19 — squash"
---

# Linear History

## Rule

A contribution PR should contain a single clean commit (or a small
number of logically distinct commits), with linear history from
upstream's HEAD to your branch's HEAD. No merge commits. No iterative
"fix typo", "fix lint", "address review" commits.

## Why

Upstream maintainers review the diff, not the commit history. But when
they merge, the commit history becomes part of their project's
permanent log. Iterative commits:

- Make `git log` noisy with "fix typo", "address feedback", "wip"
- Make `git bisect` land on intermediate broken states
- Make `git revert` harder (which commit to revert?)
- Signal that the contributor didn't clean up before submitting

A single squashed commit that addresses one concern is the easiest to
review, merge, revert, and bisect.

## How

```bash
# After all work is done and tests pass:
git rebase -i upstream/main
# In the editor, keep the first commit as "pick", mark the rest as "squash"
# Write a clean commit message covering the full change
```

Or if all changes are on top of a single upstream commit:

```bash
git reset --soft upstream/main
git commit -m "feat: add Nix flake support for one-command installation

<full description>"
```

## Exception

Some projects explicitly prefer multiple commits (e.g., separating
"add flake.nix" from "add CI workflow"). Check the project's
contributing guidelines. When in doubt, squash — it's easier for a
maintainer to ask you to split than to ask you to squash.

## Related

* [Rebase, Never Merge](rebase-never-merge.md) — rebasing is how you
  achieve linear history
* [Format Artifacts](format-artifacts.md) — formatting should be part
  of the squashed commit, not a separate commit
