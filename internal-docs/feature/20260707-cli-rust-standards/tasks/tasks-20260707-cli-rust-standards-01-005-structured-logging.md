---
story_id: "01-005"
story_title: "Structured Logging with Format Auto-Detection"
story_name: "structured-logging"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-01-005-structured-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-004"]
parallel_safe: true
modules: ["structured_log.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement structured logging with format auto-detection (JSON for non-TTY, pretty for TTY), support for RUST_LOG alongside custom env vars, and proper log level resolution precedence.

## Sub-Tasks

- [ ] Add tracing-subscriber JSON and ansi features to Cargo.toml
- [ ] Create structured_log.rs module
- [ ] Implement TTY detection for format auto-detection
- [ ] Add JSON layer for non-TTY output
- [ ] Add pretty (human-readable) layer for TTY output
- [ ] Implement RUST_LOG env variable support alongside custom vars
- [ ] Add log level resolution with precedence (env vars > CLI flags > config > defaults)
- [ ] Integrate structured logging with existing logging system
- [ ] Add structured field support (timestamp, level, module, message)
- [ ] Create tests for TTY detection
- [ ] Create tests for JSON output format
- [ ] Create tests for pretty output format
- [ ] Create tests for RUST_LOG integration
- [ ] Create tests for log level resolution precedence

## Relevant Files

- `apps/cli/rust/src/structured_log.rs` — Structured logging module
- `apps/cli/rust/src/logging.rs` — Integrate with existing logging
- `apps/cli/rust/src/config.rs` — Add log level to config schema
- `apps/cli/rust/Cargo.toml` — Structured logging dependencies
- `apps/cli/rust/tests/structured_log_test.rs` — Structured logging tests

## Acceptance Criteria

- [ ] Format auto-detects TTY vs non-TTY
- [ ] JSON output for non-TTY environments
- [ ] Pretty output for TTY environments
- [ ] RUST_LOG env variable works alongside custom vars
- [ ] Log level resolution follows correct precedence
- [ ] Structured fields included in all log entries
- [ ] All tests pass

## Test Plan

- Unit: `cargo test structured_log`
- Integration: Test format auto-detection, RUST_LOG, log level precedence
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log format selection events, TTY detection results
- Metrics: Track log format usage, log volume by format

## Compliance

- No regulatory constraints
- Ensure no sensitive data in structured logs

## Risks & Mitigations

- Risk: TTY detection fails in containerized environments — Mitigation: Add manual override via env var
- Risk: JSON format changes break log parsers — Mitigation: Version structured log format, document schema
- Risk: RUST_LOG conflicts with custom log levels — Mitigation: Clear precedence rules, validation

## Dependencies & Sequencing

- Depends on: 01-004 (logging system)
- Unblocks: None (foundational feature)

## Definition of Done

- Structured logging implemented
- Format auto-detection working
- RUST_LOG integration complete
- Log level resolution correct
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(logging): implement structured logging with format auto-detection`
- `feat(logging): add RUST_LOG support and log level resolution`
- `test(logging): add structured logging tests`
