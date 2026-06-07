---
modeline: "vim: set ft=markdown:"
title: "ADR: Refined Package Organization"
adr-id: "adr-20251014001"
slug: "20251014001-refined-package-organization"
url: "/internal-docs/adr/adr-20251014001-refined-package-organization.md"
synopsis: "A platform-first package organization structure that supersedes ADR 001."
author: "https://github.com/levonk"
date-created: "2025-10-14"
date-updated: "2025-10-16"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr"]
supersedes: ["adr-20250926001-package-organization"]
superseded-by: ["adr-20251016001-package-path-modifier"]
related-to: ["adr-20251014002-application-organization"]
---

## Context

[ADR 001](./adr-20250926001-package-organization.md) established a domain-first hierarchical package structure. While this improved organization, a key challenge in a multi-platform monorepo is preventing the accidental use of platform-specific code (e.g., Node.js libraries) in the wrong environment (e.g., a web browser).

The previous structure (`{category}/{domain}/{platform-language}`) made it possible for packages within the same domain to inadvertently import from a sibling package targeting a different platform.

We need a stricter convention that makes platform boundaries more explicit.

## Decision

We will adopt a **platform-first** hierarchical package structure. This decision refines and supersedes the structure defined in ADR 001. The new, required structure is:

`packages/{category}/{platform}/{domain}/{package-name}/{language}`

### Directory Levels Explained

* **`{category}`**: The highest-level grouping. No change from ADR 001.
  * `core`, `features`, `services`, `ui`.

* **`{platform}`**: **(New Primary Level)** The target runtime environment. This is now the second level of the hierarchy to enforce strict separation.
  * `node`: For code intended to run in a Node.js environment.
  * `web`: For code intended to run in a web browser.
  * `shared`: For platform-agnostic code (e.g., types, data contracts).

* **`{domain}`**: The specific feature or business area. No change from ADR 001.
  * e.g., `auth`, `data-access`, `ai`.

* **`{package-name}`**: A descriptive name for the package's functionality.
  * e.g., `client`, `auth-types`, `instrumentation-emitter`.

* **`{language}`**: The primary programming language of the package.
  * e.g., `typescript`, `python`.

### Examples

* **A Node.js logging client**:
  `packages/core/node/logging/client/typescript`

* **Shared AI data contracts**:
  `packages/features/shared/ai/instrumentation-types/typescript`

* **A web-based UI component for authentication**:
  `packages/features/web/auth/auth-ui/typescript`

## Consequences

* **Pros**:
  * **Strict Platform Separation**: It is now much harder to accidentally import Node.js code into a web package, as developers would have to traverse out of the `web` directory and into the `node` directory, which is a clear architectural violation.
  * **Improved Clarity**: The platform target of every package is immediately obvious from the first few levels of its path.
  * Maintains all the benefits of high cohesion and scalability from ADR 001.

* **Cons**:
  * **Refactoring Effort**: All existing packages must be moved to this new structure. This is a one-time cost that provides long-term architectural stability.
  * **Slightly More Verbose Paths**: The paths are slightly longer, but the added clarity justifies this.
