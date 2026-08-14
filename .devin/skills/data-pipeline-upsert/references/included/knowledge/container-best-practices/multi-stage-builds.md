---
type: Practice
title: Multi-Stage Builds — builder is the bloat zone
description: Use multi-stage Dockerfiles with a builder stage for toolchains and a scratch/distroless final stage for the runtime. Ship only the binary, not the compiler.
tags: [docker, dockerfile, multi-stage, scratch, distroless, go, rust, static-binary]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: distroless-images
    resource: "https://github.com/GoogleContainerTools/distroless"
    title: "Distroless images"
  - id: docker-multi-stage-build-documentation
    resource: "https://docs.docker.com/build/building/multi-stage/"
    title: "Docker multi-stage build documentation"
---

# Multi-Stage Builds — builder is the bloat zone

## Failure Mode

Running a compiled-language binary inside a full OS image (e.g. `golang:alpine`
running the compiled `go build` output). The Go runtime and toolchain are
present in the final image even though the binary is static and needs none of
it.

## Symptoms

- A "hello world" Go binary in `golang:alpine` is **272 MB**.
- A "hello world" Python app in `python:3-alpine` is ~130 MB.
- Image pull times and registry storage costs scale with the bloat.

## Practice

Use multi-stage builds. Name the first stage `builder` — the "bloat zone"
where the toolchain lives. The final stage copies **only the artifact** (binary,
wheel, static assets) and runs it on a minimal base.

### Go multi-stage pattern

```dockerfile
# Builder stage — toolchain lives here
FROM golang:1.22 AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o app main.go

# Final stage — only the binary
FROM scratch
COPY --from=builder /src/app /app
CMD ["/app"]
```

Result: 272 MB → **2.3 MB** (with `scratch`) or **11 MB** (with a minimal base).

### `FROM scratch` vs Distroless

| Base | Size | Shell | Pkg manager | CA certs | Use when |
|------|------|-------|-------------|----------|----------|
| `scratch` | smallest | no | no | no | Pure static binary, no TLS, no user |
| `distroless` | tiny | no | no | yes | Static binary needing CA certs / user |
| `slim` | small | yes | no | yes | Dynamic deps, debugging shell needed |
| `alpine` | small | yes | yes (apk) | yes | Infra services (see [base-image-selection](/base-image-selection.md)) |

> "Distroless is to `scratch` what Slim is to Alpine." — practical middle
> ground: still tiny, no shell, no package manager, but ships useful runtime
> basics (CA certs, user setup) that you occasionally need.

## When NOT to use multi-stage

- Interpreted languages (Python, Node, Ruby) where the runtime **is** the
  app — there's no "binary" to extract. Use [base-image-selection](/base-image-selection.md)
  (slim) instead.
- Debug images where you need the toolchain inside the running container.

## Related

- [base-image-selection](/base-image-selection.md) — slim vs alpine for the
  builder stage (doesn't matter) and the final stage (distroless > scratch for
  practical use).
- [layer-cache-order](/layer-cache-order.md) — `go mod download` before
  `COPY . .` in the builder stage.
