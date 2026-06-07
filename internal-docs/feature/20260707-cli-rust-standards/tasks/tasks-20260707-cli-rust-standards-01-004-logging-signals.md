---
story_id: "01-004"
story_title: "Logging and Signal Handling"
story_name: "logging-signals"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 4
branch: "feature/current/20260707-cli-rust-standards/story-01-004-logging-signals"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logging.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement logging system with --verbose, --quiet, --debug flags, SIGINT graceful handling, standard exit codes, and consistent environment variable naming conventions.

## Sub-Tasks

- [ ] Add tracing, tracing-subscriber dependencies to Cargo.toml
- [ ] Create logging.rs module for logging setup
- [ ] Implement --verbose/-v flag for increased verbosity
- [ ] Implement --quiet/-q flag for minimal output
- [ ] Implement --debug flag for debug-level logging
- [ ] Add log level resolution logic (env vars > CLI flags > config > defaults)
- [ ] Implement suppression of non-essential output in --quiet mode
- [ ] Add signal-hook dependency for SIGINT handling
- [ ] Implement SIGINT graceful handler with exit code 130
- [ ] Define standard exit codes (0 success, 1 generic error, 2 usage error)
- [ ] Add specific exit codes for different error types
- [ ] Implement consistent UPPER_CASE env variable prefix (e.g., MYTOOL_DEBUG)
- [ ] Add env variable validation and parsing
- [ ] Create tests for logging levels
- [ ] Create tests for --quiet mode suppression
- [ ] Create tests for SIGINT handling
- [ ] Create tests for exit codes
- [ ] Create tests for env variable parsing

## Relevant Files

- `apps/cli/rust/src/logging.rs` — Logging setup module
- `apps/cli/rust/src/cli.rs` — Add --verbose, --quiet, --debug flags
- `apps/cli/rust/src/error.rs` — Error types with exit codes
- `apps/cli/rust/Cargo.toml` — Logging and signal dependencies
- `apps/cli/rust/tests/logging_test.rs` — Logging tests

## Acceptance Criteria

- [ ] --verbose/-v increases output verbosity
- [ ] --quiet/-q suppresses non-essential output including progress
- [ ] --debug enables debug-level logging
- [ ] Log level resolution follows precedence (env > CLI > config > defaults)
- [ ] SIGINT handled gracefully with exit code 130
- [ ] Standard exit codes used (0, 1, 2, plus specific codes)
- [ ] Environment variables use consistent UPPER_CASE prefix
- [ ] All tests pass

## Test Plan

- Unit: `cargo test logging`
- Integration: Test logging levels, SIGINT handling, exit codes
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log level changes, signal handling events
- Metrics: Track log volume by level, signal occurrences

## Compliance

- No regulatory constraints
- Ensure no sensitive data in logs at any level

## Risks & Mitigations

- Risk: SIGINT handler conflicts with async runtime — Mitigation: Use tokio::signal for async compatibility
- Risk: Exit code confusion for users — Mitigation: Document exit codes clearly in help text
- Risk: Log level precedence complexity — Mitigation: Clear documentation and tests

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-005 (structured logging), 01-006 (config reload), 02-003 (progress indicators)

## Definition of Done

- Logging system fully implemented
- All logging modes working
- SIGINT graceful handling
- Standard exit codes defined
- Consistent env variable naming
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(logging): implement logging with --verbose, --quiet, --debug flags`
- `feat(logging): add SIGINT graceful handling with exit code 130`
- `test(logging): add comprehensive logging tests`
