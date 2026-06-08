---
story_id: "04-003"
story_title: "Progress Indicators"
story_name: "progress-indicators"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 4
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-04-003-progress-indicators"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["progress/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Show progress bars or spinners for long-running operations using cli-progress or similar library. Progress indicators must respect the `--quiet` flag (no progress indicators in quiet mode). This implements CLI Tool Standards ADR requirement #12.

## Sub-Tasks

- [x] Add cli-progress library to package.json.jinja
- [x] Create progress module with progress indicator management
- [x] Implement progress bar for file operations
- [x] Implement progress bar for network operations
- [x] Implement spinner for indeterminate operations
- [x] Add progress indicator respect for --quiet flag
- [x] Add progress indicator respect for --json flag
- [x] Implement progress context management
- [x] Add unit tests for progress indicators
- [x] Add unit tests for quiet mode behavior
- [x] Add integration tests for progress display
- [x] Update help text to document progress behavior
- [x] Add progress cancellation support

## Relevant Files

- `apps/cli/typescript/core/files/src/progress.ts.jinja` - New progress module (created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with progress integration (modified)
- `apps/cli/typescript/core/files/src/progress.test.ts.jinja` - Unit tests for progress (created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for progress (modified)
- `apps/cli/typescript/core/files/package.json.jinja` - Add cli-progress dependency (modified)

## Acceptance Criteria

- [ ] Progress bars are shown for long-running file operations
- [ ] Progress bars are shown for long-running network operations
- [ ] Spinners are shown for indeterminate operations
- [ ] Progress indicators respect --quiet flag (no progress in quiet mode)
- [ ] Progress indicators respect --json flag (no progress in JSON mode)
- [ ] Progress indicators are visually clear and informative
- [ ] Progress can be cancelled by user (Ctrl+C)
- [ ] Progress indicators don't interfere with output

## Test Plan

- Unit: `vitest run src/progress.test.ts` - Test progress indicator logic
- Integration: `vitest run src/index.test.ts` - Test progress display
- Manual: Run long operation and verify progress bar
- Manual: Test --quiet flag suppresses progress indicators

## Observability

- Progress indicators provide real-time feedback
- Log progress milestones in debug mode
- Add metrics for operation completion times

## Compliance

- Follows CLI Tool Standards ADR requirement #12 (Progress Indicators)
- Improves user experience for long-running operations

## Risks & Mitigations

- Risk: Progress indicators don't work on all terminals
  - Mitigation: Use well-tested library, fallback to simple text
- Risk: Progress indicators interfere with output formatting
  - Mitigation: Use separate lines, handle terminal width
- Risk: Progress indicators add performance overhead
  - Mitigation: Update progress at reasonable intervals, not every operation

## Dependencies

- 02-001 (Enhanced Logging Modes) - Progress should integrate with logging system

## Notes

- Use cli-progress or similar well-maintained library
- Progress should be percentage-based when possible
- Consider using spinners for operations without clear progress
- Progress indicators should be cancelled gracefully on SIGINT
