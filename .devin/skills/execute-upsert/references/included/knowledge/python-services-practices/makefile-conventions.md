---
type: Practice
title: Python Makefile Conventions
description: Matching up/down targets, standard command set (dev/test/lint/format/typecheck/build/up/down), docker compose not docker-compose, configurable COMPOSE_FILE and SERVICE_NAME.
tags: [python, makefile, commands, docker-compose, conventions]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# Python Makefile Conventions

## Failure Mode

Makefiles with `up` but no `down` leave containers running. Inconsistent command
names across services force developers to read each Makefile. Using
`docker-compose` (v1) instead of `docker compose` (v2) causes plugin errors.

## Practice

### Matching up/down

Any Makefile that defines `up` **must** also define `down`.

### Standard Command Set

```makefile
dev:        # Run uvicorn locally without Docker
test:       # Run pytest
lint:       # ruff + mypy
format:     # black + isort + ruff autofix
typecheck:  # mypy
build:      # Docker build
up:         # docker compose up -d
down:       # docker compose down
```

### docker compose (not docker-compose)

Use `docker compose` (v2 plugin) with configurable `COMPOSE_FILE` and
`SERVICE_NAME` variables.

## Related Concepts

- [Docker Standards](docker-standards.md) — What up/down controls
- [FastAPI Service Layout](fastapi-service-layout.md) — Service that Makefile manages
