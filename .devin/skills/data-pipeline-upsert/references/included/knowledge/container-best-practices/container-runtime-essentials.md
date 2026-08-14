---
type: Practice
title: Container Runtime Essentials
description: Build strategy decision tree (pre-built vs Dockerfile vs Nix), multi-arch mandates, QEMU avoidance, sidecar usage, entrypoint/healthcheck naming, base image selection by use case, and --push requirements for production images.
tags: [container, docker, runtime, base-image, multi-arch, buildx, nix, sidecar, entrypoint, healthcheck, alpine, debian]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-18"
  last-used: "2026-07-18"
---

# Container Runtime Essentials

## Build Strategy Decision Tree

Before writing any build definition, check upstream registries (GHCR, Docker
Hub, Quay) for official multi-arch images. Document the check result in the
task or PRD. If a suitable pre-built image exists, wrap it — do not rebuild
from source.

```
pre-built image exists?  →  yes → wrap it, do not rebuild
                          no  → runtime needs Nix store? → yes → Nix flake (dockerTools.buildLayeredImage)
                                                          no  → multi-stage Dockerfile + docker buildx
```

The simplest tool that produces the right artifact wins:

- **Nix flakes** for reproducibility when the runtime genuinely needs a Nix
  store at runtime (i.e., the service is a Nix client, not just a static or
  dynamically linked binary).
- **Dockerfiles + buildx** for portability and multi-arch when it doesn't.

Choose based on runtime needs, not build preferences. A Rust binary in a
Debian slim image built via `docker buildx --platform` is simpler, smaller,
and more portable than a Nix flake container that couples to a Linux build
host. Nix flake container builds couple the image to the build host's system —
avoid this coupling unless the runtime genuinely requires it.

### Build feasibility check

Before creating implementation tasks for a containerized service, verify the
build path is feasible on available build hosts. Document the build host,
target architectures, and image source (pre-built / Dockerfile / Nix flake)
in the task. If no available host can produce the required architectures,
block the task until the feasibility issue is resolved.

## Multi-Arch Build Requirements

Multi-arch is mandatory for mixed-architecture fleets. Never ship a
single-arch `:latest` tag for a fleet that spans x86_64 and aarch64. Use
multi-arch manifests:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push
```

or arch-specific tags (`:amd64`, `:arm64`). Verify with
`docker manifest inspect` before deploying.

### `--push` is required for multi-platform builds

`docker buildx build --load` only works for a single platform. Multi-platform
builds must use `--push` to a registry — the local Docker image store cannot
hold a multi-arch manifest.

### Avoid QEMU for heavy compilation

QEMU/binfmt emulation is 10-24x slower than native and known to segfault on
Rust toolchains (rust-lang/rust#147026) and the mold linker (rui314/mold#1550).
For Rust, C++, or Go production builds, use cross-compilation toolchains or
native build hosts per architecture. QEMU is acceptable only for simple
builds, dependency installation, or prototyping.

## Base Image Selection by Use Case

For the general Alpine-vs-Slim trade-off for application Dockerfiles (musl
libc breaks glibc wheels), see
[Base Image Selection](base-image-selection.md). The project-specific base
image mapping by use case:

| Use case | Base image | Reason |
|----------|-----------|--------|
| Quick-to-create container image | `localnet-base-alpine` | Smallest, fastest to build |
| Heavily invested, extreme optimization | `localnet-base-debian` (built from Nix tools) | Full control over toolchain |
| Interactive end-user use | `localnet-base-debnix` (latest Debian slim via wrapper) | Developer ergonomics |
| Development | `localnet-base-dev` | Pre-configured dev tooling |

## Sidecar Usage Patterns

Shared sidecars exist with all the shared sidecars/volumes needed for Nix,
pnpm, PyPI, etc. Use them — do not reinvent volume sharing.

For those shared sidecars to work, installations must happen in the
entrypoint script, not in the Dockerfile build stage. The entrypoint runs
at container start when the shared volumes are mounted; build-time
`RUN` commands execute before the volumes are available.

## Entry Point and Healthcheck Naming Conventions

Healthcheck, entrypoint, and Dockerfile files should always include the
service slug in the name so it's easy to differentiate the files on open.
For example, for a service with slug `api-gateway`:

- `Dockerfile.api-gateway`
- `entrypoint-api-gateway.sh`
- `healthcheck-api-gateway.sh`

For the `HEALTHCHECK` instruction syntax itself, see
[Dockerfile Best Practices](dockerfile-best-practices.md).

## `sudo` Prohibition in Containers

Do not install or use the `sudo` command in containers. Use the
OS-appropriate privilege-drop tool instead:

- **Alpine**: `su-exec` (installed by default on `localnet-base-alpine`)
- **Debian / other**: `gosu`

See job-aide ADR-20260106001 for the OS-specific standard. For the broader
non-root runtime hardening model (USER directive, `--user` override,
read-only filesystem, cap-drop), see
[Container Runtime Hardening](container-runtime-hardening.md).

## See Also

- [Base Image Selection](base-image-selection.md) — Alpine vs Slim for
  application Dockerfiles; musl libc breakage and the 15× build-time penalty.
- [Dockerfile Best Practices](dockerfile-best-practices.md) — Package manager
  cleanup, user creation, multi-stage builds, and the `HEALTHCHECK` instruction.
- [Container Runtime Hardening](container-runtime-hardening.md) — Non-root,
  read-only, cap-drop ALL, no-new-privileges; the broader runtime hardening
  model that the `su-exec`/`gosu` privilege-drop pattern complements.
- [Multi-Stage Builds](multi-stage-builds.md) — Builder vs runtime stage
  separation; the Dockerfile pattern that pairs with the build strategy above.
- [Pin Image Digests](pin-image-digests.md) — Supply-chain integrity for the
  pre-built and multi-arch images referenced by this build strategy.

## Sources

- Migrated from src/current/rules/software-dev/devops/container-essentials.md
- Migrated from src/current/rules/software-dev/devops/container-build-principles.md
