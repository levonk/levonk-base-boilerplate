---
type: feature
slug: cargo-audit-wiring
title: Wire cargo audit and dependency update into Rust boilerplate validation
status: in-progress
created: 2026-08-20
completed: ""
last-activity: 2026-08-20
---

# PRD: Wire cargo audit and dependency update into Rust boilerplate validation

## Context

GitHub reported 4 Dependabot vulnerabilities on the `levonk/apmw` default branch
(1 high, 1 moderate, 2 low). The `apmw` project was generated from the Rust CLI
boilerplate template. The boilerplate templates already define `just audit` (which
runs `cargo audit`) as a standalone target, but it is **not wired into** the
validation/quality/release pipelines or CI. This means generated projects do not
automatically catch known vulnerabilities during local validation or CI runs.

## Goal

Wire `cargo audit` and a dependency-outdated check into the standard validation
paths of all Rust boilerplate templates so that every generated Rust project
automatically runs security auditing as part of:

1. `just validate` / `just quality` / `just release` (local developer workflow)
2. CI pipelines (GitHub Actions)
3. Nx `audit` target (for monorepo-generated projects)

## Scope

### In scope

- **`_shared/partials/nx-partials/nx-target-rust.jinja`** — add an `audit` Nx target
- **`_shared/partials/devbox-partials/devbox-packages-rust.jinja`** — new shared partial with rust devbox packages including `cargo-audit` and `cargo-outdated`
- **`_shared/.github/workflows/rust-ci.yml.jinja`** — new shared CI workflow (test, lint, build, security/audit, outdated-check)
- **`_shared/.github/workflows/rust-weekly-outdated.yml.jinja`** — new shared weekly workflow that runs `cargo update` (no dry-run) and creates a PR
- **Package Rust template** (`packages/category/general/domain/package-name/rust/core/files/`) — wire `cargo audit` + `cargo outdated` into `validate`, add `outdated` target, use shared devbox packages partial, add shared CI workflows
- **CLI Rust template** (`apps/cli/rust/core/files/`) — wire `cargo audit` + `cargo outdated` into `quality` and `release`, add public `audit` and `outdated` targets, use shared devbox packages partial, use shared CI workflows
- **README docs** — update to reflect audit + outdated in validation
- **AGENTS.md** — document shared Rust CI partials

### Out of scope

- Fixing the `make` vs `just` documentation inconsistency in the package Rust README
- Updating the `apmw` project itself (that's a downstream project, not a boilerplate)
- Adding `cargo deny` or other supply-chain tools (cargo audit + cargo outdated is the scope)

## Technical approach

### cargo audit in validation

`cargo audit` checks the `Cargo.lock` against the RustSec advisory database. It
is already installed via `devbox.json` (`cargo-audit` package). The audit target
should be non-fatal when `cargo-audit` is not installed (warn and continue) so
that local development without devbox doesn't break, but CI should require it.

### cargo outdated / dependency update

`cargo outdated` is not in devbox.json. Rather than adding a new devbox package,
we use `cargo update --dry-run` for the outdated check — it's available with
stock cargo and shows what dependencies have available updates. The `outdated`
target will report available updates without making changes.

### Nx audit target

The `nx-target-rust.jinja` partial gets a new `audit` target using
`nx:run-commands` with `cargo audit`. This target is not cached (audit results
can change as new advisories are published).

## Acceptance criteria

1. `just validate` in the package Rust template runs `cargo audit` as part of validation
2. `just quality` and `just release` in the CLI Rust template run `cargo audit`
3. `just audit` is available as a standalone target in the CLI Rust template (it already exists in the package template)
4. `just outdated` is available in both Rust templates, showing available dependency updates
5. The CLI Rust CI workflow has a `security` job that runs `cargo audit`
6. The `nx-target-rust.jinja` partial includes an `audit` target
7. README documentation reflects the new audit-in-validation behavior
8. No existing targets are removed or renamed — only additions and wiring

## Risks

- **cargo-audit not installed locally**: Mitigated by the existing pattern of checking `command -v cargo-audit` and warning if missing. CI installs it explicitly.
- **cargo audit failures blocking CI**: The CI security job runs `cargo audit` — if it fails on a real vulnerability, that's the desired behavior (block the build). For advisory-only warnings, `cargo audit` exits 0.
- **cargo update --dry-run output format**: May vary between cargo versions. The `outdated` target is informational only (non-fatal).
