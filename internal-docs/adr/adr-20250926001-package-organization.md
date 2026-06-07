---
modeline: "vim: set ft=markdown:"
title: "ADR: Package Directory Organization"
adr-id: "adr-20250926001"
slug: "20250926001-package-organization"
url: "/internal-docs/adr/adr-20250926001-package-organization.md"
synopsis: "Original package organization structure (superseded by ADR 002)."
author: "https://github.com/levonk"
date-created: "2025-09-26"
date-updated: "2025-10-15"
version: "1.0.0"
status: "superseded"
aliases: []
tags: ["doc/architecture/adr", "adr"]
supersedes: []
superseded-by: ["adr-20251014001-refined-package-organization"]
related-to: []
---

**Superseded by**: [ADR 002: Refined Package Organization](./adr-20251014001-refined-package-organization.md)

## Context

The monorepo's `packages/` directory has been growing with a flat structure, where packages are grouped loosely by a high-level concept (e.g., `ai`, `auth`). As the number of packages increases, this structure is becoming difficult to navigate and scale. We anticipate needing to support multiple language-specific implementations (e.g., TypeScript, Python, Swift) for the same features in the future.

We need a more organized, scalable, and intuitive structure for our packages.

## Decision

*This ADR is superseded. See [ADR 002](./adr-20251014001-refined-package-organization.md) for the current package structure.*

We will adopt a domain-first, hierarchical package structure within the `packages/` directory. The structure is defined as follows:

```sh
packages/
└── {category}/
    └── {domain}/
        └── {platform-language}/
                └── package.json

### Guiding Principle: Vertical Slicing (Feature-First)

A core principle of this architecture is to organize code by **feature (vertical slicing)** rather than by **layer (horizontal slicing)**.

This means that all the code related to a single feature—including its UI, business logic, data access, and service integrations—should be co-located within that feature's domain directory (e.g., `packages/features/commerce/`).

We explicitly avoid organizing the codebase into top-level layer directories like `packages/data/` or `packages/ui/` that serve multiple features, as this would scatter the code for a single feature across many different parts of the repository. This makes features harder to understand, maintain, and assign ownership.

### Directory Levels Explained

1. **`{category}`**: The highest level of organization. This groups packages by their broad functional purpose. Initial categories include:
    *   `features`: Core business logic and product features that represent a user-facing capability (e.g., `auth`, `commerce`, `documents`).
    *   `services`: Clients or adapters for specific, low-level external services. These do not contain business logic (e.g., `ai`, `blob-storage`).
    *   `core`: Foundational, shared utilities that are product-agnostic (e.g., `logging`, `utils`).
    *   `ui`: Shared UI components, hooks, and design system elements.

2.  **`{domain}`**: A specific business domain or technical capability. For example, under the `features` category, we might have `commerce` or `search`. Under `services`, we might have `ai` or `blob`.

3.  **`{platform-language}`**: Specifies the target platform and language for the implementation (e.g., `web-typescript`, `api-python`, `ios-swift`). For shared, language-agnostic code (like type definitions), a `shared/` directory can be used.

4.  **`{package-name}`**: The final, specific name of the package (e.g., `payments-stripe`, `subscriptions-manager`).

### Example

```sh
packages/
└── features/
    └── commerce/
        ├── payments/
        │   ├── shared/
        │   │   └── payments-types/
        │   │       └── package.json
        │   └── web-typescript/
        │       └── payments-stripe/
        │           └── package.json
        └── subscriptions/
            └── web-typescript/
                └── subscriptions-manager/
                    └── package.json
```

## Consequences

* **Pros**:
  * **Improved Discoverability**: Developers can easily find code related to a specific feature or integration.
  * **High Cohesion**: All code for a single feature domain is co-located, making it easier to reason about and maintain.
  * **Scalability**: The structure can easily accommodate new features, platforms, and languages without becoming disorganized.
  * **Clear Ownership**: It's easier to assign ownership of specific domains to teams or individuals.
* **Cons**:
  * **Increased Path Depth**: File paths will be longer, which is a minor inconvenience.
  * **Refactoring Effort**: Existing packages must be moved, and build/configuration files (`BUILD.bazel`, `tsconfig.base.json`, etc.) must be updated to reflect the new paths. This is a one-time cost.
