---
story_id: "02-002"
story_title: "Content Truncation"
story_name: "content-truncation"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260708-cli-go-aix/story-02-002-content-truncation"
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

- [ ] Design truncation strategy and configurable limits
- [ ] Implement truncation function for text fields
- [ ] Add truncation metadata generation (total size, truncation indicator)
- [ ] Add help suggestion generation for truncated content
- [ ] Add `--full` flag to CLI argument parser
- [ ] Implement truncation logic for all large text fields
- [ ] Apply truncation to description fields
- [ ] Apply truncation to body fields
- [ ] Apply truncation to log fields
- [ ] Integrate truncation into TOON output formatting
- [ ] Integrate truncation into JSON output formatting
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
