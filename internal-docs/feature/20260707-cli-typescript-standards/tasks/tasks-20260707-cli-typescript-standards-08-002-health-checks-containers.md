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

- [x] Create health check module
- [x] Implement health check HTTP endpoint
- [x] Add service status checks
- [x] Add readiness checks
- [x] Implement dependency health checks
- [x] Add health check response format
- [x] Implement health check timeout handling
- [x] Ensure health check has no side effects
- [x] Support Docker HEALTHCHECK directive
- [x] Support Kubernetes probes (liveness/readiness)
- [x] Add unit tests for health checks
- [x] Add unit tests for no-side-effects guarantee
- [x] Add integration tests for health endpoint
- [x] Update help text to document health checks
- [x] Add health check documentation
- [x] Add health check metrics

## Relevant Files

- `apps/cli/typescript/core/files/src/health.ts.jinja` - Health check module with liveness, readiness, and dependency checks
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with --health flag integration
- `apps/cli/typescript/core/files/src/health.test.ts.jinja` - Unit tests for health checks
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for health endpoint
- `apps/cli/typescript/core/files/docs/health-checks.md.jinja` - Health check documentation

## Acceptance Criteria

- [x] Health check HTTP endpoint is available
- [x] Service status is returned
- [x] Readiness status is returned
- [x] Dependency health is checked
- [x] Health check response format is consistent
- [x] Health check timeout is handled
- [x] Health checks work in container environments
- [x] Health check response is fast (<100ms)
- [x] Health check has no side effects
- [x] Health check works with Docker HEALTHCHECK
- [x] Health check works with Kubernetes probes

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
