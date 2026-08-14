---
type: Practice
title: BuildKit Secret Mounts — never bake credentials into image layers
description: ARG and RUN with inline tokens persist secrets in layers and docker history. Use --mount=type=secret and --mount=type=ssh so credentials exist only for the RUN that needs them.
tags: [docker, buildkit, secrets, security, ssh-agent, npm-pypi, buildx, ci]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: build-secrets-docker-docs
    resource: "https://docs.docker.com/build/building/secrets/"
    title: "Build secrets | Docker Docs"
  - id: docker-buildx-build-secret-reference-docker-docs
    resource: "https://docs.docker.com/reference/cli/docker/buildx/build/#secret"
    title: "docker buildx build — --secret reference | Docker Docs"
  - id: using-secrets-with-github-actions-docker-docs
    resource: "https://docs.docker.com/build/ci/github-actions/secrets/"
    title: "Using secrets with GitHub Actions | Docker Docs"
  - id: the-hidden-risks-of-docker-build-time-arguments-microsoft-ise-developer-blog
    resource: "https://devblogs.microsoft.com/ise/hidden-risks-of-docker-build-time-arguments-and-how-to-secure-your-secrets/"
    title: "The Hidden Risks of Docker Build Time Arguments — Microsoft ISE Developer Blog"
  - id: how-secrets-leak-out-of-docker-images-truffle-security
    resource: "https://trufflesecurity.com/blog/how-secrets-leak-out-of-docker-images"
    title: "How Secrets Leak out of Docker Images — Truffle Security"
---

# BuildKit Secret Mounts — never bake credentials into image layers

## Failure Mode

Passing credentials into a build via `ARG`, `--build-arg`, `ENV`, or inline
`RUN npm login --token=...` commands. Each writes the secret into a filesystem
layer or the image history metadata, where it lives forever — cached by the
builder, pushed to registries, readable by anyone who can pull the image or
inspect a layer tarball. Multi-stage builds do **not** save you: if the secret
touches a builder-stage layer, it is in the build cache and every intermediate
image. A later `RUN rm` only adds a whiteout entry; the bytes persist in the
earlier layer's tarball.

## Symptoms

- `docker history --no-trunc <image>` shows `ARG GITHUB_TOKEN=ghp_...` or a
  `RUN pip install --extra-index-url https://token:<secret>@...` line in full.
- `dive <image>` reveals a `.env`, `.npmrc`, or `~/.aws/credentials` file in an
  intermediate layer even though a later `RUN rm` deleted it.
- A rotated token still works because an old image in a private registry
  carries the previous credential in a cached layer; CI logs echo
  `--build-arg NPM_TOKEN=...` instead of a redacted secret mount.

## Practice

Use BuildKit secret mounts: the credential is attached to a single `RUN`
instruction as a tmpfs file under `/run/secrets/`, consumed by the process,
and discarded before the layer is committed. The secret never appears in the
layer diff, the image history, or the build cache key.

### Dockerfile — file-based secret (npm/pip registry auth)

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim
WORKDIR /app

COPY package.json package-lock.json ./
# .npmrc is mounted from the host, used, then gone — not in the layer
RUN --mount=type=secret,id=npm,target=/root/.npmrc npm ci

COPY . .
CMD ["node", "index.js"]
```

### Dockerfile — environment-based secret

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3-slim
RUN --mount=type=secret,id=pypi-token,env=POETRY_HTTP_BASIC_PYPI_PASSWORD,required=true \
    pip install --index-url https://__token__:${POETRY_HTTP_BASIC_PYPI_PASSWORD}@pypi.org/simple/ -r requirements.txt
```

### Build command

```bash
# File source:        docker buildx build --secret id=npm,src=$HOME/.npmrc -t app .
# Environment source: PYPI_TOKEN=ghp_... docker buildx build --secret id=pypi-token -t app .
```
`type` is auto-detected: if an env var matching the `id` is set, Buildx uses
`type=env`; otherwise it falls back to `type=file`.

### SSH agent forwarding for private git deps

For `go get`, `npm install` from `git+ssh://`, or `pip install` from a private
GitHub repo, forward the SSH agent instead of copying a key:

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22
RUN apk add --no-cache openssh-client git
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN --mount=type=ssh go mod download
```
Build with `eval $(ssh-agent) && ssh-add ~/.ssh/id_ed25519` then
`docker buildx build --ssh default -t app .`. The key never enters a layer.

### GitHub Actions — inject secrets, never echo them

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: ghcr.io/org/app:latest
          secrets: |
            "npm=${{ secrets.NPM_RC }}"
          secret-envs: |
            "pypi-token=PYPI_TOKEN"
        env:
          PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

The `secrets:` input maps to `--secret id=...,src=` and `secret-envs:` to
`--secret id=...,env=`. Neither writes the value into a build arg, so it never
appears in the workflow log or the image history.

### Verification

- `docker history --no-trunc <image>` shows only `RUN --mount=type=secret` with
  no value — the secret id is present, the content is not.
- `dive <image>` shows no `.npmrc`, `.env`, or credential file in any layer
  diff. Rotate the token and rebuild; the old value must be unrecoverable.

## Related

- [layer-cache-order](/layer-cache-order.md) — secrets must NOT be in cached layers; layer order determines what gets cached and redistributed.
- [multi-stage-builds](/multi-stage-builds.md) — multi-stage shrinks the final image but the builder stage still caches secrets without `--mount=type=secret`.
- [build-context-hygiene](/build-context-hygiene.md) — `.dockerignore` excludes `.env` from the context; `--secret` is the build-time equivalent for credentials the build actually needs.
- [container-runtime-hardening](/container-runtime-hardening.md) — runtime secret hygiene (runtime-only env, secret managers) complements build-time secret hygiene.
