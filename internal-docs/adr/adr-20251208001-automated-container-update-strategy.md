---
modeline: "vim: set ft=markdown:"
title: "ADR: Automated Container Update Strategy"
adr-id: "adr-20251208001"
slug: "adr-20251208001-automated-container-update-strategy"
url: "https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251208001-automated-container-update-strategy.md"
synopsis: "Adoption of Watchtower and WUD for a secure, selective automated container update strategy."
author: "https://github.com/levonk"
date-created: "2025-12-08"
date-updated: "2025-12-08"
date-review: "2026-06-08"
version: "1.0.0"
status: "accepted"
tags: [doc/architecture/adr, devops, security, docker]
supersedes: []
superseded-by: []
related-to: []
scope:
  impact-scope: [devops/localnet, security]
  excluded-scope: []
---

# Decision Record: Automated Container Update Strategy

- belongs in `internal-docs/adr/adr-20251208001-automated-container-update-strategy.md`

---

## Context

Maintaining up-to-date container images is critical for security and stability. However, blind automated updates can lead to breakage if a new version introduces regressions or breaking changes. We need a strategy that balances automation with control and visibility.

## Constraints

- **Security**: The container update mechanism must not expose the Docker socket insecurely.
- **Control**: We must be able to selectively enable auto-updates for specific containers while keeping others on manual update cycles.
- **Visibility**: We need a dashboard to visualize the update status of all containers, regardless of their auto-update status.

## Decision

We will adopt a hybrid approach using **Watchtower** for selective automation and **WUD (What's Up Docker)** for comprehensive visibility.

1.  **Watchtower** will be the **actuator**. It will be configured to run in a restricted mode where it *only* updates containers that explicitly opt-in via a label.
2.  **WUD** will be the **observer**. It will monitor all running containers and report on available updates, serving as a dashboard for manual intervention on non-auto-updated services.
3.  **DockerProxy** will mediate access to the Docker socket for both services, enforcing least privilege.

## Rationale

- **Separation of Concerns**: Watchtower excels at updating, while WUD excels at visualizing and notifying. Using both covers the full spectrum of needs.
- **Risk Mitigation**: By defaulting to "no auto-update" (`WATCHTOWER_LABEL_ENABLE=true`), we prevent accidental updates of critical or stateful services that might require manual migration steps.
- **Security**: Using `dockerproxy` ensures that even if these tools are compromised, the blast radius is limited (e.g., WUD gets read-only access; Watchtower gets write access but is limited to Docker API calls).

## Technical Approach

### Watchtower Configuration

- **Image**: `containrrr/watchtower`
- **Access**: Connected to `dockerproxy-rw` (Write Access).
- **Environment**:
  - `WATCHTOWER_LABEL_ENABLE: "true"`: Enforces opt-in behavior.
  - `WATCHTOWER_POLL_INTERVAL: 7200`: Checks every 2 hours.
- **Usage**: To enable updates for a service, add the label: `com.centurylinklabs.watchtower.enable=true`.

### WUD Configuration

- **Image**: `getwud/wud`
- **Access**: Connected to `dockerproxy-ro` (Read-Only Access).
- **Environment**:
  - `DOCKER_HOST: "tcp://dockerproxy-ro:2375"`
- **Usage**: Automatically detects all containers. No special labels required for monitoring.

## Affected Components

- `apps/active/devops/localnet/services/security/docker-compose.security.yml`
- All services in the `localnet` stack (potentially).

## Consequences

### Negative

- **Complexity**: Managing two services instead of one increases the operational footprint slightly.
- **Resource Usage**: Running both services consumes marginally more CPU/RAM.

### Positive

- **Granular Control**: Precise control over which services update automatically.
- **Enhanced Visibility**: A dedicated UI for seeing what is outdated.
- **Security Posture**: Strong separation of duties and socket protection.

### Neutral

- **Network Traffic**: Both services will poll registries, but the overhead is negligible.

## Alternatives Considered

- **Watchtower Only**: Lacks a good UI/Dashboard for "monitor-only" mode.
- **WUD Only**: Can trigger webhooks but doesn't natively perform the update logic as reliably as Watchtower.
- **Renovate/Dependabot**: Good for Git-based workflow (updating tags in `docker-compose.yml`), but doesn't handle the runtime update of the actual container on the host.

## Validation

- **Success**: Watchtower updates labeled containers. WUD shows available updates for all containers.
- **Failure**: Watchtower updates unlabeled containers (configuration error) or fails to update labeled ones (permissions error).

## Review Schedule

- Review in 6 months to evaluate if the hybrid approach is still necessary or if one tool has evolved to cover both use cases effectively.

<!-- vim: set ft=markdown: -->
