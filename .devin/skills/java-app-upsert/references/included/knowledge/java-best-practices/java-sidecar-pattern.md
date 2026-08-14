---
type: Practice
title: Java Sidecar Pattern — Development Sidecars with Shared Caches
description: Package Java and Gradle as development sidecars that share Maven and Gradle cache volumes, depend on a base sidecar, and provide isolated tooling without bloating the main service image.
tags: [java, gradle, sidecar, containers, development, caching, multi-stage]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
  - id: infrahub-gradle-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/gradle-sidecar/Dockerfile.gradle-sidecar
    title: infrahub gradle-sidecar Dockerfile
  - id: infrahub-artifact-docker-compose
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/docker-compose.artifact.yml
    title: infrahub artifact docker-compose
---

# Java Sidecar Pattern

## Failure Mode

Development environments install Java/Gradle directly on the host, leading to
version conflicts, slow onboarding, and wasted time reproducing CI build issues.
Alternatively, every app image includes a full JDK, bloating production images.

## Symptoms

- "It works on my machine" because the host JDK differs from CI.
- Production images ship a JDK because the build step needs it.
- New team members spend hours installing the right Java version.
- Gradle dependencies are re-downloaded on every fresh container.

## Practice

### Sidecar Architecture

The infrahub pattern uses separate sidecar containers for build tools:

- `java-sidecar` — provides OpenJDK 17 and a `java-m2-cache` volume for Maven
  artifacts.
- `gradle-sidecar` — provides Gradle 8.5 and a `gradle-cache` volume.
- Both depend on `nix-sidecar` for Nix store/config and a `localnet-base-*`
  image for user/permissions.

### Multi-Stage Gradle Sidecar

```dockerfile
FROM localnet-base-alpine:latest AS gradle-builder
RUN apk add curl unzip ca-certificates
# Download Gradle 8.5

FROM localnet-base-sidecar:latest
RUN apk add openjdk17-jre
COPY --from=gradle-builder /opt/gradle /opt/gradle
```

The builder stage downloads and unpacks Gradle; the runtime stage only needs a
JRE and the unpacked Gradle distribution.

### Cache Volumes

- `java-m2-cache` mounted at `~/.m2/repository`.
- `gradle-cache` mounted at `~/.gradle`.
- These volumes persist across container restarts and are shared between
  sidecars and the main dev container.

### Health Checks

Each sidecar has a simple health check:

- `java-sidecar`: `java -version`
- `gradle-sidecar`: `gradle --version`

### Sidecar Is for Development, Not Production

- Do not run sidecars in production; they exist to provide tooling in dev/test
  environments.
- Production images should use multi-stage builds and ship only the JRE + built
  artifact.
