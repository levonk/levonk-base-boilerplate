---
type: Practice
title: Registry Cache Strategy — persisting BuildKit cache across CI runs
description: Export and import BuildKit layer cache to a registry, local volume, or GitHub Actions cache so CI rebuilds reuse layers instead of starting cold every run.
tags: [docker, registry, cache, buildx, buildkit, ci, github-actions, multi-arch]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: cache-storage-backends-docker-docs
    resource: "https://docs.docker.com/build/cache/backends/"
    title: "Cache storage backends — Docker Docs"
  - id: cache-management-with-github-actions-docker-docs
    resource: "https://docs.docker.com/build/ci/github-actions/cache/"
    title: "Cache management with GitHub Actions — Docker Docs"
  - id: docker-buildx-build-reference-docker-docs
    resource: "https://docs.docker.com/reference/cli/docker/buildx/build/"
    title: "docker buildx build reference — Docker Docs"
  - id: inline-cache-backend-docker-docs
    resource: "https://docs.docker.com/build/cache/backends/inline/"
    title: "Inline cache backend — Docker Docs"
  - id: registry-as-a-pull-through-cache-cncf-distribution
    resource: "https://distribution.github.io/distribution/recipes/mirror/"
    title: "Registry as a pull through cache — CNCF Distribution"
---

# Registry Cache Strategy — persisting BuildKit cache across CI runs

## Failure Mode

CI runners are ephemeral — each build starts with an empty BuildKit cache, so
every `docker build` re-runs every layer from the base image up. Without an
external cache backend, the layer cache dies with the runner. Multi-arch builds
(`--platform linux/amd64,linux/arm64`) multiply the cost: every platform
re-pulls base images and re-runs dependency installs from zero, doubling or
quadrupling registry bandwidth and CI minutes.

## Symptoms

- CI build time is constant regardless of whether one line or zero lines
  changed — no warm-cache speedup between runs.
- `docker buildx build` logs show `CACHED` only inside a single run, never
  across runs.
- Docker Hub pulls hit `429 toomanyrequests` because every CI job re-pulls
  `node:slim` anonymously.
- Multi-arch builds take 2-4x as long as single-arch with no cache reuse.

## Practice

Export BuildKit cache to an external backend on every build (`--cache-to`) and
import it on the next build (`--cache-from`). The cache is keyed by layer
content hash, so identical layers skip execution entirely. Correct layer order
(see [layer-cache-order](/layer-cache-order.md)) is the prerequisite — cache
reuse only happens when layers are stable enough to hit.

### Backend selection

| Backend | When to use | Limitation |
|---------|-------------|------------|
| `inline` | Simplest; cache metadata in the image config | Only `mode=min`; bloats image config |
| `registry` | Dedicated cache image; supports `mode=max` | Requires push access to a second ref |
| `local` | Self-hosted runners with persistent disk | Not shared across runners |
| `gha` | GitHub Actions; uses GitHub's cache API | 10 GB per-repo cache limit |

### Registry cache (recommended for shared CI)

A dedicated cache image separate from the output image. Supports `mode=max` so
intermediate multi-stage layers are cached, not just the final stage (see
[multi-stage-builds](/multi-stage-builds.md)). Import from multiple refs to
fall back to `main` when a feature branch has no cache yet.

```console
$ docker buildx build --push -t ghcr.io/user/app:latest \
    --cache-to type=registry,ref=ghcr.io/user/app:buildcache,mode=max \
    --cache-from type=ghcr.io/user/app:buildcache \
    --platform linux/amd64,linux/arm64 .
```

### Inline cache (zero-config fallback)

Embeds cache metadata in the image config. Works with any registry but only
caches the final stage (`mode=min`) — use when you cannot push a second ref.

```console
$ docker buildx build --push -t ghcr.io/user/app:latest \
    --cache-to type=inline \
    --cache-from type=registry,ref=ghcr.io/user/app:latest .
```

### Local cache (self-hosted runners)

For runners with a persistent volume, export to a directory and re-import next
run — no registry round-trip, fastest for single-runner setups:
`--cache-to type=local,dest=/tmp/buildcache,mode=max` paired with
`--cache-from type=local,src=/tmp/buildcache`.

### GitHub Actions cache (`type=gha`)

Uses GitHub's cache API — no registry credentials needed for the cache itself.
Requires Buildx >= v0.21.0 / BuildKit >= v0.20.0 (the legacy v1 API was shut
down April 15, 2025).

```yaml
name: build
on: push
jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v4
      - uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v7
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Multi-arch and `mode=max`

`mode=min` (default) only caches the final stage. `mode=max` caches every
stage, so a Go builder's `go mod download` layer is reused across
architectures and runs. Always pair `mode=max` with `registry` or `gha`;
`inline` does not support it.

### Registry mirroring (pull-through cache)

A separate concern from build cache: run a registry mirror to cache upstream
base images locally, dodging Docker Hub's 100-pull-per-6-hour anonymous rate
limit. Set `registry-mirrors` in `/etc/docker/daemon.json`:

```json
{ "registry-mirrors": ["https://mirror.example.com"] }
```

The mirror pulls `docker.io/library/node:slim` on first request and serves it
locally thereafter. Only Docker Hub can be mirrored by the daemon; for other
upstreams use a proxy like `rpardini/docker-registry-proxy`.

## Related

- [layer-cache-order](/layer-cache-order.md) — cache backends only help when
  layers are ordered for stability; dependency manifests before source.
- [multi-stage-builds](/multi-stage-builds.md) — `mode=max` caches builder
  stages, not just the final image.
- [build-context-hygiene](/build-context-hygiene.md) — smaller context means
  faster cache-key computation and fewer invalidations from stray files.
