---
type: Practice
title: Minimal Scope
description: Keep each PR to one completely working, self-contained change. Don't combine unrelated features. Prevents PR rejection for being too broad and makes review harder.
tags: [scope, pr, minimal, single-change, review]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-skill-md-step-13
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 13"
  - id: yusukebe-ax-pr-27
    resource: https://github.com/yusukebe/ax/pull/27
    title: "yusukebe/ax PR #27"
---

# Minimal Scope

## Rule

Each PR should contain **one completely working change** — nothing
more. If a second feature or fix is needed, it goes in a separate PR on
a separate branch.

## Why

Maintainers review PRs by understanding the full diff. When a PR mixes
unrelated changes:

- **Review is harder** — the reviewer must context-switch between
  unrelated code paths.
- **Rejection risk is higher** — if one part of the PR is
  controversial, the entire PR is blocked, even if the other parts are
  fine.
- **Revert is impossible** — if one part needs to be reverted, you
  can't revert just that part without a new commit that undoes it.
- **Bisect is broken** — a single commit that changes two things makes
  `git bisect` land on a commit that's ambiguous about which change
  caused the behavior.

## The Nix Flake + Devbox Lesson

The nixify skill originally bundled `flake.nix` and `devbox.json` in
every PR. For source-build flakes, this made sense — devbox shares the
same toolchain and is natural to review alongside the from-source flake.

But for **prebuilt tarball flakes**, devbox was irrelevant — the flake
wraps prebuilt binaries with no build toolchain. Including devbox added
a file the maintainer didn't ask for, expanded the review surface, and
mixed a "reproducible dev environment" proposal with a "one-command
install" proposal. The fix: skip devbox entirely for prebuilt tarball
flakes — no `devbox.json`, no devbox in the issue, PR, or README.

The general principle: **if a component isn't necessary for the PR's
core purpose, drop it.** It can be a follow-up PR if there's interest.

## How to Decide Scope

| Question | If yes | If no |
|----------|--------|-------|
| Is this component necessary for the core change to work? | Include it | Drop it |
| Would the PR be incomplete or broken without it? | Include it | Drop it |
| Does the maintainer's issue/template ask for it? | Include it | Drop it |
| Can it be a standalone follow-up PR? | Drop it from this PR | Include it |

## Exception

Some changes are inherently multi-file but still one logical change
(e.g., adding Nix flake support requires `flake.nix`, `flake.lock`,
`.gitignore`, CI workflow, and README updates). That's one change, not
five — they're all part of "add Nix flake support." The test is whether
the files serve the same purpose, not whether there are multiple files.

## Related

* [Feature Branch Only](feature-branch-only.md) — each minimal-scope
  change gets its own branch
* [Test Baseline](test-baseline.md) — don't fix unrelated bugs you
  discover during work; that expands scope
* [Follow Project Conventions](follow-project-conventions.md) — match
  the project's existing scope norms
