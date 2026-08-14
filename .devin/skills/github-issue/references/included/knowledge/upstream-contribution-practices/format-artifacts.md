---
type: Practice
title: Format Artifacts
description: Run the project's own formatter on non-project files you create before committing. Prevents review feedback asking you to format.
tags: [formatting, formatter, oxfmt, prettier, biome, review, artifacts]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: yusukebe-ax-pr-27
    resource: https://github.com/yusukebe/ax/pull/27
    title: "yusukebe/ax PR #27"
  - id: nixify-format-artifacts-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/format-artifacts.sh
    title: "nixify format-artifacts.sh"
---

# Format Artifacts

## Rule

Before committing, run the project's own formatter on every non-project
file you created or modified (workflow files, `.gitignore`, README
sections, etc.). The project's formatter is detected from its config
files, not assumed.

## Why

Upstream maintainers review PRs against their own formatting
conventions. If you create a `.github/workflows/nix.yml` that doesn't
match their formatter's output, the first review comment will be "run
our formatter on this file" — wasting a review cycle.

This happened on [yusukebe/ax PR #27](https://github.com/yusukebe/ax/pull/27):
the maintainer's first comment was:

> Can you run: `bunx oxfmt --write .github/workflows/nix.yml`

(We would run `pnpm dlx oxfmt --write .github/workflows/nix.yml` — never
`bunx`, `npx`, or `yarn dlx`. See the [Detection](#detection) table below.)

The file was correct YAML, but oxfmt's style (single-quoted strings)
differed from the double-quoted strings the template produced. The
formatter step would have caught this before pushing.

## Detection

| Formatter | Config files | Runner |
|-----------|-------------|--------|
| oxfmt | `.oxfmtrc.json`, `oxfmt` in package.json | `pnpm dlx oxfmt` |
| prettier | `.prettierrc*`, `.prettierignore`, `prettier` in package.json | `pnpm dlx prettier` |
| biome | `biome.json`, `biome.jsonc` | `pnpm dlx @biomejs/biome` |
| deno fmt | `deno.json`, `deno.jsonc` | `deno fmt` |

If no formatter is detected, skip silently. Most Nix-only or
config-only projects won't have one.

> **Runner selection is fixed**: always `pnpm dlx <pkg>` — never `npx`,
> `bunx`, `bun x`, or `yarn dlx`, even when the upstream project you're
> contributing to uses bun or yarn as its package manager. `pnpm dlx` runs the
> package identically regardless of the target project's package manager. See
> [typescript-monorepo-best-practices/pnpm-nx-monorepo.md](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md).

## Scope

Run the formatter on **only the files you created or modified**, not the
whole repo. A broad `--write .` could reformat unrelated files and create
noise in the PR diff. For modified files, the
[Massive-Change Guard](massive-change-guard.md) (run after lint) reverts
files where the combined format+lint diff exceeds a threshold.

## Order

Format runs **before** lint so the linter sees already-formatted files
and doesn't report style issues the formatter would have caught. Both
run before build/test so the build cycle isn't wasted on files that
would fail style CI.

## Related

* [Lint Artifacts](lint-artifacts.md) — linting catches semantic issues
  that formatting doesn't; format runs first, then lint
* [Separate Style Commit](separate-style-commit.md) — format and lint
  changes go in one combined style commit, separate from the feature
  commit
* [Massive-Change Guard](massive-change-guard.md) — guards against the
  formatter reformatting entire modified files
* [Linear History](linear-history.md) — the style commit is kept
  separate from the feature commit but both are part of clean linear
  history
