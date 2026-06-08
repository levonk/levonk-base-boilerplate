---
story_id: "06-003"
story_title: "Health Check for Containers"
story_name: "health-check"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 3
branch: "feature/current/cli-python-standards/story-06-003-health-check"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["health module"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "containers"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement health check mechanism for container orchestration (Docker HEALTHCHECK, Kubernetes probes). Provide signal or HTTP endpoint for health validation, ensure checks validate operational state without side effects, and return appropriate exit codes.

## Sub-Tasks

- [x] Add `include_health_check` boolean option to `copier.yml` — `apps/cli/python/core/copier.yml`
- [~] Create `health.py.jinja` template file with health check implementation — `apps/cli/python/core/files/{{project_slug}}/health.py.jinja`
- [ ] Implement signal-based health check — `health.py.jinja`
- [ ] Implement HTTP endpoint for health check (conditional on include_health_check) — `health.py.jinja`
- [ ] Add health check validation logic (operational state without side effects) — `health.py.jinja`
- [ ] Add `--health-check` command for manual health validation — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Implement appropriate exit codes for health status (0 healthy, 1 unhealthy) — `health.py.jinja`
- [ ] Add Docker HEALTHCHECK instruction to Dockerfile.jinja — `apps/cli/python/core/files/Dockerfile.jinja`
- [ ] Add Kubernetes probe configuration to docker-compose.yml.jinja — `apps/cli/python/core/files/docker-compose.yml.jinja`
- [ ] Add tests for health check mechanism — `apps/cli/python/core/files/tests/test_health.py.jinja` (conditional)

## Relevant Files

- `apps/cli/python/core/copier.yml` — Add include_health_check template option
- `apps/cli/python/core/files/{{project_slug}}/health.py.jinja` — New health check module (conditional)
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --health-check command
- `apps/cli/python/core/files/Dockerfile.jinja` — Add HEALTHCHECK instruction
- `apps/cli/python/core/files/docker-compose.yml.jinja` — Add Kubernetes probe config
- `apps/cli/python/core/files/tests/test_health.py.jinja` — New test file (conditional)

## Acceptance Criteria

- [ ] Health check mechanism implemented (signal and/or HTTP)
- [ ] Health check validates operational state without side effects
- [ ] `--health-check` command works for manual validation
- [ ] Exit codes: 0 for healthy, 1 for unhealthy
- [ ] Docker HEALTHCHECK instruction added (conditional)
- [ ] Kubernetes probe configuration added (conditional)
- [ ] Health check is optional via template choice
- [ ] All tests pass for health check scenarios

## Test Plan

- Unit: `pytest tests/test_health.py::test_signal_health_check` (conditional)
- Unit: `pytest tests/test_health.py::test_http_health_check` (conditional)
- Unit: `pytest tests/test_health.py::test_health_check_exit_codes` (conditional)
- Integration: Test health check in container environment (conditional)

## Observability

- Log health check results for monitoring
- Track health check failure rates

## Compliance

- Health check does not expose sensitive information
- Health check respects resource limits

## Risks & Mitigations

- Risk: HTTP endpoint adds complexity and dependencies — Mitigation: Make optional via template choice
- Risk: Health check may have side effects — Mitigation: Design checks to be read-only and idempotent

## Dependencies & Sequencing

- Depends on: None (standalone container feature)
- Unblocks: None (standalone operational feature)

## Definition of Done

- Health check mechanism implemented
- Signal and/or HTTP endpoint working
- Health check validates operational state without side effects
- Manual health check command working
- Container orchestration integration (Docker/Kubernetes)
- Health check optional via template choice
- Tests pass for health check scenarios
- Documentation updated for health check usage

## Commit Conventions

- `feat(health): add health check mechanism`
- `feat(health): implement HTTP endpoint for health checks`
- `feat(health): add container orchestration integration`
- `test(health): add tests for health check`
