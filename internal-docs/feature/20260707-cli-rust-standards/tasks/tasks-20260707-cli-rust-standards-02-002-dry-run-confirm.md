---
story_id: "02-002"
story_title: "Dry-Run and Confirmation Prompts"
story_name: "dry-run-confirm"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260707-cli-rust-standards/story-02-002-dry-run-confirm"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["cli.rs"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement --dry-run flag to preview changes without execution, and require confirmation for destructive operations with --force flag to bypass confirmation prompts.

## Sub-Tasks

- [ ] Add --dry-run flag to CLI
- [ ] Implement dry-run mode logic (preview only, no execution)
- [ ] Add destructive operation detection
- [ ] Implement confirmation prompts for destructive operations
- [ ] Add --force flag to bypass confirmation prompts
- [ ] Add dry-run output formatting (show what would happen)
- [ ] Integrate dry-run with command execution flow
- [ ] Create tests for --dry-run flag
- [ ] Create tests for confirmation prompts
- [ ] Create tests for --force flag bypass
- [ ] Add documentation for destructive operations

## Relevant Files

- `apps/cli/rust/src/cli.rs` — Add --dry-run and --force flags
- `apps/cli/rust/src/executor.rs` — Add dry-run logic to execution
- `apps/cli/rust/tests/dry_run_test.rs` — Dry-run tests

## Acceptance Criteria

- [ ] --dry-run flag previews changes without execution
- [ ] Destructive operations trigger confirmation prompts
- [ ] --force flag bypasses confirmation prompts
- [ ] Dry-run output clearly shows what would happen
- [ ] All tests pass

## Test Plan

- Unit: `cargo test dry_run`
- Integration: Test dry-run mode, confirmation prompts, --force bypass
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log dry-run mode activation, confirmation responses
- Metrics: Track dry-run usage, confirmation bypass rate

## Compliance

- No regulatory constraints
- Ensure destructive operations clearly documented

## Risks & Mitigations

- Risk: Dry-run output doesn't match actual execution — Mitigation: Use same code path for preview and execution, toggle execution flag
- Risk: Confirmation prompts annoy users in automation — Mitigation: --force flag, respect CI env var

## Dependencies & Sequencing

- Depends on: 01-001 (standard arguments)
- Unblocks: None (safety feature)

## Definition of Done

- --dry-run flag implemented
- Confirmation prompts for destructive operations
- --force flag to bypass prompts
- Dry-run output accurate
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(cli): implement --dry-run flag for change preview`
- `feat(cli): add confirmation prompts for destructive operations`
- `test(cli): add dry-run and confirmation tests`
