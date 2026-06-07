---
story_id: "01-006"
story_title: "Signal-Based Config Reload"
story_name: "config-reload"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 6
branch: "feature/current/20260707-cli-rust-standards/story-01-006-config-reload"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002", "01-004"]
parallel_safe: true
modules: ["signals.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "signals"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement SIGHUP signal handler to reload configuration files without process restart, with validation before applying, logging of reload events, and graceful error handling that keeps old config active on validation failure.

## Sub-Tasks

- [ ] Add signal-hook or tokio::signal dependency to Cargo.toml
- [ ] Create signals.rs module for signal handling
- [ ] Implement SIGHUP signal handler registration
- [ ] Add config reload function that re-reads config files
- [ ] Implement config validation before applying new config
- [ ] Add logging for config reload events (success/failure)
- [ ] Implement graceful error handling (keep old config on validation failure)
- [ ] Add config hot-reload integration with existing config system
- [ ] Create tests for SIGHUP signal handling
- [ ] Create tests for config reload logic
- [ ] Create tests for config validation on reload
- [ ] Create tests for error handling (old config retention)

## Relevant Files

- `apps/cli/rust/src/signals.rs` — Signal handling module
- `apps/cli/rust/src/config.rs` — Add reload support
- `apps/cli/rust/src/logging.rs` — Log reload events
- `apps/cli/rust/Cargo.toml` — Signal handling dependencies
- `apps/cli/rust/tests/signals_test.rs` — Signal handling tests

## Acceptance Criteria

- [ ] SIGHUP signal triggers config reload
- [ ] Config re-read from file on reload
- [ ] New config validated before applying
- [ ] Validation failures logged and old config kept active
- [ ] Successful reloads logged
- [ ] No process restart required
- [ ] All tests pass

## Test Plan

- Unit: `cargo test signals`
- Integration: Send SIGHUP to running process, verify config reload
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log SIGHUP receipt, config reload attempts, validation results
- Metrics: Track config reload frequency, success/failure rate

## Compliance

- No regulatory constraints
- Ensure no sensitive data in reload logs

## Risks & Mitigations

- Risk: Config reload causes runtime instability — Mitigation: Validation before apply, rollback on failure
- Risk: Signal handler conflicts with async runtime — Mitigation: Use tokio::signal for async compatibility
- Risk: Config file locked during reload — Mitigation: Atomic file reading, handle file access errors

## Dependencies & Sequencing

- Depends on: 01-002 (config management), 01-004 (logging)
- Unblocks: None (operational feature)

## Definition of Done

- SIGHUP signal handler implemented
- Config reload working without restart
- Validation before applying new config
- Graceful error handling with old config retention
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(signals): implement SIGHUP config reload without restart`
- `feat(signals): add config validation before reload application`
- `test(signals): add signal handling tests`
