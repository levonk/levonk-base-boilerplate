---
type: Practice
title: Sync Before Push
description: Fetch and rebase onto the latest upstream tip before pushing. Catch upstream movement during the work phase, not at PR review time.
tags: [git, sync, rebase, upstream, fork, push]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-sync-upstream-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/sync-upstream.sh
    title: "nixify sync-upstream.sh"
  - id: nixify-setup-branch-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/setup-branch.sh
    title: "nixify setup-branch.sh"
---

# Sync Before Push

## Rule

Before pushing your feature branch, fetch and rebase onto the latest
upstream tip. This catches any upstream movement that happened during
the work phase.

```bash
git fetch upstream
git rebase upstream/main
# resolve conflicts if any, then:
git push
```

## Why

Upstream is not frozen while you work. Other PRs may merge between when
you branched and when you push. If you push a stale branch:

- The PR diff may include reverted or changed code, confusing reviewers
- Conflicts surface at review time instead of before push, delaying the
  PR
- The CI may fail against outdated base code

Syncing right before push ensures your branch is on top of the latest
upstream state. If conflicts exist, you resolve them locally with full
context, not in a rush during review.

## Two Sync Points

The full contribution lifecycle has two sync points:

1. **Before branching** — fetch + rebase to start from a fresh base
2. **Before pushing** — fetch + rebase to catch movement during work

Both use the same operation (`git fetch` + `git rebase`). The first
ensures you don't branch from a stale upstream HEAD. The second ensures
you don't push a branch that drifted behind upstream during the work
phase.

## When to Skip

If the work phase was fast (minutes, not hours/days) and you're
confident no upstream merges happened, the pre-push sync may be
redundant. But the cost is near-zero (a fetch + a no-op rebase), so
running it anyway is the safer default.

## Related

* [Rebase, Never Merge](rebase-never-merge.md) — the sync uses rebase,
  never merge
* [Linear History](linear-history.md) — syncing preserves linear
  history
