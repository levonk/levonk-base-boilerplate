---
type: Practice
title: Node.js in Containers — Production Hardening
description: Harden Node.js containers with npm ci --omit=dev, NODE_ENV=production, non-root ownership, dumb-init for signal handling, and multi-stage builds that separate build and runtime.
tags: [devsecops, security, nodejs, docker, containers, npm, production]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: job-aide-node-js-in-containers-section
    resource: ".devin/rules/codeguard-0-devops-ci-cd-containers.md"
    title: "job-aide (Node.js in containers section)"
  - id: job-aide
    resource: ".devin/rules/dockerfile-best-practices.md"
    title: "job-aide"
---

# Node.js in Containers — Production Hardening

## Failure Mode

Node.js containers that ship development dependencies, run as root, ignore
SIGTERM signals, or bundle the entire build toolchain into the runtime image
are bloated, insecure, and operationally unsound. Dev dependencies increase
the attack surface. Root-owned processes allow privilege escalation. Missing
signal handling causes ungraceful shutdowns and zombie processes under
orchestrators like Kubernetes.

## Practice

### Deterministic Builds

Use `npm ci` with `--omit=dev` (or `--only=production`) for reproducible
installs from the lockfile:

```dockerfile
RUN npm ci --omit=dev
```

`npm ci` deletes `node_modules` and installs exactly what the lockfile
specifies — no mutation, no resolution drift. Pin the base image with a
digest:

```dockerfile
FROM node:20-slim@sha256:abc123...
```

### Production Environment

```dockerfile
ENV NODE_ENV=production
```

`NODE_ENV=production` enables Node.js optimizations and causes many
frameworks (Express, etc.) to disable verbose middleware and enable caching.

### Non-Root Ownership

Copy files with correct ownership and drop to a non-root user:

```dockerfile
COPY --chown=node:node . /app
USER node
```

The official `node` image ships with a `node` user (UID 1000). Use it.

### Signal Handling with an Init

Node.js does not handle PID 1 responsibilities — reaping zombies and
forwarding signals. Use an init like `dumb-init`:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
```

Without an init, `SIGTERM` from orchestrators may not reach the Node.js
process, causing forced kills after the grace period instead of graceful
shutdown.

### Graceful Shutdown Handlers

Implement shutdown handlers in the application:

```javascript
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    process.exit(0);
  });
});
```

### Multi-Stage Builds

Separate build and runtime stages. The builder stage contains dev
dependencies and build tools; the final stage contains only production
artifacts:

```dockerfile
# Builder stage
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-slim AS runtime
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist
USER node
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
```

### .dockerignore

Maintain a `.dockerignore` to prevent `node_modules`, `.git`, test files, and
logs from entering the build context. See
[build-context-hygiene](/build-context-hygiene.md).

### BuildKit Secret Mounts

For npm tokens or other build-time secrets, use BuildKit secret mounts — never
bake them into layers:

```dockerfile
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc npm ci
```

See [buildkit-secrets](/buildkit-secrets.md)
for why credentials must never appear in image layers. For credential
detection patterns in source code, see the
[devsecops-codeguard hardcoded-credentials-detection](../devsecops-codeguard/hardcoded-credentials-detection.md)
concept.

## Implementation Checklist

- [ ] `npm ci --omit=dev` used (not `npm install`)
- [ ] `NODE_ENV=production` set
- [ ] Non-root `USER` set with correct file ownership
- [ ] `dumb-init` or equivalent init used as entrypoint
- [ ] Graceful shutdown handlers implemented
- [ ] Multi-stage build separates builder and runtime
- [ ] Base image pinned with tag + digest
- [ ] `.dockerignore` maintained
- [ ] No build-time secrets in layers (use BuildKit secret mounts)
