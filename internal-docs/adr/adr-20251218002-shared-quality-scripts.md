---
modeline: "vim: set ft=markdown:"
title: "ADR: Shared Dockerized Quality Scripts for Hooks and CI"
adr-id: 20251218002
slug: 20251218002-shared-quality-scripts
url: /internal-docs/adr/adr-20251218002-shared-quality-scripts.md
synopsis: "Adopt a single Docker-based quality script that can be invoked by pre-commit hooks and GitHub Actions with configurable task sets to preserve developer velocity."
author: https://github.com/levonk
date-created: 2025-12-18
date-updated: 2025-12-18
version: 1.0.0
status: accepted
aliases: []
tags:
  - doc/architecture/adr
  - adr
  - ci
  - developer-experience
  - security
supersedes: []
superseded-by: []
related-to:
  - adr-20251106014-cicd-strategy
  - adr-20251218001-container-isolation-and-docker-socket-hardening
  - adr-20260131001-standard-developer-ux-flow
---

# Shared Dockerized Quality Scripts for Hooks and CI

## Context

- Every boilerplate now ships with lint, IaC, and container security checks.
- Maintaining separate implementations for pre-commit hooks and CI workflows causes drift, duplicated dependency pinning, and conflicting scan configurations.
- Developers reported slow feedback loops when heavyweight scans (e.g., Trivy, Checkov) always run locally, even when a quick docs-only change is staged.
- We already have a containerized `scripts/run-quality-checks.sh` pattern in the Docker Compose boilerplate; other stacks will follow.

## Constraints

1. Tooling must run identically across macOS, Linux, and CI runners without bespoke installations.
2. Security scanners (Trivy, Checkov, Falco, Docker Bench, etc.) must honor the repository's "no new privileges" container policy.
3. Developers need to opt in/out of slow checks to avoid blocking urgent iterations.
4. Git hooks and CI workflows must be easy to regenerate via Copier without manual edits.

## Decision

**Adopt a single Docker-based quality script per boilerplate (and eventually per app/package) that both pre-commit hooks and GitHub Actions invoke, with configuration switches controlling which scanners run in each context.**

- The script lives in `scripts/run-quality-checks.sh` (or equivalent) and is the **only** place that pins tool images and orchestrates scans.
- Git hooks call the script directly; GitHub Actions simply `chmod +x` and invoke the same entry point.
- The script supports environment variables/CLI flags (e.g., `SKIP_RUNTIME_SCAN=1`, `FAST_MODE=1`, `MARKDOWN_ONLY=1`) so that local runs can skip heavy checks while CI always runs the full suite.

## Rationale

- **Parity:** One script eliminates divergence between local and CI behavior.
- **Isolation:** Dockerized tools satisfy container hardening requirements and avoid polluting developer machines.
- **Configurability:** Developers can tailor local runs to the change scope without editing the hook or workflow.
- **Maintainability:** Updating tool versions or adding a scanner happens in one file, then propagates everywhere via Copier.

## Technical Approach

1. **Script contract**
   - Accepts boolean env vars for each scanner (e.g., `ENABLE_TRIVY`, `ENABLE_CHECKOV`); defaults align with CI expectations.
   - Provides composite toggles such as `FAST_MODE` (run lint only) and `FULL_MODE` (run everything).
   - Returns non-zero exit code on first failure so hooks and CI fail fast.
2. **Pre-commit hook**
   - Minimal wrapper that ensures the script is executable and passes through any developer overrides (e.g., `FAST_MODE=1`).
   - Documented in generated README sections.
3. **GitHub Actions workflow**
   - Checkout → `chmod +x` script → run with `FULL_MODE=1`.
   - Honors repository policies (`--security-opt=no-new-privileges`) and caches scanner directories via Actions cache when feasible.
4. **Copier integration**
   - Template definitions updated so every boilerplate emits the script, hook, and workflow automatically.
   - Variables exposed in `copier.yml` allow future projects to decide which scanners are included.

## Consequences

### Positive

- **Consistent enforcement:** Same checks run locally and in CI, reducing "works on my machine".
- **Faster onboarding:** Developers only learn one interface (`./scripts/run-quality-checks.sh`).
- **Easier upgrades:** Security tooling can be patched centrally without editing multiple files.

### Negative

- **Single point of failure:** A bug in the script blocks hooks and CI simultaneously; mitigated via regression tests.
- **Perceived indirection:** Contributors must read the script to understand which scanners run, though docs mitigate this.

## Alternatives Considered

1. **Separate hook and CI scripts**
   - *Rejected:* doubles maintenance and risks drift in tool versions and policies.
2. **Invoke linters directly from pre-commit and use custom Actions steps**
   - *Rejected:* forces developers to install every tool locally, contradicting Docker-based security posture.
3. **Use Trunk or other meta-linters only**
   - *Rejected:* some scanners (Falco, Docker Bench) require bespoke container setups; a custom script provides flexibility while still allowing third-party orchestrators to call it.

## Rollout / Migration

1. Update all existing boilerplates to emit the shared script, hook, and workflow through Copier.
2. For legacy projects, add the script and rewire hooks/Actions to call it; document opt-in toggles.
3. Educate teams via README updates and release notes on how to run selective checks locally.
4. Monitor CI logs to ensure the script remains the single source of truth; regressions open follow-up ADRs if needed.

## Validation

- CI runs referencing this ADR must show the script being executed instead of bespoke commands.
- Developer surveys (or retro feedback) should report reduced context switching and faster local cycles due to configurable modes.
- Security reviews confirm Dockerized scanners adhere to hardening policies across environments.

## References

- [ADR 20251106014: GitHub Actions for CI/CD](./adr-20251106014-cicd-strategy.md)
- [ADR 20251218001: Container Isolation and Docker Socket Hardening](./adr-20251218001-container-isolation-and-docker-socket-hardening.md)
- Docker Compose boilerplate `scripts/run-quality-checks.sh` implementation (current canonical example)
