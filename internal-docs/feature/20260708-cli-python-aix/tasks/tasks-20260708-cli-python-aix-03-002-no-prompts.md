---
story_id: "03-002"
story_title: "No Interactive Prompts"
story_name: "no-prompts"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260708-cli-python-aix/story-03-002-no-prompts"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["03-001"]
parallel_safe: true
modules: ["cli.py", "prompts.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "prompts", "agent-mode"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Ensure every operation is completable with flags alone. If required value is missing, fail immediately with clear error — don't prompt. Suppress prompts from wrapped tools in agent mode. Human mode can retain prompts (unless `--force` is used).

## Sub-Tasks

- [x] Add `--force` flag to CLI using click/typer — `cli/main.py`
- [x] Detect missing required values — `cli/validation.py`
- [x] Fail immediately with clear error for missing values — `cli/validation.py`
- [x] Suppress prompts in agent mode — `cli/prompts.py`
- [x] Retain prompts in human mode (unless --force) — `cli/prompts.py`
- [x] Suppress prompts from wrapped tools in agent mode — `cli/wrappers.py`
- [x] Ensure all operations completable with flags alone — `cli/validation.py`
- [x] Test missing value error handling — `tests/test_prompts.py`
- [x] Test prompt suppression in agent mode — `tests/test_prompts.py`
- [x] Test prompt retention in human mode — `tests/test_prompts.py`
- [x] Test --force flag behavior — `tests/test_prompts.py`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — CLI with --force flag (already exists)
- `apps/cli/python/core/files/{{project_slug}}/prompts.py.jinja` — Prompt suppression logic
- `apps/cli/python/core/files/tests/test_prompts.py.jinja` — Prompt tests

## Acceptance Criteria

- [x] Missing required values fail immediately with clear error
- [x] No prompts appear in agent mode
- [x] Prompts work in human mode (unless --force)
- [x] `--force` flag suppresses prompts in human mode
- [x] Prompts from wrapped tools suppressed in agent mode
- [x] All operations completable with flags alone
- [x] All tests pass

## Test Plan

- Unit: Test missing value error handling
- Unit: Test prompt suppression logic
- Unit: Test prompt retention logic
- Integration: Test actual CLI behavior in agent mode
- Integration: Test actual CLI behavior in human mode
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log prompt suppression events
- Log missing value errors
- Track --force flag usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Missing value error unclear — Mitigation: Clear error messages, suggest required flags
- Risk: Prompts leak in agent mode — Mitigation: Comprehensive suppression, test all paths
- Risk: --force flag too aggressive — Mitigation: Document clearly, use only for prompts

## Dependencies & Sequencing

- Depends on: 03-001 (Structured Errors)
- Unblocks: 03-003 (Idempotent Ops)

## Definition of Done

- Prompt suppression implemented
- Missing value errors clear
- All operations flag-completable
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(cli): add --force flag to suppress prompts`
- `feat(cli): suppress prompts in agent mode`
- `test(cli): add tests for prompt handling`
