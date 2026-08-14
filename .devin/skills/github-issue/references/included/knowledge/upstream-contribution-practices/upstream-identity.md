---
type: Practice
title: Upstream Identity
description: All code, docs, issues, and PRs reference the upstream owner/repo, not the fork. The fork is only for development.
tags: [fork, upstream, identity, pr, issue, documentation]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-skill-md-critical-rule-for-forks
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md — CRITICAL RULE FOR FORKS"
---

# Upstream Identity

## Rule

When contributing to an upstream project via a fork, ALL user-facing
content — code files, documentation, commit messages, issue bodies, PR
bodies, README sections — MUST reference the upstream repository
(`upstream-owner/upstream-repo`), NOT the fork
(`your-user/upstream-repo`).

The fork is only for development and testing. Once the PR merges, the
flake/install instructions/docs must work against the upstream repo, not
your fork (which may be deleted or archived).

## What to Check

| Artifact | Reference | Common Mistake |
|----------|-----------|----------------|
| `flake.nix` homepage URL | `github.com/upstream-owner/repo` | `github.com/your-user/repo` |
| README install instructions | `nix run github:upstream-owner/repo` | `nix run github:your-user/repo` |
| PR body install examples | `github:upstream-owner/repo` | `github:your-user/repo` |
| Issue "Implementation" link | `github.com/your-user/repo/tree/branch` | (this one correctly points to the fork) |
| Docs site install page | upstream URLs | fork URLs |

The exception is the "Implementation" link in the orientation issue,
which correctly points to the fork branch where the work was done.

## Enforcement

Use variables (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`)
and substitute by text replacement, not shell expansion. See
[gh --body-file](gh-body-file.md) for why shell expansion corrupts these.

## Related

* [gh --body-file](gh-body-file.md) — the posting method that preserves
  these placeholders correctly
