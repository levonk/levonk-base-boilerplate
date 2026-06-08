---
story_id: "04-003"
story_title: "Logging Modes Enhancement"
story_name: "logging-modes"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 4
parallel_id: 3
branch: "feature/current/cli-python-standards/story-04-003-logging-modes"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-003"]
parallel_safe: true
modules: ["logging.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "logging"]
due: "2026-07-22"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Enhance logging modes to ensure `--quiet` suppresses all non-essential output including progress indicators. Maintain existing `--verbose` and `--quiet` flags, and ensure proper integration with exit codes. Note: Structured logging is now covered by story 06-001.

## Sub-Tasks

- [x] Ensure `--quiet` suppresses all non-essential output including progress indicators — `logging.py.jinja`
- [x] Integrate logging with exit codes from signal handling — `logging.py.jinja`
- [x] Add log level filtering for different verbosity levels — `logging.py.jinja`
- [x] Add timestamp and module information to logs — `logging.py.jinja`
- [x] Add tests for quiet mode suppression of progress indicators — `apps/cli/python/core/files/tests/test_logging.py.jinja`
- [x] Add tests for logging integration with exit codes — `tests/test_logging.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` — Add structured logging and quiet mode enhancements
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --log-format flag
- `apps/cli/python/core/files/tests/test_logging.py.jinja` — Add tests for logging enhancements

## Acceptance Criteria

- [x] `--quiet` suppresses all non-essential output including progress indicators
- [x] Log level filtering works for different verbosity levels
- [x] Logs include timestamp, level, module, and message
- [x] Logging integrates with exit codes from signal handling
- [x] All tests pass for logging enhancements

## Test Plan

- Unit: `pytest tests/test_logging.py::test_structured_logging`
- Unit: `pytest tests/test_logging.py::test_log_format_flag`
- Unit: `pytest tests/test_logging.py::test_quiet_mode_suppression`
- Unit: `pytest tests/test_logging.py::test_logging_with_exit_codes`
- Integration: Test structured logging in various scenarios

## Observability

- Structured logs enable machine-readable log analysis
- Track logging mode usage patterns

## Compliance

- Structured logs do not expose sensitive information
- Quiet mode respected for automated environments

## Risks & Mitigations

- Risk: Structured logging may be less readable for humans — Mitigation: Keep human format as default, JSON as optional
- Risk: Quiet mode may suppress important information — Mitigation: Document what is suppressed, provide override

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System), 01-003 (Signal Handling and Exit Codes)
- Unblocks: None (standalone logging enhancement)

## Definition of Done

- Structured logging implemented with JSON format
- `--log-format` flag working
- Quiet mode suppresses all non-essential output
- Logging integrated with exit codes
- Tests pass for all logging scenarios
- Documentation updated for logging modes

## Commit Conventions

- `feat(logging): add structured logging with JSON format`
- `feat(logging): add --log-format flag`
- `feat(logging): ensure quiet mode suppresses progress indicators`
- `test(logging): add tests for logging enhancements`
