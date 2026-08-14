---
type: Practice
title: Pin Image Digests, Not Tags
description: Tags can move; digests don't. Pin FROM lines to @sha256:<digest> for production images, especially internal ones where mistakes are more common.
tags: [docker, dockerfile, supply-chain, digest, tag, pinning, reproducibility]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: docker-buildx-imagetools-inspect
    resource: "https://docs.docker.com/reference/cli/docker/buildx/imagetools/inspect/"
    title: "docker buildx imagetools inspect"
  - id: open-container-initiative-image-spec-digests
    resource: "https://github.com/opencontainers/image-spec/blob/main/descriptor.md#digests"
    title: "Open Container Initiative Image Spec — Digests"
---

# Pin Image Digests, Not Tags

## Failure Mode

Using mutable tags (`node:26-slim`, `python:3`, `latest`, `nightly`) in
`FROM` lines. Tags can be repointed to a different build — by accident or on
purpose — and your "reproducible" build silently changes underneath you.

## Symptoms

- A build that worked yesterday fails today with no code change.
- A build that worked yesterday behaves differently today (the base image
  shipped a regression).
- Internal images are worse than official ones: mistakes in tag repointing
  are far more common when there's no public scrutiny.

## Practice

Pin every `FROM` line to an immutable digest for production images.

```dockerfile
# Mutable — the tag can move
FROM node:26-slim

# Immutable — pinned forever
FROM node:26-slim@sha256:<digest>
```

### How to find the digest

```bash
docker buildx imagetools inspect node:26-slim
```

Returns the immutable build digest SHA. Add it to the `FROM` line:

```dockerfile
FROM node:26-slim@sha256:0f4a7b1a3b2c...<full digest>
```

### When to pin vs not

| Context | Pin? | Reason |
|---------|------|--------|
| Production images | **Yes** | Reproducibility, supply-chain integrity |
| Internal images | **Yes** | Internal mistakes are more common than upstream |
| Dev / local | Optional | Convenience of `latest` may outweigh reproducibility |
| CI base images | **Yes** | CI must be reproducible |

## Related

- [base-image-selection](/base-image-selection.md) — choose the right base
  image first, then pin its digest.
- [dockerfile-linting](/dockerfile-linting.md) — `hadolint` flags unpinned
  `FROM` lines.
