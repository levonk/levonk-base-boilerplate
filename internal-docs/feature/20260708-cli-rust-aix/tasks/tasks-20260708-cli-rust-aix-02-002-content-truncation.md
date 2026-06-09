---
story_id: "02-002"
story_title: "Content Truncation"
story_name: "content-truncation"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260708-cli-rust-aix/story-02-002-content-truncation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["output-formats"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "output", "axi"]
due: "2026-06-16"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement content truncation for large text fields (descriptions, bodies, logs) to reduce token consumption. Truncate by default (500-1500 chars) with escape hatch via `--full` flag. Include truncation metadata showing total size and help suggestions for retrieving full content.

## Sub-Tasks

- [x] Design truncation strategy and configurable limits
- [x] Implement truncation function for text fields
- [x] Add truncation metadata generation (total size, truncation indicator)
- [x] Add help suggestion generation for truncated content
- [x] Add `--full` flag to CLI argument parser
- [x] Implement truncation logic for all large text fields
- [x] Apply truncation to description fields
- [x] Apply truncation to body fields
- [x] Apply truncation to log fields
- [x] Integrate truncation into TOON output formatting
- [x] Integrate truncation into JSON output formatting
- [x] Ensure truncation is only applied when content exceeds limit
- [x] Apply truncation to both agent and human modes
- [x] Write unit tests for truncation function
- [x] Write unit tests for truncation metadata generation
- [x] Write integration tests for `--full` flag functionality
- [x] Write tests for truncation application to various field types
- [x] Update CLI help text to document truncation behavior

## Relevant Files

- `apps/cli/rust/core/files/src/internal/truncation/mod.rs.jinja` — Truncation module exports (new file)
- `apps/cli/rust/core/files/src/internal/truncation/truncator.rs.jinja` — Truncation logic (new file)
- `apps/cli/rust/core/files/src/internal/truncation/tests.rs.jinja` — Integration tests for truncation (new file)
- `apps/cli/rust/core/files/src/internal/truncation/metadata.rs.jinja` — Truncation metadata generation (new file)
- `apps/cli/rust/core/files/src/internal/toon/mod.rs.jinja` — Integrate truncation into output formatting
- `apps/cli/rust/core/files/src/internal/mod.rs.jinja` — Add truncation module export
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Add `--full` flag and truncation documentation
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrate truncation with CLI arguments
- `apps/cli/rust/core/files/src/config.rs.jinja` — truncation_limit config field (already added in story 01-003)

## Acceptance Criteria

- [x] Truncation function correctly truncates text to specified limit
- [x] Truncation metadata includes total size and truncation indicator
- [x] Help suggestions are generated only when content is actually truncated
- [x] `--full` flag successfully disables truncation
- [x] Truncation is applied to all large text fields
- [x] Truncation works correctly for TOON output
- [x] Truncation works correctly for JSON output
- [x] Truncation is not applied when content is under limit
- [x] Truncation works in both agent and human modes
- [x] Configurable truncation limit is respected
- [x] All truncation functionality has test coverage
- [x] Help text documents truncation behavior and `--full` flag

## Test Plan

- Unit: `cargo test --lib internal::truncation`
- Unit: `cargo test --lib internal::output`
- Integration: Test truncation with various field sizes
- Manual: Verify truncation metadata format
- Manual: Test `--full` flag with truncated content

## Observability

- Add logging for truncation decisions at debug level
- Add metrics for truncation frequency and sizes

## Compliance

- Ensure truncation doesn't lose critical information
- Validate that truncation metadata doesn't leak sensitive information

## Risks & Mitigations

- Risk: Truncation may remove critical information — Mitigation: Set appropriate default limits, provide `--full` escape hatch
- Risk: Truncation may break existing integrations — Mitigation: Document truncation behavior clearly, provide examples

## Dependencies

- Requires: TOON format implementation (01-002) for truncation integration with TOON output
- No other dependencies (can be developed in parallel with 02-001, 02-003, 02-004)

## Notes

- Truncation limit should be configurable per field type if needed
- Consider adding smart truncation that breaks at word boundaries
- Document recommended truncation limits for different content types
