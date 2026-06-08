---
story_id: "02-003"
story_title: "Progress Indicators"
story_name: "progress-indicators"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260707-cli-rust-standards/story-02-003-progress-indicators"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-004"]
parallel_safe: true
modules: ["cli.rs"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement progress bars or spinners for long-running operations, with respect for --quiet flag (no progress indicators in quiet mode).

## Sub-Tasks

- [x] Add indicatif dependency to Cargo.toml
- [~] Create progress indicator utilities in cli.rs
- [ ] Implement progress bar for operations with known progress
- [ ] Implement spinner for operations with unknown duration
- [ ] Add progress indicator integration with command execution
- [ ] Implement --quiet flag respect (suppress progress indicators)
- [ ] Add progress indicator cleanup on completion/interrupt
- [ ] Create tests for progress bars
- [ ] Create tests for spinners
- [ ] Create tests for --quiet mode suppression

## Relevant Files

- `apps/cli/rust/core/files/src/cli.rs.jinja` — Progress indicator utilities, Progress struct with bar/spinner methods
- `apps/cli/rust/core/files/Cargo.toml.jinja` — indicatif dependency (already present)
- `apps/cli/rust/core/files/tests/progress_test.rs.jinja` — Progress indicator tests (to be created)

## Acceptance Criteria

- [ ] Progress bars display for operations with known progress
- [ ] Spinners display for operations with unknown duration
- [ ] --quiet flag suppresses all progress indicators
- [ ] Progress indicators clean up on completion
- [ ] Progress indicators handle interrupts gracefully
- [ ] All tests pass

## Test Plan

- Unit: `cargo test progress`
- Integration: Test progress bars, spinners, --quiet suppression
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log progress indicator start/stop events
- Metrics: Track operation durations, progress indicator usage

## Compliance

- No regulatory constraints
- Ensure progress indicators don't impact performance significantly

## Risks & Mitigations

- Risk: Progress indicators impact performance — Mitigation: Minimal overhead, benchmark critical paths
- Risk: Progress indicators break in non-TTY environments — Mitigation: Auto-detect TTY, disable in non-TTY

## Dependencies & Sequencing

- Depends on: 01-004 (logging for --quiet mode)
- Unblocks: None (UX improvement)

## Definition of Done

- Progress bars implemented
- Spinners implemented
- --quiet mode respected
- Progress indicators clean up properly
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(cli): implement progress bars and spinners for long operations`
- `feat(cli): add --quiet mode suppression of progress indicators`
- `test(cli): add progress indicator tests`
