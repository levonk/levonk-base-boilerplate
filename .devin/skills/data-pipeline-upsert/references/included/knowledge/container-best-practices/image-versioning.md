---
type: Practice
title: Deterministic Image Versioning from Git State
description: Derive every image version from Git state with a single scripts/version.sh that emits <epoch>.<semver>-<commit>-<dirty>, inject it via build args and OCI labels, and never rely on Git smudge/clean filters or CI environment variables. Supports post-deployment override via ConfigMap, bind mount, or env var.
tags: [docker, versioning, git, semver, oci-labels, reproducibility, buildkit, multi-arch, gitops, supply-chain]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"

sources:
  - id: canonical-docker-image-versioning-spec
    resource: "https://copilot.microsoft.com/shares/58jfrWSQ83wu6fwm25Ddf"
    title: "Canonical Docker Image Versioning Spec (reconstructed)"
  - id: gitattributes-smudge-clean-filters
    resource: "https://git-scm.com/docs/gitattributes#_filtering_files_at_checkout_and_checkin"
    title: "gitattributes — Filtering files at checkout and checkin (smudge/clean)"
  - id: oci-image-spec-annotations
    resource: "https://github.com/opencontainers/image-spec/blob/main/annotations.md"
    title: "OCI Image Spec — Annotations (org.opencontainers.image.version/revision/created)"
  - id: docker-buildx-multi-platform
    resource: "https://docs.docker.com/build/building/multi-platform/"
    title: "docker buildx multi-platform builds"
---

# Deterministic Image Versioning from Git State

## Failure Mode

Images tagged with non-deterministic strings — CI build numbers, timestamps,
`latest`, or version strings derived from environment variables that differ
across CI runners. Two builds from the same commit produce different tags, the
registry fills with untraceable images, and an incident post-mortem cannot map
a running image back to its source commit. Worse: teams reach for Git keyword
expansion (smudge/clean filters) to bake versions into files, which breaks
multi-arch builds, shallow clones, and Docker build contexts.

## Symptoms

- Two CI runs on the same commit produce different image tags (driven by
  `$BUILD_NUMBER` or `date`).
- `docker inspect` shows no `org.opencontainers.image.revision` — there is no
  way to find the commit that produced a running container.
- A multi-arch buildx push emits different version strings per platform
  because the version was computed per-platform instead of once.
- A "reproducible" rebuild produces a different image because the version
  string changed and a downstream consumer pinned the tag.
- Git smudge filters silently fail in CI (filters disabled in ephemeral
  runners, shallow clones lack the tag history) and the baked `$Id$` stays
  unexpanded inside the image.

## Practice

Derive the version string from Git state with a single script, generate a
`.version` file, and inject it through Docker build args + OCI labels. Never
rely on Git keyword expansion. Never rely on CI environment variables as the
primary source.

### Version string format (authoritative)

```
<epoch>.<semver>-<commit>-<dirty>
```

| Component | Source | Notes |
|-----------|--------|-------|
| `epoch` | manually incremented | only changes when the versioning scheme itself changes |
| `semver` | nearest Git tag | `v1.4.2` → `1.4.2`; ahead-of-tag → `1.4.2+3` |
| `commit` | `git rev-parse --short HEAD` | always short SHA |
| `dirty` | `-dirty` if working tree modified | empty if clean |

Examples:

| State | Output |
|-------|--------|
| Clean tag | `1.1.4.2-a1b2c3d` |
| Ahead of tag | `1.1.4.2+3-a1b2c3d` |
| Dirty | `1.1.4.2+3-a1b2c3d-dirty` |

The string is the **single source of truth** for all downstream systems —
image tag, OCI labels, runtime introspection file, and post-deployment
overrides all derive from it.

### Version extraction script (canonical)

`scripts/version.sh` is the only generator. It produces a deterministic string
regardless of CI environment.

```bash
#!/usr/bin/env bash
set -euo pipefail

epoch=1

tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
commits=$(git rev-list --count "${tag}..HEAD" || echo 0)
sha=$(git rev-parse --short HEAD)
dirty=""
git diff --quiet || dirty="-dirty"

if [ "$commits" -eq 0 ]; then
    semver="${tag#v}"
else
    semver="${tag#v}+${commits}"
fi

echo "${epoch}.${semver}-${sha}${dirty}"
```

### Version file generation (required)

Generate a real file instead of relying on keyword expansion:

```bash
./scripts/version.sh > .version
```

This file is deterministic, reproducible, portable across Docker / Podman /
Buildx / Nix / GitOps, safe for shallow clones, and safe for CI ephemeral
workspaces. It replaces all Git keyword expansion mechanisms.

### Dockerfile integration

```dockerfile
ARG VERSION
ARG BUILD_DATE
ARG GIT_COMMIT

LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/<org>/<repo>"

COPY .version /app/.version
```

