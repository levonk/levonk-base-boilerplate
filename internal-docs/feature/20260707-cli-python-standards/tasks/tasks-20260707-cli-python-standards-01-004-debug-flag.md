---
story_id: "01-004"
story_title: "Debug Flag"
story_name: "debug-flag"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 4
branch: "feature/current/20260707-cli-python-standards/story-01-004-debug-flag"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "debugging"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Add `--debug` flag separate from `--verbose` for detailed diagnostic logging. Debug mode should enable stack traces, internal state information, and detailed logging at DEBUG level.

## Sub-Tasks

- [ ] Add --debug flag to CLI argument parser
- [ ] Implement debug mode in logging module
- [ ] Add stack trace output in debug mode
- [ ] Add internal state logging in debug mode
- [ ] Ensure debug flag is separate from --verbose
- [ ] Add tests for debug flag behavior
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` - Logging module
- `tests/test_logging.py.jinja` - Logging tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--debug` flag enables DEBUG level logging
- [ ] Debug mode includes stack traces on errors
- [ ] Debug mode logs internal state information
- [ ] Debug flag is independent from --verbose
- [ ] Debug output is only shown when --debug is set
- [ ] Tests verify debug mode behavior

## Test Plan

- Unit: `pytest tests/test_logging.py -v -k test_debug`
- Integration: `pytest tests/test_main.py -v -k test_debug_mode`
- Manual: Run with --debug and verify detailed output

## Observability

- Debug mode logs all internal operations
- Stack traces include full context

## Compliance

- Avoid logging sensitive data even in debug mode
- Follow security best practices for debug output

## Risks & Mitigations

- Risk: Debug output may contain sensitive data — Mitigation: Sanitize debug output
- Risk: Debug mode performance impact — Mitigation: Only enable when flag is set

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Debug flag implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(logging): add debug flag`

## Changelog

- 2025-07-08: initialized story file
