---
story_id: "02-004"
story_title: "Definitive Empty States"
story_name: "empty-states"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260708-cli-go-aix/story-02-004-empty-states"
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

- [x] Design empty state message format with context
- [x] Implement empty state detection for all command outputs
- [x] Create empty state formatting function
- [x] Include context in empty state messages (filter criteria, scope)
- [x] Ensure empty state messages indicate successful command execution
- [x] Apply empty state formatting to list commands
- [x] Apply empty state formatting to detail commands
- [x] Apply empty state formatting to search commands
- [x] Integrate empty state formatting into TOON output
- [x] Integrate empty state formatting into JSON output
- [x] Ensure exit code 0 for successful empty queries
- [x] Write unit tests for empty state detection
- [x] Write unit tests for empty state formatting
- [x] Write integration tests for empty state output
- [x] Write tests for exit code behavior with empty results
- [x] Update CLI help text to document empty state behavior

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/emptystate/detector.go.jinja` — Empty state detection logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/emptystate/detector_test.go.jinja` — Tests for empty state detection (new file)
- `boilerplate/apps/cli/go/core/files/internal/emptystate/formatter.go.jinja` — Empty state formatting logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/emptystate/formatter_test.go.jinja` — Tests for empty state formatting (new file)
- `boilerplate/apps/cli/go/core/files/internal/formatting/formatter.go.jinja` — Integrate empty state formatting
- `boilerplate/apps/cli/go/core/files/internal/formatting/formatter_test.go.jinja` — Tests for empty state integration

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

- Unit: `go test ./internal/emptystate/...`
- Unit: `go test ./internal/output/...`
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
