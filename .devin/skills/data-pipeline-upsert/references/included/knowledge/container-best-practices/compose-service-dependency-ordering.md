---
type: Practice
title: Compose Service Dependency Ordering — healthchecks over depends_on alone
description: depends_on only waits for the container to start, not for the service to be ready; pair it with condition: service_healthy and a healthcheck to avoid startup race conditions.
tags: [docker, docker-compose, depends-on, healthcheck, service-healthy, pg-isready, startup-order]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: control-startup-and-shutdown-order-in-compose
    resource: "https://docs.docker.com/compose/how-tos/startup-order/"
    title: "Control startup and shutdown order in Compose"
  - id: compose-file-reference-services-depends-on-and-healthcheck
    resource: "https://docs.docker.com/reference/compose-file/services/"
    title: "Compose file reference — services: depends_on and healthcheck"
  - id: docker-compose-healthchecks-and-depends-on-practical-guide
    resource: "https://toolsops.dev/en/guides/docker-compose-healthchecks"
    title: "Docker Compose healthchecks and depends_on — practical guide"
  - id: docker-compose-depends-on-not-working-postgres-startup-fix
    resource: "https://jakeinsight.com/tech/2026-04-16-docker-compose-healthcheck-dependson-not-working-p/"
    title: "Docker Compose depends_on Not Working: Postgres Startup Fix"
  - id: docker-healthchecks-service-readiness-and-dependencies-in-compose
    resource: "https://blog.gntech.me/posts/2026-05-26-docker-healthchecks-compose-service-readiness/"
    title: "Docker Healthchecks — Service Readiness and Dependencies in Compose"
---

# Compose Service Dependency Ordering — healthchecks over depends_on alone

## Failure Mode

Using the short-list form of `depends_on` (`depends_on: [db]`) and assuming
Compose waits until the database is **ready**. It does not. The short form is
equivalent to `condition: service_started` — "the container process was
launched", not "port 5432 is accepting connections". The app container starts
the instant the dependency's entrypoint PID exists, races to connect, and
crashes with `Connection refused` while Postgres is still running its init
script.

## Symptoms

- App containers exit on startup with `ECONNREFUSED` even though the database
  is listed in `depends_on`.
- Teams paper over it with `restart: unless-st` and accept 3–5 crash-restart
  cycles before the app stabilises.
- CI is flaky: local runs pass (warm daemon) but CI fails because the database
  init takes longer on slower I/O.

## Practice

Pair `depends_on` (long form) with `condition: service_healthy` **and** a
`healthcheck` on the dependency. Compose then holds the dependent container
until the target's healthcheck returns exit code 0.

### The three conditions

| Condition | Meaning | Use for |
|-----------|---------|---------|
| `service_started` (default) | Container process launched | Nothing needing readiness |
| `service_healthy` | Container's `healthcheck` returns 0 | Databases, caches, brokers |
| `service_completed_successfully` | Container exits with code 0 | One-shot init/migration containers |

### Corrected compose file

```yaml
services:
  db:
    image: postgres:16
    environment: {POSTGRES_USER: app, POSTGRES_PASSWORD: changeme, POSTGRES_DB: myapp}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  migrate:
    build: .
    command: npm run migrate
    depends_on: {db: {condition: service_healthy}}
    restart: "no"

  app:
    build: .
    depends_on:
      db: {condition: service_healthy}
      redis: {condition: service_healthy}
      migrate: {condition: service_completed_successfully}
```

The `app` service will not start until Postgres accepts connections, Redis
responds to `PING`, **and** the migration container has exited 0.

### Healthcheck parameters

- `test` — command to run; exit 0 = healthy. `CMD` invokes the binary directly,
  `CMD-SHELL` runs through a shell (needed for `$${VAR}` expansion).
- `interval` / `timeout` / `retries` — how often to check, how long to wait,
  and consecutive failures before marking unhealthy (defaults `30s`/`30s`/`3`).
- `start_period` — grace period; failures here don't count toward `retries`.
  Essential for slow-starting services like Postgres and MySQL.

The double dollar sign (`$${POSTGRES_USER}`) is critical: Compose interprets
`$$` as a literal `$`, so the container shell evaluates the variable at
runtime. A single `$VAR` is resolved from the **host** environment at parse
time — usually empty.

### Common healthcheck commands

| Service | Command | Notes |
|---------|---------|-------|
| PostgreSQL | `pg_isready -U $$POSTGRES_USER` | Ships in the postgres image |
| MySQL | `mysqladmin ping -h localhost` | Ships in the mysql image |
| Redis | `redis-cli ping` | Returns `PONG` when ready |
| HTTP web | `curl -f http://localhost:8080/health` | Requires `curl` in the image |

Prefer the service's native tool over a TCP port check — `pg_isready` verifies
the server accepts connections, not just that the port is open. This is where
[base-image-selection](/base-image-selection.md) matters: `pg_isready` and
`mysqladmin` are present in official images but absent from minimal bases.

### Why not wait-for-it.sh / dockerize / restart policies?

External wait scripts poll the port from inside the app container — they work
but duplicate orchestrator logic, ship extra binaries, and can't express
`service_completed_successfully` for migration ordering. `restart: unless-st`
masks the race rather than fixing it. Healthchecks are declarative and
integrate with `depends_on` natively.

## Related

- [base-image-selection](/base-image-selection.md) — healthcheck commands like
  `pg_isready` depend on tooling present in the base image.
- [single-container-multi-process](/single-container-multi-process.md) — a
  healthcheck probes one process; multi-process containers need a
  supervisor-aware check.
