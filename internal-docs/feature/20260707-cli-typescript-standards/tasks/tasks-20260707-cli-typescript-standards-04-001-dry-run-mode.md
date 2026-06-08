---
story_id: "04-001"
story_title: "Dry-Run Mode"
story_name: "dry-run-mode"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-04-001-dry-run-mode"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["index.ts", "dry-run/"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "ux"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add `--dry-run` flag to preview changes without executing them. Show exactly what would be done without making any changes. Apply dry-run mode to all file operations, network calls, and state changes. This implements CLI Tool Standards ADR requirement #10.

## Sub-Tasks

- [x] Create dry-run module with dry-run context management
- [x] Add `--dry-run` flag to index.ts
- [x] Implement dry-run context propagation through the application
- [x] Add dry-run logging for file operations
- [x] Add dry-run logging for network calls
- [x] Add dry-run logging for state changes
- [x] Implement no-op wrappers for destructive operations
- [x] Add dry-run indicator in output
- [x] Add unit tests for dry-run context
- [x] Add unit tests for dry-run operation logging
- [x] Add integration tests for dry-run flag behavior
- [x] Update help text to document dry-run mode
- [x] Add dry-run status to JSON output mode

## Relevant Files

- `apps/cli/typescript/core/files/src/dry-run.ts.jinja` - Dry-run module with context management
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with dry-run flag
- `apps/cli/typescript/core/files/src/dry-run.test.ts.jinja` - Unit tests for dry-run
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for dry-run

## Acceptance Criteria

- [ ] `--dry-run` flag enables dry-run mode
- [ ] Dry-run mode shows what would be done without executing
- [ ] File operations are logged but not executed in dry-run mode
- [ ] Network calls are logged but not executed in dry-run mode
- [ ] State changes are logged but not executed in dry-run mode
- [ ] Dry-run indicator is visible in output
- [ ] Dry-run status is included in JSON output
- [ ] All operations respect dry-run context

## Test Plan

- Unit: `vitest run src/dry-run.test.ts` - Test dry-run context management
- Integration: `vitest run src/index.test.ts` - Test dry-run flag behavior
- Manual: Run with --dry-run and verify no changes are made
- Manual: Verify dry-run output shows what would happen

## Observability

- Log all operations that would be executed in dry-run mode
- Include dry-run status in all output formats
- Add metrics for dry-run usage

## Compliance

- Follows CLI Tool Standards ADR requirement #10 (Dry-Run Mode)
- Enables safe testing of CLI operations

## Risks & Mitigations

- Risk: Dry-run mode misses some operations
  - Mitigation: Comprehensive testing, clear documentation of covered operations
- Risk: Dry-run output is too verbose
  - Mitigation: Make dry-run output concise but informative
- Risk: Dry-run context not propagated correctly
  - Mitigation: Use context/dependency injection pattern for dry-run state

## Dependencies

- None - this can be developed in parallel with other Phase 4 stories

## Notes

- Dry-run should be a global context that affects all operations
- Consider using a context pattern or dependency injection for dry-run state
- Dry-run output should be clear about what would happen
- Network calls in dry-run mode should not actually make requests
