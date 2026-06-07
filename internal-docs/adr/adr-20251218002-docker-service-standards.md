---
modeline: "vim: set ft=markdown:"
title: "ADR: Docker Service Standards"
adr-id: "20251218002"
slug: "20251218002-docker-service-standards"
url: "/internal-docs/adr/adr-20251218002-docker-service-standards.md"
synopsis: "Codify the required structure, configuration, and security rules for all Docker-based services, aligning code with the existing docker-standards workflow."
author: "https://github.com/levonk"
date-created: "2025-12-18"
date-updated: "2025-12-18"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "docker", "devops", "containers", "security", "workflow"]
supersedes: []
superseded-by: []
related-to: [
  "adr-20251106012-containerization-strategy",
  "adr-20251218001-container-isolation-and-docker-socket-hardening",
  "adr-20251129001-copier-based-boilerplate-standard"
]
scope:
  impact-scope: ["apps/active/devops/localnet", "packages/active/**/docker", "boilerplate/apps/**", "infrastructure services" ]
  excluded-scope: ["non-containerized scripts", "third-party vendor containers we do not maintain"]
---

# Decision Record: Docker Service Standards

- belongs in `internal-docs/adr/adr-20251218002-docker-service-standards.md`

---

## Context

The repo maintains dozens of Dockerized services (localnet stacks, security appliances, boilerplates). Standards for file layout, naming, environment variables, and security have been captured informally in the workflow file `config/ai/workflows/software-dev/devops/containers/docker-standards.md` inside the dotfiles repo. Without a canonical ADR in this repository:

- Contributors miss required structure (assets, mounts, tests, Makefiles) when creating services.
- Compose files diverge in formatting and naming, causing collisions during orchestration.
- Environment variables drift, breaking automation that expects `PUID/PGID/TZ` or deterministic bind variable names.
- Logging, testing, and shell-script safety rules are applied inconsistently.

This ADR copies the workflow guidance into an enforceable decision for every Docker-enabled project in this repo.

## Constraints

- Standards must be enforceable via code review, linting, or copier boilerplates.
- Must align with existing base images (`localnet/base-alpine`, `localnet/base-debian`) and container hardening ADRs.
- Must remain compatible with tooling captured in dotfiles workflow (copier templates, Makefiles, logging anchors).

## Decision

Adopt the **Docker Service Standards** summarized below. Every Docker-based service (apps, packages, boilerplates, infra utilities) **must** comply.

### 1. Base Images

- Use project-specific hardened base images (e.g., `localnet/base-alpine`, `localnet/base-debian`) rather than upstream random images.

### 2. File & Directory Layout

Each service follows this canonical structure (schematic shown for clarity):

```text
service-name/
├── .env.example
├── .dockerignore
├── docker-compose.yml
├── Makefile
├── README.md
├── assets/
│   └── entrypoint.sh
├── docker/
│   └── Dockerfile
├── healthcheck/
│   ├── healthcheck-internal-{service}.sh
│   └── healthcheck-external-{service}.sh
├── mounts/
│   ├── <static files>
│   └── templates/
│       └── *.template (requires env substitution)
└── tests/
    └── test-service.sh
```

Key rules:

- Dockerfiles live in `docker/`.
- Runtime scripts/assets live in `assets/`.
- Templates that require runtime substitution MUST be under `mounts/templates/`.
- Every service includes a standalone `docker-compose.yml` and `Makefile` at the root for isolated dev/testing.

### 3. YAML Formatting

- All YAML files (Compose, configs) start with `---`.
- Never use the deprecated `version` top-level key in `docker-compose.yml`.

### 4. Naming

- Container names follow `localnet-app-{service_name}` or the product-specific prefix documented in the service README.

### 5. Environment Variables

