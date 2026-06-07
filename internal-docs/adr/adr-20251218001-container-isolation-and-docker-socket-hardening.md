---
modeline: "vim: set ft=markdown:"
title: "ADR: Container Isolation and Docker Socket Hardening"
adr-id: "20251218001"
slug: "20251218001-container-isolation-and-docker-socket-hardening"
url: "/internal-docs/adr/adr-20251218001-container-isolation-and-docker-socket-hardening.md"
synopsis: "Standardize container hardening guardrails and security checks to reduce blast radius from app-level RCE and prevent Docker socket takeovers."
author: "https://github.com/levonk"
date-created: "2025-12-18"
date-updated: "2025-12-18"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "security", "docker", "containers", "cicd", "devops", "supply-chain"]
supersedes: []
superseded-by: []
related-to: [
  "adr-20251106012-containerization-strategy",
  "adr-20251106014-cicd-strategy",
  "adr-20251129003-python-services-and-packages-standard",
  "adr-20251208001-automated-container-update-strategy",
  "adr-20251210001-cli-standards-and-boilerplates"
]
scope:
  impact-scope: ["all containerized services", "apps/active/devops/localnet", "boilerplate/*", ".github/workflows"]
  excluded-scope: ["non-containerized scripts", "third-party vendor images"]
---

# Decision Record: Container Isolation and Docker Socket Hardening

- belongs in `internal-docs/adr/adr-20251218001-container-isolation-and-docker-socket-hardening.md`

---

## Context

Application CVEs can lead to **remote code execution (RCE)** inside a container. A real-world example is a service compromised via a Next.js vulnerability. The attacker got code execution in the container, but they could not take over the host because the deployment followed basic isolation best practices:

- The process ran as a **non-root user**.
- The container did not have dangerous mounts (especially no Docker socket).

This is a "success story" in failure. Even when a vulnerability is exploited, strong defaults can keep the blast radius small.

The biggest common mistake is mounting the Docker socket into an app container:

- `/var/run/docker.sock` provides direct access to the Docker daemon.
- With Docker daemon access, an attacker can usually start a new privileged container and mount the host filesystem, which effectively becomes host root access.

This ADR makes container hardening a first-class architecture decision. It also defines a free and open-source toolchain to enforce the guardrails.

## Constraints

- Use only free and open-source tools.
- Work for both local Docker Compose stacks (like `localnet`) and CI.
- Prefer prevention and enforcement over best-effort review.

## Decision

### 1. Baseline container hardening rules (required)

All containerized services in this repository must follow these runtime rules:

- Run as **non-root** by default.
- Do not use `privileged: true`.
- Do not mount `/var/run/docker.sock` into application containers unless it's specificlly the dockerproxy-{ro,rw} container.
- Do not mount dockerproxy-{ro,rw} volumes directly into application containers unless it's absolutely necessary.
- Do not use host PID or host networking unless an ADR explicitly documents the exception.
- Drop Linux capabilities by default; add back only the minimum needed.
- Set `no-new-privileges:true`.
- Prefer a read-only root filesystem with explicit writable paths via `tmpfs` or dedicated volumes.

### 2. Controlled Docker API access (required)

If a service needs to talk to the Docker API (for example, update automation or monitoring), it must not mount the raw socket. It must use a mediated approach with least privilege.

In this repository, that means following the `dockerproxy` pattern established in:

- `adr-20251208001-automated-container-update-strategy`

### 3. Toolchain enforcement (recommended baseline)

We will enforce these rules with a simple toolchain, split by lifecycle stage:

- **Linting (Dockerfile)**: [Hadolint](https://github.com/hadolint/hadolint)
- **Linting (Compose/IaC)**: [Checkov](https://github.com/bridgecrewio/checkov)
- **Build-time CVE scanning (images)**: [Trivy](https://github.com/aquasecurity/trivy)
- **Runtime detection (host)**: [Falco](https://github.com/falcosecurity/falco)
- **Host posture audit (periodic)**: [Docker Bench for Security](https://github.com/docker/docker-bench-security)

This ADR does not require immediate rollout in every pipeline today. It defines the target standard and the intended enforcement stack.

## Rationale

- Hardening rules reduce the chance that an application-level exploit becomes a host-level incident.
- Docker socket exposure is a common, high-impact escalation path. Blocking it by default prevents a full class of incidents.
- Linting and scanning make security errors harder to merge and easier to catch early.
- Runtime detection and host audits provide defense-in-depth for unknown vulnerabilities and configuration drift.

## Technical Approach

### Compose hardening defaults

A hardened Compose service typically uses:

```yaml
services:
  my-service:
    user: "1000:1000"
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
```

Notes:

- Add back `cap_add` only when needed.
- Mount configuration as `:ro`.
- Never add `/var/run/docker.sock` to `volumes` for an application container.

### Dockerfile hardening defaults

Dockerfiles should end with a non-root user. Hadolint will flag Dockerfiles that end as root (`DL3002`).

### Base image guidance

- Prefer minimal images that remove unnecessary tooling.
- When practical, prefer hardened bases such as:
  - [Distroless](https://github.com/GoogleContainerTools/distroless) images.
  - Nix-built images via [`dockerTools.buildImage`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) when a Nix pipeline is already in place.

### Catching CVEs before deploy

Trivy scans built images for known vulnerabilities in OS packages and language dependencies.

### Runtime detection

Falco can detect suspicious runtime behavior, including attempts to access the Docker socket and outbound connections commonly used by crypto miners.

### Host audits

Docker Bench for Security audits host-level Docker daemon and kernel posture. It may require elevated access because it is checking the host.

## Consequences

### Positive

- Reduced blast radius from RCE inside containers.
- Fewer unsafe Compose and Dockerfile patterns in review.
- Stronger defaults across services and boilerplates.

### Negative

- Some services may need small refactors (filesystem writes, user permissions) to comply.
- Runtime detection tools like Falco add operational complexity.

### Neutral

- This ADR defines baseline expectations. Individual services can document justified exceptions via additional ADRs.

## Alternatives Considered

- **Rely on best-effort review only**: Rejected because unsafe patterns (like socket mounts) are easy to miss.
- **Allow Docker socket mounts for convenience**: Rejected because it collapses container isolation and turns a container compromise into a host compromise.
- **Kubernetes-only controls (OPA/Gatekeeper/PSA)**: Not selected as the baseline because the repo also targets Compose-based deployments. These may be added later.

## Rollout / Migration

- Add CI jobs (or pre-commit hooks) to run Hadolint and Checkov on changed Docker and Compose files.
- Add Trivy scanning for built images in CI.
- Audit existing Compose files for:
  - `privileged: true`
  - Docker socket mounts
  - missing `user` settings
- Ensure docker API consumers use `dockerproxy` instead of raw socket mounts.

## Validation

This ADR is successful when:

- No application container mounts `/var/run/docker.sock`.
- New Dockerfiles and Compose changes fail CI when hardening rules are violated.
- Image scans detect and block critical CVEs before deployment.

## References

- Next.js security advisories: https://github.com/vercel/next.js/security/advisories
- Docker security documentation: https://docs.docker.com/engine/security/
- Hadolint: https://github.com/hadolint/hadolint
- Checkov: https://github.com/bridgecrewio/checkov
- Trivy: https://github.com/aquasecurity/trivy
- Falco: https://github.com/falcosecurity/falco
- Docker Bench for Security: https://github.com/docker/docker-bench-security

<!-- vim: set ft=markdown: -->
