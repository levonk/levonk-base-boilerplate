---
story_id: "01-003"
story_title: "Signal Handling and Exit Codes"
story_name: "signal-handling"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 1
parallel_id: 3
branch: "feature/current/cli-python-standards/story-01-003-signal-handling"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["__main__.py", "logging.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "signals"]
due: "2026-07-15"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Enhance signal handling and implement standard exit codes. Maintain existing SIGINT handling with exit code 130, and add specific exit codes for different error types (0 success, 1 generic error, 2 usage error, plus specific codes for network, validation, file not found, permission denied).

## Sub-Tasks

- [x] Define exit code constants in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Implement exit code 0 for success — `__main__.py.jinja`
- [x] Implement exit code 1 for generic errors — `__main__.py.jinja`
- [x] Implement exit code 2 for usage errors — `__main__.py.jinja`
- [x] Implement exit code 3 for network errors — `__main__.py.jinja`
- [x] Implement exit code 4 for validation errors — `__main__.py.jinja`
- [x] Implement exit code 5 for file not found errors — `__main__.py.jinja`
- [x] Implement exit code 6 for permission denied errors — `__main__.py.jinja`
- [x] Ensure existing SIGINT handling with exit code 130 is maintained — `__main__.py.jinja`
- [x] Add exit code usage throughout error handling — `__main__.py.jinja`
- [x] Add tests for all exit code scenarios — `apps/cli/python/core/files/tests/test_main.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Main CLI entry point, add exit code constants and usage
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` — May need updates for exit code logging
- `apps/cli/python/core/files/tests/test_main.py.jinja` — Add tests for exit code scenarios

## Acceptance Criteria

- [x] Exit code 0 returned on successful execution
- [x] Exit code 1 returned for generic errors
- [x] Exit code 2 returned for usage errors
- [x] Exit code 3 returned for network errors
- [x] Exit code 4 returned for validation errors
- [x] Exit code 5 returned for file not found errors
- [x] Exit code 6 returned for permission denied errors
- [x] Exit code 130 returned on SIGINT (user abort)
- [x] All exit codes tested and documented

## Test Plan

- Unit: `pytest tests/test_main.py::test_exit_codes`
- Unit: `pytest tests/test_main.py::test_sigint_exit_code`
- Integration: Test exit codes in various error scenarios

## Observability

- Log exit codes for debugging and monitoring
- Track exit code distribution in analytics

## Compliance

- Exit codes follow standard Unix conventions
- Sensitive information not exposed in exit code context

## Risks & Mitigations

- Risk: Exit code conflicts with existing codes — Mitigation: Use standard codes, document any custom codes
- Risk: Exit codes may not be consistent across all error paths — Mitigation: Create helper function for consistent exit code usage

## Dependencies & Sequencing

- Depends on: None (foundation story)
- Unblocks: 02-003 (Error Formatting), 04-003 (Logging Modes Enhancement)

## Definition of Done

- All standard exit codes implemented and used consistently
- SIGINT handling maintained with exit code 130
- Exit codes tested for all error scenarios
- Exit code constants documented
- Helper function for consistent exit code usage

## Commit Conventions

- `feat(cli): add standard exit codes for different error types`
- `feat(cli): maintain SIGINT handling with exit code 130`
- `test(cli): add tests for all exit code scenarios`
