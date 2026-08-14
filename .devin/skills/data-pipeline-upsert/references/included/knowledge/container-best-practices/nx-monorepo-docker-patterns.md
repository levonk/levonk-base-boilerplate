---
type: Practice
title: Nx Monorepo Docker Patterns — two-layer base, affected builds, dual cache
description: Dockerize Nx monorepo frontends with a two-layer base image (node-base + deps-base), Nx-affected Docker builds that only rebuild changed apps, and the union of Nx computation cache + Docker BuildKit cache. Covers pnpm vs bun build-time and runtime tradeoffs, @nx/docker inference plugin, custom hash-based executors, and dev-time docker-compose with shared volumes.
tags: [docker, dockerfile, nx, monorepo, pnpm, bun, caching, buildkit, affected, base-image, frontend, nextjs]
date:
  created: "2026-07-28"
  knowledge-basis: "2026-07-28"
  last-used: "2026-07-28"

sources:
  - id: dockerizing-nx-frontend-monorepos-without-losing-your-sanity
    resource: "https://medium.com/@amomammadw/dockerizing-nx-frontend-monorepos-without-losing-your-sanity-878771999206"
    title: "Dockerizing NX Frontend Monorepos Without Losing Your Sanity"
  - id: pnpm-vs-bun-2026-package-manager-showdown
    resource: "https://dev.to/pockit_tools/pnpm-vs-npm-vs-yarn-vs-bun-the-2026-package-manager-showdown-51dc"
    title: "pnpm vs npm vs yarn vs Bun: The 2026 Package Manager Showdown"
  - id: cut-nextjs-docker-build-time-switching-pnpm-to-bun
    resource: "https://techresolve.blog/2025/12/23/cut-my-next-js-docker-build-time-by-2-3s-switch/"
    title: "Cut my Next.js Docker build time by 2/3 switching from pnpm to bun"
  - id: sharp-linuxmusl-x64-runtime-error
    resource: "https://github.com/lovell/sharp/issues/4361"
    title: "Sharp@0.34.0 fails to compile with NextJS 15 (linuxmusl-x64 runtime error)"
  - id: pnpm-sidecar-archive-pattern
    resource: "../../../../../infrahub/shared/active/03-container/services/artifact/pnpm-sidecar/Dockerfile.pnpm-sidecar"
    title: "pnpm-sidecar — multi-stage archive pattern for shared pnpm store"
  - id: pnpm-sidecar-entrypoint
    resource: "../../../../../infrahub/shared/active/03-container/services/artifact/pnpm-sidecar/assets/static/pnpm-sidecar/entrypoint-pnpm-sidecar.sh"
    title: "pnpm-sidecar entrypoint — archive extraction to shared volume"
  - id: pnpm-sidecar-healthcheck
    resource: "../../../../../infrahub/shared/active/03-container/services/artifact/pnpm-sidecar/assets/static/pnpm-sidecar/healthcheck-pnpm.sh"
    title: "pnpm-sidecar healthcheck — pnpm store status validation"
  - id: nx-sidecar-entrypoint
    resource: "../../../../../infrahub/shared/active/03-container/services/artifact/nx-sidecar/assets/static/nx-sidecar/entrypoint-nx-sidecar.sh"
    title: "nx-sidecar entrypoint — nx install from shared pnpm store, cache init"
  - id: artifact-sidecar-agents
    resource: "../../../../../infrahub/shared/active/03-container/services/artifact/AGENTS.md"
    title: "Artifact Sidecar Containers — Architecture Guide (archive pattern, volume naming)"
  - id: docker-compose-shared-volumes
    resource: "../../../../../infrahub/shared/active/03-container/docker-compose.shared.yml"
    title: "docker-compose.shared.yml — canonical volume names (localnet-artifact-pnpm-store-volume, localnet-artifact-nx-cache-volume)"
  - id: nx-docker-plugin-introduction
    resource: "https://nx.dev/docs/technologies/build-tools/docker/introduction"
    title: "Nx with Docker — @nx/docker inference plugin (docker:build, docker:run, nx-release-publish)"
  - id: nx-release-docker-images
    resource: "https://nx.dev/docs/guides/nx-release/release-docker-images"
    title: "Release Docker Images with Nx Release"
  - id: docker-compose-nx-monorepo-multi-apps-dev
    resource: "https://www.codefeetime.com/post/using-docker-compose-with-nx-monorepo-for-multi-apps-development/"
    title: "Using Docker Compose with Nx Monorepo For Multi Apps Development — dev-time shared volumes, hot reload"
  - id: custom-nx-executor-docker-images
    resource: "https://www.ngserve.io/how-to-create-an-nx-executor-for-building-docker-images/"
    title: "How to Write an Nx Executor for Building Docker Images — hash-based base image tagging, child_process exec"
  - id: bun-vs-node-2026-runtime-performance
    resource: "https://strapi.io/blog/bun-vs-nodejs-performance-comparison-guide"
    title: "Bun vs Node.js in 2026: Benchmarks & Migration Guide — runtime performance, cold start, memory"
  - id: bun-vs-node-serverless-cold-starts-2026
    resource: "https://www.console.today/serverless/bun-vs-node-serverless-cold-starts-2026"
    title: "Bun 1.3 vs Node 24: The True Cost of Serverless Cold Starts in 2026 — Lambda cold start, container image size"
  - id: bun-vs-node-real-production-performance
    resource: "https://woyable.com/en/posts/bun-vs-nodejs-2026-runtime"
    title: "Bun vs Node.js 2026: Benchmarks vs Real Performance — database I/O dominates, 4x collapses to 3%"
  - id: nx-affected-documentation
    resource: "https://nx.dev/features/affected"
    title: "Nx Affected — only rebuild what changed"
  - id: docker-buildx-cache-documentation
    resource: "https://docs.docker.com/build/cache/"
    title: "Docker build cache documentation"
