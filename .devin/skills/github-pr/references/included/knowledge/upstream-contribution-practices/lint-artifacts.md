---
type: Practice
title: Lint Artifacts
description: Run linters on files you create or modify before the build/test phase. Auto-discover project lint configs. Fall back to nix run if a linter isn't installed. Prevents upstream lint CI failures on a PR that builds but fails style checks.
tags: [linting, linter, yamllint, markdownlint, statix, deadnix, ci, review]
date:
  created: "2026-07-16"
  knowledge-basis: "2026-07-16"
  last-used: "2026-07-16"
sources:
  - id: nixify-lint-artifacts-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/lint-artifacts.sh
    title: "nixify lint-artifacts.sh"
  - id: nixify-skill-md-step-21
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 21"
---

# Lint Artifacts

## Rule

Before the build/test phase, run linters on every file you created or
modified. Each linter must auto-discover the project's own lint config
and conform to the project's standards. If a linter is not on the host
PATH, fall back to `nix run nixpkgs#<tool>` (or the equivalent package
manager ephemeral run for non-Nix projects). If the project has no lint
configs, run with built-in defaults — but write your templates to pass
default lint settings.

## Why

A PR that builds and runs correctly can still be rejected by upstream
lint CI. Most projects enforce lint checks as a required CI gate — if
your files trigger lint failures, the PR is blocked even though the code
works. Catching lint issues before the build/test phase saves the
expensive build cycle from being wasted on a PR that will fail CI
anyway.

This is distinct from [Format Artifacts](format-artifacts.md):
formatting (oxfmt, prettier, biome) normalizes style; linting
(yamllint, markdownlint, statix, deadnix) catches semantic issues like
bad patterns, dead code, and structural problems. Format runs **before**
lint so the linter sees already-formatted files and doesn't report style
issues the formatter would have caught. Both run before build/test.

## Linters by File Type

| File type | Linter | Auto-fix | Config auto-discovery |
|-----------|--------|----------|----------------------|
| `.yml`/`.yaml` | yamllint | No (check-only) | `.yamllint.yaml`, `.yamllint.yml`, `.yamllint` |
| `.md`/`.mdx` | markdownlint-cli2 | Yes (`--fix`) | `.markdownlint-cli2.jsonc`, `.markdownlint.json`, `.markdownlint.yaml`, `.markdownlintrc` |
| `.nix` | statix | Yes (`statix fix`) | `statix.toml` |
| `.nix` | deadnix | Yes (`--edit -L`) | None (flag-based config) |

The `-L` flag on deadnix is critical: it prevents removing lambda
pattern names, which would break `callPackage` interfaces in nixpkgs.

## Tool Availability

If a linter is not on the host PATH, fall back to an ephemeral run:

```bash
# Nix (preferred for Nix projects — Nix is a prerequisite)
nix run nixpkgs#yamllint -- -d default file.yml
nix run nixpkgs#markdownlint-cli2 -- --fix file.md
nix run nixpkgs#statix -- check file.nix
nix run nixpkgs#deadnix -- --fail -L file.nix

# Or add to devbox.json so devbox shell provides them
```

Running inside `devbox shell` makes the tools available on the host
PATH if they're listed in `devbox.json`. This is faster than `nix run`
on subsequent invocations (no store fetch).

## Scope

Lint **only the files you created or modified**, not the whole repo.
A whole-repo lint would surface pre-existing issues in files you didn't
touch, creating noise and scope expansion.

## Config Conformance

The linter must conform to the project's standards, not yours:

1. **Project has lint config** → the linter auto-discovers it and
   conforms. Your templates must pass the project's config, not just
   default settings.
2. **Project has no lint config** → run with built-in defaults. Your
   templates must pass default lint settings so they don't trigger
   findings on projects that haven't configured linters.
3. **Project has a linter but no config for a specific file type** →
   run with defaults for that file type. Don't invent a config.

## Related

* [Format Artifacts](format-artifacts.md) — formatting normalizes style;
  linting catches semantic issues. Both are needed. Format runs first.
* [Separate Style Commit](separate-style-commit.md) — format and lint
  fixes go in one combined style commit, not hidden in the feature commit
* [Massive-Change Guard](massive-change-guard.md) — revert format+lint
  auto-fix changes that exceed a threshold on modified files
* [Follow Project Conventions](follow-project-conventions.md) — lint
  config conformance is a subset of following project conventions
