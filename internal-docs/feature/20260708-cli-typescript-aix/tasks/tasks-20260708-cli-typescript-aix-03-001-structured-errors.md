---
story_id: "03-001"
story_title: "Structured Errors and Exit Codes"
story_name: "structured-errors"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260708-cli-typescript-aix/story-03-001-structured-errors"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "02-004"]
parallel_safe: true
modules: ["errors", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "errors", "exit-codes"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement structured errors on stdout with actionable suggestions, idempotent mutations (no error when desired state already exists), and proper exit codes (0 = success including no-ops, 1 = error, 2 = usage error). Never let raw dependency output leak through.

## Sub-Tasks

- [ ] Implement structured error class — `src/errors/structured-error.mts`
- [ ] Implement error formatter for stdout — `src/errors/formatter.mts`
- [ ] Implement error translation logic — `src/errors/translator.mts`
- [ ] Add idempotent mutation detection — `src/errors/idempotency.mts`
- [ ] Implement exit code logic — `src/errors/exit-codes.mts`
- [ ] Validate required flags before calling dependencies — `src/cli/validator.mts`
- [ ] Integrate structured errors into all commands — `src/commands/*.mts`
- [ ] Add tests for structured errors — `tests/errors/structured-error.test.mts`
- [ ] Add tests for error translation — `tests/errors/translator.test.mts`
- [ ] Add tests for idempotent mutations — `tests/errors/idempotency.test.mts`
- [ ] Add tests for exit codes — `tests/errors/exit-codes.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/errors/structured-error.mts.jinja` — New file for structured error class
- `apps/cli/typescript/core/files/src/errors/formatter.mts.jinja` — New file for error formatter
- `apps/cli/typescript/core/files/src/errors/translator.mts.jinja` — New file for error translation
- `apps/cli/typescript/core/files/src/errors/idempotency.mts.jinja` — New file for idempotency detection
- `apps/cli/typescript/core/files/src/errors/exit-codes.mts.jinja` — New file for exit code logic
- `apps/cli/typescript/core/files/src/cli/validator.mts.jinja` — New file for flag validation
- `apps/cli/typescript/core/files/src/commands/base.mts.jinja` — Base command (updated with error handling)
- `apps/cli/typescript/core/files/tests/errors/structured-error.test.mts.jinja` — New file for error tests
- `apps/cli/typescript/core/files/tests/errors/translator.test.mts.jinja` — New file for translator tests
- `apps/cli/typescript/core/files/tests/errors/idempotency.test.mts.jinja` — New file for idempotency tests
- `apps/cli/typescript/core/files/tests/errors/exit-codes.test.mts.jinja` — New file for exit code tests

## Acceptance Criteria

- [ ] Errors go to stdout in same structured format as normal output
- [ ] Errors include what went wrong and actionable suggestion
- [ ] Example: `error: --title is required help: tasks create --title "..." [--body "..."]`
- [ ] Raw dependency output (API errors, stack traces) never leaks through
- [ ] Required flags validated before calling dependencies
- [ ] Errors translated to extract actionable meaning
- [ ] Dependency names never leaked in suggestions
- [ ] Idempotent mutations don't error when desired state exists
- [ ] Example: `task: #42 already closed (no-op) # exit 0`
- [ ] Exit codes: 0 = success (including no-ops), 1 = error, 2 = usage error
- [ ] All tests pass

## Test Plan

- Unit: Test structured error formatting
- Unit: Test error translation logic
- Unit: Test idempotent mutation detection
- Unit: Test exit code logic
- Integration: Test CLI error output
- Integration: Test idempotent operations
- Integration: Test exit codes for various scenarios
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log error events
- Log error translation
- Log idempotent operations

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Error translation may lose important information — Mitigation: Preserve actionable meaning, discard noise only
- Risk: Idempotent detection may be complex — Mitigation: Clear logic, comprehensive tests
- Risk: Exit codes may be inconsistent — Mitigation: Clear exit code policy, documentation

## Dependencies & Sequencing

- Depends on: 01-001 (Mode Selection), 02-004 (Empty States)
- Unblocks: 03-002 (No Interactive Prompts), 03-003 (Output Channels)

## Definition of Done

- Structured errors implemented
- Error translation implemented
- Idempotent mutations implemented
- Exit code logic implemented
- Flag validation implemented
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(errors): implement structured error class`
- `feat(errors): implement error formatter for stdout`
- `feat(errors): implement error translation logic`
- `feat(errors): add idempotent mutation detection`
- `feat(errors): implement exit code logic`
- `feat(cli): add required flag validation`
- `feat(commands): integrate structured errors into all commands`
- `test(errors): add tests for error system`