---

# Nx Monorepo Docker Patterns — two-layer base, affected builds, dual cache

## Failure Mode

Dockerizing an Nx monorepo with multiple frontend apps (React, Next.js) by
giving each app a standalone Dockerfile that reinstalls all workspace
dependencies from scratch on every build. When the workspace grows to 5+ apps
and 10+ shared packages, build times explode because:

1. Every app Dockerfile re-runs `pnpm install` / `npm install` for the entire
   workspace, even though 90% of the dependencies are shared across apps.
2. Every CI run rebuilds every app's Docker image, even apps whose source did
   not change.
3. The Nx computation cache (which knows which apps are affected by a change)
   is never consulted inside the Docker build, so unchanged packages are
   recompiled inside the builder stage.
4. Docker layer cache and Nx cache operate in isolation — neither benefits the
   other.

## Symptoms

- A one-line change to a shared package triggers a full Docker rebuild of every
  app image in the monorepo, each taking 5+ minutes.
- CI build time scales linearly with the number of apps, not with the number of
  changed apps.
- `docker build` logs show `pnpm install` re-running in every app's builder
  stage even though the lockfile did not change.
- Nx cache hits are visible locally (`nx build` says "cached") but lost inside
  the Docker build because the cache is not mounted or restored.

## Practice

### 1. Two-Layer Base Image Strategy

Split the base into two layers so dependencies are installed once and shared
across all app Dockerfiles.

**Layer 1 — `node-base`**: Node.js + package manager only. Rarely changes.

```dockerfile
# docker/base.Dockerfile
FROM node:22-slim AS node-base

# Install pnpm globally — pnpm is the standard package manager (see
# pnpm-nx-monorepo). Inside a container that uses the pnpm-sidecar shared
# store, pnpm reads the store from the mounted volume; the binary itself is
# small and stable.
RUN npm install -g pnpm

WORKDIR /app
```

