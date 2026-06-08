---
story_id: "05-001"
story_title: "Content-First No-Args Behavior"
story_name: "content-first"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 5
parallel_id: 1
branch: "feature/current/20260708-cli-go-aix/story-05-001-content-first"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002", "02-003"]
parallel_safe: false
modules: ["cli-commands", "output-formats"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli-commands", "axi"]
due: "2026-06-19"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement content-first no-args behavior where running the CLI with no arguments shows the most relevant live content, not a usage manual. This enables agents to see actual state immediately and act without a second call. Detailed help remains available via `--help` flag.

## Sub-Tasks

- [ ] Design content-first output strategy for no-args invocation
- [ ] Implement state summary generation for no-args
- [ ] Identify most relevant live content for each CLI context
- [ ] Implement context-aware content selection (directory-based)
- [ ] Update root command to show state summary instead of help
- [ ] Keep detailed help available via `--help` flag (unchanged)
- [ ] Integrate pre-computed aggregates into no-args output
- [ ] Integrate contextual help suggestions into no-args output
- [ ] Apply content-first behavior to both agent and human modes
- [ ] Ensure no-args output uses TOON format in agent mode
- [ ] Ensure no-args output uses human-readable format in human mode
- [ ] Write unit tests for content selection logic
- [ ] Write unit tests for state summary generation
- [ ] Write integration tests for no-args behavior
- [ ] Write tests for context-aware content selection
- [ ] Update CLI help text to document no-args behavior

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/content/selector.go` — Content selection logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/content/selector_test.go` — Tests for content selection (new file)
- `boilerplate/apps/cli/go/core/files/internal/content/summary.go` — State summary generation (new file)
- `boilerplate/apps/cli/go/core/files/internal/content/summary_test.go` — Tests for state summary (new file)
- `boilerplate/apps/cli/go/core/files/cli/root.go` — Update no-args behavior
- `boilerplate/apps/cli/go/core/files/cli/root_test.go` — Tests for no-args behavior

## Acceptance Criteria

- [ ] No-args invocation shows relevant live content
- [ ] No-args invocation does not show usage manual
- [ ] State summary includes most relevant information
- [ ] Content selection is context-aware (directory-based)
- [ ] Detailed help remains available via `--help` flag
- [ ] Pre-computed aggregates are included in no-args output
- [ ] Contextual help suggestions are included in no-args output
- [ ] Content-first behavior works in agent mode
- [ ] Content-first behavior works in human mode
- [ ] No-args output uses correct format for each mode
- [ ] All content-first functionality has test coverage
- [ ] Help text documents no-args behavior

## Test Plan

- Unit: `go test ./internal/content/...`
- Integration: Test no-args behavior in different contexts
- Manual: Verify no-args output shows relevant state
- Manual: Test `--help` flag still shows detailed help

## Observability

- Add logging for content selection decisions at debug level
- Add metrics for no-args invocation patterns

## Compliance

- Ensure no-args output doesn't leak sensitive information
- Validate that content selection doesn't bypass security controls

## Risks & Mitigations

- Risk: Content selection may not be relevant for all contexts — Mitigation: Provide sensible defaults, allow customization
- Risk: No-args behavior may confuse existing users — Mitigation: Clear documentation, `--help` flag still available

## Dependencies

- Requires: Mode selection (01-001) for mode-aware output
- Requires: TOON format (01-002) for agent mode output
- Requires: Pre-computed aggregates (02-003) for state summary
- Cannot be developed in parallel with 05-002 (depends on same modules)

## Notes

- Content selection should be optimized for common use cases
- Document what content is shown in different contexts
- Consider adding customization options for no-args behavior
