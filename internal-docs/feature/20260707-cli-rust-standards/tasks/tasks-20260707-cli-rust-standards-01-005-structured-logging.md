---
story_id: "01-005"
story_title: "Structured Logging with Format Auto-Detection"
story_name: "structured-logging"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-01-005-structured-logging"
status: "done"
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

- [x] Add tracing-subscriber JSON and ansi features to Cargo.toml
- [x] Create structured_log.rs module
- [x] Implement TTY detection for format auto-detection
- [x] Add JSON layer for non-TTY output
- [x] Add pretty (human-readable) layer for TTY output
- [x] Implement RUST_LOG env variable support alongside custom vars
- [x] Add log level resolution with precedence (env vars > CLI flags > config > defaults)
- [x] Integrate structured logging with existing logging system
- [x] Add structured field support (timestamp, level, module, message)
- [x] Create tests for TTY detection
- [x] Create tests for JSON output format
- [x] Create tests for pretty output format
- [x] Create tests for RUST_LOG integration
- [x] Create tests for log level resolution precedence

## Relevant Files

- `apps/cli/rust/core/files/src/structured_log.rs.jinja` — Structured logging module (NEW)
- `apps/cli/rust/core/files/src/logging.rs.jinja` — Integrate with existing logging (MODIFIED)
- `apps/cli/rust/core/files/Cargo.toml.jinja` — Structured logging dependencies (MODIFIED - already has required features)
- `apps/cli/rust/core/files/tests/structured_log_test.rs.jinja` — Structured logging tests (NEW)

## Acceptance Criteria

- [x] Format auto-detects TTY vs non-TTY
- [x] JSON output for non-TTY environments
- [x] Pretty output for TTY environments
- [x] RUST_LOG env variable works alongside custom vars
- [x] Log level resolution follows correct precedence
- [x] Structured fields included in all log entries
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
