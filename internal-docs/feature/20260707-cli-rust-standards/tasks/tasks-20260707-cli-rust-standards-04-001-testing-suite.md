---
story_id: "04-001"
story_title: "Comprehensive Testing Suite"
story_name: "testing-suite"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260707-cli-rust-standards/story-04-001-testing-suite"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002", "01-003", "01-004"]
parallel_safe: false
modules: ["tests/"]
priority: "MUST"
risk_level: "high"
tags: ["test", "validation"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive testing suite covering help output, globbing, stdin, config precedence, JSON vs human output, exit-code behavior, standard arguments, config file initialization, shell completion, error handling, and daemon mode to achieve >90% test coverage.

## Sub-Tasks

- [x] Add assert_cmd, predicates, tempfile dependencies to Cargo.toml
- [x] Create test directory structure
- [x] Implement tests for help output validation
- [x] Implement tests for globbing patterns
- [x] Implement tests for stdin handling
- [x] Implement tests for config precedence (CLI > env > local > user > system > defaults)
- [x] Implement tests for JSON vs human output
- [x] Implement tests for exit-code behavior (0, 1, 2, specific codes)
- [x] Implement tests for standard arguments (--help, --version, --usage)
- [x] Implement tests for config file initialization
- [x] Implement tests for shell completion scripts
- [x] Implement tests for error handling and formatting
- [x] Implement tests for daemon mode operations
- [x] Add property-based tests for configuration logic
- [x] Add cross-platform tests for path handling
- [x] Add performance benchmarks for startup time
- [x] Set up test coverage reporting
- [x] Ensure >90% coverage for all new code
- [x] Add tests to CI pipeline

## Relevant Files

- `apps/cli/rust/tests/` — Comprehensive test suite
- `apps/cli/rust/tests/cli_test.rs` — CLI argument tests
- `apps/cli/rust/tests/config_test.rs` — Configuration tests
- `apps/cli/rust/tests/io_test.rs` — Input/output tests
- `apps/cli/rust/tests/daemon_test.rs` — Daemon tests
- `apps/cli/rust/benches/` — Performance benchmarks
- `apps/cli/rust/Cargo.toml` — Test dependencies

## Acceptance Criteria

- [ ] Help output tests pass
- [ ] Globbing tests pass
- [ ] Stdin handling tests pass
- [ ] Config precedence tests pass
- [ ] JSON vs human output tests pass
- [ ] Exit-code behavior tests pass
- [ ] Standard arguments tests pass
- [ ] Config initialization tests pass
- [ ] Shell completion tests pass
- [ ] Error handling tests pass
- [ ] Daemon mode tests pass
- [ ] Test coverage >90%
- [ ] All tests pass in CI

## Test Plan

- Unit: `cargo test`
- Integration: Full test suite run
- Coverage: `cargo tarpaulin` or similar
- Benchmarks: `cargo bench`
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Metrics: Track test coverage, test execution time, flaky test rate

## Compliance

- No regulatory constraints
- Ensure tests don't expose sensitive data

## Risks & Mitigations

- Risk: Test suite becomes slow — Mitigation: Parallel test execution, unit/integration test separation
- Risk: Flaky tests in CI — Mitigation: Deterministic test design, proper fixtures, timeout handling

## Dependencies & Sequencing

- Depends on: 01-001, 01-002, 01-003, 01-004 (core features to test)
- Unblocks: 04-006 (final validation)

## Definition of Done

- Comprehensive test suite implemented
- All required test categories covered
- Test coverage >90%
- All tests passing
- Performance benchmarks in place
- CI integration complete
- Documentation updated

## Commit Conventions

- `test(cli): add comprehensive test suite for CLI features`
- `test(config): add configuration precedence tests`
- `test(daemon): add daemon mode tests`
- `ci: add test coverage reporting`
