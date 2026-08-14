---
type: Practice
title: Build Context Hygiene — .dockerignore over COPY gymnastics
description: The bad pattern is not COPY . — it's sending garbage into the Docker build context. Use .dockerignore to filter, keep COPY . readable.
tags: [docker, dockerfile, dockerignore, build-context, copy]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: docker-dockerignore-documentation
    resource: "https://docs.docker.com/build/concepts/context/#dockerignore-files"
    title: "Docker .dockerignore documentation"
---

# Build Context Hygiene — .dockerignore over COPY gymnastics

## Failure Mode

Banning `COPY . .` outright and replacing it with mile-long `COPY` commands
that enumerate every file individually — because teams don't know about
`.dockerignore` or treat it as an obscure feature. The real problem is not
`COPY .`; it's shipping `node_modules/`, `.git/`, `*.log`, `dist/`, and `.env`
files into the Docker daemon.

## Symptoms

- `docker build` log reports "transferring X MB of context" where X is far
  larger than the actual application source.
- Dockerfiles have 20-line `COPY` blocks enumerating every file.
- Build context includes `node_modules/`, `.git/`, build artifacts, `.env`
  files — all shipped to the daemon and then discarded.

## Practice

Use a `.dockerignore` file (mirroring `.gitignore` semantics) to filter the
build context, then keep `COPY . .` for readability.

### Canonical .dockerignore

```gitignore
# Dependencies
node_modules/

# Version control
.git/
.gitignore

# Build artifacts
dist/
build/
*.o
*.so

# Logs
*.log

# Environment
.env
.env.*
!.env.example

# IDE
.vscode/
.idea/

# Docker
Dockerfile
docker-compose*.yml
.dockerignore
```

### Why not enumerate COPY commands?

- **Readability**: `COPY . .` is one line; enumerating 20 files is noise.
- **Maintenance**: every new source file requires a Dockerfile edit.
- **Drift**: the enumeration inevitably misses files, then someone "fixes" it
  by adding `COPY . .` anyway.

## Related

- [layer-cache-order](/layer-cache-order.md) — `COPY . .` is safe once context
  is filtered; layer order still matters for caching.
- [dockerfile-linting](/dockerfile-linting.md) — `hadolint` flags `COPY .`
  without a `.dockerignore`.
