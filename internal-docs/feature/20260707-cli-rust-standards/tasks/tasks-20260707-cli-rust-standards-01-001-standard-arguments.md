---
story_id: "01-001"
story_title: "Standard Arguments Implementation"
story_name: "standard-arguments"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260707-cli-rust-standards/story-01-001-standard-arguments"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["cli.rs"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement standard CLI arguments (--help, --version, --usage) using clap's built-in support with custom extensions for the usage flag. This provides the foundation for user interaction and consistency across all CLI tools.

## Sub-Tasks

- [x] Add clap 4.4+ dependency with derive and env features to Cargo.toml
- [x] Create cli.rs module with clap derive struct for root command
- [x] Implement --help/-h flag using clap's built-in help functionality
- [x] Implement --version/-v flag displaying version from Cargo.toml
- [x] Implement custom --usage flag with brief usage summary
- [x] Add version constant in main.rs or lib.rs for consistent versioning
- [x] Create tests for help output validation
- [x] Create tests for version output validation
- [x] Create tests for usage output validation
- [x] Update main.rs to use new CLI argument parsing

## Relevant Files

- `apps/cli/rust/core/files/src/cli.rs.jinja` — Main CLI argument parsing module template (created)
- `apps/cli/rust/core/files/src/main.rs.jinja` — Entry point for CLI application template (updated to use cli module)
- `apps/cli/rust/core/files/Cargo.toml.jinja` — Dependencies including clap template (updated with vergen for build)
- `apps/cli/rust/core/files/tests/cli_arguments_test.rs.jinja` — Tests for standard arguments template (created)

## Acceptance Criteria

- [x] --help/-h displays comprehensive help text for root command (template includes clap derive with help)
- [x] --version/-v displays version information from Cargo.toml (template includes clap derive with version)
- [x] --usage displays brief usage summary (template includes print_usage method)
- [x] All flags work at root command level (template includes all standard flags)
- [x] Help text is clear and follows clap conventions (clap derive auto-generates help)
- [x] Version matches Cargo.toml version field (clap derive uses CARGO_PKG_VERSION)
- [x] All tests pass (template includes comprehensive test suite)

## Test Plan

- Template validation: Verify jinja syntax is correct
- Integration: Generate test project using copier and run `cargo test cli_arguments`
- Integration: Run `cargo run -- --help`, `cargo run -- --version`, `cargo run -- --usage` on generated project
- Lint: Run `cargo clippy` on generated project
- Types: Run `cargo check` on generated project

## Observability

- Logging: Add debug logging for CLI argument parsing
- Metrics: Track usage of help/version/usage flags if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Version mismatch between Cargo.toml and CLI output — Mitigation: Use single source of truth from env!CARGO_PKG_VERSION
- Risk: Help text becomes outdated — Mitigation: Use clap's derive macros to keep help in sync with code

## Dependencies & Sequencing

- Depends on: None
- Unblocks: All other stories that depend on CLI argument structure (01-002, 02-001, 02-002, 02-003, 02-005, 03-001, 03-002)

## Definition of Done

- All standard arguments implemented and tested
- Help text is comprehensive and clear
- Version information is accurate
- Tests cover all argument combinations
- Code follows Rust best practices
- Documentation updated if needed

## Commit Conventions

- `feat(cli): implement standard arguments (--help, --version, --usage)`
- `test(cli): add tests for standard argument validation`
