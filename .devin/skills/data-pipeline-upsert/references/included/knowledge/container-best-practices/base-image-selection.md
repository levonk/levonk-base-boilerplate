---
type: Practice
title: Base Image Selection — Slim over Alpine for applications
description: Prefer slim over alpine for application Dockerfiles because musl libc breaks native dependency wheels and forces source compilation.
tags: [docker, dockerfile, base-image, alpine, slim, musl, glibc, build-time]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: musl-libc
    resource: "https://musl.libc.org/"
    title: "musl libc"
  - id: glibc
    resource: "https://www.gnu.org/software/libc/"
    title: "glibc"
  - id: existing-project-standard-alpine-for-infra
    resource: "../../workflows/software-dev/devops/containers/docker-standards.md"
    title: "existing project standard (alpine-for-infra)"
---

# Base Image Selection — Slim over Alpine for applications

## Failure Mode

Defaulting to `alpine` base images for application Dockerfiles because "smaller
is better", without understanding that Alpine uses [musl libc](https://musl.libc.org/)
instead of [glibc](https://www.gnu.org/software/libc/). Most upstream package
releases (Debian, Ubuntu, Fedora ecosystems) build against glibc and ship
glibc-only wheels/binaries. On Alpine, those dependencies must be recompiled
from source or silently run slower.

## Symptoms

- `pip install` / `npm install` fails with `no matching distribution found` for
  packages that have no musl wheel (e.g. Confluent Kafka, LMDB).
- Builds "succeed" only because `--only-binary` masks the missing musl wheel by
  refusing to compile — the dependency is silently absent.
- Build times balloon: ~10 s to compile one C library on Alpine vs <1 s on
  Slim (~15× slower). At enterprise scale (thousands of builds/day) this
  compounds badly.
- The common ChatGPT "fix" — `apk add build-base` (GCC, make, musl-dev) —
  works but adds a C toolchain to the image and forces every dependency to
  recompile on every cold build.

## Practice

Prefer `slim` (Debian-based, glibc) over `alpine` (musl) for **application**
Dockerfiles unless you have a specific, measured reason to accept musl's
compatibility tax.

- `python:3-slim` vs `python:3-alpine`: ~90 MB size difference, negligible
  compared to the build-time and compatibility cost.
- `node:slim` vs `node:alpine`: same trade-off.
- For compiled languages (Go, Rust) producing static binaries, see
  [multi-stage-builds](/multi-stage-builds.md) — the base image of the
  **builder** stage doesn't matter, and the **final** stage can be `scratch`
  or `distroless`.

## When Alpine Is Correct

Alpine is appropriate when **you control the full toolchain** and the size
savings are worth the compilation cost:

- Infrastructure services where you build everything from source anyway.
- Security-hardened base images (e.g. `localnet/base-alpine`) where the small
  attack surface is the point.
- Sidecar/init containers with no native dependencies.

## Apparent Contradiction With Project Standards

The job-aide `docker-standards.md` workflow says "prefer alpine images if
possible". This is **not** a contradiction — it is context-dependent:

| Context | Recommendation | Reason |
|---------|----------------|--------|
| Infrastructure services (you own the toolchain) | Alpine | Small attack surface, you compile everything anyway |
| Application Dockerfiles (upstream deps) | Slim | musl breaks glibc wheels, 15× build-time penalty |
| Compiled-language final stage | `scratch` / `distroless` | No OS needed for a static binary |

When in doubt, measure: build the same Dockerfile on `alpine` and `slim`,
compare build time, final size, and whether native deps resolve without
`build-base`.
