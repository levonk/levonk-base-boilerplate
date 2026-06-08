---
story_id: "05-001"
story_title: "Content-First No-Args Output"
story_name: "content-first"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 5
parallel_id: 1
branch: "feature/current/20260708-cli-typescript-aix/story-05-001-content-first"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002", "02-001", "02-003", "04-001"]
parallel_safe: false
modules: ["cli", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement content-first no-args behavior where running CLI with no arguments shows most relevant live content, not usage manual. When agent sees actual state, it can act immediately. Show different content based on current directory/context.

## Sub-Tasks

- [ ] Implement no-args state summary generator — `src/cli/no-args-generator.mts`
- [ ] Implement context-aware content selection — `src/cli/context-selector.mts`
- [ ] Update main CLI entry point for no-args behavior — `src/index.mts`
- [ ] Move detailed help to `--help` flag only — `src/cli/help.mts`
- [ ] Implement directory-scoped content display — `src/cli/directory-scoper.mts`
- [ ] Add tests for no-args state summary — `tests/cli/no-args-generator.test.mts`
- [ ] Add tests for context-aware selection — `tests/cli/context-selector.test.mts`
- [ ] Add integration tests for no-args behavior — `tests/cli/no-args-integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/cli/no-args-generator.mts.jinja` — New file for no-args generation
- `apps/cli/typescript/core/files/src/cli/context-selector.mts.jinja` — New file for context selection
- `apps/cli/typescript/core/files/src/cli/directory-scoper.mts.jinja` — New file for directory scoping
- `apps/cli/typescript/core/files/src/index.mts.jinja` — Main entry point (updated for no-args)
- `apps/cli/typescript/core/files/src/cli/help.mts.jinja` — Help system (updated)
- `apps/cli/typescript/core/files/tests/cli/no-args-generator.test.mts.jinja` — New file for generator tests
- `apps/cli/typescript/core/files/tests/cli/context-selector.test.mts.jinja` — New file for selector tests
- `apps/cli/typescript/core/files/tests/cli/no-args-integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Running CLI with no arguments shows most relevant live content
- [ ] No-args output shows state summary, not usage manual
- [ ] Example output: `tasks[3]{id,title,status}: 1,Fix bug,open 2,Add feature,open 3,Update docs,closed help[2]: Run mytool view <id> for details Run mytool create --title "..." to add a task`
- [ ] Different content shown based on current directory/context
- [ ] Directory-scoped content display (relevant to current working directory)
- [ ] Detailed help moved to `--help` flag only
- [ ] Content-first applies to both agent and human modes
- [ ] All tests pass

## Test Plan

- Unit: Test no-args state summary generation
- Unit: Test context-aware content selection
- Unit: Test directory scoping logic
- Integration: Test CLI no-args behavior
- Integration: Test no-args output in different directories
- Integration: Test `--help` flag still shows detailed help
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log no-args invocation
- Log context selection
- Log directory scoping

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: No-args output may be confusing for human users — Mitigation: Clear help suggestions, keep `--help` available
- Risk: Context selection may be inaccurate — Mitigation: Robust context detection logic
- Risk: Directory scoping may miss relevant content — Mitigation: Comprehensive scoping logic

## Dependencies & Sequencing

- Depends on: 01-001 (Mode Selection), 01-002 (TOON Format), 02-001 (Minimal Schemas), 02-003 (Aggregates), 04-001 (Session Hooks)
- Unblocks: 05-002 (Contextual Disclosure)

## Definition of Done

- No-args state summary implemented
- Context-aware selection implemented
- Directory scoping implemented
- Main entry point updated
- Help system updated
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(cli): implement content-first no-args behavior`
- `feat(cli): add context-aware content selection`
- `feat(cli): implement directory-scoped content display`
- `refactor(cli): move detailed help to --help flag only`
- `test(cli): add tests for no-args behavior`
