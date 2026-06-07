---
modeline: "vim: set ft=markdown:"
title: "ADR: Vitest and pnpm as Standard Tooling"
adr-id: "adr-20251017001"
slug: "20251017001-testing-and-package-management"
url: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251017001-testing-and-package-management.md"
synopsis: "Formalize Vitest for automated testing and pnpm for package management across the monorepo."
author: "https://github.com/levonk"
date-created: "2025-10-17"
date-updated: "2025-10-18"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr"]
supersedes: []
superseded-by: []
related-to: ["adr-20251014001-refined-package-organization", "adr-20251016001-package-path-modifier"]
---

# Architecture Decision Record: Vitest and pnpm as Standard Tooling

## Context

The monorepo hosts multiple applications, services, and shared packages. Teams need a consistent, performant tooling stack that integrates with pnpm builds, supports TypeScript-first workflows, and scales across many projects.

Historically, ad-hoc choices were made between Jest vs. Vitest and npm vs. pnpm, creating friction when switching contexts and bloating install times.

## Decision

We standardize on:

- **Vitest** for all unit, integration, and end-to-end test suites that run in Node-based environments.
- **pnpm** as the sole JavaScript package manager for dependency installation, scripting, and workspace orchestration.

## Rationale

- **Performance**: Vitest reuses Vite's lightning-fast ESBuild pipeline; pnpm's content-addressed store and deterministic lock file shorten installs.
- **TypeScript alignment**: Both tools have first-class TypeScript support, reducing friction in typed projects and enabling incremental adoption of advanced TS features.
- **Monorepo friendliness**: Vitest supports project-wide concurrency and watch mode; pnpm's workspace features align dependency graphs without duplicating node_modules trees.
- **Consistency**: A single toolchain eliminates context switching, documents best practices once, and simplifies onboarding.

## Consequences

### Pros
- Unified test runner and package manager accelerate CI/CD and local workflows.
- Reduced tooling surface area minimizes maintenance and documentation overhead.
- Easier caching and reproducibility thanks to pnpm's deterministic snapshots.

### Cons
- Contributors must migrate any legacy npm/yarn scripts to pnpm equivalents.
- Browser-only test scenarios may still require Playwright or Cypress in addition to Vitest.

## Implementation Notes

1. All package.json scripts must invoke `pnpm`, never npm, yarn, or bun.
2. Vitest configuration lives in `vitest.config.ts`; suites must import Vitest globals explicitly when run outside Vite contexts.
3. CI pipeline targets rely on `pnpm install --frozen-lockfile` and `pnpm test` as canonical commands.

## Status

Accepted. Applies to all existing and future JavaScript/TypeScript workspaces.

## References

- [Vitest documentation](https://vitest.dev/)
- [pnpm documentation](https://pnpm.io/)
