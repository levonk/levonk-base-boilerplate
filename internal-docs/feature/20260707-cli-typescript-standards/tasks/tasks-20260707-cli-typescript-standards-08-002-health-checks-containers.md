---
story_id: "08-002"
story_title: "Health Checks for Containers"
story_name: "health-checks-containers"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 8
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-08-002-health-checks-containers"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["health/"]
priority: "COULD"
risk_level: "low"
tags: ["feat", "cli", "containers"]
due: "2026-09-01"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add health check endpoint for containerized deployments. Return service status and readiness information, and support container orchestration health check patterns. This implements CLI Tool Standards ADR requirement #27.

## Sub-Tasks

- [~] Create health check module
- [ ] Implement health check HTTP endpoint
- [ ] Add service status checks
- [ ] Add readiness checks
- [ ] Implement dependency health checks
- [ ] Add health check response format
- [ ] Implement health check timeout handling
- [ ] Ensure health check has no side effects
- [ ] Support Docker HEALTHCHECK directive
- [ ] Support Kubernetes probes (liveness/readiness)
- [ ] Add unit tests for health checks
- [ ] Add unit tests for no-side-effects guarantee
- [ ] Add integration tests for health endpoint
- [ ] Update help text to document health checks
- [ ] Add health check documentation
- [ ] Add health check metrics

## Relevant Files

- `apps/cli/typescript/core/files/src/health.ts.jinja` - New health check module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with health check integration
- `apps/cli/typescript/core/files/src/health.test.ts.jinja` - Unit tests for health checks (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for health endpoint

## Acceptance Criteria

- [ ] Health check HTTP endpoint is available
- [ ] Service status is returned
- [ ] Readiness status is returned
- [ ] Dependency health is checked
- [ ] Health check response format is consistent
- [ ] Health check timeout is handled
- [ ] Health checks work in container environments
- [ ] Health check response is fast (<100ms)
- [ ] Health check has no side effects
- [ ] Health check works with Docker HEALTHCHECK
- [ ] Health check works with Kubernetes probes

## Test Plan

- Unit: `vitest run src/health.test.ts` - Test health check logic
- Integration: `vitest run src/index.test.ts` - Test health endpoint
- Manual: Test health check endpoint
- Manual: Test health check in container

## Observability

- Health check endpoint provides service status
- Track health check results for monitoring
- Add metrics for health check performance

## Compliance

- Follows CLI Tool Standards ADR requirement #27 (Health Checks for Containers)
- Enables container orchestration integration

## Risks & Mitigations

- Risk: Health checks are too slow
  - Mitigation: Optimize checks, use caching, set appropriate timeouts
- Risk: Health checks give false positives
  - Mitigation: Comprehensive checks, regular testing
- Risk: Health check endpoint is not needed for CLI
  - Mitigation: Make health check optional, document use case

## Dependencies

- None - this can be developed in parallel with other Phase 8 stories

## Notes

- Health check should be lightweight and fast
- Use standard HTTP status codes (200 for healthy, 503 for unhealthy)
- Consider adding a --health flag for CLI health checks
- Health check format should follow container orchestration conventions
