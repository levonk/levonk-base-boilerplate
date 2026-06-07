---
modeline: "vim: set ft=markdown:"
title: "ADR: Use oRPC for APIs and Zod for Validation"
adr-id: 20251106004
slug: 20251106004-orpc-and-zod-for-apis
url: /internal-docs/adr/adr-20251106004-orpc-and-zod-for-apis.md
synopsis: Adopt oRPC for the API communication layer and Zod for data schema definition and validation to ensure end-to-end type safety and data integrity.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "api", "rpc", "orpc", "zod", "validation", "typescript"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

We need a robust, type-safe, and efficient method for communication between our frontend and backend services. Furthermore, all data crossing service boundaries must be rigorously validated to ensure data integrity and prevent security vulnerabilities. The solution should provide an excellent developer experience within our TypeScript monorepo.

## Constraints

- The solution must provide end-to-end type safety from the server to the client.
- It must be framework-agnostic and work well with our chosen frontend (Next.js) and backend (Node.js) environments.
- The validation library must be powerful, well-maintained, and have strong type-inference capabilities.

## Decision

1. We will use **oRPC** as the RPC framework for defining and handling API procedures.
2. We will use **Zod** for defining all data schemas and performing validation on all API inputs and outputs.

## Rationale

- **oRPC**: This is a lightweight, minimalistic RPC framework that offers a simple way to create type-safe APIs without the complexity of larger frameworks. Its simplicity aligns with a desire to use focused tools that do one job well.

- **Zod**: Zod is the de-facto standard for schema declaration and validation in the TypeScript ecosystem. Its key advantage is its ability to infer static TypeScript types directly from the validation schema. This ensures that our static types and our runtime validators can never drift out of sync, eliminating a common source of bugs. It has a rich feature set and a massive community.

- **Why Zod over ArkType**: While ArkType is a compelling alternative with excellent performance and a unique ability to infer types from string definitions, Zod is the more mature and battle-tested choice. Zod's ecosystem of integrations (e.g., for form generation, mock data) is larger, and its "define-first" API is arguably more explicit and easier to maintain for complex, nested data structures. For this project, the stability, community support, and ecosystem of Zod are prioritized over the novel approach and raw performance of ArkType.

## Consequences

- **Positive**:
  - Guarantees end-to-end type safety between the client and server.
  - Provides a single source of truth for data shapes, used for both runtime validation and static typing.
  - Reduces boilerplate and eliminates the need to maintain separate type definitions and validation logic.

- **Negative**:
  - `oRPC` is a niche framework compared to alternatives like `oRPC`. This means there will be fewer community resources, tutorials, and pre-built integrations available. The team will need to rely more on the official documentation.

## Alternatives Considered

- **oRPC**: The most popular choice for this kind of architecture. It is more feature-rich and has a larger community than `oRPC`. However, `oRPC` was chosen for its minimalism.
- **REST + OpenAPI/Swagger**: The traditional approach. It is language-agnostic but requires significant boilerplate and manual effort to keep client-side types and server-side validation in sync with the OpenAPI schema.
- **GraphQL**: Extremely powerful for complex data-fetching requirements and provides strong typing. However, it introduces significant complexity to both the client and server, including schema management, resolvers, and specialized client libraries.

## Rollout / Migration

1. A shared package (e.g., `@/core/api`) will be created in the monorepo.
2. This package will contain the shared Zod schemas and the oRPC router definitions.
3. The first new API endpoint will be built using this pattern to establish best practices.
4. All subsequent API development will adhere to this ADR.

## References

- [oRPC](https://github.com/unnoq/orpc)
- [Zod](https://zod.dev/)
- [ArkType](https://arktype.io/) (Alternative Considered)

<!-- vim: set ft=markdown: -->
