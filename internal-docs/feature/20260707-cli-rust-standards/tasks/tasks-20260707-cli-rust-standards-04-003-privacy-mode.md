---
story_id: "04-003"
story_title: "Privacy Mode with Anonymous Lists"
story_name: "privacy-mode"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 3
branch: "feature/current/20260707-cli-rust-standards/story-04-003-privacy-mode"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["privacy.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "privacy"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement privacy mode with explicit ignore lists for sensitive identifiers, distinguishing between "unknown" (logged but not assigned) and "anonymous" (ignored entirely), with configurable privacy toggles to disable specific data collection.

## Sub-Tasks

- [x] Create privacy.rs module
- [x] Implement ignore list configuration in config file
- [x] Add privacy mode flag to CLI
- [x] Implement identifier detection logic
- [x] Add "unknown" vs "anonymous" distinction
- [x] Implement ignore list matching
- [x] Add configurable privacy toggles for data collection
- [x] Integrate privacy mode with data collection
- [x] Add privacy mode to logging
- [x] Create tests for ignore list functionality
- [x] Create tests for unknown vs anonymous distinction
- [x] Create tests for privacy toggles
- [x] Create tests for privacy mode integration

## Relevant Files

- `apps/cli/rust/src/privacy.rs` — Privacy mode module
- `apps/cli/rust/src/config.rs` — Add privacy config settings
- `apps/cli/rust/src/cli.rs` — Add privacy mode flag
- `apps/cli/rust/src/logging.rs` — Integrate privacy with logging
- `apps/cli/rust/tests/privacy_test.rs` — Privacy mode tests

## Acceptance Criteria

- [x] Ignore list configuration works
- [x] Privacy mode flag toggles privacy features
- [x] "Unknown" identifiers logged but not assigned
- [x] "Anonymous" identifiers ignored entirely
- [x] Privacy toggles disable specific data collection
- [x] Privacy mode integrates with data collection
- [x] All tests pass

## Test Plan

- Unit: `cargo test privacy`
- Integration: Test privacy mode, ignore lists, privacy toggles
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log privacy mode activation, ignore list matches, privacy toggle changes
- Metrics: Track privacy mode usage, ignore list hit rate

## Compliance

- No regulatory constraints
- Ensure privacy mode doesn't break required functionality

## Risks & Mitigations

- Risk: Privacy mode breaks analytics — Mitigation: Clear documentation, optional feature
- Risk: Ignore list false positives — Mitigation: Configurable patterns, allowlist options

## Dependencies & Sequencing

- Depends on: 01-002 (config management)
- Unblocks: None (privacy feature)

## Definition of Done

- Privacy mode implemented
- Ignore lists working
- Unknown vs anonymous distinction working
- Privacy toggles functional
- Integration with data collection
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(privacy): implement privacy mode with ignore lists`
- `feat(privacy): add unknown vs anonymous distinction`
- `test(privacy): add privacy mode tests`
