---
story_id: "03-007"
story_title: "Structured Logging with Format Auto-Detection"
story_name: "structured-logging"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 7
branch: "feature/current/20260707-cli-python-standards/story-03-007-structured-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logging", "main"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "logging"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Use structured logging (JSON or structured text). Auto-detect format based on TTY (JSON for non-TTY, pretty for TTY), support language-native env filters (e.g., LOG_LEVEL), and implement log level resolution: env vars > CLI flags > config file > defaults.

## Sub-Tasks

- [ ] Implement structured logging (JSON)
- [ ] Implement pretty logging for TTY
- [ ] Add TTY detection for format auto-selection
- [ ] Add LOG_LEVEL environment variable support
- [ ] Implement log level precedence chain
- [ ] Add tests for structured logging
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` - Logging module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_logging.py.jinja` - Logging tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Structured logging uses JSON format
- [ ] Pretty logging used for TTY
- [ ] Format auto-detected based on TTY
- [ ] LOG_LEVEL environment variable supported
- [ ] Log level precedence chain implemented
- [ ] Tests verify structured logging

## Test Plan

- Unit: `pytest tests/test_logging.py -v -k test_structured`
- Integration: `pytest tests/test_main.py -v -k test_logging_format`
- Manual: Test in TTY and non-TTY environments

## Observability

- Log format selection
- Log level resolution

## Compliance

- Use standard structured logging formats
- Respect user log level preferences

## Risks & Mitigations

- Risk: TTY detection fails — Mitigation: Default to pretty format
- Risk: JSON parsing issues — Mitigation: Standard JSON format

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Structured logging implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(logging): add structured logging with auto-detection`

## Changelog

- 2025-07-08: initialized story file
