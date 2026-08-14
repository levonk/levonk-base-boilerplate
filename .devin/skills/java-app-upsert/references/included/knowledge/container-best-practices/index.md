---
okf_version: "0.2"
---

# Container Best Practices

A compounding knowledge base documenting hard-won lessons from authoring
container images. Each concept captures a specific failure mode that has
occurred in real Dockerfiles and the practice that prevents it.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [Base Image Selection](base-image-selection.md) - Prefer slim over alpine for applications; musl libc breaks glibc wheels and forces source compilation
* [Layer Cache Order](layer-cache-order.md) - Order layers from least- to most-frequently-changed; the onion model for cache strategy
* [Build Context Hygiene](build-context-hygiene.md) - The bad pattern is not COPY . — it's sending garbage into the build context. Use .dockerignore
* [Multi-Stage Builds](multi-stage-builds.md) - Builder is the bloat zone; ship only the binary on scratch or distroless
* [Single-Container Multi-Process](single-container-multi-process.md) - One process per container is a vibe, not a law; use supervisord when it pays
* [Pin Image Digests](pin-image-digests.md) - Tags can move; digests don't. Pin FROM lines for production and internal images
* [Dockerfile Linting](dockerfile-linting.md) - Run hadolint in CI to catch the patterns in this bundle automatically
* [Compose Service Dependency Ordering](compose-service-dependency-ordering.md) - depends_on only waits for the container to start, not for the service to be ready; pair with condition: service_healthy and a healthcheck
* [Container Runtime Hardening](container-runtime-hardening.md) - Non-root, read-only, cap-drop ALL, no-new-privileges; layer resource limits, seccomp, and MAC on top; docker.sock prohibition, TCP daemon TLS, image scanning, implementation checklist
* [Registry Cache Strategy](registry-cache-strategy.md) - Export and import BuildKit layer cache to a registry, local volume, or GHA cache so CI reuses layers across runs
* [BuildKit Secret Mounts](buildkit-secrets.md) - Use --mount=type=secret and --mount=type=ssh so credentials never bake into image layers or appear in docker history
* [Node.js in Containers](nodejs-in-containers.md) - npm ci --omit=dev, NODE_ENV=production, non-root ownership, dumb-init signal handling, multi-stage builds
* [Dockerfile Best Practices](dockerfile-best-practices.md) - Package manager cleanup (apt vs apk), user creation (groupadd vs addgroup), multi-stage builds, healthchecks
* [Container Runtime Essentials](container-runtime-essentials.md) - Build strategy decision tree (pre-built vs Dockerfile vs Nix), multi-arch mandates, QEMU avoidance, sidecar usage, entrypoint/healthcheck naming, base image by use case, --push requirement
* [Nx Monorepo Docker Patterns](nx-monorepo-docker-patterns.md) - Two-layer base image (node-base + deps-base), Nx-affected Docker builds, dual cache (Nx + BuildKit), pnpm-vs-bun-in-containers tradeoff with pnpm-sidecar, @nx/docker plugin, custom hash-based executors, dev-time docker-compose
* [Deterministic Image Versioning](image-versioning.md) - Derive every image version from Git state with scripts/version.sh emitting <epoch>.<semver>-<commit>-<dirty>; inject via build args + OCI labels; never use Git smudge/clean filters; post-deployment override via ConfigMap, bind mount, or env var
