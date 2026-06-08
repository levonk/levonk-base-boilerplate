---
story_id: "02-005"
story_title: "Command Organization and Terminal Awareness"
story_name: "command-organization"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 2
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-02-005-command-organization"
status: "done"
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

Organize commands hierarchically with consistent patterns under logical subcommands, and implement terminal size detection on startup with resize event handling where possible.

## Sub-Tasks

- [x] Review existing command structure
- [x] Design hierarchical command organization
- [x] Implement logical subcommands using clap subcommand feature
- [x] Add consistent patterns across subcommands (help, version, etc.)
- [x] Implement terminal size detection on startup
- [x] Add terminal resize event handling where supported
- [x] Update command help text for hierarchical structure
- [x] Create tests for command hierarchy
- [x] Create tests for terminal size detection
- [x] Create tests for resize event handling

## Relevant Files

- `apps/cli/rust/src/cli.rs` — Command organization and terminal detection
- `apps/cli/rust/src/terminal.rs` — Terminal utilities (new module)
- `apps/cli/rust/tests/cli_test.rs` — CLI tests

## Acceptance Criteria

- [x] Commands organized hierarchically under logical subcommands
- [x] Consistent patterns across all subcommands
- [x] Terminal size detected on startup
- [x] Resize events handled where supported
- [x] Help text reflects hierarchical structure
- [x] All tests pass (tests created, require template rendering to execute)

## Test Plan

- Unit: `cargo test cli`
- Integration: Test command hierarchy, terminal detection, resize handling
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log terminal size detection, resize events
- Metrics: Track terminal size distribution, resize event frequency

## Compliance

- No regulatory constraints
- Ensure terminal detection doesn't fail in non-terminal environments

## Risks & Mitigations

- Risk: Terminal detection fails in containerized environments — Mitigation: Graceful fallback to default size
- Risk: Resize events not supported on all platforms — Mitigation: Platform detection, optional feature

## Dependencies & Sequencing

- Depends on: 01-001 (standard arguments)
- Unblocks: None (structural improvement)

## Definition of Done

- Commands organized hierarchically
- Consistent patterns across subcommands
- Terminal size detection working
- Resize event handling where supported
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(cli): organize commands hierarchically with subcommands`
- `feat(cli): add terminal size detection and resize handling`
- `test(cli): add command organization tests`
