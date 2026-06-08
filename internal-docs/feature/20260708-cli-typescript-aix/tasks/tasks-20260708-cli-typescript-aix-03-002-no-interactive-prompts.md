---
story_id: "03-002"
story_title: "No Interactive Prompts"
story_name: "no-interactive-prompts"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260708-cli-typescript-aix/story-03-002-no-interactive-prompts"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "03-001"]
parallel_safe: true
modules: ["cli", "prompts"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "prompts", "cli"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Ensure every operation is completable with flags alone. Suppress prompts in agent mode, fail immediately with clear error when required value is missing. Human mode can retain prompts unless `--force` is used.

## Sub-Tasks

- [ ] Audit all commands for interactive prompts — `src/commands/*.mts`
- [ ] Add `--force` flag to suppress prompts in human mode — `src/cli/flags.mts`
- [ ] Implement prompt suppression in agent mode — `src/prompts/suppressor.mts`
- [ ] Add required value validation before prompting — `src/cli/validator.mts`
- [ ] Replace prompts with clear error messages — `src/prompts/error-handler.mts`
- [ ] Add `--yes` / `--no` flags for binary prompts — `src/cli/flags.mts`
- [ ] Suppress prompts from wrapped tools in agent mode — `src/prompts/wrapper-suppressor.mts`
- [ ] Add tests for prompt suppression — `tests/prompts/suppressor.test.mts`
- [ ] Add tests for required value validation — `tests/cli/validator.test.mts`
- [ ] Add integration tests for flag-only operations — `tests/prompts/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/cli/flags.mts.jinja` — CLI flags (updated with --force, --yes, --no)
- `apps/cli/typescript/core/files/src/prompts/suppressor.mts.jinja` — New file for prompt suppression
- `apps/cli/typescript/core/files/src/prompts/error-handler.mts.jinja` — New file for prompt error handling
- `apps/cli/typescript/core/files/src/prompts/wrapper-suppressor.mts.jinja` — New file for wrapper prompt suppression
- `apps/cli/typescript/core/files/src/cli/validator.mts.jinja` — Flag validator (updated)
- `apps/cli/typescript/core/files/src/commands/*.mts.jinja` — All commands (updated to remove prompts)
- `apps/cli/typescript/core/files/tests/prompts/suppressor.test.mts.jinja` — New file for suppressor tests
- `apps/cli/typescript/core/files/tests/cli/validator.test.mts.jinja` — Validator tests (updated)
- `apps/cli/typescript/core/files/tests/prompts/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Every operation is completable with flags alone
- [ ] Required value missing fails immediately with clear error
- [ ] No prompts in agent mode
- [ ] Human mode retains prompts unless `--force` is used
- [ ] `--yes` / `--no` flags work for binary prompts
- [ ] Prompts from wrapped tools suppressed in agent mode
- [ ] Error messages include actionable suggestions
- [ ] All tests pass

## Test Plan

- Unit: Test prompt suppression logic
- Unit: Test required value validation
- Integration: Test CLI operations with flags only
- Integration: Test CLI operations with missing required values
- Integration: Test prompt suppression in agent mode
- Integration: Test `--force` flag in human mode
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log prompt suppression events
- Log required value validation failures

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Removing prompts may degrade human UX — Mitigation: Keep prompts in human mode, add `--force` flag
- Risk: Required value validation may be incomplete — Mitigation: Comprehensive audit of all commands
- Risk: Wrapper prompt suppression may not work for all tools — Mitigation: Test with common wrapped tools

## Dependencies & Sequencing

- Depends on: 01-001 (Mode Selection), 03-001 (Structured Errors)
- Unblocks: 03-003 (Output Channels)

## Definition of Done

- All commands audited for prompts
- Prompt suppression implemented
- Required value validation implemented
- `--force`, `--yes`, `--no` flags added
- Wrapper prompt suppression implemented
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(cli): add --force flag to suppress prompts`
- `feat(cli): add --yes/--no flags for binary prompts`
- `feat(prompts): implement prompt suppression in agent mode`
- `feat(prompts): add required value validation`
- `feat(prompts): suppress prompts from wrapped tools`
- `refactor(commands): remove interactive prompts from commands`
- `test(prompts): add tests for prompt suppression`