> **Avoid `node:18-alpine` and `node:22-alpine` for application Dockerfiles.**
> Node 18 is EOL. Alpine uses musl libc; Next.js depends on `sharp` for image
> optimization, and `sharp` ships glibc-only prebuilt binaries. On Alpine,
> `sharp` fails with `Could not load the "sharp" module using the
> linuxmusl-x64 runtime` — a documented, recurring issue
> ([lovell/sharp#4361](https://github.com/lovell/sharp/issues/4361)). Use
> `node:22-slim` (Debian, glibc) for application Dockerfiles — see
> [base-image-selection](/base-image-selection.md). Alpine is for infrastructure
> services where you control the full toolchain.

**Layer 2 — `deps-base`**: Workspace dependencies. Changes only when
`pnpm-lock.yaml` or workspace structure changes.

```dockerfile
# docker/deps.Dockerfile
FROM node-base AS deps-base

WORKDIR /app

# Copy dependency manifests first — layer cache hits unless these change
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json nx.json ./

# Copy workspace structure so Nx and pnpm can resolve the dependency graph
# before installing. Without apps/ and packages/ skeletons, pnpm cannot
# resolve workspace:* dependencies.
COPY apps/ ./apps/
COPY packages/ ./packages/

RUN pnpm install --frozen-lockfile
```

Build and push the deps-base image. Each app Dockerfile inherits from it:

```dockerfile
# apps/my-app/Dockerfile
FROM myregistry.com/nx-monorepo-deps:latest AS builder

WORKDIR /app

# Copy only this app's source — deps are already in the base image
COPY apps/my-app ./apps/my-app
# Copy shared packages that this app depends on (Nx knows the graph; in
# practice, copy the packages/ directory or use Nx's `--project` filtering
# to copy only what's needed)
COPY packages/ ./packages/

# Build with Nx — pnpm exec, never npx (see pnpm-nx-monorepo)
RUN pnpm exec nx build my-app
```

> **Avoid `npx nx run my-app:build`.** `npx` bypasses the pnpm lockfile and
> installs outside the workspace store. Use `pnpm exec nx build my-app` (pnpm
> workspace) or `bunx nx build my-app` (bun runtime) — see
> [pnpm-nx-monorepo](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md).

```dockerfile
# Runtime stage — lean, non-root, with healthcheck
FROM node:22-slim AS runtime
WORKDIR /app
COPY --from=builder /app/dist/apps/my-app ./
RUN groupadd -g 1000 appuser && useradd -d /home/appuser -u 1000 -g appuser -s /usr/sbin/nologin appuser
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["curl", "-f", "http://localhost:3000/api/health"] || exit 1
CMD ["node", "server.js"]
```

> **Avoid root-owned runtime stages and floating tags.** Never ship a runtime
> stage without a non-root `USER` and a `HEALTHCHECK` — root-owned containers
> allow privilege escalation and missing healthchecks hide failures (see
> [nodejs-in-containers](/nodejs-in-containers.md),
> [container-runtime-hardening](/container-runtime-hardening.md)). Pin the
> `FROM` image by digest (`node:22-slim@sha256:...`), not a floating `:latest`
> or `:alpine` tag — tags move, digests don't (see
> [pin-image-digests](/pin-image-digests.md)). Pass npm tokens via
> `--mount=type=secret,id=npmrc,target=/root/.npmrc` in the builder stage,
> never `--build-arg` — build-time secrets must not bake into layers (see
> [buildkit-secrets](/buildkit-secrets.md)).

> **Why this works**: Dependencies don't reinstall on every app build. The
> deps-base image is rebuilt only when the lockfile changes (a separate CI job
> pushes it). App builds start from a warm dependency layer and only compile
> the app's own source.

### 2. Nx-Affected Docker Builds

Nx knows which apps are affected by a change. Use `nx affected` to build only
the Docker images for apps whose source (or dependencies' source) changed —
not every app in the monorepo.

```bash
# On the host or in CI — determine affected apps, then build only their images
AFFECTED=$(pnpm exec nx show projects --affected --type=app)
for app in $AFFECTED; do
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    -t myregistry.com/$app:${{ github.sha }} \
    -f apps/$app/Dockerfile .
done
```

Or use Nx's Docker plugin (`@nx/docker`) to integrate the Docker build as an
Nx target, so `nx affected -t docker-build` builds only affected app images:

```json
// apps/my-app/project.json
{
  "targets": {
    "docker-build": {
      "executor": "@nx/docker:build",
      "options": {
        "dockerfile": "./Dockerfile",
        "context": "../..",
        "tags": ["myregistry.com/my-app:latest"]
      }
    }
  }
}
```

```bash
# Only build Docker images for apps affected by this commit
pnpm exec nx affected -t docker-build --parallel=3
```

This is the single biggest win for large monorepos: CI build time scales with
the number of changed apps, not the total number of apps.

### 3. Dual Cache — Nx Computation Cache + Docker BuildKit Cache

The two caching systems are complementary, not redundant:

| Cache | What it caches | Granularity | Invalidated by |
|-------|---------------|-------------|---------------|
| Nx computation cache | Build outputs (compiled JS, dist artifacts) per project | Per-project, per-target | Source hash of the project + its deps |
| Docker BuildKit cache | Docker layers (filesystem diffs) | Per-layer | Earlier layer changing |

**Union strategy**: restore the Nx cache inside the Docker builder stage so
unchanged projects skip compilation entirely, AND use BuildKit `--cache-from`/
`--cache-to` so Docker layers are reused across CI runs.

```dockerfile
# In the builder stage — mount the Nx cache as a BuildKit cache mount
# so it persists across builds without baking it into the image layer.
# In a sidecar-based deployment, this is the localnet-artifact-nx-cache-volume
# mounted at /var/cache/nx-cache (see section 4).
FROM deps-base AS builder
WORKDIR /app
COPY apps/my-app ./apps/my-app
COPY packages/ ./packages/

# Mount Nx cache via BuildKit — cache survives across builds, not in the image.
# Set NX_CACHE_DIRECTORY so Nx reads from the mounted cache path.
ENV NX_CACHE_DIRECTORY=/var/cache/nx-cache
RUN --mount=type=cache,target=/var/cache/nx-cache,id=nx-cache \
    pnpm exec nx build my-app --skip-nx-cache=false
```

In CI, pair this with a registry/GHA BuildKit cache backend (see
[registry-cache-strategy](/registry-cache-strategy.md)):

```yaml
# .github/workflows/build.yml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Nx affected needs full history

- uses: docker/setup-buildx-action@v4

- uses: docker/build-push-action@v7
  with:
    context: .
    file: apps/my-app/Dockerfile
    push: true
    tags: myregistry.com/my-app:${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

> **Avoid manual `actions/cache@v3` for Nx cache.** The integrated
> `docker/setup-buildx-action@v4` + `type=gha` BuildKit cache is simpler and
> caches all Docker layers, not just the Nx cache directory. Manual
> `actions/cache` restores only one directory and misses layer cache — see
> [registry-cache-strategy](/registry-cache-strategy.md).

The result: if a shared package didn't change, Nx skips its build (cache hit
from the mounted `.nx/cache`), and if the Dockerfile layers didn't change,
BuildKit skips them (cache hit from GHA). The two caches union to cache the
maximum amount of work.

### 4. Package Manager and Runtime in Containers — pnpm vs Bun Tradeoff

The existing standard (see [pnpm-nx-monorepo](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md))
says "use `bunx` inside containers, never install pnpm in a container." This
remains correct for **standalone app containers** that don't need workspace
resolution. But for **Nx monorepo Docker builds**, the tradeoff shifts.

The decision has two independent axes: **build-time package manager** (what
installs dependencies) and **runtime** (what executes the app). They can
differ — you can install with pnpm and run on Node.js, or install with bun
and run on bun.

#### Build-Time Package Manager

| Factor | Bun install | pnpm install (with pnpm-sidecar) |
|--------|------------|----------------------------------|
| Cold install speed | 4-28x faster than pnpm | Slower (pnpm is 3-5x faster than npm, but bun is faster still) |
| Workspace `workspace:*` support | Yes (bun install reads pnpm-workspace.yaml) | Native (pnpm authored it) |
| `catalog:` protocol support | No | Yes (pnpm 9.5+) |
| Shared store across containers | No (bun has no content-addressable store) | Yes (pnpm-sidecar provides a shared store volume) |
| Docker layer cache friendliness | Better (flat node_modules caches cleanly) | Worse (symlinked .pnpm structure is harder to cache in layers) |
| Offline install from shared volume | No | Yes (pnpm-sidecar store mounted, `--offline` flag) |

#### Runtime Performance — Bun vs Node.js

| Factor | Bun runtime | Node.js runtime |
|--------|------------|-----------------|
| Synthetic HTTP throughput (hello-world) | ~52,000 req/s (4x faster) | ~13,000 req/s |
| Real-world HTTP (Postgres + serialization) | ~12,400 req/s (~3% faster) | ~12,000 req/s |
| p99 latency under 10K req/s (Postgres) | ~31ms (35% better) | ~48ms |
| Memory usage (API servers) | 25-40% less | baseline |
| Container image size | ~40 MB (`oven/bun:distroless`) | ~220 MB (`node:24-slim`) |
| Container cold start (pull + boot) | 0.8-1.5s | 2.5-4.0s |
| AWS Lambda cold start | 750ms (3-4x **slower** — custom layer overhead) | 180ms (managed runtime) |
| CPU-bound work (sort 100K numbers) | 1,700ms (2x faster) | 3,400ms |
| npm ecosystem compatibility | Good but gaps in native bindings, OpenTelemetry, mature ORMs | Complete |
| Next.js compatibility | Works but `sharp` and some native modules need attention | Native, fully supported |

> **Key insight**: Bun's 4x HTTP throughput advantage collapses to ~3% on real
> apps with database I/O — the database round-trip dominates total latency, not
> the JavaScript runtime. Bun wins meaningfully on memory (25-40% less), image
> size (5x smaller), and container cold start (3x faster). But Node.js wins on
> Lambda cold start (managed runtime advantage), npm ecosystem compatibility,
> and Next.js native module support (`sharp`). For Nx monorepo frontends
> (Next.js, React), Node.js is the safer runtime; for greenfield APIs without
> native bindings, Bun's memory and cold-start advantages compound at scale.

#### Decision Matrix

| Scenario | Build-time PM | Runtime | Why |
|----------|--------------|---------|-----|
| Nx monorepo with `catalog:`, 5+ apps | pnpm + pnpm-sidecar | Node.js | `catalog:` support, shared store, Next.js compatibility |
| Nx monorepo without `catalog:`, small | bun install | Node.js | Fast installs, Node.js runtime compatibility |
| Greenfield API, no native bindings | bun install | bun | Fastest end-to-end, smallest image, least memory |
| Next.js app with image optimization | pnpm + pnpm-sidecar | Node.js | `sharp` needs glibc, Node.js has full Next.js support |

**When to use pnpm in the container (with pnpm-sidecar)**:

- The monorepo uses `catalog:` for external dependency versioning (bun cannot
  read `catalog:` references).
- Multiple app containers share the same pnpm store via the pnpm-sidecar
  shared volume — the store is populated once and mounted read-only into each
  builder stage, eliminating redundant downloads across apps.
- You want build-time and runtime to use the same package manager as the host
  (pnpm) for consistency.

**When to use bun in the container**:

- The monorepo does not use `catalog:` (or you're willing to resolve catalog
  references to concrete versions before the Docker build).
- Raw install speed matters more than store sharing (small monorepo, few apps).
- You want bun as the runtime too (faster startup, smaller image).

**The pnpm-sidecar pattern** (canonical implementation at
`infrahub/shared/active/03-container/services/artifact/pnpm-sidecar/`):
a sidecar container builds a zstd-compressed archive of the pnpm store at image
build time, then at runtime extracts it to a shared volume if the volume is
empty. App builder stages mount the shared volume so
`pnpm install --frozen-lockfile --offline` resolves from the shared store
without network access. This eliminates the "pnpm is slow in containers"
penalty by making the store a shared, pre-populated volume — no per-container
download.

#### Canonical Volume Names and Mount Paths

The infrahub pnpm-sidecar defines two named volumes that all app containers
MUST use. Standardizing on these names ensures the sidecar populates the store
once and every app container reads from the same shared volume.

| Volume name | Docker volume name | Mount path | Purpose |
|-------------|-------------------|------------|---------|
| `pnpm-store` | `localnet-artifact-pnpm-store-volume` | `/home/cuser/.local/share/pnpm` | pnpm content-addressable store (the global package store, populated from archive) |
| `pnpm-cache` | (per-app or shared) | `/home/cuser/.cache/pnpm` | pnpm download cache (HTTP cache, separate from the store) |
| `nx-cache` | `localnet-artifact-nx-cache-volume` | `/var/cache/nx-cache` | Nx computation cache (FHS layout: `vANY/hashes`, `vANY/terminalOutputs`, `vANY/outputs`) |

The `pnpm-store` volume is the one the pnpm-sidecar populates. App containers
mount it read-only or read-write depending on whether they need to add packages
to the store. The `nx-cache` volume is populated by the nx-sidecar and shared
across all Nx app containers.

#### pnpm-sidecar — Store Population and Module Validation

The pnpm-sidecar uses the **archive pattern** (see the artifact sidecar AGENTS.md):
a build stage creates a zstd-compressed archive of the pnpm store, the runtime
stage copies only the archive, and the entrypoint extracts it to the shared
volume on first boot.

```dockerfile
# docker/deps.Dockerfile — pnpm-sidecar (simplified from infrahub)
FROM localnet-base-sidecar:latest AS pnpm-builder
RUN --mount=type=cache,target=/var/cache/apk,id=pnpm-sidecar-apk \
    --mount=type=cache,target=/root/.npm,id=pnpm-sidecar-npm \
    apk add nodejs npm zstd tar ca-certificates && \
    mkdir -p /tmp/pnpm-store && \
    npm install -g pnpm --prefix /tmp/pnpm-store && \
    tar -I "zstd -19" -cf /tmp/pnpm-store-archive.tar.zstd -C /tmp/pnpm-store .

FROM localnet-base-sidecar:latest
RUN apk add nodejs zstd
RUN mkdir -p /home/cuser/.local/share/pnpm /home/cuser/.cache/pnpm pnpm-sidecar/tmp
COPY --from=pnpm-builder /tmp/pnpm-store-archive.tar.zstd /pnpm-sidecar/tmp/
COPY assets/static/ /
RUN chmod +x /pnpm-sidecar/entrypoint-pnpm-sidecar.sh /pnpm-sidecar/healthcheck-pnpm.sh
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ["/pnpm-sidecar/healthcheck-pnpm.sh"]
USER 1000
ENTRYPOINT ["/pnpm-sidecar/entrypoint-pnpm-sidecar.sh"]
CMD ["sleep", "30"]
```

The entrypoint extracts the archive only if the shared volume is not yet
initialized:

```bash
# entrypoint-pnpm-sidecar.sh (simplified)
if [ ! -f "/home/cuser/.local/share/pnpm/.initialized" ]; then
    echo "pnpm store not found on shared volume, extracting from archive..."
    mkdir -p /home/cuser/.local/share/pnpm
    zstd -dc /pnpm-sidecar/tmp/pnpm-store-archive.tar.zstd | tar -xf - -C /home/cuser/.local/share/pnpm/
    touch /home/cuser/.local/share/pnpm/.initialized
else
    echo "pnpm store already available on shared volume"
fi
```

**Module validation via healthcheck**: the pnpm-sidecar healthcheck runs
`pnpm store status` to validate the integrity of the shared store on every
health check interval. If the store is corrupted or incomplete, the sidecar
reports unhealthy and dependent app containers (which declare
`depends_on: pnpm-sidecar: condition: service_healthy`) will not start or will
be restarted by the orchestrator.

```bash
# healthcheck-pnpm.sh — validates the shared store
if ! pnpm store status > /dev/null 2>&1; then
    echo "PNPM store integrity check failed"
    exit 1
fi
```

This is the "sidecar validates the modules" contract: the sidecar owns the
store, populates it from the archive, and continuously validates its integrity.
App containers trust the store because the sidecar is healthy — they do not
run their own integrity checks.

#### nx-sidecar — Nx Cache and Tooling

A companion `nx-sidecar` depends on the pnpm-sidecar (service_healthy), installs
`nx` globally via pnpm from the shared store, and initializes the Nx
computation cache directory structure on the `nx-cache` shared volume:

```bash
# entrypoint-nx-sidecar.sh (simplified)
export PNPM_HOME="/home/cuser/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Install nx from the shared pnpm store
if [ ! -f "/home/cuser/.local/share/pnpm/bin/nx" ]; then
    pnpm add -g nx
fi

# Initialize FHS-compliant nx cache structure
if [ ! -f "/var/cache/nx-cache/.initialized" ]; then
    mkdir -p /var/cache/nx-cache/vANY/hashes
    mkdir -p /var/cache/nx-cache/vANY/terminalOutputs
    mkdir -p /var/cache/nx-cache/vANY/outputs
    touch /var/cache/nx-cache/.initialized
fi
```

#### App Container Pattern — Mounting the Shared Volumes

App containers mount the `pnpm-store` and `nx-cache` volumes and declare a
`depends_on` on the pnpm-sidecar with `condition: service_healthy` so they
only start after the store is populated and validated:

```yaml
# docker-compose.my-app.yml
services:
  my-app:
    image: myregistry.com/my-app:latest
    depends_on:
      pnpm-sidecar:
        condition: service_healthy
      nx-sidecar:
        condition: service_healthy
    volumes:
      # Mount the shared pnpm store (populated + validated by pnpm-sidecar)
      - pnpm-store:/home/cuser/.local/share/pnpm:ro
      # Mount the shared nx computation cache (populated by nx-sidecar)
      - nx-cache:/var/cache/nx-cache:rw
    environment:
      - PNPM_HOME=/home/cuser/.local/share/pnpm
      - NX_CACHE_DIRECTORY=/var/cache/nx-cache
    security_opt:
      - no-new-privileges
    cap_drop:
      - ALL
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m

volumes:
  pnpm-store:
    name: localnet-artifact-pnpm-store-volume
    external: true
  nx-cache:
    name: localnet-artifact-nx-cache-volume
    external: true
```

For **Dockerfile builder stages** (not runtime containers), mount the shared
store via BuildKit cache mount or a bind mount so `pnpm install --offline`
reads from the pre-populated store:

```dockerfile
# Builder stage using the pnpm-sidecar shared store
FROM node:22-slim AS builder
RUN npm install -g pnpm
WORKDIR /app
ENV PNPM_HOME=/home/cuser/.local/share/pnpm
# The pnpm store is mounted from the pnpm-sidecar shared volume at runtime
# (docker-compose bind mount or Kubernetes volume mount)
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --offline  # reads from mounted store
COPY . .
RUN pnpm exec nx build my-app
```

#### Build-Time Sidecar vs Injecting node_modules — We Do Both

The pnpm-sidecar and baking `node_modules` into the image are **not
alternatives — they solve different problems and compose**:

| Concern | Solution | When |
|---------|----------|------|
| Fast `pnpm install` during Docker build | pnpm-sidecar shared store (mounted into builder stage) | Build time — accelerates the install step |
| Self-contained production image | `node_modules` baked into the image via multi-stage `COPY --from=builder` | Runtime — the image must run anywhere without external volumes |

The sidecar accelerates the **builder stage's install step** (reads from the
shared store, no network). The resulting `node_modules` are then copied into
the final image via the standard multi-stage `COPY --from=builder` pattern
(see [multi-stage-builds](/multi-stage-builds.md) and
[nodejs-in-containers](/nodejs-in-containers.md)). The production image does
NOT mount the pnpm-sidecar volume at runtime — it is self-contained.

```dockerfile
# Builder stage — pnpm-sidecar accelerates the install
FROM node:22-slim AS builder
RUN npm install -g pnpm
WORKDIR /app
ENV PNPM_HOME=/home/cuser/.local/share/pnpm
# pnpm-sidecar store is mounted here during build (BuildKit cache mount or
# docker-compose bind mount). The install reads from the shared store.
COPY pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --offline
COPY . .
RUN pnpm exec nx build my-app

# Runtime stage — node_modules baked in, NO sidecar volume needed
FROM node:22-slim AS runtime
WORKDIR /app
# Copy only production node_modules and build output from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist/apps/my-app ./
RUN groupadd -g 1000 appuser && useradd -d /home/appuser -u 1000 -g appuser -s /usr/sbin/nologin appuser
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["curl", "-f", "http://localhost:3000/api/health"] || exit 1
CMD ["node", "server.js"]
```

> **Why not mount the sidecar at runtime too?** Production containers must be
> self-contained — they run on hosts that may not have the pnpm-sidecar
> volume. The sidecar is a build-time acceleration tool; the production image
> carries its own `node_modules`. For **development containers** (hot reload,
> shared source), mounting the sidecar at runtime is fine — see the dev-time
> pattern below.

> **Decision rule**: if the monorepo uses `catalog:` or has 5+ apps that share
> dependencies, use pnpm in the container with the pnpm-sidecar
> (`localnet-artifact-pnpm-store-volume`). If the monorepo is small and raw
> speed matters most, use bun. Never use `npx` inside a container — use
> `pnpm exec nx` (pnpm workspace) or `bunx nx` (bun runtime).

### 5. @nx/docker Inference Plugin — Official Nx Docker Integration

The official `@nx/docker` plugin auto-infers `docker:build` and `docker:run`
targets from any `Dockerfile` in the workspace. This is the canonical way to
integrate Docker builds into Nx — no custom executor needed.

```bash
# Install the plugin
pnpm exec nx add @nx/docker
```

```json
// nx.json — configure the inference plugin
{
  "plugins": [
    {
      "plugin": "@nx/docker",
      "options": {
        "buildTarget": {
          "name": "docker:build",
          "args": [
            "--platform", "linux/amd64,linux/arm64",
            "--label", "project={projectName}"
          ],
          "env": { "DOCKER_BUILDKIT": "1" },
          "envFile": ".env.docker",
          "cwd": "{projectRoot}"
        },
        "runTarget": {
          "name": "docker:run",
          "args": ["--rm"]
        }
      }
    }
  ]
}
```

The plugin infers three tasks per project with a Dockerfile:

| Task | Purpose |
|------|---------|
| `docker:build` | Build the image (supports `--platform` for multi-arch, custom args, env vars) |
| `docker:run` | Run the image locally (useful for dev/testing) |
| `nx-release-publish` | Publish the image to a registry during `nx release` |

```bash
# Build a single app's Docker image
pnpm exec nx docker:build my-app

# Build only affected app images
pnpm exec nx affected -t docker:build --parallel=3

# Run an app's image locally
pnpm exec nx docker:run my-app

# Release: build + publish all affected images
pnpm exec nx release --projects=my-app
```

The `buildTarget` options support pattern interpolation (`{projectName}`,
`{projectRoot}`) so a single `nx.json` config works for all apps. Set
`docker:build` to `dependsOn: ["build"]` so the app is compiled before the
Docker image is built.

> **When to use `@nx/docker` vs a custom executor**: `@nx/docker` covers the
> standard case (build, run, publish). Use a custom executor only when you need
> logic that the plugin doesn't support — e.g., hash-based tagging where the
> base image tag is derived from a hash of `base.Dockerfile` + `pnpm-lock.yaml`
> (so the base image is only rebuilt when those files change), or
> domain-tag-filtered affected builds (`--tag=domain:billing`). See the custom
> executor pattern below.

### 6. Custom Nx Executor — Hash-Based Base Image Tagging

When the two-layer base strategy needs the base image tag to be derived from
the content hash of `base.Dockerfile` + `pnpm-lock.yaml` (so the base image is
only rebuilt when those files change), write a custom Nx executor using
Node's `child_process.exec`. This pattern predates `@nx/docker` but remains
useful for hash-based tagging that the plugin doesn't provide out of the box.

```typescript
// executors/build-docker-image/executor.ts (simplified)
import { exec } from 'child_process';
import { promisify } from 'util';
import { createHash } from 'crypto';
import { readFileSync } from 'fs';

const execPromise = promisify(exec);

// Base image tag = hash of base.Dockerfile + pnpm-lock.yaml
// Rebuilt only when those files change
function baseImageTag(): string {
  const baseDocker = readFileSync('docker/base.Dockerfile');
  const lockfile = readFileSync('pnpm-lock.yaml');
  return createHash('sha256').update(baseDocker).update(lockfile).digest('hex').slice(0, 12);
}

// App image tag = git commit hash
// Ties each image to the commit that produced it
async function appImageTag(): Promise<string> {
  const { stdout } = await execPromise('git rev-parse --short HEAD');
  return stdout.trim();
}

export default async function runExecutor(options: { outputPath?: string }) {
  const baseTag = baseImageTag();
  const appTag = await appImageTag();

  // Build base image if it doesn't exist
  const { stdout: queryResult } = await execPromise(
    `docker images -q myregistry.com/nx-base:${baseTag}`
  );
  if (!queryResult.trim()) {
    await execPromise(
      `docker buildx build -t myregistry.com/nx-base:${baseTag} -f docker/base.Dockerfile --push .`
    );
  }

  // Build app image FROM the base image
  await execPromise(
    `docker buildx build --platform linux/amd64,linux/arm64 --push ` +
    `-t myregistry.com/${options.projectName}:${appTag} ` +
    `--build-arg BASE_TAG=${baseTag} -f apps/${options.projectName}/Dockerfile .`
  );
  return { success: true };
}
```

```json
// apps/my-app/project.json
{
  "targets": {
    "build-docker-image": {
      "executor": "./executors/build-docker-image:executor",
      "dependsOn": ["build"],
      "cache": true,
      "options": {
        "outputPath": "dist/apps/my-app"
      }
    }
  }
}
```

```bash
# Build only affected app images, filtered by domain tag
pnpm exec nx affected -t build-docker-image --base=main~1 --head=main --tag=domain:billing --parallel=1
```

The hash-based tagging ensures the base image is only rebuilt when its inputs
change — the same principle as Docker layer caching, but at the image level.
Combined with `nx affected`, this means a commit that doesn't touch
`base.Dockerfile` or `pnpm-lock.yaml` skips the base image build entirely and
only rebuilds the affected app images from the existing base.

### 7. Dev-Time Docker Compose — Multi-App Development with Shared Volumes

For **development** (not production), docker-compose can run all Nx apps
simultaneously with shared source and shared `node_modules` — the dev-time
analog of the pnpm-sidecar pattern. This is for hot-reload development, not
production deployment.

```yaml
# docker-compose.dev.yml — dev-time multi-app with shared volumes
services:
  nx-app-base:
    build:
      context: .
      dockerfile: Dockerfile.dev
    environment:
      - DEV_PLATFORM=DOCKER
      - PNPM_HOME=/home/cuser/.local/share/pnpm
    volumes:
      # Shared source — enables hot reload from host edits
      - ./:/app
      # Shared pnpm store from pnpm-sidecar (canonical volume name)
      - pnpm-store:/home/cuser/.local/share/pnpm:ro
      # Shared nx cache from nx-sidecar
      - nx-cache:/var/cache/nx-cache:rw
    depends_on:
      pnpm-sidecar:
        condition: service_healthy

  app-1:
    extends:
      service: nx-app-base
    command: pnpm exec nx serve app-1 --host=0.0.0.0
    ports:
      - "4201:4200"

  app-2:
    extends:
      service: nx-app-base
    command: pnpm exec nx serve app-2 --host=0.0.0.0
    ports:
      - "4202:4200"

volumes:
  pnpm-store:
    name: localnet-artifact-pnpm-store-volume
    external: true
  nx-cache:
    name: localnet-artifact-nx-cache-volume
    external: true
```

**Hot reload across OS filesystem boundaries**: when the host (macOS/Windows)
and container (Linux) run different filesystems, Webpack's file-watcher fails
to detect changes. Use polling mode:

```javascript
// webpack.dev.config.js — polling for Docker cross-OS hot reload
if (process.env.DEV_PLATFORM === 'DOCKER') {
  config.watchOptions = {
    aggregateTimeout: 500,
    poll: 1000,  // poll every 1s instead of filesystem events
  };
  config.devServer = {
    ...config.devServer,
    client: {
      webSocketURL: 'auto://0.0.0.0:0/ws',  // handle host:container port mismatch
    },
  };
}
```

> **Dev vs production volume mounting**: in development, mounting the
> pnpm-sidecar store at runtime is correct (the container needs live access
> for hot reload). In production, `node_modules` are baked into the image via
> multi-stage `COPY --from=builder` — the production container does NOT mount
> the sidecar volume. See "Build-Time Sidecar vs Injecting node_modules" above.

## Implementation Checklist

- [ ] `node-base` image uses `node:22-slim` (not alpine, not EOL versions)
- [ ] `deps-base` image copies lockfile + workspace structure before `pnpm install`
- [ ] `deps-base` is rebuilt and pushed as a separate CI job when the lockfile changes
- [ ] App Dockerfiles `FROM deps-base` and copy only app source + shared packages
- [ ] `pnpm exec nx build` (or `bunx nx build`) used — never `npx nx`
- [ ] `nx affected -t docker-build` builds only changed app images in CI
- [ ] Nx cache mounted at `/var/cache/nx-cache` (canonical path) via `--mount=type=cache,target=/var/cache/nx-cache,id=nx-cache` (BuildKit) or `localnet-artifact-nx-cache-volume` (docker-compose)
- [ ] BuildKit `--cache-from type=gha --cache-to type=gha,mode=max` in CI
- [ ] Runtime stage has non-root `USER`, `HEALTHCHECK`, and is pinned by digest
- [ ] npm tokens (if any) passed via `--mount=type=secret`, never `--build-arg`
- [ ] `.dockerignore` excludes `node_modules/`, `.git/`, `dist/`, `.nx/` from context
- [ ] pnpm-sidecar deployed with `localnet-artifact-pnpm-store-volume` mounted at `/home/cuser/.local/share/pnpm`
- [ ] pnpm-sidecar healthcheck runs `pnpm store status` to validate module integrity
- [ ] App containers declare `depends_on: pnpm-sidecar: condition: service_healthy`
- [ ] App containers mount `pnpm-store` volume (read-only for runtime, read-write for builder)
- [ ] nx-sidecar deployed with `localnet-artifact-nx-cache-volume` mounted at `/var/cache/nx-cache`

## Related

- [base-image-selection](/base-image-selection.md) — why `slim` not `alpine`
  for application Dockerfiles (musl breaks glibc wheels, including `sharp`).
- [layer-cache-order](/layer-cache-order.md) — the onion model that the
  two-layer base strategy extends to monorepos.
- [multi-stage-builds](/multi-stage-builds.md) — builder vs runtime stage
  separation; the per-app Dockerfile pattern.
- [registry-cache-strategy](/registry-cache-strategy.md) — BuildKit
  `--cache-from`/`--cache-to` backends (`type=gha`, `type=registry`, `mode=max`).
- [buildkit-secrets](/buildkit-secrets.md) — `--mount=type=secret` for npm
  tokens; never bake credentials into layers.
- [nodejs-in-containers](/nodejs-in-containers.md) — `npm ci --omit=dev`,
  `NODE_ENV=production`, non-root, `dumb-init`, graceful shutdown.
- [pin-image-digests](/pin-image-digests.md) — pin `FROM` lines by digest for
  reproducible builds.
- [container-runtime-hardening](/container-runtime-hardening.md) — non-root,
  read-only, cap-drop ALL, no-new-privileges.
- [pnpm-nx-monorepo](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md)
  — pnpm workspaces, `catalog:` protocol, Nx task orchestration, the
  `npx`/`bunx`/`pnpm exec` rule and its container exception.
