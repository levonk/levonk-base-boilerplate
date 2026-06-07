---
modeline: "vim: set ft=markdown:"
title: "ADR: Use pnpm and Turborepo for Monorepo Management"
adr-id: "adr-20251106001"
slug: 20251106001-pnpm-and-turborepo
url: /internal-docs/adr/adr-20251106001-pnpm-and-turborepo.md
synopsis: Standardize on pnpm for package management and Turborepo for build orchestration to ensure efficient, consistent, and scalable development in the monorepo.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2026-04-19
version: 1.0.0
status: "superseded"
aliases: []
tags: ["doc/architecture/adr", "pnpm", "turborepo", "monorepo", "build-system"]
supersedes: []
superseded-by: ["adr-20260419001-nx-monorepo-build-tool"]
related-to: ["adr-20260131001-standard-developer-ux-flow", "adr-20260419001-nx-monorepo-build-tool"]
---


> ⚠️ **SUPERSEDED**: This ADR has been superseded by [ADR 20260419001: Use NX for Monorepo Build Orchestration](./adr-20260419001-nx-monorepo-build-tool.md). The decision to use Turborepo has been reversed in favor of NX to support polyglot build orchestration across JavaScript, Docker, Python, and Rust.

## Context

The project is a monorepo containing multiple TypeScript applications and packages. As the number of projects grows, we need a robust, efficient, and scalable way to manage dependencies, run scripts, and orchestrate builds. The current setup has shown inconsistencies, with some packages using `bun` while the stated preference is `pnpm`. This leads to confusion, duplicated effort, and potential dependency conflicts.

## Constraints

- The solution must support a TypeScript-heavy monorepo.
- It must be fast and efficient, especially concerning disk space and installation times.
- It must provide robust build caching and task orchestration to avoid re-building unchanged code.
- It must integrate well with our CI/CD pipeline (GitHub Actions).

## Decision

We will exclusively use **pnpm** as the package manager and **Turborepo** as the high-level build system/task runner across the entire monorepo.

## Rationale

- **pnpm**: Its non-flat `node_modules` structure and content-addressable store are highly efficient for monorepos. It saves significant disk space by symlinking dependencies, and its strictness helps prevent phantom dependency issues, where packages can access modules they don't explicitly declare in `package.json`.

- **Turborepo**: It excels at managing monorepo workflows. Its remote caching feature dramatically speeds up CI/CD pipelines by ensuring that we only build and test what has changed. Its task dependency graph (`"dependsOn"`) allows for precise and parallelized execution of scripts.

- **Combined Power**: `pnpm` workspaces integrate seamlessly with Turborepo. This combination is a well-established industry best practice for high-performance TypeScript monorepos.

- **Rule Alignment**: This decision formalizes the existing repository policy documented in memory (`MEMORY[674b4b04-274f-4c14-9677-dc1b01ac91af]`), which mandates the use of `pnpm`.

## Consequences

- **Positive**:
  - Faster, more reliable dependency installation and builds.
  - Reduced disk space usage.
  - A single, unified workflow for all developers.
  - Simplified CI/CD configuration.
  - Stricter dependency management reduces a class of common bugs.

- **Negative**:
  - Developers unfamiliar with `pnpm` or Turborepo will have a learning curve.
  - All existing projects using `bun` or other package managers must be migrated.

## Alternatives Considered

- **npm/yarn with Lerna**: Lerna is a classic monorepo tool, but Turborepo has largely superseded it in terms of performance and caching capabilities. `npm` and `yarn` (v1) create bloated `node_modules` directories, which is inefficient for monorepos.

- **Bun**: While `bun` is extremely fast, `pnpm`'s ecosystem is more mature and its dependency management model is arguably better suited for preventing phantom dependencies in a large monorepo. Given the existing preference for `pnpm`, standardizing on it is the path of least resistance.

- **Nx**: Nx is another powerful monorepo tool. However, Turborepo is often considered simpler to configure and adopt, providing most of the benefits (like caching and task scheduling) with less boilerplate.

## Rollout / Migration

1. An audit will be performed to identify any projects currently using `bun.lock` or `package-lock.json`.
2. These lockfiles will be deleted, and `pnpm import` will be used to generate `pnpm-lock.yaml` files.
3. All `package.json` scripts will be reviewed to ensure they are compatible with `pnpm` and Turborepo's execution model.
4. A root `turbo.json` file will be configured to define the pipeline dependencies.
5. CI workflows will be updated to use `pnpm` and `npx turbo ...` commands.
6. Documentation will be updated to reflect this as the standard.

## To Investigate

- Explore Turborepo's remote caching options (e.g., Vercel's remote cache or self-hosted alternatives) to maximize CI performance.

## References

- [pnpm](https://pnpm.io/)
- [Turborepo](https://turbo.build/repo)
- [Monorepo Handbook](https://monorepo.tools/)

<!-- vim: set ft=markdown: -->