This ensures OCI metadata is correct, runtime introspection is possible, and
the version file is always present inside the image.

### CI integration (GitHub Actions)

```yaml
- name: Compute version
  run: |
    VERSION=$(./scripts/version.sh)
    echo "$VERSION" > .version
    echo "VERSION=$VERSION" >> $GITHUB_ENV

- name: Build image
  run: |
    docker build \
      --build-arg VERSION=${VERSION} \
      --build-arg GIT_COMMIT=${GITHUB_SHA} \
      --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
      -t myimage:${VERSION} .
```

### Multi-arch (Buildx)

Compute the version **once** before invoking buildx so every platform gets the
same string:

```bash
VERSION=$(./scripts/version.sh)
echo "$VERSION" > .version

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --push \
  --build-arg VERSION=${VERSION} \
  --build-arg GIT_COMMIT=$(git rev-parse HEAD) \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  -t myimage:${VERSION} .
```

### Tagging rules

Push:

- `myimage:<full-version>` — always
- `myimage:<major.minor>` — only on clean tags (no `+N`, no `-dirty`)
- `myimage:latest` — only on the main branch

### Runtime version introspection

Every container must support:

- **File-based**: `/app/.version`
- **CLI**: a small `cat /app/.version` wrapper
- **HTTP (optional)**: `GET /version` returns the file contents

## Post-Deployment Version Override

Sometimes version info must be injected or updated **after** a container is
already deployed — hotfix labelling, environment pinning, or rollback
annotation. Three deterministic mechanisms, all production-safe.

### Option A — Kubernetes ConfigMap overlay (preferred)

Mount a ConfigMap over the version file inside the running container without
rebuilding the image:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: runtime-version
data:
  .version: "runtime-override-2026-04-03"
```

```yaml
volumeMounts:
  - name: version
    mountPath: /app/.version
    subPath: .version
volumes:
  - name: version
    configMap:
      name: runtime-version
```

### Option B — Docker / Podman bind mount override

```bash
docker run \
  -v "$(pwd)/runtime-version.txt:/app/.version" \
  myimage:latest
```

### Option C — Runtime environment variable override

Add logic to the entrypoint:

```bash
if [ -n "${RUNTIME_VERSION_OVERRIDE:-}" ]; then
    echo "$RUNTIME_VERSION_OVERRIDE" > /app/.version
fi
```

Then inject at runtime:

```bash
docker run -e RUNTIME_VERSION_OVERRIDE="hotfix-2026-04-03" myimage
```

Or in Kubernetes:

```yaml
env:
  - name: RUNTIME_VERSION_OVERRIDE
    value: "hotfix-2026-04-03"
```

## Avoid: Git Smudge/Clean Filters for Version Injection

Git's smudge/clean filter mechanism (`.gitattributes` + `filter.expand.smudge`
/ `filter.expand.clean`) is the only built-in way to expand placeholders like
`$Id$` at checkout. **Do not use it for image versioning.** It breaks:

- **Reproducibility** — expanded text mutates file contents, breaking content
  hashing.
- **Multi-arch builds** — buildx contexts are assembled without smudge filters.
- **Docker build contexts** — `COPY . .` bypasses smudge unless filters are
  explicitly re-configured in CI and `git checkout --force .` is run first.
- **CI shallow clones** — `git describe --tags` fails without tag history.
- **GitOps workflows** — declarative renderers do not run smudge filters.
- **Cross-platform consistency** — filter behavior differs across Git builds.

Git has **no built-in keyword identifiers** the way CVS/Subversion did. The
`ident` attribute expands `$Id$` to the blob SHA-1, not the commit hash or
semver — it is useless for versioning. Everything must be wired through
user-defined filters, and the resulting fragility is not worth it. The
`.version` file approach is deterministic and portable.

## Reproducibility Guarantees

- Version is fully derivable from Git state.
- No reliance on CI environment variables as the primary source.
- Dirty builds are explicitly marked.
- Multi-arch builds produce identical version strings (computed once).
- OCI labels ensure traceability from registry → image → commit.
- Post-deployment overrides are layered on top, never baked in.

## Related

- [pin-image-digests](pin-image-digests.md) — pin `FROM` lines to immutable
  digests; this concept pins the *output* image tag to a deterministic version
  string. Together they make builds fully reproducible end-to-end.
- [registry-cache-strategy](registry-cache-strategy.md) — layer cache reuse
  composes with deterministic versioning: same version + same layers = same
  image.
- [container-runtime-hardening](container-runtime-hardening.md) — OCI labels
  set here are consumed by image scanners and runtime policy enforcement.
- [buildkit-secrets](buildkit-secrets.md) — `--mount=type=secret` for
  credentials; `--build-arg` for version metadata. Different mechanisms for
  different payload types.
- [container-runtime-essentials](container-runtime-essentials.md) — the
  `--push` requirement for multi-platform builds pairs with the
  compute-version-once rule here.
