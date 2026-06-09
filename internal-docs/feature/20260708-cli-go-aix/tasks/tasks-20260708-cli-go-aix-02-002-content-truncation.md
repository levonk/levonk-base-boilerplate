---
story_id: "02-002"
story_title: "Content Truncation"
story_name: "content-truncation"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260708-cli-go-aix/story-02-002-content-truncation"
status: "in_progress"
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
- [x] Add truncation config to config file
- [~] Integrate truncation into TOON output formatting
- [ ] Integrate truncation into JSON output formatting
- [ ] Integrate truncation into formatter with config support
- [ ] Apply truncation to description fields
- [ ] Apply truncation to body fields
- [ ] Apply truncation to log fields
- [ ] Ensure truncation is only applied when content exceeds limit
- [ ] Apply truncation to both agent and human modes
- [ ] Write unit tests for truncation function
- [ ] Write unit tests for truncation metadata generation
- [ ] Write integration tests for `--full` flag functionality
- [ ] Write tests for truncation application to various field types
- [ ] Update CLI help text to document truncation behavior

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/truncation/truncator.go` — Truncation logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/truncation/truncator_test.go` — Tests for truncation (new file)
- `boilerplate/apps/cli/go/core/files/internal/truncation/metadata.go` — Truncation metadata generation (new file)
- `boilerplate/apps/cli/go/core/files/internal/output/formatter.go` — Integrate truncation into output formatting
- `boilerplate/apps/cli/go/core/files/internal/output/formatter_test.go` — Tests for truncation integration
- `boilerplate/apps/cli/go/core/files/cli/root.go` — Add `--full` flag
- `boilerplate/apps/cli/go/core/files/config/config.go` — Add truncation_limit config field

## Acceptance Criteria

- [ ] Truncation function correctly truncates text to specified limit
- [ ] Truncation metadata includes total size and truncation indicator
- [ ] Help suggestions are generated only when content is actually truncated
- [ ] `--full` flag successfully disables truncation
- [ ] Truncation is applied to all large text fields
- [ ] Truncation works correctly for TOON output
- [ ] Truncation works correctly for JSON output
- [ ] Truncation is not applied when content is under limit
- [ ] Truncation works in both agent and human modes
- [ ] Configurable truncation limit is respected
- [ ] All truncation functionality has test coverage
- [ ] Help text documents truncation behavior and `--full` flag

## Test Plan

- Unit: `go test ./internal/truncation/...`
- Unit: `go test ./internal/output/...`
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

## Truncation Strategy Design

### Default Limits
- **Description fields**: 500 characters
- **Body fields**: 1000 characters
- **Log fields**: 1500 characters
- **Configurable**: All limits can be overridden via config file

### Truncation Behavior
- Smart truncation at word boundaries (when possible)
- Ellipsis indicator (`...`) appended to truncated content
- Metadata includes:
  - `truncated`: boolean flag
  - `original_length`: total character count
  - `truncated_length`: displayed character count
  - `truncation_limit`: the limit applied

### Escape Hatch
- `--full` flag disables all truncation
- Config option `disable_truncation` for permanent disable

### Help Suggestions
When content is truncated, append help text:
- For TOON format: Add `_truncated` metadata field
- For JSON format: Add `__truncated` top-level field
- For human format: Append `(truncated from N chars, use --full for complete content)`

### Field Types
Apply truncation to:
- `description` fields
- `body` fields
- `log` fields
- Any field > 200 characters (configurable threshold)

### Implementation Structure
```
internal/truncation/
  truncator.go       - Core truncation logic
  metadata.go        - Metadata generation
  types.go           - Truncation types and constants
  truncator_test.go  - Unit tests
```
