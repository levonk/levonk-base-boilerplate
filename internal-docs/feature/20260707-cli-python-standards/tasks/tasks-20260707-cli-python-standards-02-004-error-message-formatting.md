---
story_id: "02-004"
story_title: "Error Message Formatting"
story_name: "error-message-formatting"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260707-cli-python-standards/story-02-004-error-message-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Standardize error format: `ERROR: <description> - <suggestion>`. Provide actionable suggestions for resolution, include context (file, line number) where applicable, and use consistent error types and exit codes.

## Sub-Tasks

- [ ] Implement standardized error format
- [ ] Add actionable suggestions to errors
- [ ] Include file and line number context
- [ ] Define consistent error types
- [ ] Define consistent exit codes
- [ ] Add tests for error formatting
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/errors.py.jinja` - Error formatting module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_errors.py.jinja` - Error tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Errors follow standardized format
- [ ] Errors include actionable suggestions
- [ ] Errors include file/line context where applicable
- [ ] Consistent error types used
- [ ] Consistent exit codes used
- [ ] Tests verify error formatting

## Test Plan

- Unit: `pytest tests/test_errors.py -v -k test_formatting`
- Integration: `pytest tests/test_main.py -v -k test_errors`
- Manual: Trigger errors and verify format

## Observability

- Log error events
- Log error context

## Compliance

- Provide helpful error messages
- Avoid exposing sensitive data in errors

## Risks & Mitigations

- Risk: Error messages too verbose — Mitigation: Configurable verbosity
- Risk: Suggestions not helpful — Mitigation: User testing

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 03-003

## Definition of Done

- Error formatting implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): standardize error message formatting`

## Changelog

- 2025-07-08: initialized story file
