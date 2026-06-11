---
story_id: "06-001"
story_title: "Structured Logging with Format Auto-Detection"
story_name: "structured-logging"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 1
branch: "feature/current/cli-python-standards/story-06-001-structured-logging"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["04-003"]
parallel_safe: true
modules: ["logging.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "logging"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement structured logging with format auto-detection based on TTY. Support Python-native env filters, implement log level resolution precedence (env vars > CLI flags > config file > defaults), and add `--log-format` flag for format selection.

## Sub-Tasks

- [x] Add structlog dependency to `pyproject.toml.jinja` — `apps/cli/python/core/files/pyproject.toml.jinja`
- [x] Implement structured logging (JSON format) in `logging.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja`
- [x] Add format auto-detection based on TTY — `logging.py.jinja`
- [x] Support Python-native env filters (LOG_LEVEL, PYTHON_LOG) — `logging.py.jinja`
- [x] Implement log level resolution: env vars > CLI flags > config file > defaults — `logging.py.jinja`
- [x] Add `--log-format` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Add structured text format option (human-readable but structured) — `logging.py.jinja`
- [x] Add tests for structured logging format auto-detection — `apps/cli/python/core/files/tests/test_logging.py.jinja`
- [x] Add tests for log level resolution precedence — `tests/test_logging.py.jinja`
- [x] Add tests for env filter support — `tests/test_logging.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/pyproject.toml.jinja` — Add structlog dependency
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` — Implement structured logging
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --log-format flag
- `apps/cli/python/core/files/tests/test_logging.py.jinja` — Add tests for structured logging

## Acceptance Criteria

- [x] Structured logging (JSON format) implemented
- [x] Format auto-detection based on TTY working
- [x] Python-native env filters (LOG_LEVEL, PYTHON_LOG) supported
- [x] Log level resolution follows: env vars > CLI flags > config file > defaults
- [x] `--log-format` flag allows choosing between human, JSON, and structured text
- [x] Structured text format provides human-readable but structured output
- [x] All tests pass for structured logging scenarios

## Test Plan

- Unit: `pytest tests/test_logging.py::test_structured_logging_json`
- Unit: `pytest tests/test_logging.py::test_format_auto_detection`
- Unit: `pytest tests/test_logging.py::test_log_level_resolution`
- Unit: `pytest tests/test_logging.py::test_env_filters`
- Integration: Test structured logging in various TTY/non-TTY environments

## Observability

- Structured logs enable machine-readable log analysis
- Track log format usage patterns
- Monitor log level resolution effectiveness

## Compliance

- Structured logs do not expose sensitive information
- Env filters respect user environment preferences

## Risks & Mitigations

- Risk: Structured logging may be less readable for humans — Mitigation: Auto-detect TTY, use human format by default
- Risk: Log level resolution may be complex — Mitigation: Document precedence clearly, provide override options

## Dependencies & Sequencing

- Depends on: 04-003 (Logging Modes Enhancement)
- Unblocks: None (standalone logging enhancement)

## Definition of Done

- Structured logging implemented with JSON and structured text formats
- Format auto-detection based on TTY working
- Env filters supported
- Log level resolution following correct precedence
- `--log-format` flag working
- Tests pass for all structured logging scenarios
- Documentation updated for structured logging usage

## Commit Conventions

- `feat(logging): add structured logging with JSON format`
- `feat(logging): implement format auto-detection based on TTY`
- `feat(logging): add env filter support`
- `feat(logging): implement log level resolution precedence`
- `test(logging): add tests for structured logging`
