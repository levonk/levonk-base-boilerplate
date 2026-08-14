---
type: Practice
title: Layer Cache Order — the Onion Model
description: Order Dockerfile layers from least-frequently-changed (deps) to most-frequently-changed (app code) so code edits don't invalidate dependency install layers.
tags: [docker, dockerfile, cache, layers, build-time, npm-ci]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: docker-build-cache-documentation
    resource: "https://docs.docker.com/build/cache/"
    title: "Docker build cache documentation"
---

# Layer Cache Order — the Onion Model

## Failure Mode

Copying application source **before** installing dependencies, so every code
edit invalidates the dependency-install layer and triggers a full cold rebuild.

## Symptoms

- Changing one character in `console.log("hello")` triggers `npm ci` / `pip
  install` / `go mod download` to re-run from scratch.
- Build times are constant regardless of how small the change is.
- CI accumulates hours of avoidable build time.

## Practice

Order layers from **least-frequently-changed** to **most-frequently-changed**.
Docker reuses layers until an earlier input changes; every layer after the
changed one is rebuilt.

### The Onion Mental Model

> "You peel it from the outside. The deeper the change you're making, the
> deeper we need to peel this onion to rebuild it. The more external the
> change, the more cache we have, the less we have to rebuild."

- Outer layers (rarely change): base image, system packages, dependency
  manifests, dependency install.
- Inner layers (change often): application source.
- A change to an inner layer does **not** invalidate outer layers.

### Corrected Node Dockerfile

```dockerfile
FROM node:slim
WORKDIR /app

# 1. Manifests first — rarely change
COPY package.json package-lock.json ./

# 2. Install deps — cached unless manifests change
RUN npm ci

# 3. App source last — changes often, doesn't invalidate step 2
COPY . .
CMD ["npm", "start"]
```

### Corrected Python Dockerfile

```dockerfile
FROM python:3-slim
WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
CMD ["python", "main.py"]
```

### Corrected Go Dockerfile (multi-stage)

See [multi-stage-builds](/multi-stage-builds.md) — the builder stage copies
`go.mod`/`go.sum` and runs `go mod download` before copying source.

## Related

- [build-context-hygiene](/build-context-hygiene.md) — `COPY . .` is safe once
  the build context is filtered.
- [dockerfile-linting](/dockerfile-linting.md) — `hadolint` flags
  `npm install` vs `npm ci` and other layer-order smells.
