# Container Hygiene

Practices for writing clean, secure, reproducible Dockerfiles that produce small
images and don't leak secrets.

## Core Principles

1. **Multi-stage builds** — separate build environment from final image
2. **Layer ordering** — stable-to-volatile (deps before code)
3. **No secrets in layers** — use BuildKit mounts, never `COPY .env`
4. **Non-root runtime** — final stage runs as an unprivileged user
5. **Pinned tags** — specific versions, never `:latest`

## Multi-Stage Build Pattern

```dockerfile
# syntax=docker/dockerfile:1

# ---- Base stage: shared foundation ----
FROM golang:1.22-bookworm AS base
WORKDIR /src

# ---- Deps stage: cacheable, changes rarely ----
FROM base AS deps
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# ---- Build stage: compiles, needs secrets for private deps ----
FROM deps AS build
RUN --mount=type=ssh go mod verify   # SSH mount for private repos
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o /app ./cmd/server

# ---- Final stage: minimal, no build tools, no secrets ----
FROM gcr.io/distroless/static-debian12:nonroot AS final
COPY --from=build /app /app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
```

## BuildKit Secrets

Never `COPY` secrets or pass them as `ARG` (they persist in image history).
Use `--mount=type=secret`:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci
COPY . .
RUN npm run build
```

```bash
docker build --secret id=npmrc,src=$HOME/.npmrc .
# SSH for private deps: docker build --ssh default=$SSH_AUTH_SOCK .
```

## Mandatory .dockerignore

`.dockerignore` is a mandatory security gate, not a nice-to-have optimization.
Without it, secret directories (`.local/`, `.env`, `.ssh/`), build artifacts
(`build/`, `bin/`, `dist/`), and `.git/` get copied into the Docker build
context and potentially baked into published images — leaking credentials and
inflating image size.

Always exclude at minimum:

```
# Secrets
.local/
.env
.env.*
.ssh/
*.pem
*.key

# VCS & metadata
.git/
.gitignore
.github/
Dockerfile*
docker-compose*.yml
.DS_Store

# Build artifacts
build/
bin/
dist/
target/
node_modules/

# Editor / misc
*.log
tags
TAGS
docs/
*.md
LICENSE
```

As a backstop, scan the final image for secrets before publishing (Gitleaks,
TruffleHog) — see `security-scans.md` for the full scanning pipeline.

## DRY Dockerfile Stages

| Stage | Contains | Purpose |
|-------|----------|---------|
| `base` | OS + language runtime | Shared foundation, rarely changes |
| `deps` | Dependency manifests + install | Cacheable, changes on lockfile bump |
| `build` | Source + compiler output | Produces binary/artifact |
| `test` | Source + test runner | Optional, runs tests in-image |
| `final` | Binary only, distroless | Minimal runtime, no toolchain |

## Layer Ordering: Stable to Volatile

```dockerfile
# ✅ Correct: deps first (cache hit on code-only changes)
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build

# ❌ Wrong: invalidates dep cache on every code change
COPY . .
RUN go mod download && go build
```

## Running as Non-Root

```dockerfile
# Option 1: distroless nonroot variant
FROM gcr.io/distroless/static-debian12:nonroot

# Option 2: create user in regular image
FROM debian:bookworm-slim
RUN groupadd -r app && useradd -r -g app app
USER app
```

## Image Tagging

| Tag type | Example | When to use |
|----------|---------|-------------|
| SHA | `:sha-abc1234` | Reproducible, traceable to commit |
| Semver | `:v1.2.3` | Releases |
| `:latest` | (avoid) | Dev convenience only, never production |

Never use `:latest` in production manifests — it's mutable and breaks
reproducibility.

## Anti-Pattern: Masking Failures with `|| true`

Never mask failures with `|| true` in Dockerfile `RUN` steps. If a package
install fails silently, the image will be missing tools and every CI run that
uses it will fail in confusing ways. Let the build fail loudly so the problem
is caught at image build time, not at CI run time.

## Pre-Publish Scanning

Scan the built image before pushing or before the deploy job:

```yaml
  scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ghcr.io/org/app:sha-${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: '1'   # Fail on CRITICAL/HIGH
```

See `security-scans.md` for the full scanning pipeline.

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| BuildKit | Secrets, cache mounts | Built into modern Docker |
| Trivy | Container + filesystem scanning | Free, SARIF output |
| Hadolint | Dockerfile linting | Catches bad patterns early |
| dive | Image layer inspection | Debug layer bloat |
| distroless | Minimal base images | No shell, no package manager |
