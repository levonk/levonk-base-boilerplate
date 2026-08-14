---
type: Practice
title: Python Docker Standards
description: Multi-stage builds on base-alpine image, non-root user, standard env vars (PUID, PGID, TZ, PORT), /health healthcheck endpoint.
tags: [python, docker, multi-stage, non-root, healthcheck, base-alpine]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# Python Docker Standards

## Failure Mode

Inconsistent Docker practices across Python services — different base images,
root containers, missing healthchecks, and ad-hoc environment variable handling.

## Practice

Python service Dockerfiles must:

### Multi-Stage Build

- Use the monorepo **base-alpine** image as the base
- **Builder stage**: installs dependencies (`.[dev]` during build acceptable)
- **Runtime stage**: installs only runtime deps, copies artifacts, drops to
  non-root user

### Standard Environment Variables

- `PUID`, `PGID` — configure user/group IDs
- `TZ` — timezone
- `PORT` — HTTP listener port

### Health Check

Expose the service port and define a `HEALTHCHECK` hitting `/health`.

### docker-compose

- Service name derived from Copier answers
- `build` block pointing to service Dockerfile
- Pass `PUID`, `PGID`, `TZ`, `NODE_ENV`, `PORT` via `environment`
- Map `PORT:PORT` via `ports` for local development
- `restart: unless-stopped` for local/dev environments

## Related Concepts

- [FastAPI Service Layout](fastapi-service-layout.md) — Provides /health endpoint
- [Makefile Conventions](makefile-conventions.md) — up/down targets use docker compose
