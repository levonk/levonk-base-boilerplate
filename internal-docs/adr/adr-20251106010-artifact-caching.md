---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Verdaccio and Nexus for Artifact Caching"
adr-id: 20251106010
slug: 20251106010-artifact-caching
url: /internal-docs/adr/adr-20251106010-artifact-caching.md
synopsis: Adopt Verdaccio as a dedicated npm cache and Sonatype Nexus as a multi-format cache (Docker, PyPI, Maven) to improve build speed and reliability.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2026-04-19
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "caching", "artifacts", "verdaccio", "nexus", "ci", "build-system"]
supersedes: []
superseded-by: []
related-to: ["adr-20260419001-nx-monorepo-build-tool"]
---

## Architecture Decision Record: Use Verdaccio and Nexus for Artifact Caching

> **Note**: With the adoption of NX ([ADR 20260419001](./adr-20260419001-nx-monorepo-build-tool.md)), the unified NX cache may reduce reliance on Nexus for Docker caching. This ADR remains valid for npm (Verdaccio) and as fallback, but NX's built-in caching may consolidate some artifact caching needs.

## Context

Our monorepo relies on numerous external dependencies from various package registries (npmjs.org, Docker Hub, PyPI, etc.). Fetching these dependencies over the public internet during every build is slow, subject to network failures and rate limiting, and introduces a dependency on third-party uptime. We need a robust caching layer to mitigate these issues.

## Constraints

- The solution must support caching for npm, Docker images, Python packages, and Maven artifacts.
- It must be self-hostable within our containerized environment.
- It must integrate seamlessly with our developer tools (`pnpm`, `docker`, `pip`) and CI/CD pipeline.

## Decision

We will implement a two-part artifact caching strategy:

1. **Verdaccio**: Will be used as a private, lightweight proxy and cache specifically for npm packages.
2. **Sonatype Nexus Repository OSS**: Will be used as a powerful, multi-format repository to proxy and cache Docker images, PyPI packages, Maven artifacts, and potentially other formats in the future.

## Rationale

- **Specialization and Simplicity**: This approach uses the best tool for the job. Verdaccio is extremely simple to set up and maintain for its sole purpose: npm caching. Nexus is an industry-standard, feature-rich repository manager that excels at handling the complexity of multiple binary formats like Docker images.
- **Performance and Reliability**: Caching artifacts on our local network will dramatically reduce build times and eliminate build failures caused by transient network issues or public registry outages.
- **Security and Control**: It provides a single, controlled gateway for all external dependencies. This enables future initiatives like security scanning of all downloaded artifacts and enforcing policies about which packages are allowed.
- **Separation of Concerns**: Using two separate tools isolates our primary JavaScript ecosystem (Verdaccio) from all other artifact types (Nexus). This simplifies configuration and prevents a misconfiguration in one format from impacting another.

## Consequences

- **Positive**:
  - Significantly faster and more reliable local and CI builds.
  - Reduced reliance on external services' uptime.
  - A centralized point for auditing and securing third-party dependencies.

- **Negative**:
  - We are responsible for deploying, maintaining, securing, and backing up two additional infrastructure services.
  - Requires initial configuration effort on developer machines and in CI to point all tools to the new repository URLs.

## Alternatives Considered

- **Nexus for Everything**: Using Nexus to proxy npm packages is possible. However, its npm support is more complex to configure than Verdaccio, which is purpose-built and works flawlessly out of the box.
- **JFrog Artifactory**: A direct and powerful competitor to Nexus. Nexus was chosen primarily for its widespread use and what is often considered a more generous and capable open-source offering.
- **Cloud-Based Registries (GitHub Packages, etc.)**: While convenient, self-hosting provides greater control, can be more cost-effective at scale, and ensures functionality even if our connection to the public internet is degraded.

## Rollout / Migration

1. Verdaccio and Nexus will be deployed as containerized services within our local development environment.
2. The `.npmrc` file at the root of the monorepo will be configured to point `pnpm` to the Verdaccio registry URL.
3. Docker clients will be configured to use Nexus as a pull-through cache.
4. `pip` and `Maven` configurations will be updated to use the respective Nexus proxy repositories.
5. CI/CD scripts will be updated to perform this same configuration at the start of each job.

## References

- [Verdaccio](https://verdaccio.org/)
- [Sonatype Nexus Repository](https://www.sonatype.com/products/nexus-repository)

<!-- vim: set ft=markdown: -->
