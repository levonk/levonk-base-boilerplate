---
story_id: "03-003"
story_title: "Dry-Run and Confirmation Prompts"
story_name: "dry-run-confirm"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 3
parallel_id: 3
branch: "feature/current/cli-python-standards/story-03-003-dry-run-confirm"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["__main__.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "safety"]
due: "2026-07-19"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement dry-run mode to preview changes without execution, and confirmation prompts for destructive operations. Add `--dry-run` flag and `--force` flag to bypass prompts.

## Sub-Tasks

- [x] Add `--dry-run` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Add `--force` flag to bypass confirmation prompts — `__main__.py.jinja`
- [x] Implement dry-run logic to show what would be done without executing — `__main__.py.jinja`
- [x] Implement confirmation prompts for destructive operations (delete, overwrite) — `__main__.py.jinja`
- [x] Apply dry-run to all destructive operations — `__main__.py.jinja`
- [x] Add tests for dry-run mode — `apps/cli/python/core/files/tests/test_main.py.jinja`
- [x] Add tests for confirmation prompts — `tests/test_main.py.jinja`
- [x] Add tests for --force flag behavior — `tests/test_main.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add dry-run and force flags, implement prompts
- `apps/cli/python/core/files/tests/test_main.py.jinja` — Add tests for dry-run and confirmation

## Acceptance Criteria

- [x] `--dry-run` flag shows exactly what would be done without making changes
- [x] Dry-run applies to all destructive operations
- [x] Confirmation prompts required for destructive operations
- [x] `--force` flag bypasses confirmation prompts
- [x] Dry-run output is clear and actionable
- [x] All tests pass for dry-run and confirmation scenarios

## Test Plan

- Unit: `pytest tests/test_main.py::test_dry_run`
- Unit: `pytest tests/test_main.py::test_confirmation_prompts`
- Unit: `pytest tests/test_main.py::test_force_flag`
- Integration: Test dry-run with various destructive operations

## Observability

- Log dry-run executions for audit trail
- Track confirmation prompt acceptance rates

## Compliance

- Confirmation prompts prevent accidental data loss
- Dry-run does not expose sensitive information

## Risks & Mitigations

- Risk: Users may ignore dry-run output — Mitigation: Make dry-run output clear and prominent
- Risk: Confirmation prompts may be annoying for experienced users — Mitigation: Provide --force flag to bypass

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone safety feature)

## Definition of Done

- Dry-run mode implemented and working
- Confirmation prompts implemented for destructive operations
- Force flag implemented to bypass prompts
- Dry-run applies to all destructive operations
- Tests pass for all scenarios
- Documentation updated for dry-run and confirmation usage

## Commit Conventions

- `feat(cli): add --dry-run flag for preview mode`
- `feat(cli): add confirmation prompts for destructive operations`
- `feat(cli): add --force flag to bypass prompts`
- `test(cli): add tests for dry-run and confirmation`