- Port/IP bindings must be represented via variables using the format `{CATEGORY}_{SERVICE}_{SUB_SERVICE}_{HOST|CONTAINER}_{PORT|IP}`.
  - Examples: `DNS_DNSCRYPT_ODOH_CONTAINER_PORT`, `PROXY_TOR_MAIN_CONTAINER_IP`.
- Every service exposes and honors `PUID`, `PGID`, and `TZ` variables (default 1000/1000/UTC).
- `.env.example` documents all required variables, and `Makefile` targets load them consistently.

### 6. Logging

- Containers must reuse the shared Compose `x-logging` anchor configured for `json-file` with rotation.

### 7. Documentation

- Each service ships with `README.md` describing purpose, setup, env vars, and platform caveats (e.g., WSL2 networking limits).

### 8. Testing & Automation

- Automated tests live in `tests/` and run via `make test`.
- Makefile must expose standard targets (`build`, `up`, `down`, `test`, `security-scan`, etc.) aligned with the docker-linux boilerplate.

### 9. Shell Script Hygiene

- Shell scripts include a `shellcheck` directive right after the shebang and use `set -euo pipefail` (or equivalent) for strict mode.

### 10. Security

- Follow ADR 20251218001 for container isolation: run as non-root, drop caps, `no-new-privileges`, no raw Docker socket mounts, prefer read-only filesystems with `tmpfs` for writable paths.
- Integrate Trivy / Hadolint / Dockle scans via `make security-scan` or CI jobs.

### 11. Boilerplate Usage

- New services generated via copier must start from the `docker-linux` boilerplate and choose `base-debian` or `base-alpine`. Health checks, Makefile targets, and directory layout from the boilerplate must be preserved.

## Rationale

- Aligns repository implementation with the enforced workflow memory so CI, documentation, and AI assistants operate on the same standard.
- Consistent directory layout improves discoverability and makes copier re-application safe.
- Deterministic env/port naming prevents collisions when services are composed together.
- Shared logging/testing rules reduce onboarding time and simplify incident response.

## Technical Approach

- Update copier templates (`boilerplate/apps/**`, `boilerplate/services/**`) to match the structure if any drift remains.
- Extend linting or review checklists to verify YAML frontmatter, container name patterns, and presence of required files.
- Reference this ADR from the docker standards workflow so both point to the same source.

## Consequences

### Positive

- Predictable service scaffolds; easier automation, documentation, and CI reuse.
- Reduced risk of Compose conflicts and security regressions.
- Faster onboarding because every Docker service looks and behaves the same way.

### Negative

- Existing services that deviate from the structure will need remediation work.
- Boilerplate changes may require rerunning copier templates, possibly causing merge work.

### Neutral

- Services can still customize internals; this ADR governs structure/configuration, not application logic.

## Alternatives Considered

1. **Leave guidance only in dotfiles workflow**
   - *Rejected*: Non-obvious for newcomers working only inside the repo; lacks enforceable reference.
2. **Adopt generic upstream Docker guidelines**
   - *Rejected*: We already maintain bespoke base images, logging anchors, and networks; bespoke rules ensure compatibility with localnet stacks.

## Rollout / Migration

1. Audit existing services for compliance (structure, YAML markers, env vars, README, tests).
2. Update non-conforming projects; document exceptions with mini-ADRs if necessary.
3. Ensure future service scaffolding (copier, scripts) references this ADR and the docker standards workflow.

## Validation

This ADR is successful when:

- New Docker services match the canonical structure without manual fixes.
- Port/env collisions stop appearing in localnet Compose stacks.
- Code reviews routinely cite this ADR when evaluating service changes.

## References

- Workflow source of truth: `/home/micro/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/workflows/software-dev/devops/containers/docker-standards.md`
- ADR 20251106012: Containerization Strategy
- ADR 20251218001: Container Isolation and Docker Socket Hardening
- Docker Linux boilerplate (`boilerplate/apps/infrastructure/docker/docker-linux`)

<!-- vim: set ft=markdown: -->
