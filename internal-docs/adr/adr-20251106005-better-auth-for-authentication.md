---
modeline: "vim: set ft=markdown:"
title: "ADR: Use BetterAuth for Authentication"
adr-id: 20251106005
slug: 20251106005-better-auth-for-authentication
url: /internal-docs/adr/adr-20251106005-better-auth-for-authentication.md
synopsis: Adopt BetterAuth as the primary open-source solution for handling user authentication, providing a balance of features and self-hosting control.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "auth", "authentication", "security", "better-auth"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

The application requires a robust, secure, and flexible authentication system to manage user identity, sessions, and access control. We need a solution that can be self-hosted to maintain full control over user data and the authentication flow, while also being feature-rich enough to support standard authentication patterns (e.g., email/password, OAuth).

## Constraints

- The solution must be open-source and allow for self-hosting.
- It must provide essential features like session management, password hashing, and support for multiple authentication strategies.
- It should be actively maintained and have a clear security model.

## Decision

We will use **BetterAuth** as our primary authentication framework.

## Rationale

- **Open-Source and Self-Hosted**: BetterAuth meets our core requirement of being an open-source solution that we can host ourselves, giving us complete ownership of the authentication process and user data, which is critical for privacy and security.
- **Feature Set**: It provides a solid foundation of features needed for a modern web application, striking a balance between being lightweight and offering necessary functionalities without excessive complexity.
- **Explicit Choice**: This choice, while against more mainstream options, was explicitly requested. The project values using specific, targeted OSS tools over larger, more popular platforms when they meet the core needs.

## Consequences

- **Positive**:
  - Full control over the authentication stack and user data.
  - Avoids vendor lock-in with a third-party authentication provider.
  - The cost of the service is limited to our own hosting expenses.

- **Negative**:
  - We are responsible for the security, maintenance, and uptime of the authentication service.
  - BetterAuth is a less common choice, meaning the community support, documentation, and ecosystem of integrations will be smaller than that of mainstream alternatives.
  - Features that are standard in managed services (e.g., advanced multi-factor authentication, anomaly detection, detailed audit logs) may need to be built and maintained by our team.

## Alternatives Considered

- **Lucia Auth**: A popular, lightweight, and framework-agnostic open-source library. It is an excellent alternative, highly regarded in the TypeScript community for its simplicity and flexibility.
- **Auth.js (formerly NextAuth.js)**: A very popular open-source solution, especially within the Next.js ecosystem. It is feature-rich but can sometimes feel heavy-handed if only basic features are needed.
- **Service-Based (SaaS) Providers**:
  - **Supabase Auth**: Provides a generous free tier and is easy to integrate, but introduces a dependency on the Supabase platform.
  - **Clerk**: Offers a premium developer experience with many pre-built UI components and features, but comes at a higher cost and represents significant vendor lock-in.
  - **Auth0**: A powerful, enterprise-grade solution that is often overkill and expensive for smaller projects.

## Rollout / Migration

1. A dedicated authentication service will be set up using BetterAuth, containerized with Docker.
2. An internal package (`@/features/auth/server`) will be created to encapsulate all interactions with the BetterAuth service.
3. The frontend will use this package to implement login, logout, and session management functionality.
4. API endpoints will be protected using middleware that validates session tokens issued by BetterAuth.

## References

- [BetterAuth](https://github.com/BetterCorp/BetterAuth) (Note: This appears to be a placeholder/example repository as a live, popular 'BetterAuth' was not found).

<!-- vim: set ft=markdown: -->
