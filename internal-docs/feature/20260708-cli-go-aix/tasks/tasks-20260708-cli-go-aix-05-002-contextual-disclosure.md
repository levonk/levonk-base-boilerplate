---
story_id: "05-002"
story_title: "Contextual Disclosure"
story_name: "contextual-disclosure"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 5
parallel_id: 2
branch: "feature/current/20260708-cli-go-aix/story-05-002-contextual-disclosure"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002", "02-003"]
parallel_safe: false
modules: ["cli-commands", "suggestion-engine"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli-commands", "axi"]
due: "2026-06-19"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement contextual disclosure with next steps suggestions that follow logically from current output. Include 2-4 relevant, actionable suggestions per output. Format suggestions as structured `help[]` array in TOON output. This enables agents to discover CLI capabilities organically by using the tool.

## Sub-Tasks

- [ ] Design suggestion engine architecture
- [ ] Implement suggestion generation logic for each command
- [ ] Define suggestion rules based on current state and output
- [ ] Implement relevant suggestion ranking (context-aware)
- [ ] Generate suggestions for open items (suggest closing)
- [ ] Generate suggestions for empty lists (suggest creating)
- [ ] Generate suggestions for list views (suggest viewing)
- [ ] Ensure suggestions are actionable (complete commands)
- [ ] Ensure suggestions carry forward disambiguating flags
- [ ] Limit suggestions to 2-4 maximum per output
- [ ] Format suggestions as structured `help[]` array in TOON
- [ ] Integrate suggestions into all command outputs
- [ ] Make suggestions smart (context-aware, not generic)
- [ ] Write unit tests for suggestion generation logic
- [ ] Write unit tests for suggestion ranking
- [ ] Write integration tests for suggestion output
- [ ] Write tests for suggestion context awareness
- [ ] Update CLI help text to document suggestion behavior

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/suggestions/engine.go` — Suggestion engine logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/suggestions/engine_test.go` — Tests for suggestion engine (new file)
- `boilerplate/apps/cli/go/core/files/internal/suggestions/rules.go` — Suggestion rules per command (new file)
- `boilerplate/apps/cli/go/core/files/internal/suggestions/rules_test.go` — Tests for suggestion rules (new file)
- `boilerplate/apps/cli/go/core/files/internal/output/formatter.go` — Integrate suggestions into output
- `boilerplate/apps/cli/go/core/files/internal/output/formatter_test.go` — Tests for suggestion integration
- `boilerplate/apps/cli/go/core/files/cli/commands/*.go` — Define suggestion rules for each command
- `boilerplate/apps/cli/go/core/files/cli/commands/*_test.go` — Update tests for suggestions

## Acceptance Criteria

- [ ] Suggestion engine generates relevant suggestions for each command
- [ ] Suggestions are context-aware based on current state
- [ ] Suggestions are actionable (complete commands)
- [ ] Suggestions carry forward disambiguating flags
- [ ] Suggestions are limited to 2-4 maximum per output
- [ ] Suggestions are ranked by relevance
- [ ] Suggestions are formatted as structured `help[]` array in TOON
- [ ] Suggestions are integrated into all command outputs
- [ ] Suggestions are smart (not generic)
- [ ] All suggestion functionality has test coverage
- [ ] Help text documents suggestion behavior

## Test Plan

- Unit: `go test ./internal/suggestions/...`
- Unit: `go test ./internal/output/...`
- Integration: Test suggestion output for all commands
- Manual: Verify suggestion relevance in various contexts

## Observability

- Add logging for suggestion generation decisions at debug level
- Add metrics for suggestion frequency and patterns

## Compliance

- Ensure suggestions don't leak sensitive information
- Validate that suggestions don't bypass security controls

## Risks & Mitigations

- Risk: Suggestions may not be relevant for all contexts — Mitigation: Context-aware rules, fallback to generic suggestions
- Risk: Suggestions may be too generic — Mitigation: Continuous improvement based on usage patterns

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- Requires: TOON format (01-002) for suggestion formatting
- Requires: Pre-computed aggregates (02-003) for context awareness
- Cannot be developed in parallel with 05-001 (depends on same modules)

## Notes

- Suggestion rules should be easily extensible for new commands
- Document suggestion patterns for consistency
- Consider adding A/B testing for suggestion effectiveness
