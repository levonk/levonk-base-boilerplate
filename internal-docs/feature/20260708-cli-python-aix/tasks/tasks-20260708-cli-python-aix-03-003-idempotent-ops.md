---
story_id: "03-003"
story_title: "Idempotent Operations"
story_name: "idempotent-ops"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260708-cli-python-aix/story-03-003-idempotent-ops"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["03-001", "03-002"]
parallel_safe: true
modules: ["operations.py", "idempotent.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "idempotent", "operations"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Ensure all mutation operations are idempotent. Repeating commands should not cause errors when desired state already exists. Acknowledge no-ops with exit code 0. Reserve non-zero exit codes for situations where agent's intent cannot be satisfied.

## Sub-Tasks

- [x] Identify all mutation operations (create, update, delete) — `operations/registry.py`
- [x] Implement idempotent check for each mutation — `operations/idempotent.py`
- [x] Check if desired state already exists before mutation — `operations/idempotent.py`
- [x] Acknowledge no-ops with clear message — `operations/idempotent.py`
- [x] Return exit code 0 for no-ops — `operations/idempotent.py`
- [x] Only execute mutation when state change needed — `operations/idempotent.py`
- [x] Test idempotent create operations — `tests/test_idempotent.py`
- [x] Test idempotent update operations — `tests/test_idempotent.py`
- [x] Test idempotent delete operations — `tests/test_idempotent.py`
- [x] Test no-op acknowledgment messages — `tests/test_idempotent.py`
- [x] Test exit code 0 for no-ops — `tests/test_idempotent.py`

## Relevant Files

- `apps/cli/python/core/files/operations/registry.py.jinja` — Operation registry
- `apps/cli/python/core/files/operations/idempotent.py.jinja` — Idempotent logic
- `apps/cli/python/core/files/tests/test_idempotent.py.jinja` — Idempotent tests

## Acceptance Criteria

- [x] All mutation operations are idempotent
- [x] Desired state checked before mutation
- [x] No-ops acknowledged with clear message
- [x] Exit code 0 for no-ops
- [x] Mutation only executed when state change needed
- [x] Repeating commands doesn't cause errors
- [x] All tests pass

## Test Plan

- Unit: Test idempotent create operations
- Unit: Test idempotent update operations
- Unit: Test idempotent delete operations
- Integration: Test actual CLI idempotent behavior
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log idempotent check events
- Log no-op acknowledgments
- Track idempotent operation frequency if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Idempotent check too expensive — Mitigation: Optimize checks, cache if needed
- Risk: No-op message unclear — Mitigation: Clear format, consistent across operations
- Risk: State check race conditions — Mitigation: Use atomic operations where possible

## Dependencies & Sequencing

- Depends on: 03-001 (Structured Errors), 03-002 (No Prompts)
- Unblocks: 04-001 (Session Hooks)

## Definition of Done

- All mutation operations idempotent
- No-op acknowledgments clear
- Exit code 0 for no-ops
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(operations): add idempotent operation logic`
- `test(operations): add tests for idempotent operations`
