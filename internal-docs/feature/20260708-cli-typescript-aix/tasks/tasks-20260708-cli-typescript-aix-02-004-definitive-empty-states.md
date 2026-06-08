---
story_id: "02-004"
story_title: "Definitive Empty States"
story_name: "definitive-empty-states"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260708-cli-typescript-aix/story-02-004-definitive-empty-states"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-001", "02-003"]
parallel_safe: true
modules: ["output", "commands"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "output", "empty-states"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement definitive empty states that explicitly state when a query has no results, include context (filter criteria, scope), and ensure exit code 0 for successful empty queries. Make clear that command succeeded—absence of results is the answer.

## Sub-Tasks

- [ ] Implement empty state detection logic — `src/output/empty-detector.mts`
- [ ] Implement empty state formatting — `src/output/empty-formatter.mts`
- [ ] Add context extraction for empty states — `src/output/context-extractor.mts`
- [ ] Integrate empty state formatting into all commands — `src/commands/*.mts`
- [ ] Ensure exit code 0 for successful empty queries — `src/commands/base.mts`
- [ ] Add tests for empty state detection — `tests/output/empty-detector.test.mts`
- [ ] Add tests for empty state formatting — `tests/output/empty-formatter.test.mts`
- [ ] Add integration tests for empty state output — `tests/output/empty-integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/output/empty-detector.mts.jinja` — New file for empty state detection
- `apps/cli/typescript/core/files/src/output/empty-formatter.mts.jinja` — New file for empty state formatting
- `apps/cli/typescript/core/files/src/output/context-extractor.mts.jinja` — New file for context extraction
- `apps/cli/typescript/core/files/src/commands/base.mts.jinja` — Base command (updated with exit code logic)
- `apps/cli/typescript/core/files/src/commands/list.mts.jinja` — List command (updated with empty states)
- `apps/cli/typescript/core/files/src/commands/view.mts.jinja` — View command (updated with empty states)
- `apps/cli/typescript/core/files/tests/output/empty-detector.test.mts.jinja` — New file for detector tests
- `apps/cli/typescript/core/files/tests/output/empty-formatter.test.mts.jinja` — New file for formatter tests
- `apps/cli/typescript/core/files/tests/output/empty-integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Empty result sets are detected across all commands
- [ ] Empty states are formatted consistently
- [ ] Empty states explicitly state "nothing" with context
- [ ] Empty states include filter criteria and scope
- [ ] Example: `tasks: 0 closed tasks found in this repository`
- [ ] Exit code 0 for successful empty queries
- [ ] Empty states make clear command succeeded
- [ ] All tests pass

## Test Plan

- Unit: Test empty state detection logic
- Unit: Test empty state formatting
- Unit: Test context extraction
- Integration: Test CLI output with empty results
- Integration: Test exit code for empty queries
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log empty state detection
- Log context extraction

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Empty state formatting may be inconsistent — Mitigation: Use centralized formatter
- Risk: Context extraction may miss important information — Mitigation: Comprehensive context extraction logic
- Risk: Exit code 0 for empty queries may be confusing — Mitigation: Clear empty state message

## Dependencies & Sequencing

- Depends on: 02-001 (Minimal Schemas), 02-003 (Aggregates)
- Unblocks: 03-001 (Structured Errors)

## Definition of Done

- Empty state detection implemented
- Empty state formatting implemented
- Context extraction implemented
- Empty states integrated into all commands
- Exit code 0 for successful empty queries
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(output): implement empty state detection`
- `feat(output): implement empty state formatting`
- `feat(output): add context extraction for empty states`
- `feat(commands): integrate empty states into all commands`
- `feat(commands): ensure exit code 0 for successful empty queries`
- `test(output): add tests for empty state system`
