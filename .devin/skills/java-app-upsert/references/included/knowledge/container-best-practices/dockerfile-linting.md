---
type: Practice
title: Dockerfile Linting — hadolint in CI
description: Run hadolint on every Dockerfile in CI to catch the patterns in this bundle automatically: npm install vs npm ci, COPY . without .dockerignore, unpinned tags.
tags: [docker, dockerfile, linting, hadolint, ci, quality-gate]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: hadolint-dockerfile-linter
    resource: "https://github.com/hadolint/hadolint"
    title: "hadolint — Dockerfile linter"
  - id: hadolint-github-action
    resource: "https://github.com/hadolint/hadolint-action"
    title: "hadolint GitHub Action"
---

# Dockerfile Linting — hadolint in CI

## Failure Mode

Reviewing Dockerfiles manually for the practices in this bundle. Humans miss
things; CI doesn't.

## Symptoms

- A Dockerfile with `npm install` instead of `npm ci` ships to production.
- A Dockerfile with `COPY .` and no `.dockerignore` ships 500 MB of context.
- A Dockerfile with an unpinned `FROM node:latest` ships a different image
  every build.

## Practice

Run **[hadolint](https://github.com/hadolint/hadolint)** on every Dockerfile
in CI. It catches exactly the patterns in this bundle:

| hadolint rule | Catches | See |
|---------------|---------|-----|
| DL3016 | `npm install` vs `npm ci` | [layer-cache-order](/layer-cache-order.md) |
| DL3022 | `COPY .` without `.dockerignore` | [build-context-hygiene](/build-context-hygiene.md) |
| DL3007 | `FROM ...:latest` | [pin-image-digests](/pin-image-digests.md) |
| DL3006 | Unpinned `FROM` tag | [pin-image-digests](/pin-image-digests.md) |
| DL3059 | Multiple consecutive `RUN` (cache inefficiency) | [layer-cache-order](/layer-cache-order.md) |

### CI integration

```yaml
# .github/workflows/dockerfile-lint.yml
name: Dockerfile Lint
on: [pull_request]
jobs:
  hadolint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: Dockerfile
          failure-threshold: error  # fail on errors, warn on warnings
```

### Local use

```bash
# Full roast mode (default)
hadolint Dockerfile

# No-roast mode — just list what to fix
hadolint --no-fail Dockerfile
```

### Severity thresholds

- `error` — fail the build (e.g. `npm install` in production Dockerfile).
- `warning` — warn but don't fail (e.g. unpinned minor version tag).
- `info` — informational (e.g. style suggestions).

Start with `failure-threshold: error` and tighten to `warning` as the team
matures.

## Related

- Every other concept in this bundle — hadolint is the automated enforcement
  layer for all of them.
