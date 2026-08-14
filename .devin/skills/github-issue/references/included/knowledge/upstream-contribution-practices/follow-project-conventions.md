---
type: Practice
title: Follow Project Conventions
description: Match the project's existing style for changelog entries, issue/PR templates, documentation format, and translated docs. Prevents review feedback asking you to match their conventions.
tags: [conventions, style, changelog, templates, documentation, translation]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-issue-pr-templates-md-changelog-entry
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/references/issue-pr-templates.md
    title: "nixify issue-pr-templates.md — Changelog Entry"
  - id: nixify-skill-md-step-15
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 15"
---

# Follow Project Conventions

## Rule

Every artifact you produce — code, documentation, changelog entries,
issue bodies, PR bodies — should match the project's existing
conventions. Read their files first, then mimic the style.

## Why

Maintainers notice when a contribution doesn't match their conventions.
A changelog entry in the wrong tense, a README section in a different
heading style, or a missing translation update all generate review
feedback that delays the PR. Matching conventions signals you respect
the project's norms and did your homework.

## What to Match

### Changelog

If the project has a `CHANGELOG.md`, check:

- **Tense** — most use present tense ("Added" not "Adds")
- **Section structure** — `## Unreleased` → `### Added` / `### Changed`
  / `### Fixed` (Keep a Changelog format) or a custom format
- **Entry style** — reference issue numbers? Link to PRs? One line or
  multi-line?

```bash
# Check existing changelog style
head -50 CHANGELOG.md
```

### Issue and PR Templates

If the project has `.github/ISSUE_TEMPLATE/` or
`.github/PULL_REQUEST_TEMPLATE.md`, use them. Don't invent your own
format.

```bash
ls .github/ISSUE_TEMPLATE/
cat .github/PULL_REQUEST_TEMPLATE.md
```

### Documentation

Match the project's documentation style:

- **Heading levels** — if install instructions are `### Installation`,
  don't use `## Nix Installation`
- **Code block language tags** — if they use ```bash, don't use ```sh
- **Link style** — relative vs absolute, GitHub vs custom domain

### Translated Docs

If the project has translated READMEs (e.g., `README.ko.md`,
`README.zh-CN.md`, `README.ja.md`), mirror your changes to each
translation that exists. Don't update only the English README and leave
the translations stale.

```bash
# Find translated READMEs
ls README*.md
```

### Commit Messages

Match the project's commit message conventions:

- **Conventional Commits** (`feat:`, `fix:`, `docs:`) — check `git log`
  for the pattern
- **No commit trailers** — some projects don't use `Co-Authored-By` or
  `Generated with` lines. Check their existing commits before adding
  them.
- **Line length** — some projects enforce 72-character subject lines
- **Tag arrays** — some projects append a `#tag` array as the last line
  of the commit body for search/filter/analytics metadata. The
  `git-repository-management` skill uses this convention with
  `#skill-grm-created` as a provenance marker. See the shared
  `commit-tagging-standard` include for the full tag schema and the
  project-override config path.

```bash
# Check existing commit style
git log --oneline -20
```

{{{ include "includes/commit-tagging-standard.md" . }}}

## Related

* [Contribution Eligibility](contribution-eligibility.md) — reading
  CONTRIBUTING.md is where convention discovery starts
* [Format Artifacts](format-artifacts.md) — formatting is a subset of
  conventions; the formatter handles code style, this page covers
  everything else
* [Minimal Scope](minimal-scope.md) — don't reformat or restyle files
  you're not touching (scope expansion)
