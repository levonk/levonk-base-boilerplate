---
story_id: "05-002"
story_title: "Contextual Disclosure with Next Steps"
story_name: "contextual-disclosure"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 5
parallel_id: 2
branch: "feature/current/20260708-cli-python-aix/story-05-002-contextual-disclosure"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["05-001"]
parallel_safe: false
modules: ["output.py", "suggestions.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "suggestions", "ux"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement contextual disclosure with next steps suggestions. Include few next steps that follow logically from current output. Agent discovers CLI surface area organically. Suggestions are relevant, actionable, concise, and structured as `help[]` array in TOON.

## Sub-Tasks

- [ ] Implement suggestion engine for each command — `output/suggestions.py`
- [ ] Generate contextual help based on current state — `output/suggestions.py`
- [ ] Generate contextual help based on output — `output/suggestions.py`
- [ ] Format suggestions as structured `help[]` array in TOON — `output/toon.py`
- [ ] Include 2-4 suggestions maximum — `output/suggestions.py`
- [ ] Rank suggestions by relevance — `output/suggestions.py`
- [ ] Make suggestions context-aware (not generic) — `output/suggestions.py`
- [ ] Ensure every suggestion is complete command — `output/suggestions.py`
- [ ] Include disambiguating flags in suggestions — `output/suggestions.py`
- [ ] Add suggestion logic for after open item → suggest closing — `output/suggestions.py`
- [ ] Add suggestion logic for after empty list → suggest creating — `output/suggestions.py`
- [ ] Add suggestion logic for after list → suggest viewing — `output/suggestions.py`
- [ ] Test suggestion generation for all commands — `tests/test_suggestions.py`
- [ ] Test suggestion relevance ranking — `tests/test_suggestions.py`
- [ ] Test suggestion formatting in TOON — `tests/test_suggestions.py`

## Relevant Files

- `apps/cli/python/core/files/output/suggestions.py.jinja` — Suggestion engine
- `apps/cli/python/core/files/output/toon.py.jinja` — TOON with help[] array
- `apps/cli/python/core/files/tests/test_suggestions.py.jinja` — Suggestion tests

## Acceptance Criteria

- [ ] Next steps included in output
- [ ] Suggestions follow logically from current output
- [ ] Suggestions are relevant (context-aware)
- [ ] Suggestions are actionable (complete commands)
- [ ] Suggestions are concise (2-4 maximum)
- [ ] Suggestions ranked by relevance
- [ ] Suggestions formatted as `help[]` array in TOON
- [ ] Suggestions include disambiguating flags
- [ ] Specific suggestion logic for common scenarios
- [ ] All tests pass

## Test Plan

- Unit: Test suggestion generation logic
- Unit: Test suggestion relevance ranking
- Unit: Test suggestion formatting
- Integration: Test actual CLI output with suggestions
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log suggestion generation events
- Log suggestion ranking events
- Track suggestion usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data in suggestions

## Risks & Mitigations

- Risk: Suggestions not relevant — Mitigation: Context-aware logic, test with real scenarios
- Risk: Suggestions too generic — Mitigation: Command-specific logic, ranking algorithm
- Risk: Suggestions too many — Mitigation: Limit to 2-4, rank by relevance

## Dependencies & Sequencing

- Depends on: 05-001 (Content First)
- Unblocks: None (final story)

## Definition of Done

- Suggestion engine implemented
- Contextual suggestions included
- Suggestions relevant and actionable
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add contextual disclosure with next steps`
- `test(output): add tests for suggestion engine`
