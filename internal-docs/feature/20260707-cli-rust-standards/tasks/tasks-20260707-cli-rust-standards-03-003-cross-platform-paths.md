---
story_id: "03-003"
story_title: "Cross-Platform Path Handling"
story_name: "cross-platform-paths"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260707-cli-rust-standards/story-03-003-cross-platform-paths"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-003"]
parallel_safe: true
modules: ["io.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cross-platform"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement cross-platform path handling that works consistently across Windows/Linux/macOS with platform-appropriate separators, handling both forward and backward slashes.

## Sub-Tasks

- [x] Review existing path handling code
- [x] Add path normalization for cross-platform consistency
- [x] Implement platform-appropriate separator detection
- [x] Add forward slash support on Windows
- [x] Add backward slash support on Unix systems
- [x] Implement path conversion utilities
- [x] Update globbing to handle cross-platform paths
- [x] Add path validation for all platforms
- [x] Create tests for Windows path handling
- [x] Create tests for Linux path handling
- [x] Create tests for macOS path handling
- [x] Create tests for slash handling (forward/backward)

## Relevant Files

- `apps/cli/rust/core/files/src/path.rs.jinja` — Cross-platform path module (new)
- `apps/cli/rust/core/files/src/io.rs.jinja` — Updated to use PathUtils for normalization
- `apps/cli/rust/core/files/src/main.rs.jinja` — Added path module
- `apps/cli/rust/core/files/src/lib.rs.jinja` — Exported PathUtils
- `apps/cli/rust/core/files/tests/path_test.rs.jinja` — Comprehensive cross-platform path tests

## Acceptance Criteria

- [x] Paths handled consistently across Windows/Linux/macOS
- [x] Platform-appropriate separators used
- [x] Forward slashes work on Windows
- [x] Backward slashes work on Unix systems
- [x] Path normalization working
- [x] All tests pass

## Test Plan

- Unit: `cargo test path`
- Integration: Test path handling on all platforms (via CI)
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log path normalization events, platform detection
- Metrics: Track path handling by platform

## Compliance

- No regulatory constraints
- Ensure no path traversal vulnerabilities

## Risks & Mitigations

- Risk: Path handling differences cause bugs on specific platforms — Mitigation: Comprehensive cross-platform testing
- Risk: Slash conversion causes issues with network paths — Mitigation: Special handling for UNC paths, URL detection

## Dependencies & Sequencing

- Depends on: 01-003 (input/output handling)
- Unblocks: None (cross-platform feature)

## Definition of Done

- Cross-platform path handling implemented
- Platform-appropriate separators working
- Forward/backward slash support
- Path normalization working
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(io): implement cross-platform path handling`
- `feat(io): add forward/backward slash support`
- `test(io): add cross-platform path tests`
