# Prebuilt CI Images

Pre-built container images that bundle your toolchain (compilers, linters,
runtime versions) so CI jobs start fast instead of installing tools on every
run.

## When to Use

- Toolchain install takes more than ~2 minutes per run
- Multiple jobs share the same toolchain (amortize the build cost)
- You need reproducible, pinned tool versions across all CI runs
- You want to test the exact image developers use locally (devbox-in-CI parity)

## When NOT to Use

- GitHub-hosted runners already have your tools (Node, Python, Go, Docker)
- Build is simple — `npm ci && npm test` doesn't need a custom image
- Toolchain install is under 30 seconds (setup actions are fine)
- You don't control the image build process and can't keep it updated

## Rebuild Trigger Patterns

Rebuild the CI image when any of its inputs change:

| Trigger file | Reason |
|--------------|--------|
| `Dockerfile.ci` | Image definition changed |
| `devbox.json` | Tool versions changed |
| `Justfile` (if installed in image) | Task runner changed |
| `*.lock` / `go.sum` / `package-lock.json` | Dependency versions changed |
| `.github/workflows/ci-image.yml` | The build workflow itself changed |

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'Dockerfile.ci'
      - 'devbox.json'
      - 'Justfile'
      - 'go.sum'
      - '.github/workflows/ci-image.yml'
  workflow_dispatch:   # Allow manual rebuilds
```

## GHCR Publishing Workflow

GitHub Container Registry (GHCR) requires no extra secrets — `GITHUB_TOKEN`
has `packages: write` scope when granted via `permissions:`.

```yaml
name: Build CI Image

on:
  push:
    branches: [main]
    paths:
      - 'Dockerfile.ci'
      - 'devbox.json'
      - 'go.sum'
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/ci-tools

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix={{sha}},format=short
            type=raw,value=latest,enable={{is_default_branch}}

      - uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile.ci
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Consuming the Image

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/${{ github.repository }}/ci-tools:latest
    steps:
      - uses: actions/checkout@v4
      - run: just test   # tools already installed in the image
```

## Using the Image in CI

Once the image is published to GHCR, CI jobs reference it via the `container:`
directive — no `devbox-install-action` needed because the tools are already
baked in:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/owner/repo/ci-image:latest
    steps:
      - uses: actions/checkout@v4
      - run: just test  # tools already in the image, no devbox-install-needed
```

## Container Shell Configuration

GitHub Actions runs container steps with `bash --noprofile --norc` by default.
Any PATH setup in `.bashrc` or `/etc/profile.d/` is silently ignored — tools
are "installed" in the image but not findable at runtime, a confusing failure
mode where `just: command not found` appears despite `just` being present in
the image.

Fix: add `shell: bash -l {0}` to every step that needs tools from the image.
The `-l` flag sources `/etc/profile.d/*.sh`, putting the image's tools on PATH:

```yaml
- name: Run tests
  shell: bash -l {0}   # sources /etc/profile.d/*.sh, puts tools on PATH
  run: just test
```

Without this, tools are "installed" in the image but not findable at runtime —
a confusing failure mode where the image works locally but fails in CI.

## First-Run Bootstrap

When you add `container: ghcr.io/owner/repo/ci-image:latest` to a workflow, the
image doesn't exist on first run — the workflow fails with "image not found".

Two fixes:

1. **Manual bootstrap** — build and push the image before the first CI run:
   ```bash
   docker build -f Dockerfile.ci -t ghcr.io/owner/repo/ci-image:latest .
   docker push ghcr.io/owner/repo/ci-image:latest
   ```
2. **Fallback in the workflow** — detect the missing image and fall back to
   direct tool install (e.g., `devbox-install-action`) instead of failing.

The rebuild-image workflow should be merged **before** the main workflow starts
using the container, so the image exists by the time consuming jobs run.

## Secret Format Differences: act vs Real CI

Real GitHub secrets are multi-line PEM (`gh secret set` handles multi-line).
`act`'s `--secret-file` only handles single-line `KEY=value` pairs. This
mismatch causes PEM keys to be truncated or mangled when running locally with
`act`.

Fix: base64-encode secrets for `act`, then detect and decode in the workflow:

```bash
# act: base64-encode secrets in the secret file
echo "MY_KEY=$(base64 < key.pem | tr -d '\n')" >> act-secrets.txt

# Workflow: detect format and decode
decode_if_b64() {
  if echo "$1" | grep -q '^-----BEGIN'; then
    printf '%s' "$1"          # already PEM
  else
    printf '%s' "$1" | base64 -d  # act base64
  fi
}
```

## Nix Daemon in Docker Build

Devbox relies on the Nix daemon, which isn't running inside a Docker build by
default. Start it in a `RUN` step before calling `devbox install`:

```dockerfile
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
    && nix-daemon --daemon > /tmp/nix-daemon.log 2>&1 & \
    for i in $(seq 1 30); do \
      if [ -S /nix/var/nix/daemon-socket/socket ]; then break; fi; \
      sleep 1; \
    done \
    && devbox install
```

> **Note:** Copy both `devbox.json` AND `devbox.lock` into the Docker build
> context for reproducible installs.

## Caching Strategies

| Strategy | Scope | Best for |
|----------|-------|----------|
| Layer cache (`cache-from/to: type=gha`) | GitHub Actions cache | Small-to-medium images, single arch |
| BuildKit cache mounts (`--mount=type=cache`) | Within a single build | Package manager caches (npm, pip, go mod) |
| Registry cache (`type=registry`) | Shared across runners | Large images, multi-arch, cross-branch |

### BuildKit cache mount in Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod go build -o /app ./...
```

## Cache Invalidation on Image Changes

When the pre-built CI image changes (new tool version), caches that depend on
the old image may produce stale results — a cache hit returns artifacts built
against the previous toolchain, masking incompatibilities.

Fix: include the image digest or tag in cache keys so a new image invalidates
the cache:

```yaml
- uses: actions/cache@v4
  with:
    path: .next/cache
    key: ${{ matrix.os }}-${{ hashFiles('devbox.json') }}-${{ github.sha }}
    restore-keys: |
      ${{ matrix.os }}-${{ hashFiles('devbox.json') }}-
```

Or use `restore-keys:` with a fallback strategy — exact match first, then
progressively looser matches. `actions/cache` keys should include a hash of
the environment definition (e.g., `devbox.json`, `Dockerfile.ci`), not just
the OS, so toolchain changes invalidate dependent caches.

## Multi-Arch Considerations

- Use `docker/setup-qemu-action` and `docker/setup-buildx-action` for cross-arch
- Multi-arch builds are slower — only build arches you actually use
- Tag with architecture suffix or rely on manifest list for `:latest`
- Cache per-arch to avoid cache conflicts

```yaml
      - uses: docker/setup-qemu-action@v3
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          platforms: linux/amd64,linux/arm64
          # ... rest of config
```

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| docker/build-push-action | Build & push images | Standard for GHCR |
| docker/metadata-action | Auto-tagging (sha, semver) | Generates tags from git refs |
| docker/setup-buildx-action | BuildKit builder | Required for cache mounts |
| depot.dev | Faster builds | Drop-in buildx replacement, remote cache |
