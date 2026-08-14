---
type: Practice
title: Rebase, Never Merge
description: Always rebase from upstream; never merge upstream into a feature branch. Merge commits pollute upstream history on merge.
tags: [git, rebase, merge, fork, history]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: git-docs-rebasing
    resource: https://git-scm.com/docs/git-rebase
    title: "Git docs: Rebasing"
  - id: nixify-sync-upstream-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/sync-upstream.sh
    title: "nixify sync-upstream.sh"
---

# Rebase, Never Merge

## Rule

When syncing a feature branch with upstream, always rebase. Never merge
upstream into the feature branch.

```bash
# Correct
git fetch upstream
git rebase upstream/main

# Wrong — creates a merge commit
git fetch upstream
git merge upstream/main
```

## Why

Upstream maintainers typically want a clean, linear history. A merge
commit in your feature branch becomes part of their history when the PR
is merged (especially with "Create a merge commit" or "Rebase and merge"
strategies). Merge commits:

- Clutter the log with "Merge branch 'main' into feat-x" noise
- Make `git bisect` harder (the merge commit may not represent a single
  coherent state)
- Signal that the contributor didn't keep their branch up to date
  incrementally

Rebasing replays your commits on top of the latest upstream tip,
preserving linear history. The PR diff is identical either way, but the
commit graph is clean.

## When Conflicts Arise

```bash
git rebase upstream/main
# conflict occurs
# resolve in your editor
git add <resolved-files>
git rebase --continue
# repeat until clean
```

Never `git rebase --abort` and switch to merge to avoid resolving
conflicts. Resolve them in the rebase — the conflict resolution is the
same work either way, but the rebase produces clean history.

## Related

* [Linear History](linear-history.md) — squashing iterative commits
  after the rebase
* [Sync Before Push](sync-before-push.md) — when to sync during the
  contribution lifecycle
