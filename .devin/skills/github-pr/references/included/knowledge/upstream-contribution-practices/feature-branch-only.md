---
type: Practice
title: Feature Branch Only
description: Always develop on a feature branch, never commit directly to main/master. Prevents polluting the default branch and enables clean PR creation.
tags: [git, branch, feature-branch, workflow, fork]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-setup-branch-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/setup-branch.sh
    title: "nixify setup-branch.sh"
  - id: about-branches
    resource: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches
    title: "GitHub: About branches"
---

# Feature Branch Only

## Rule

Always create a feature branch before making any changes. Never commit
directly to `main`, `master`, or the project's default branch.

```bash
# After syncing from upstream:
git checkout -b feat-<descriptive-name>
```

## Why

Committing to the default branch:

- **Cannot produce a PR** — a PR is a diff between two branches. If your
  changes are on `main`, there's no branch to compare against.
- **Blocks syncing** — when you later need to rebase from upstream, your
  commits on `main` conflict with upstream's `main`. You end up
  force-pushing your fork's `main`, which is messy and error-prone.
- **Makes rollback impossible** — if the contribution is rejected, you
  must reset your fork's `main` to upstream's `main`, losing any other
  work that was mixed in.
- **Violates project norms** — most projects expect contributions via
  feature branches. Committing to `main` signals unfamiliarity with git
  workflow.

## Branch Naming

Use a descriptive name prefixed with the change type:

```
feat-nix-package-manager-install
fix-memory-leak-in-parser
docs-add-nix-install-section
```

The nixify skill uses `feat-nix-package-manager-install` — the prefix
communicates the change type, and the rest communicates the specific
feature.

## When You Have Direct Access

If you have direct push access to the upstream repo (you're a
collaborator), you still use a feature branch. Direct pushes to `main`
bypass review and break the PR workflow. The only exception is trivial
fixes that the project's guidelines explicitly allow on `main`.

## Related

* [Sync Before Push](sync-before-push.md) — sync from upstream before
  creating the branch to start from a fresh base
* [Minimal Scope](minimal-scope.md) — one feature branch should carry
  one coherent change
