---
type: Practice
title: Verify Command Currency
description: Tool commands get deprecated and renamed. Verify every command in your PR against current tool documentation before using it. Skill templates can become stale. Prevents shipping deprecated syntax that breaks for users on current tool versions.
tags: [deprecated, commands, documentation, verification, nix, staleness]
date:
  created: "2026-07-16"
  knowledge-basis: "2026-07-16"
  last-used: "2026-07-16"
sources:
  - id: nix-2-30-release-notes
    resource: https://nixos.org/manual/nix/stable/release-notes/rl-2.30.html
    title: "Nix 2.30 release notes"
  - id: coleam00-archon-pr-2131
    resource: https://github.com/coleam00/Archon/pull/2131
    title: "coleam00/Archon PR #2131"
  - id: nixify-skill-v2-8-0-v2-9-0
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify skill v2.8.0 → v2.9.0"
---

# Verify Command Currency

## Rule

Before including any tool command in a PR (install instructions, CI
workflows, documentation), verify the command is current against the
tool's latest documentation. Skill templates and references can become
stale — the tool may have deprecated or renamed commands since the
template was written.

## Why

Tool maintainers deprecate and rename commands over time. If your PR
ships deprecated syntax, users on current tool versions get errors or
deprecation warnings. This creates immediate bug reports and erodes
trust in the contribution.

### The `nix profile install` → `nix profile add` Lesson

The nixify skill (v2.8.0) shipped `nix profile install` in all its
documentation templates, issue/PR templates, and README snippets. This
command was **deprecated in Nix 2.30** (released 2025-07-07) and
renamed to `nix profile add`. Every PR created by the skill before the
fix shipped deprecated syntax to upstream projects.

This was caught when an Archon PR (coleam00/Archon#2131) was reviewed
and the contributor discovered the deprecation during validation. The
fix required updating 16 occurrences across 10 files in the skill
source — the skill itself had a bug that propagated to every project it
touched.

The general principle: **skill templates are not authoritative**. They
encode what was correct at authoring time, not what is correct now.
Always verify commands against current docs.

## How to Verify

1. **Check the tool's official documentation** for the command you're
   using. Look for deprecation notices, rename announcements, or new
   syntax.
2. **Check the tool's changelog or release notes** for versions released
   after the skill's `date.knowledge-basis` field.
3. **Run the command locally** on your current tool version — if it
   prints a deprecation warning, find the replacement.
4. **Search for deprecation discussions** in the tool's issue tracker
   or community forums.

```bash
# Example: verify nix commands are current
nix --version  # check your local version
nix profile add --help  # verify the command exists
# Check Nix release notes for deprecations since the skill's date
```

## What to Check

| Artifact | Commands to verify |
|----------|-------------------|
| Install instructions (README, docs) | `nix run`, `nix profile add`, `nix build` |
| CI workflows | `nix flake check`, `nix build`, `nix run` |
| Devbox config | `devbox run`, `devbox shell` |
| Hash automation workflows | `nix store prefetch-file`, `nix flake update` |

## When to Update the Skill Source

If you discover a deprecated command while working on a PR:

1. **Fix it in the PR** — update the command in the files you're
   submitting to the upstream project.
2. **Fix it in the skill source** — update the skill's templates and
   references so future PRs don't ship the same deprecated syntax.
   This is a separate commit/PR to the skill repo.
3. **Bump the skill version** — increment the `version` field in the
   skill's frontmatter and update the `date.knowledge-basis` field.

## Related

* [Follow Project Conventions](follow-project-conventions.md) — using
  current command syntax is part of following the project's conventions
* [Test Baseline](test-baseline.md) — running commands locally catches
  deprecation warnings before they reach the PR
