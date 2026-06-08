---
story_id: "02-004"
story_title: "Definitive Empty States"
story_name: "empty-states"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260708-cli-python-aix/story-02-004-empty-states"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["output.py", "empty.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "empty-states", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement definitive empty states for all commands. When answer is "nothing", state the zero with context. Make clear command succeeded — absence of results is the answer. Ensure exit code 0 for successful empty queries.

## Sub-Tasks

- [ ] Implement empty result detection across all commands — `output/empty.py`
- [ ] Format empty states consistently — `output/empty.py`
- [ ] Include context in empty states (filter criteria, scope) — `output/empty.py`
- [ ] State the zero explicitly (e.g., "0 closed tasks found") — `output/empty.py`
- [ ] Ensure exit code 0 for successful empty queries — `output/empty.py`
- [ ] Make clear command succeeded — `output/empty.py`
- [ ] Apply empty state formatting to all commands — `output/empty.py`
- [ ] Test empty state detection for all commands — `tests/test_empty.py`
- [ ] Test empty state formatting — `tests/test_empty.py`
- [ ] Test exit code 0 for empty queries — `tests/test_empty.py`

## Relevant Files

- `apps/cli/python/core/files/output/empty.py.jinja` — Empty state detection and formatting
- `apps/cli/python/core/files/tests/test_empty.py.jinja` — Empty state tests

## Acceptance Criteria

- [ ] Empty result sets are detected across all commands
- [ ] Empty states are formatted consistently
- [ ] Empty states include context (filter criteria, scope)
- [ ] Zero is stated explicitly
- [ ] Exit code 0 for successful empty queries
- [ ] Command success is clear
- [ ] Empty state formatting applies to all commands
- [ ] All tests pass

## Test Plan

- Unit: Test empty state detection for all commands
- Unit: Test empty state formatting
- Unit: Test exit code handling for empty queries
- Integration: Test actual CLI output with empty results
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log empty state detection events
- Log empty state formatting events
- Track empty query frequency if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Empty state context confusing — Mitigation: Clear format, include relevant filters
- Risk: Exit code 0 mistaken for error — Mitigation: Clear message, consistent format
- Risk: Empty state detection false positives — Mitigation: Test thoroughly, handle edge cases

## Dependencies & Sequencing

- Depends on: 02-001 (Minimal Schemas)
- Unblocks: 03-001 (Structured Errors)

## Definition of Done

- Empty state detection implemented
- Empty state formatting consistent
- Context included in empty states
- Exit code 0 for empty queries
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add definitive empty states`
- `test(output): add tests for empty states`
