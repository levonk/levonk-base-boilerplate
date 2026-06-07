---
story_id: "07-002"
story_title: "Resource Limits"
story_name: "resource-limits"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 7
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-07-002-resource-limits"
status: "todo"
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

- [ ] Create resource management module
- [ ] Add `--max-memory` flag to index.ts
- [ ] Add `--max-cpu` flag to index.ts
- [ ] Implement memory usage monitoring
- [ ] Implement CPU usage monitoring
- [ ] Add memory limit enforcement
- [ ] Add CPU limit enforcement
- [ ] Implement graceful limit violation handling
- [ ] Add clear error messages for limit violations
- [ ] Add unit tests for resource monitoring
- [ ] Add unit tests for limit enforcement
- [ ] Add integration tests for resource limits
- [ ] Update help text to document resource limits
- [ ] Add resource usage logging in verbose mode

## Relevant Files

- `apps/cli/typescript/core/files/src/resources.ts.jinja` - New resource management module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with resource limit flags
- `apps/cli/typescript/core/files/src/resources.test.ts.jinja` - Unit tests for resources (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for resource limits

## Acceptance Criteria

- [ ] `--max-memory` flag sets memory limit
- [ ] `--max-cpu` flag sets CPU limit
- [ ] Memory usage is monitored
- [ ] CPU usage is monitored
- [ ] Memory limit is enforced
- [ ] CPU limit is enforced
- [ ] Limit violations are handled gracefully
- [ ] Clear error messages for limit violations
- [ ] Resource usage is logged in verbose mode
- [ ] Limits work across different platforms

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
