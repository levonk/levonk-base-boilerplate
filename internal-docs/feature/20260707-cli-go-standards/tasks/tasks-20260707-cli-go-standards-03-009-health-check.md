---
story_id: "03-009"
story_title: "Health Check for Containers"
story_name: "health-check"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 9
branch: "feature/current/20260707-cli-go-standards/story-03-009-health-check"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["health", "main"]
priority: "COULD"
risk_level: "low"
tags: ["feat", "health"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement health check mechanism for container orchestration (Docker HEALTHCHECK, Kubernetes probes). Provide health check via signal or HTTP endpoint that validates operational state without side effects and responds quickly (<100ms).

## Sub-Tasks

- [ ] Add --health-check flag — `core/files/main.go.jinja`
- [ ] Implement health check function — `core/files/health.go.jinja`
- [ ] Add HTTP endpoint for health checks — `core/files/health.go.jinja`
- [ ] Implement signal-based health check (SIGUSR1) — `core/files/health.go.jinja`
- [ ] Ensure health check has no side effects — `core/files/health.go.jinja`
- [ ] Optimize health check response time (<100ms) — `core/files/health.go.jinja`
- [ ] Add health check to Dockerfile — `core/files/Dockerfile.jinja`
- [ ] Test health check flag — `core/files/health_test.go.jinja`
- [ ] Test HTTP health endpoint — `core/files/health_test.go.jinja`
- [ ] Test signal-based health check — `core/files/health_test.go.jinja`
- [ ] Test health check response time — `core/files/health_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add health check flag
- `apps/cli/go/core/files/health.go.jinja` — New file for health check logic
- `apps/cli/go/core/files/health_test.go.jinja` — New file for health tests
- `apps/cli/go/core/files/Dockerfile.jinja` — Add HEALTHCHECK instruction

## Acceptance Criteria

- [ ] Health check validates operational state
- [ ] Health check has no side effects
- [ ] Health check responds in <100ms
- [ ] HTTP endpoint works for container probes
- [ ] Signal-based health check works
- [ ] Docker HEALTHCHECK instruction included
- [ ] Health check is reliable and consistent

## Test Plan

- Unit: Test health check functions
- Integration: Test health check in container context
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Health check status is clear
- Health check failures are logged

## Compliance

- Ensure health check doesn't expose sensitive data
- Support both Docker and Kubernetes health checks

## Risks & Mitigations

- Risk: Health check may be slow — Mitigation: Optimize for speed
- Risk: Health check may have side effects — Mitigation: Design to be read-only

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Health check works for Docker and Kubernetes
- Response time is <100ms
- No side effects
- All tests pass

## Commit Conventions

- `feat(health): add health check for containers`
- `feat(health): add HTTP health endpoint`
- `test(health): add tests for health check`
