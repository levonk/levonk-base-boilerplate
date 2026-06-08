---
story_id: "03-002"
story_title: "Man Pages Generation"
story_name: "man-pages"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260707-cli-rust-standards/story-03-002-man-pages"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["docs/"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "docs"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement traditional Unix man pages accessible via `man <command>` or `--man` flag, using help2man or similar tool for dynamic generation from help text.

## Sub-Tasks

- [x] Add help2man or similar tool to build process
- [x] Create man page template with standard sections
- [x] Implement man page generation from help text
- [x] Add --man flag to CLI to display man page
- [x] Install man pages to system man directory
- [x] Add man page generation to build script
- [x] Create tests for man page generation
- [x] Create tests for --man flag
- [x] Validate man page format and content
- [x] Document man page usage in README

## Relevant Files

- `apps/cli/rust/core/files/docs/man/{{ project_slug }}.1.jinja` — Man page template
- `apps/cli/rust/core/files/Cargo.toml.jinja` — Added clap_mangen build dependency
- `apps/cli/rust/core/files/build.rs.jinja` — Build script for man page generation
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Added --man flag
- `apps/cli/rust/core/files/src/man.rs.jinja` — Man page handler module
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrated man page display
- `apps/cli/rust/core/files/src/lib.rs.jinja` — Exported ManHandler
- `apps/cli/rust/core/files/justfile.jinja` — Added man page generation/validation/install commands
- `apps/cli/rust/core/files/tests/man_test.rs.jinja` — Man page tests
- `apps/cli/rust/core/files/README.md.jinja` — Documented man page usage

## Acceptance Criteria

- [x] Man pages generated from help text
- [x] --man flag displays man page
- [x] Man pages accessible via `man <command>`
- [x] Man pages follow standard Unix format
- [x] Man pages installed to correct directory
- [x] All tests pass

## Test Plan

- Unit: `cargo test man`
- Integration: Test man page generation, --man flag, actual man command
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log man page generation events
- Metrics: Track man page usage

## Compliance

- No regulatory constraints
- Ensure man pages don't expose sensitive information

## Risks & Mitigations

- Risk: Man page generation fails on some systems — Mitigation: Graceful fallback, clear error messages
- Risk: Man pages out of sync with help text — Mitigation: Auto-generation on build, CI validation

## Dependencies & Sequencing

- Depends on: 01-001 (standard arguments)
- Unblocks: None (documentation feature)

## Definition of Done

- Man pages implemented
- --man flag working
- Man pages accessible via man command
- Auto-generation from help text
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(docs): implement man page generation from help text`
- `feat(docs): add --man flag to display man pages`
- `test(docs): add man page generation tests`
