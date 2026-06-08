---
story_id: "03-009"
story_title: "Health Check for Containers"
story_name: "health-check"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 9
branch: "feature/current/20260707-cli-python-standards/story-03-009-health-check"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["health", "main"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "container"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Provide health check mechanism (signal or HTTP endpoint) for container orchestration. Support Docker HEALTHCHECK and Kubernetes probes, validate operational state without side effects, and ensure fast response (<100ms).

## Sub-Tasks

- [ ] Implement health check command
- [ ] Add HTTP endpoint for health checks
- [ ] Add signal-based health check
- [ ] Support Docker HEALTHCHECK
- [ ] Support Kubernetes probes
- [ ] Ensure no side effects
- [ ] Ensure fast response (<100ms)
- [ ] Add tests for health check
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/health.py.jinja` - Health module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_health.py.jinja` - Health tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Health check command works
- [ ] HTTP endpoint responds
- [ ] Signal-based check works
- [ ] Docker HEALTHCHECK supported
- [ ] Kubernetes probes supported
- [ ] No side effects from checks
- [ ] Response time <100ms
- [ ] Tests verify health check

## Test Plan

- Unit: `pytest tests/test_health.py -v -k test_health`
- Integration: `pytest tests/test_main.py -v -k test_health_check`
- Manual: Test health check command and HTTP endpoint

## Observability

- Log health check results
- Log health check failures

## Compliance

- Follow container health check standards
- Ensure fast response times

## Risks & Mitigations

- Risk: Health check too slow — Mitigation: Optimize checks
- Risk: Health check has side effects — Mitigation: Read-only checks only

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Health check implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(container): add health check mechanism`

## Changelog

- 2025-07-08: initialized story file
