---
story_id: "01-003"
story_title: "Input/Output Handling"
story_name: "input-output"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260707-cli-rust-standards/story-01-003-input-output"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["io.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "io"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive input/output handling with recursive globbing, stdin support, JSON output mode, color control, VSCode-compatible file references, browser-compatible URLs, and auto-pager support.

## Sub-Tasks

- [x] Add glob dependency to Cargo.toml
- [x] Create io.rs module for input/output handling
- [x] Implement recursive **/* globbing pattern support
- [x] Add stdin detection via `-` argument or piped input
- [x] Implement file vs stdin processing logic
- [x] Add --json output mode flag
- [x] Implement JSON serialization for all output
- [x] Add --color=auto|always|never flag (default: auto)
- [x] Implement smart TTY detection for auto color mode
- [x] Add color setting to config file schema
- [x] Implement NO_COLOR environment variable support (takes precedence)
- [x] Add color mode resolution logic (NO_COLOR > --color > config > auto-detect)
- [x] Implement VSCode-compatible file reference formatting (file:///absolute/path:line:column)
- [x] Implement standard file:line:column fallback format
- [x] Add URL encoding for browser-compatible URLs
- [x] Implement auto-pager detection (respect PAGER env var, default to less)
- [x] Add --no-pager flag to bypass paging
- [x] Create tests for globbing patterns
- [x] Create tests for stdin handling
- [x] Create tests for JSON output mode
- [x] Create tests for color control (auto/always/never)
- [x] Create tests for NO_COLOR env var
- [x] Create tests for file reference formatting
- [x] Create tests for pager functionality

## Relevant Files

- `apps/cli/rust/core/files/src/io.rs.jinja` — Input/output handling module (NEW)
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Add --json, --color, --no-pager flags (MODIFIED)
- `apps/cli/rust/core/files/src/config.rs.jinja` — Add color setting to config schema (MODIFIED)
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrate IO handlers (MODIFIED)
- `apps/cli/rust/core/files/Cargo.toml.jinja` — IO-related dependencies (MODIFIED)
- `apps/cli/rust/core/files/templates/config.toml.jinja` — Update color config (MODIFIED)
- `apps/cli/rust/core/files/tests/io_test.rs.jinja` — IO tests (NEW)

## Acceptance Criteria

- [ ] Recursive globbing works with **/* pattern
- [ ] stdin works via `-` argument and piped input
- [ ] Files and stdin processed interchangeably
- [ ] --json mode produces valid JSON output
- [ ] --color=auto|always|never works correctly
- [ ] Smart TTY detection works in auto mode
- [ ] Config file color setting respected
- [ ] NO_COLOR env var takes precedence
- [ ] File references use VSCode-compatible format
- [ ] URLs are browser-compatible with proper encoding
- [ ] Auto-pager respects PAGER env var
- [ ] --no-pager bypasses paging
- [ ] All tests pass

## Test Plan

- Unit: `cargo test io`
- Integration: Test globbing, stdin, JSON output, color modes, pager
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log IO mode detection, color mode resolution, pager activation
- Metrics: Track IO performance, file processing times

## Compliance

- No regulatory constraints
- Ensure no sensitive data in JSON output

## Risks & Mitigations

- Risk: Globbing performance issues with large file trees — Mitigation: Add tests for performance, consider lazy evaluation
- Risk: Color detection fails in non-standard terminals — Mitigation: Fallback to no color, log detection issues
- Risk: Pager causes issues in automated environments — Mitigation: Respect NO_PAGER env var, --no-pager flag

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-004 (logging uses stderr), 03-003 (cross-platform paths)

## Definition of Done

- Input/output handling fully implemented
- Globbing, stdin, JSON output working
- Color control with all modes
- File references and URLs formatted correctly
- Auto-pager with bypass option
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(io): implement input/output handling with globbing and JSON mode`
- `feat(io): add color control with --color flag and NO_COLOR support`
- `test(io): add comprehensive IO tests`
