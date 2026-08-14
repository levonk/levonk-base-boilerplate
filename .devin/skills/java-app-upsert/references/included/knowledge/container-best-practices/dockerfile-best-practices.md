---
type: Practice
title: Dockerfile Best Practices — apt vs apk, User Creation, and Multi-Stage Builds
description: Clean package manager caches, create non-root users correctly for Debian (groupadd/useradd) and Alpine (addgroup/adduser), use multi-stage builds, and add HEALTHCHECK to every production image.
tags: [devsecops, security, docker, dockerfile, alpine, debian, healthcheck, multi-stage]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: job-aide-dockerfile-best-practices-md
    resource: "https://github.com/lrepo52/job-aide/blob/main/.devin/rules/dockerfile-best-practices.md"
    title: "job-aide dockerfile-best-practices.md"
  - id: job-aide-codeguard-0-devops-ci-cd-containers-md
    resource: "https://github.com/lrepo52/job-aide/blob/main/.devin/rules/codeguard-0-devops-ci-cd-containers.md"
    title: "job-aide codeguard-0-devops-ci-cd-containers.md"
---

# Dockerfile Best Practices

## Failure Mode

Dockerfiles bloat images, retain package caches, run as root, and skip health
checks, leading to oversized attack surfaces and undetected service failures.

## Symptoms

- `apt-get update` is run without `rm -rf /var/lib/apt/lists/*`.
- Alpine `apk add` is used without `--no-cache`.
- Images run as `root` by default.
- No `HEALTHCHECK` is defined, so orchestrators cannot detect failures.
- Everything is built in one stage, shipping compilers and build tools to
  production.

## Practice

### Package Manager Cleanup

Debian/Ubuntu:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

Alpine:

```dockerfile
RUN apk add --no-cache package1 package2
```

### User Creation

Debian/Ubuntu:

```dockerfile
RUN groupadd -g 1000 myuser && \
    useradd -d /home/myuser -u 1000 -g myuser -s /usr/sbin/nologin myuser
USER myuser
```

Alpine:

```dockerfile
RUN addgroup -g 1000 myuser && \
    adduser -D -u 1000 -G myuser -h /home/myuser -s /sbin/nologin myuser
USER myuser
```

### Multi-Stage Builds

- Compile in a builder stage.
- Copy only the built artifact to a runtime stage.
- Use `distroless` or `scratch` for compiled binaries when possible.

### HEALTHCHECK

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD [ "curl", "-f", "http://localhost:8080/health" ] || exit 1
```

## Related Concepts

- [multi-stage-builds](/multi-stage-builds.md) — deeper treatment of builder
  vs runtime stage separation and distroless/scratch targets.
- [base-image-selection](/base-image-selection.md) — Alpine vs Slim vs
  distroless guidance for choosing the right base image.
- [layer-cache-order](/layer-cache-order.md) — why package install layers
  must come before source COPY layers.
- [container-runtime-hardening](/container-runtime-hardening.md) — runtime
  hardening controls that complement Dockerfile-level user creation and
  healthchecks.
- [dockerfile-linting](/dockerfile-linting.md) — automate enforcement of
  these patterns with hadolint in CI.
