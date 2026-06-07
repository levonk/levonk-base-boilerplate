---
modeline: "vim: set ft=markdown:"
title: "ADR: Runtime Guards for Browser-Safe Web Applications"
adr-id: "adr-20251018001"
slug: "20251018001-runtime-guards-browser-safety"
url: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251018001-runtime-guards-browser-safety.md"
synopsis: "Adopt @job-aide/runtime-guards to standardize browser/server runtime checks in web applications."
author: "https://github.com/levonk"
date-created: "2025-10-18"
date-updated: "2025-10-18"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr"]
supersedes: []
superseded-by: []
related-to: ["adr-20251014001-refined-package-organization", "adr-20251017001-testing-and-package-management"]
application: "apps/active/job/ai-resume-analyzer/web/typescript"
package: "@job-aide/runtime-guards"
---

# Architecture Decision Record: Runtime Guards for Browser-Safe Web Applications

## Context

- React and Next.js applications interact with browser-only APIs such as `window`, `document`, and `URL.createObjectURL`.
- Remix Router executes loaders and components during server-side rendering; unguarded browser code can throw reference errors on the server.
- The shared package `packages/active/core/runtime/runtime-guards/typescript` already exports lightweight guards and assertions for environment detection.

## Constraints

- The monorepo standardizes on pnpm.
- Browser-specific logic must coexist with server-rendered routes without duplicating implementation across separate entry points.
- TypeScript consumers expect type-safe assertions to narrow browser-only types.

## Decision

- Adopt `@job-aide/runtime-guards` as the canonical way to detect browser versus server execution within web applications.
- Require all modules that touch browser globals to import `isBrowser`, `assertBrowser`, or `assertServer` before executing window-dependent logic or dynamic imports.
- Centralize environment checks inside shared utilities (for example, `app/lib/puter.ts`, `app/lib/pdf2img.ts`) so UI components can assume safe browser access once the guard passes.

## Rationale

- The runtime guard package provides reusable, well-tested abstractions that reduce copy-pasted `typeof window !== "undefined"` snippets.
- Guard functions expose TypeScript type predicates and assertion signatures, improving IDE assistance and preventing accidental server execution.
- Consolidating on a shared guard library keeps future SSR migrations or platform changes consistent across applications.

## Consequences

### Pros

- Fewer SSR regressions from accidentally accessing browser-only globals during server rendering.
- Clear, documented pattern for environment detection that onboarding engineers can follow.
- Reuse of existing core package code avoids reinventing guard utilities in each application.

### Cons

- Requires auditing existing modules to ensure imports use the shared guards.
- Slightly increases dependency surface for web apps that previously relied on inline checks.

## Alternatives Considered

- **Option A — Inline `typeof window` checks**: Rejected because the pattern is error-prone, lacks shared typing, and duplicates logic across modules.
- **Option B — Split browser-only logic into separate entry points**: Rejected due to higher maintenance overhead and duplicated routing code.

## Rollout / Migration

- Add `@job-aide/runtime-guards` as a workspace dependency for the AI Resume Analyzer web app.
- Refactor browser-only utilities (`app/lib/puter.ts`, `app/lib/pdf2img.ts`, and related components) to invoke `isBrowser` or `assertBrowser` before accessing DOM APIs.
- Validate SSR routes via existing Vitest suites and Playwright E2E tests to confirm no regressions.

## To Investigate

- Provide lint rules or codemods that flag direct `window`/`document` access without a guard.
- Evaluate whether other web applications should adopt the same pattern and share migration scripts.

## Notes

- Document the current guard usage in `internal-docs/ARCHITECTURE.md` so future ADRs reference the standard.
- Ensure web based pnpm `apps/` targets include the guard package in their dependency graph to avoid build failures.

## References

- `packages/active/core/runtime/runtime-guards/typescript`
- `apps/active/job/ai-resume-analyzer/web/typescript`
- ADR 005: Vitest and pnpm as Standard Tooling`
