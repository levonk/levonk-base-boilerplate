---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Vitest for TypeScript Testing"
adr-id: 20251106002
slug: 20251106002-vitest-for-testing
url: /internal-docs/adr/adr-20251106002-vitest-for-testing.md
synopsis: Adopt Vitest as the standard testing framework for unit and integration tests, and as the test runner for E2E tests, to ensure a fast, modern, and unified testing strategy.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "testing", "vitest", "typescript", "e2e"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106001-pnpm-and-turborepo", "adr-20260104001-hybrid-webui-testing-playwright-stagehand"]
---


## Context

The project requires a comprehensive testing strategy covering unit, integration, and end-to-end (E2E) tests. We need a testing framework that is fast, integrates seamlessly with our TypeScript and `pnpm/Turborepo` monorepo setup, and provides a consistent developer experience across different types of testing.

## Constraints

- The framework must have first-class TypeScript and ES Modules (ESM) support.
- It must be fast to keep the feedback loop short for developers and CI builds.
- It must integrate well with our existing monorepo tooling.
- It must be capable of running different types of tests, including unit, integration, and serving as a runner for E2E tests.

## Decision

We will use **Vitest** as the primary framework for all TypeScript testing.

- **Unit & Integration Tests**: Vitest will be used directly to write and run these tests.
- **End-to-End (E2E) Tests**: Vitest will act as the test runner, orchestrating tests that use **Stagehand** (with Playwright for browser automation). This includes both procedural tests for requirement compliance and agent-based tests to evaluate UX and AI behavior. For detailed standards on Stagehand/Playwright hybrid usage, see [ADR 20260104001](./adr-20260104001-hybrid-webui-testing-playwright-stagehand.md).

## Rationale

- **Performance**: Vitest is built on top of Vite and is significantly faster than older frameworks like Jest, leveraging native ESM and a smart test-filtering system.
- **Modern Tooling**: It provides out-of-the-box support for TypeScript and ESM, eliminating the complex configuration and transpilation steps often required by other frameworks.
- **Unified Experience**: Using Vitest for all layers of testing (unit, integration, E2E runner) provides a single, consistent API and developer experience, reducing cognitive overhead.
- **Jest Compatibility**: Its API is largely compatible with Jest, making it familiar to many developers and simplifying any potential future migrations.
- **Monorepo Integration**: Vitest's workspace feature works seamlessly within our `pnpm` and `Turborepo` setup, allowing for efficient, isolated testing of individual packages.

## Consequences

- **Positive**:
  - A fast, modern, and unified testing experience for all developers.
  - Reduced configuration overhead for testing.
  - Faster CI/CD pipeline execution times due to Vitest's performance.
  - A clear strategy for different levels of testing.

- **Negative**:
  - Developers accustomed to Jest may need a brief period to adjust, although the API similarity minimizes this.

## Alternatives Considered

- **Jest**: The long-time standard for JavaScript testing. However, it is slower than Vitest and requires more complex configuration for modern TypeScript and ESM projects.
- **Mocha & Chai**: A classic and flexible combination, but it lacks the integrated, "all-in-one" developer experience that Vitest provides. It would require more setup to achieve a similar level of functionality.
- **Playwright Test Runner**: Playwright has its own excellent test runner, which is a strong candidate for E2E testing. However, by using Vitest as the runner for all test types, we achieve a more unified ecosystem and syntax across the board.

## Rollout / Migration

1. A global `vitest.config.ts` will be created at the root of the monorepo.
2. Individual packages will extend this root configuration as needed.
3. New features must include unit tests written with Vitest.
4. E2E testing suites will be set up in dedicated test packages using Vitest and Stagehand.
5. `package.json` scripts (`"test"`, `"test:e2e"`) will be standardized to use `vitest` commands.

## To Investigate

- Explore Vitest's UI for a more interactive testing and debugging experience during development.
- Evaluate the performance of the Stagehand agent mode for AI-driven E2E testing.

## References

- [Vitest](https://vitest.dev/)
- [Stagehand](https://docs.stagehand.dev/)

<!-- vim: set ft=markdown: -->
