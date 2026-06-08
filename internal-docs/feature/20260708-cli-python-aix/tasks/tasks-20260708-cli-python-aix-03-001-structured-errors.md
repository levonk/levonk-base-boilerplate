---
story_id: "03-001"
story_title: "Structured Errors & Exit Codes"
story_name: "structured-errors"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260708-cli-python-aix/story-03-001-structured-errors"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-004"]
parallel_safe: true
modules: ["errors.py", "output.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "errors", "exit-codes"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement structured errors on stdout with idempotent mutations. Errors go to stdout in same structured format as normal output. Include what went wrong and actionable suggestion. Never let raw dependency output leak through. Reserve non-zero exit codes for unsatisfiable intents.

## Sub-Tasks

- [ ] Implement idempotent mutation logic — `errors/idempotent.py`
- [ ] Don't error when desired state already exists — `errors/idempotent.py`
- [ ] Acknowledge no-ops with exit code 0 — `errors/idempotent.py`
- [ ] Implement structured error formatting on stdout — `errors/formatter.py`
- [ ] Include what went wrong in error output — `errors/formatter.py`
- [ ] Include actionable suggestion in error output — `errors/formatter.py`
- [ ] Validate required flags before calling dependencies — `errors/validation.py`
- [ ] Translate errors — extract actionable meaning — `errors/translator.py`
- [ ] Never leak dependency names in suggestions — `errors/translator.py`
- [ ] Never let raw dependency output leak through — `errors/translator.py`
- [ ] Reserve non-zero exit codes for unsatisfiable intents — `errors/exit_codes.py`
- [ ] Define exit codes: 0=success, 1=error, 2=usage — `errors/exit_codes.py`
- [ ] Test idempotent mutations — `tests/test_idempotent.py`
- [ ] Test structured error formatting — `tests/test_errors.py`
- [ ] Test error translation and sanitization — `tests/test_errors.py`
- [ ] Test exit code handling — `tests/test_exit_codes.py`

## Relevant Files

- `apps/cli/python/core/files/errors/idempotent.py.jinja` — Idempotent mutation logic
- `apps/cli/python/core/files/errors/formatter.py.jinja` — Structured error formatting
- `apps/cli/python/core/files/errors/validation.py.jinja` — Input validation
- `apps/cli/python/core/files/errors/translator.py.jinja` — Error translation
- `apps/cli/python/core/files/errors/exit_codes.py.jinja` — Exit code definitions
- `apps/cli/python/core/files/tests/test_idempotent.py.jinja` — Idempotent tests
- `apps/cli/python/core/files/tests/test_errors.py.jinja` — Error tests
- `apps/cli/python/core/files/tests/test_exit_codes.py.jinja` — Exit code tests

## Acceptance Criteria

- [ ] Idempotent mutations don't error when state exists
- [ ] No-ops acknowledged with exit code 0
- [ ] Errors go to stdout in structured format
- [ ] Errors include what went wrong
- [ ] Errors include actionable suggestion
- [ ] Required flags validated before dependencies
- [ ] Errors translated to actionable meaning
- [ ] Dependency names never leaked in suggestions
- [ ] Raw dependency output never leaks through
- [ ] Non-zero exit codes only for unsatisfiable intents
- [ ] Exit codes: 0=success, 1=error, 2=usage
- [ ] All tests pass

## Test Plan

- Unit: Test idempotent mutation logic
- Unit: Test structured error formatting
- Unit: Test error translation and sanitization
- Unit: Test exit code handling
- Integration: Test actual CLI error output
- Integration: Test actual CLI exit codes
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log error events
- Log error translation events
- Log exit code usage
- Track error frequency if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data in error messages

## Risks & Mitigations

- Risk: Error translation loses important context — Mitigation: Test thoroughly, preserve key info
- Risk: Dependency output leaks in edge cases — Mitigation: Comprehensive sanitization, test all paths
- Risk: Exit code confusion — Mitigation: Clear documentation, consistent usage

## Dependencies & Sequencing

- Depends on: 02-004 (Empty States)
- Unblocks: 03-002 (No Prompts), 03-003 (Idempotent Ops)

## Definition of Done

- Idempotent mutations implemented
- Structured errors on stdout
- Error translation and sanitization
- Exit code handling
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(errors): add idempotent mutation logic`
- `feat(errors): add structured error formatting`
- `feat(errors): add error translation and sanitization`
- `test(errors): add tests for error handling`
