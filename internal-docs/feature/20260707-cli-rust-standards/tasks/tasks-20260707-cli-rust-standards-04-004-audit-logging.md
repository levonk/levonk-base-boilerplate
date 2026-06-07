---
story_id: "04-004"
story_title: "Audit Logging with Retention"
story_name: "audit-logging"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 4
branch: "feature/current/20260707-cli-rust-standards/story-04-004-audit-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["audit.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "audit"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement optional append-only audit log (SQLite) with configurable retention period, auto-pruning of old audit data on startup, and export commands for external analysis.

## Sub-Tasks

- [ ] Add rusqlite dependency to Cargo.toml
- [ ] Create audit.rs module
- [ ] Implement SQLite audit log schema
- [ ] Add append-only audit log writing
- [ ] Implement configurable retention period in config
- [ ] Add auto-pruning of old audit data on startup
- [ ] Implement audit log export commands
- [ ] Add audit log to config file schema
- [ ] Integrate audit logging with CLI operations
- [ ] Create tests for audit log writing
- [ ] Create tests for retention period configuration
- [ ] Create tests for auto-pruning
- [ ] Create tests for audit log export

## Relevant Files

- `apps/cli/rust/src/audit.rs` — Audit logging module
- `apps/cli/rust/src/config.rs` — Add audit config settings
- `apps/cli/rust/src/cli.rs` — Add audit export commands
- `apps/cli/rust/Cargo.toml` — SQLite dependency
- `apps/cli/rust/tests/audit_test.rs` — Audit logging tests

## Acceptance Criteria

- [ ] Audit log writes append-only entries
- [ ] Retention period configurable
- [ ] Auto-pruning works on startup
- [ ] Audit log export produces valid output
- [ ] Audit logging integrated with CLI operations
- [ ] All tests pass

## Test Plan

- Unit: `cargo test audit`
- Integration: Test audit logging, retention, pruning, export
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log audit events, pruning operations
- Metrics: Track audit log size, pruning frequency

## Compliance

- No regulatory constraints
- Ensure audit logs don't contain sensitive data unless required
- Follow data retention best practices

## Risks & Mitigations

- Risk: Audit log grows unbounded — Mitigation: Configurable retention, auto-pruning
- Risk: SQLite performance issues with large logs — Mitigation: Indexing, periodic cleanup, partitioning if needed

## Dependencies & Sequencing

- Depends on: 01-002 (config management)
- Unblocks: None (audit feature)

## Definition of Done

- Audit logging implemented
- Append-only SQLite log working
- Configurable retention period
- Auto-pruning on startup
- Export commands functional
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(audit): implement append-only audit log with SQLite`
- `feat(audit): add configurable retention and auto-pruning`
- `feat(audit): add audit log export commands`
- `test(audit): add audit logging tests`
