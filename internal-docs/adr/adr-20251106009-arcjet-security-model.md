---
modeline: "vim: set ft=markdown:"
title: "ADR: Adopt the ArcJet Model for Application Security"
adr-id: 20251106009
slug: 20251106009-arcjet-security-model
url: /internal-docs/adr/adr-20251106009-arcjet-security-model.md
synopsis: Implement a security strategy based on the ArcJet model, focusing on proactive, in-code defense against bots, rate-limiting abuse, and common exploits.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "security", "arcjet", "rate-limiting", "bot-protection"]
supersedes: []
superseded-by: []
related-to: []
---

## Architecture Decision Record: Adopt the ArcJet Model for Application Security

## Context

Modern web applications are constant targets for automated bots, denial-of-service attacks, and various security exploits. We need a robust, multi-layered security strategy to protect our application, user data, and infrastructure. This strategy should be implemented as close to the application code as possible to provide context-aware protection.

## Constraints

- The security solution must protect against common threats like credential stuffing, content scraping, and application-layer DDoS attacks.
- It must include intelligent rate limiting to prevent abuse without harming legitimate user experience.
- It should be implemented within the application code (e.g., as middleware) to leverage application context for decision-making.

## Decision

We will adopt the security patterns and architectural model championed by **ArcJet**. This means implementing security middleware directly within our application stack to handle:

1. **Rate Limiting**: Sophisticated rate limiting (e.g., token bucket, sliding window) to protect sensitive endpoints.
2. **Bot Protection**: Defense against automated threats.
3. **Email Verification**: Protection for sign-up forms.
4. **Exploit Prevention**: Guarding against common attack vectors.

While we will follow the ArcJet model, we are not strictly committing to using the ArcJet service itself. We may implement these patterns using open-source libraries or our own code initially, with the option to adopt the managed ArcJet service later if needed.

## Rationale

- **Defense in Depth**: The ArcJet model promotes embedding security directly into the application layer. This provides a critical defense layer that complements, rather than replaces, traditional infrastructure-level security (e.g., WAFs from Cloudflare).
- **Context-Aware Security**: By running inside the application, the security middleware has access to the full application context (e.g., user identity, session data), allowing for much more intelligent and precise security decisions than a generic, edge-based WAF.
- **Developer-Centric**: This approach treats security as a code problem, which aligns with our team's expertise. Developers can define, test, and version security policies alongside the application code.
- **Flexibility**: By deciding to follow the *model* rather than mandating the *service*, we retain the flexibility to choose the best implementation (build vs. buy) for our needs at any given time.

## Consequences

- **Positive**:
  - Stronger, more context-aware protection against automated attacks and abuse.
  - Security policies are version-controlled, testable, and part of the standard development workflow.
  - Reduced risk of false positives that block legitimate users, as decisions can be more granular.

- **Negative**:
  - Implementing these patterns ourselves (if we choose not to use the ArcJet service) requires significant security expertise and development effort.
  - The security middleware will consume some application resources (CPU, memory).

## Alternatives Considered

- **Relying Solely on Edge WAF (e.g., Cloudflare)**: While essential, edge WAFs lack application-level context. They are good for blocking known bad IPs and generic attack patterns but are less effective against sophisticated, application-specific abuse.
- **Using a Traditional WAF Appliance**: These are often complex to configure, expensive, and suffer from the same lack of application context as edge WAFs.
- **Custom Middleware from Scratch**: Building all security logic from scratch without a guiding model like ArcJet's would be time-consuming and likely result in a less comprehensive solution.

## Rollout / Migration

1. A security-focused package (`@/core/security`) will be created in the monorepo.
2. Initial implementation will focus on adding rate limiting to the most critical API endpoints (e.g., login, password reset).
3. We will use a library like `upstash/ratelimit` with Redis for a scalable implementation.
4. Bot detection and other protections will be layered in incrementally.

## References

- [ArcJet](https://arcjet.com/)
- [Upstash Rate Limiting](https://upstash.com/docs/redis/features/rate-limiting)

<!-- vim: set ft=markdown: -->
