---
story_id: "07-002"
story_title: "Resource Limits"
story_name: "resource-limits"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 7
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-07-002-resource-limits"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["resources/"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "cli", "performance"]
due: "2026-08-25"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add `--max-memory` and `--max-cpu` flags for resource limits where applicable. Implement resource monitoring and enforcement, and provide clear error messages when limits are exceeded. This implements CLI Tool Standards ADR requirement #26.

## Sub-Tasks

- [x] Create resource management module
- [x] Add `--max-memory` flag to index.ts
- [x] Add `--max-cpu` flag to index.ts
- [x] Implement memory usage monitoring
- [x] Implement CPU usage monitoring
- [x] Add memory limit enforcement
- [x] Add CPU limit enforcement
- [x] Implement graceful limit violation handling
- [x] Add clear error messages for limit violations
- [x] Add unit tests for resource monitoring
- [x] Add unit tests for limit enforcement
- [x] Add integration tests for resource limits
- [x] Update help text to document resource limits
- [x] Add resource usage logging in verbose mode

## Relevant Files

- `apps/cli/typescript/core/files/src/resources.ts.jinja` - Resource management module
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with resource limit flags
- `apps/cli/typescript/core/files/src/resources.test.ts.jinja` - Unit tests for resources
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for resource limits (to be updated)

## Acceptance Criteria

- [x] `--max-memory` flag sets memory limit
- [x] `--max-cpu` flag sets CPU limit
- [x] Memory usage is monitored
- [x] CPU usage is monitored
- [x] Memory limit is enforced
- [x] CPU limit is enforced
- [x] Limit violations are handled gracefully
- [x] Clear error messages for limit violations
- [x] Resource usage is logged in verbose mode
- [x] Limits work across different platforms

## Test Plan

- Unit: `vitest run src/resources.test.ts` - Test resource monitoring
- Integration: `vitest run src/index.test.ts` - Test resource limit enforcement
- Manual: Test with various resource limits
- Manual: Verify error messages for limit violations

## Observability

- Log resource usage in verbose mode
- Track limit violations for analytics
- Add metrics for resource consumption

## Compliance

- Follows CLI Tool Standards ADR requirement #26 (Resource Limits)
- Prevents resource exhaustion issues

## Risks & Mitigations

- Risk: Resource monitoring adds performance overhead
  - Mitigation: Efficient monitoring, configurable sampling rate
- Risk: Limit enforcement is too aggressive
  - Mitigation: Graceful degradation, clear warnings before enforcement
- Risk: Platform-specific resource monitoring issues
  - Mitigation: Platform detection, fallback behavior

## Dependencies

- None - this can be developed in parallel with other Phase 7 stories

## Notes

- Use Node.js built-in resource monitoring where available
- Consider using v8 or process.memoryUsage() for memory monitoring
- CPU monitoring may be platform-specific
- Limits should be configurable with sensible defaults
