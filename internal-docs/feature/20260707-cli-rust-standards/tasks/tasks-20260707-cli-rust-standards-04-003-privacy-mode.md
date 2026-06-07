---
story_id: "04-003"
story_title: "Privacy Mode with Anonymous Lists"
story_name: "privacy-mode"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 3
branch: "feature/current/20260707-cli-rust-standards/story-04-003-privacy-mode"
status: "todo"
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

- [ ] Create privacy.rs module
- [ ] Implement ignore list configuration in config file
- [ ] Add privacy mode flag to CLI
- [ ] Implement identifier detection logic
- [ ] Add "unknown" vs "anonymous" distinction
- [ ] Implement ignore list matching
- [ ] Add configurable privacy toggles for data collection
- [ ] Integrate privacy mode with data collection
- [ ] Add privacy mode to logging
- [ ] Create tests for ignore list functionality
- [ ] Create tests for unknown vs anonymous distinction
- [ ] Create tests for privacy toggles
- [ ] Create tests for privacy mode integration

## Relevant Files

- `apps/cli/rust/src/privacy.rs` — Privacy mode module
- `apps/cli/rust/src/config.rs` — Add privacy config settings
- `apps/cli/rust/src/cli.rs` — Add privacy mode flag
- `apps/cli/rust/src/logging.rs` — Integrate privacy with logging
- `apps/cli/rust/tests/privacy_test.rs` — Privacy mode tests

## Acceptance Criteria

- [ ] Ignore list configuration works
- [ ] Privacy mode flag toggles privacy features
- [ ] "Unknown" identifiers logged but not assigned
- [ ] "Anonymous" identifiers ignored entirely
- [ ] Privacy toggles disable specific data collection
- [ ] Privacy mode integrates with data collection
- [ ] All tests pass

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
