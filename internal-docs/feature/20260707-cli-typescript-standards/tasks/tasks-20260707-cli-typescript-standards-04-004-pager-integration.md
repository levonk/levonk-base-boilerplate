---
story_id: "04-004"
story_title: "Pager Integration"
story_name: "pager-integration"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 4
parallel_id: 4
branch: "feature/current/20260707-cli-typescript-standards/story-04-004-pager-integration"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["pager/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement auto-pager for long output that respects the PAGER environment variable (default to less). Add `--no-pager` flag to bypass paging. Detect when output exceeds terminal height and invoke pager automatically. This implements CLI Tool Standards ADR requirement #19.

## Sub-Tasks

- [x] Create pager module with pager integration logic
- [x] Add `--no-pager` flag to index.ts
- [x] Implement PAGER environment variable detection
- [x] Implement default pager (less) when PAGER not set
- [x] Implement terminal height detection
- [x] Implement output length detection
- [x] Add automatic pager invocation for long output
- [x] Add pager bypass for JSON output mode
- [x] Add pager bypass for piped output
- [x] Add unit tests for pager detection
- [x] Add unit tests for pager invocation logic
- [x] Add integration tests for pager behavior
- [x] Update help text to document pager integration

## Relevant Files

- `apps/cli/typescript/core/files/src/pager.ts.jinja` - Pager module with pager integration logic
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with pager integration
- `apps/cli/typescript/core/files/src/pager.test.ts.jinja` - Unit tests for pager
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for pager

## Acceptance Criteria

- [x] Long output is automatically paged
- [x] PAGER environment variable is respected
- [x] Default pager (less) is used when PAGER not set
- [x] `--no-pager` flag bypasses paging
- [x] Paging is disabled for JSON output mode
- [x] Paging is disabled for piped output
- [x] Terminal height is correctly detected
- [x] Output length is correctly detected
- [x] Pager is invoked only when output exceeds terminal height

## Test Plan

- Unit: `vitest run src/pager.test.ts` - Test pager detection and invocation
- Integration: `vitest run src/index.test.ts` - Test pager behavior
- Manual: Generate long output and verify pager is invoked
- Manual: Test --no-pager flag bypasses paging
- Manual: Test PAGER environment variable

## Observability

- Log pager invocation in debug mode
- Track pager usage for analytics
- Add metrics for pager performance

## Compliance

- Follows CLI Tool Standards ADR requirement #19 (Pager Integration)
- Improves readability of long output

## Risks & Mitigations

- Risk: Pager doesn't work on all systems
  - Mitigation: Gracefully handle pager errors, fallback to no paging
- Risk: Pager interferes with output formatting
  - Mitigation: Detect pager capability, disable for incompatible output
- Risk: Terminal height detection is inaccurate
  - Mitigation: Use reliable detection library, provide manual override

## Dependencies

- None - this can be developed in parallel with other Phase 4 stories

## Notes

- Use a pager library or simple child process spawning
- Consider using cli-pager or similar library
- Pager should be invoked only for human-readable output
- Terminal height detection should handle resize events
