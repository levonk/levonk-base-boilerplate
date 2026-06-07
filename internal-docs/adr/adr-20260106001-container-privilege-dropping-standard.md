---
modeline: "vim: set ft=markdown:"
title: "ADR: Container Privilege Dropping Standard"
adr-id: "20260106001"
slug: "20260106001-container-privilege-dropping-standard"
url: "/internal-docs/adr/adr-20260106001-container-privilege-dropping-standard.md"
synopsis: "Standardizes the use of su-exec/gosu and 'cuser' for dropping privileges in containers."
author: "https://github.com/levonk"
date-created: "2026-01-06"
date-updated: "2026-01-06"
version: "1.0.0"
status: "accepted"
tags: ["doc/architecture/adr", "adr", "security", "containers", "docker"]
related-to: ["adr-20251218001-container-isolation-and-docker-socket-hardening"]
scope:
  impact-scope: ["all applications", "devops"]
  excluded-scope: []
---

# Decision Record: Container Privilege Dropping Standard

- belongs in `internal-docs/adr/adr-20260106001-container-privilege-dropping-standard.md`

---

## Context

Running container processes as root is a significant security risk. We need a consistent, lightweight, and secure way to drop privileges to a non-root user across all our containerized services.

Historically, we have used various user names (`developer`, `appuser`, `node`) and different methods for dropping privileges (`su`, `sudo`, `gosu`, `su-exec`). This inconsistency makes maintenance difficult and increases the attack surface.

## Constraints

- Must be lightweight to minimize image size.
- Must minimize attack surface (avoid full-featured tools like `sudo` where possible).
- Must handle signal propagation correctly (unlike simple `su -c`).
- Must support dynamic UID/GID assignment for volume permission compatibility.

## Decision

We will standardize privilege dropping across all containers using the following rules:

1.  **Tooling**:
    - **Alpine**: Use `su-exec`.
    - **Other (Debian, etc.)**: Use `gosu`.
    - **Forbidden**: Do not use `su` or `sudo` for privilege dropping in entrypoints as they are heavyweight and have larger attack surfaces.

2.  **User Definition**:
    - **Name**: `cuser` (short for "current user").
    - **UID/GID**: Default to `1000/1000`.
    - **Home**: `/home/cuser`.

3.  **Environment Variables**:
    - The hosting environment (e.g., Docker Compose) MUST set `PUID`, `PGID`, and `TZ`.
    - The entrypoint script MUST use these variables to adjust the `cuser` UID/GID at runtime if they differ from the defaults.

## Rationale

- **gosu/su-exec**: These tools are designed specifically for this task. They correctly handle signal propagation and do not leave a "middle-man" process like `su` or `sudo` does.
- **Attack Surface**: `su` and `sudo` are complex binaries with many features and potential vulnerabilities. `gosu` and `su-exec` are much smaller and focused.
- **Consistency**: Standardizing on `cuser` and `1000:1000` simplifies Dockerfiles and entrypoint logic across the entire monorepo.
- **PUID/PGID**: This pattern (pioneered by LinuxServer.io) is the industry standard for ensuring volume mounts work correctly across different host systems without permission issues.

## Technical Approach

### 1. Dockerfile Standard

```dockerfile
# Create non-root user
ARG USERNAME=cuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Alpine
RUN addgroup -g $USER_GID $USERNAME && \
    adduser -u $USER_UID -G $USERNAME -D -h /home/$USERNAME $USERNAME

# Debian
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
```

### 2. Entrypoint Pattern

The entrypoint should dynamically find the privilege-dropping tool and adjust the user before executing the command.

```bash
# Robust tool discovery
SU_EXEC=$(find_tool su-exec)
GOSU=$(find_tool gosu)

# Sync UID/GID if provided via PUID/PGID
# ... logic to usermod/groupmod ...

# Execute
if [ -n "$SU_EXEC" ]; then
    exec "$SU_EXEC" "$USERNAME" "$@"
elif [ -n "$GOSU" ]; then
    exec "$GOSU" "$USERNAME" "$@"
fi
```

## Consequences

### Positive

- **Security**: Reduced attack surface and better signal handling.
- **Maintainability**: Unified patterns across all services.
- **Portability**: Correct handling of volume permissions via `PUID`/`PGID`.

### Negative

- **Migration**: Requires updating existing Dockerfiles and entrypoints.

## Alternatives Considered

- **su -c**: Rejected because it doesn't handle signals properly (it keeps a root process alive).
- **sudo**: Rejected because it is heavyweight and requires complex configuration (`sudoers`).
- **User namespaces**: While more secure, they are harder to configure in multi-tenant or complex environments; the `gosu`/`su-exec` pattern is a more portable intermediate step.

## Rollout / Migration

1. Update base services (`base-alpine`, `base-debian`, `base-sidecar`, `dev-base`) to use the new standard.
2. Update application-specific Dockerfiles as they are refactored.

## Validation

- Containers should start up as root, adjust their UID/GID to match host variables, and then run the main process as `cuser` with PID 1 (or as a direct child of an init like `tini`).
- Volume permissions should be correct when checked from the host.

## References

- [gosu repository](https://github.com/tianon/gosu)
- [su-exec repository](https://github.com/ncopa/su-exec)
- [LinuxServer.io PUID/PGID documentation](https://docs.linuxserver.io/general/understanding-puid-and-pgid)
