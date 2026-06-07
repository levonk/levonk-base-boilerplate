---
modeline: "vim: set ft=markdown:"
title: "ADR: Application Directory Organization"
adr-id: "adr-20251014002"
slug: "20251014002-application-organization"
url: "/internal-docs/adr/adr-20251014002-application-organization.md"
synopsis: "Defines the hierarchical structure for organizing applications in the apps/ directory."
author: "https://github.com/levonk"
date-created: "2025-10-14"
date-updated: "2025-10-15"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr"]
supersedes: []
superseded-by: []
related-to: ["adr-20251014001-refined-package-organization"]
---

## Context

As our monorepo grows, we need a formal structure for the `apps/` directory to complement the package organization defined in ADR 002. The current flat structure is insufficient for managing a growing number of applications that may belong to different product suites, target multiple platforms (web, node, iOS), and be written in various languages.

We also require a clear way to distinguish between applications that are in active development and those that are planned but on hold (in an "icebox").

## Decision

We will adopt a hierarchical, five-level directory structure for all applications within the `apps/` directory:

**`apps/{status}/{product-suite}/{app-name}/{platform}/{language}`**

### Directory Levels Explained

*   **`{status}`**: The lifecycle state of the application.
    *   `active`: For applications currently in development, testing, or production.
    *   `icebox`: For planned or conceptualized applications not yet in active development.

*   **`{product-suite}`**: A logical grouping for a collection of related applications that form a larger product.
    *   *Example*: `jobs-apps`, `recruiter-tools`.

*   **`{app-name}`**: The specific, individual application within the suite. For standalone apps, this will be the same as the `{product-suite}`.
    *   *Example*: `homepage`, `dashboard`, `ai-resume-analyzer`.

*   **`{platform}`**: The target runtime environment.
    *   *Example*: `web`, `node`, `ios`, `android`.

*   **`{language}`**: The primary implementation language.
    *   *Example*: `typescript`, `python`, `swift`.

## Rationale

This structure was chosen for several reasons:

*   **Consistency**: It mirrors the explicit, platform-first philosophy established for the `packages/` directory in ADR 002.
*   **Scalability**: It can handle significant complexity, including multiple applications per product suite and multiple platform-specific components per application.
*   **Clarity**: The path hierarchy makes the status, product affiliation, and technical stack of any application immediately obvious.

## Consequences

*   **Pros**:
    *   Cleanly separates active and inactive projects.
    *   Provides a logical grouping for related applications within a product suite.
    *   Maintains a consistent and predictable structure across the entire monorepo.
*   **Cons**:
    *   Creates deeper, more verbose file paths.
    *   Requires a one-time refactoring effort to move any existing applications into this new structure.

## Alternatives Considered

A flatter structure, `apps/{status}/{app-name}/{platform}/{language}`, was considered. It was rejected because it did not provide a mechanism for grouping related applications into product suites, which was a key requirement.
