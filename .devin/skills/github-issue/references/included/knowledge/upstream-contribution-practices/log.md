---
type: Log
title: Bundle Update Log
description: Chronological history of updates to the Upstream Contribution Practices knowledge bundle.
tags: [log, history]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
---

# Bundle Update Log

## 2026-07-26
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md, migrated `# Citations` body sections to `sources` frontmatter with footnote attribution per §13.1, (migrated `timestamp` to `generated` if applicable).

## 2026-07-16
* **Initialization**: Created the Upstream Contribution Practices knowledge bundle at `src/current/knowledge/upstream-contribution-practices/`.
* **Creation**: Created bundle root `index.md` with `okf_version: "0.1"` and concept catalog.
* **Creation**: Created `overview.md` synthesis documenting the contribution lifecycle and mapping practices to phases.
* **Creation**: Created 6 concept pages extracted from the nixify skill: `gh-body-file.md`, `rebase-never-merge.md`, `upstream-identity.md`, `format-artifacts.md`, `linear-history.md`, `sync-before-push.md`.
* **Research**: Reviewed nixify SKILL.md.tmpl, issue-pr-templates.md, advanced-features.md, and scripts (sync-upstream.sh, setup-branch.sh, format-artifacts.sh, validate-pr-issue.sh) to extract generalizable practices. Cross-referenced with ax PR #27 review feedback.
* **Expansion**: Added 8 concept pages covering pre-flight, branching, scoping, and posting practices that were encoded in the nixify skill but not yet in the bundle:
  - `contribution-eligibility.md` — check project accepts contributions, read CONTRIBUTING.md, assess CLA/DCO risk
  - `search-before-opening.md` — search existing issues/PRs before opening new ones
  - `feature-branch-only.md` — always develop on a feature branch, never commit to main/master
  - `test-baseline.md` — run tests before starting, document pre-existing failures, don't fix unrelated bugs
  - `minimal-scope.md` — one working change per PR, don't combine unrelated features (nix flake + devbox lesson)
  - `follow-project-conventions.md` — match changelog, template, documentation, and commit message style
  - `git-author-privacy.md` — verify git author doesn't leak hostname/username, use GitHub noreply email
  - `human-review-gate.md` — present issue/PR content to user before posting, never auto-open
* **Update**: Reorganized `index.md` concept list to follow the contribution lifecycle order (pre-flight → branch → work → post).
* **Update**: Expanded `overview.md` lifecycle table from 6 to 14 practices, covering pre-flight, branch creation, pre-work, development, pre-commit, pre-push, and posting phases.

## 2026-07-15
* **Creation**: Added `no-user-identity-leak.md` — never include local user directories, usernames, or fork-specific paths in files destined for upstream repos. Distinct from `git-author-privacy.md` (which covers commit metadata); this covers file content. Confirm with user before any necessary personal reference (e.g., fork branch link in orientation issue).
* **Update**: Added `no-user-identity-leak.md` to `index.md` and `overview.md` lifecycle table (Development phase).

## 2026-07-16
* **Creation**: Added `lint-artifacts.md` — run linters (yamllint, markdownlint-cli2, statix, deadnix) on files you create/modify before the build/test phase. Auto-discover project lint configs; fall back to `nix run nixpkgs#<tool>` if linter not on host PATH. Distinct from `format-artifacts.md` (formatters normalize style; linters catch semantic issues). Format runs before lint; both run before build/test.
* **Creation**: Added `separate-style-commit.md` (originally `separate-lint-commit.md`, renamed) — keep format and lint fixes in one combined style commit, separate from the feature commit. Reviewers need to see what the tools changed independently, not hidden inside the larger feature diff. Format and lint go in one commit because they're both style-only changes. Complements `linear-history.md` (squash iterative commits, but keep the style commit separate).
* **Creation**: Added `massive-change-guard.md` — when a formatter or linter auto-fixes a file you modified (not created), revert if the combined format+lint-induced diff exceeds a threshold (default 20 lines). Pre-existing style issues belong to the project, not your PR. Prevents scope creep from aggressive auto-fix. The guard checks the combined diff because format runs before lint.
* **Creation**: Added `verify-command-currency.md` — tool commands get deprecated and renamed. Verify every command against current tool documentation before including it in a PR. Skill templates can become stale. Source: `nix profile install` was deprecated to `nix profile add` in Nix 2.30 (2025-07-07); the nixify skill v2.8.0 shipped deprecated syntax in 16 occurrences across 10 files, discovered during Archon PR #2131.
* **Update**: Added 4 new concepts to `index.md` (Lint Artifacts, Separate Style Commit, Massive-Change Guard, Verify Command Currency) between Format Artifacts and Sync Before Push.
* **Update**: Expanded `overview.md` lifecycle to include format, lint, and commit phases. Updated lifecycle diagram to `sync → commit feature → format → lint → commit style → scan → build → test → push`. Added 4 new rows to the lifecycle table (Pre-commit lint, Pre-commit verify, Commit separate-style, Commit massive-change-guard).
* **Update**: Updated `format-artifacts.md` to note format runs before lint, both run before build/test, and the massive-change guard covers combined format+lint diff. Updated Related links to point to `separate-style-commit.md` and `massive-change-guard.md`.
* **Update**: Renamed `separate-lint-commit.md` to `separate-style-commit.md` and rewrote to cover combined format+lint commit. Updated commit message from `style: lint nixify artifacts` to `style: format and lint nixify artifacts`.
