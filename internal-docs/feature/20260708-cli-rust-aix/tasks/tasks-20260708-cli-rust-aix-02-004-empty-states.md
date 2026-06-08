---
story_id: "02-004"
story_title: "Definitive Empty States"
story_name: "empty-states"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260708-cli-rust-aix/story-02-004-empty-states"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["output-formats", "cli-commands"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "output", "axi"]
due: "2026-06-16"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement definitive empty state formatting to explicitly communicate when queries return no results. This prevents agents from re-running commands with different flags to verify empty results, reducing token waste and improving clarity.

## Sub-Tasks

- [ ] Design empty state message format with context
- [ ] Implement empty state detection for all command outputs
- [ ] Create empty state formatting function
- [ ] Include context in empty state messages (filter criteria, scope)
- [ ] Ensure empty state messages indicate successful command execution
- [ ] Apply empty state formatting to list commands
- [ ] Apply empty state formatting to detail commands
- [ ] Apply empty state formatting to search commands
- [ ] Integrate empty state formatting into TOON output
- [ ] Integrate empty state formatting into JSON output
- [ ] Ensure exit code 0 for successful empty queries
- [ ] Write unit tests for empty state detection
- [ ] Write unit tests for empty state formatting
- [ ] Write integration tests for empty state output
- [ ] Write tests for exit code behavior with empty results
- [ ] Update CLI help text to document empty state behavior

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/emptystate/detector.rs` — Empty state detection logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/emptystate/tests.rs` — Tests for empty state detection (new file)
- `boilerplate/apps/cli/rust/core/src/internal/emptystate/formatter.rs` — Empty state formatting logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/emptystate/formatter_tests.rs` — Tests for empty state formatting (new file)
- `boilerplate/apps/cli/rust/core/src/internal/output/formatter.rs` — Integrate empty state formatting
- `boilerplate/apps/cli/rust/core/src/internal/output/tests.rs` — Tests for empty state integration
- `boilerplate/apps/cli/rust/core/src/cli/commands/*.rs` — Update each command to handle empty states
- `boilerplate/apps/cli/rust/core/src/cli/commands/*_tests.rs` — Update tests for empty state handling

## Acceptance Criteria

- [ ] Empty state detection works correctly for all command types
- [ ] Empty state messages include relevant context
- [ ] Empty state messages clearly indicate successful execution
- [ ] Empty state formatting is consistent across all commands
- [ ] Empty state formatting works for TOON output
- [ ] Empty state formatting works for JSON output
- [ ] Exit code is 0 for successful empty queries
- [ ] All empty state functionality has test coverage
- [ ] Help text documents empty state behavior

## Test Plan

- Unit: `cargo test --lib internal::emptystate`
- Unit: `cargo test --lib internal::output`
- Integration: Test empty state handling for all commands
- Manual: Verify empty state message format with various scenarios

## Observability

- Add logging for empty state detection at debug level
- Add metrics for empty state frequency

## Compliance

- Ensure empty state messages don't leak sensitive information
- Validate that empty state handling doesn't bypass security controls

## Risks & Mitigations

- Risk: Empty state detection may miss edge cases — Mitigation: Comprehensive test coverage for various query scenarios
- Risk: Empty state messages may be confusing — Mitigation: Clear, consistent formatting with helpful context

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- No other dependencies (can be developed in parallel with 02-001, 02-002, 02-003)

## Notes

- Empty state messages should be consistent with the overall output format
- Consider adding suggestions for next steps in empty state messages
- Document empty state format for consistency across commands
