---
story_id: "05-002"
story_title: "Contextual Disclosure with Next Steps"
story_name: "contextual-disclosure"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 5
parallel_id: 2
branch: "feature/current/20260708-cli-typescript-aix/story-05-002-contextual-disclosure"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["05-001"]
parallel_safe: false
modules: ["suggestions", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "suggestions", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement contextual disclosure with next steps suggestions. Include few next steps that follow logically from current output, formatted as structured `help[]` array in TOON. Agent discovers CLI surface area organically by using it.

## Sub-Tasks

- [ ] Implement suggestion engine for each command — `src/suggestions/engine.mts`
- [ ] Implement context-aware suggestion logic — `src/suggestions/context-aware.mts`
- [ ] Implement next step generation based on current state — `src/suggestions/next-steps.mts`
- [ ] Format suggestions as structured `help[]` array in TOON — `src/suggestions/toon-formatter.mts`
- [ ] Integrate suggestions into all command outputs — `src/commands/*.mts`
- [ ] Add tests for suggestion engine — `tests/suggestions/engine.test.mts`
- [ ] Add tests for context-aware suggestions — `tests/suggestions/context-aware.test.mts`
- [ ] Add integration tests for suggestion output — `tests/suggestions/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/suggestions/engine.mts.jinja` — New file for suggestion engine
- `apps/cli/typescript/core/files/src/suggestions/context-aware.mts.jinja` — New file for context-aware logic
- `apps/cli/typescript/core/files/src/suggestions/next-steps.mts.jinja` — New file for next step generation
- `apps/cli/typescript/core/files/src/suggestions/toon-formatter.mts.jinja` — New file for TOON formatting
- `apps/cli/typescript/core/files/src/commands/*.mts.jinja` — All commands (updated with suggestions)
- `apps/cli/typescript/core/files/tests/suggestions/engine.test.mts.jinja` — New file for engine tests
- `apps/cli/typescript/core/files/tests/suggestions/context-aware.test.mts.jinja` — New file for context-aware tests
- `apps/cli/typescript/core/files/tests/suggestions/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Next steps suggestions included in all command outputs
- [ ] Suggestions follow logically from current output
- [ ] Suggestions are relevant (after open item → suggest closing; after empty list → suggest creating; after list → suggest viewing)
- [ ] Suggestions are actionable (every suggestion is complete command with disambiguating flags)
- [ ] Suggestions are concise (2-4 suggestions maximum, ranked by relevance)
- [ ] Suggestions formatted as structured `help[]` array in TOON
- [ ] Suggestions are smart (context-aware, not generic)
- [ ] Agent discovers CLI surface area organically by using it
- [ ] All tests pass

## Test Plan

- Unit: Test suggestion engine logic
- Unit: Test context-aware suggestion generation
- Unit: Test next step generation
- Integration: Test suggestion output in various commands
- Integration: Test suggestion relevance in different contexts
- Integration: Test TOON formatting of suggestions
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log suggestion generation
- Log suggestion relevance scoring

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Suggestions may be irrelevant — Mitigation: Context-aware logic, relevance scoring
- Risk: Suggestions may be too many — Mitigation: Limit to 2-4, rank by relevance
- Risk: Suggestions may be generic — Mitigation: Context-aware generation, not hardcoded

## Dependencies & Sequencing

- Depends on: 05-001 (Content First)
- Unblocks: None (final story)

## Definition of Done

- Suggestion engine implemented
- Context-aware suggestions implemented
- Next step generation implemented
- TOON formatting implemented
- Suggestions integrated into all commands
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(suggestions): implement suggestion engine`
- `feat(suggestions): add context-aware suggestion logic`
- `feat(suggestions): implement next step generation`
- `feat(suggestions): format suggestions as help[] array in TOON`
- `feat(commands): integrate suggestions into all command outputs`
- `test(suggestions): add tests for suggestion system`
