---
story_id: "02-003"
story_title: "Error Message Formatting"
story_name: "error-formatting"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 2
parallel_id: 3
branch: "feature/current/cli-python-standards/story-02-003-error-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["error handling module"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "errors"]
due: "2026-07-17"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement consistent error message formatting with actionable suggestions. Use format `ERROR: <description> - <suggestion>`. Include file references with line numbers in VSCode-compatible format and ensure all URLs are browser-compatible.

## Sub-Tasks

- [ ] Create `errors.py.jinja` template file with error formatting utilities — `apps/cli/python/core/files/{{project_slug}}/errors.py.jinja`
- [ ] Implement error formatter with `ERROR: <description> - <suggestion>` format — `errors.py.jinja`
- [ ] Add VSCode-compatible file reference formatting: `file:///absolute/path/to/file:line:column` — `errors.py.jinja`
- [ ] Add standard `file:line:column` format for terminal auto-linkification — `errors.py.jinja`
- [ ] Implement URL formatting with proper encoding for browser compatibility — `errors.py.jinja`
- [ ] Create error helper functions for common error types — `errors.py.jinja`
- [ ] Integrate error formatter into `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Replace existing error messages with formatted errors — `__main__.py.jinja`
- [ ] Add tests for error message formatting — `apps/cli/python/core/files/tests/test_errors.py.jinja`
- [ ] Add tests for file reference formatting — `tests/test_errors.py.jinja`
- [ ] Add tests for URL formatting — `tests/test_errors.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/errors.py.jinja` — New error formatting module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Integrate error formatter
- `apps/cli/python/core/files/tests/test_errors.py.jinja` — New test file for error formatting

## Acceptance Criteria

- [ ] All error messages follow `ERROR: <description> - <suggestion>` format
- [ ] Error suggestions are actionable and helpful
- [ ] File references use VSCode-compatible format: `file:///absolute/path/to/file:line:column`
- [ ] File references also support standard `file:line:column` format
- [ ] URLs are properly encoded for browser compatibility
- [ ] Error formatter used consistently throughout the CLI
- [ ] All tests pass for error formatting scenarios

## Test Plan

- Unit: `pytest tests/test_errors.py::test_error_format`
- Unit: `pytest tests/test_errors.py::test_file_reference_vscode`
- Unit: `pytest tests/test_errors.py::test_file_reference_standard`
- Unit: `pytest tests/test_errors.py::test_url_formatting`
- Integration: Test error messages in various error scenarios

## Observability

- Log formatted errors for debugging
- Track error types and frequencies in analytics

## Compliance

- Error messages do not expose sensitive information
- File references respect user privacy (no absolute paths in logs)

## Risks & Mitigations

- Risk: Error suggestions may not be contextually appropriate — Mitigation: Provide generic but helpful suggestions, allow custom suggestions
- Risk: File references may not work in all terminals — Mitigation: Support both VSCode and standard formats

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: 03-001 (Daemon Process Support)

## Definition of Done

- Error formatter implemented with required format
- VSCode-compatible file references implemented
- URL formatting implemented
- Error formatter integrated throughout CLI
- Tests pass for all error formatting scenarios
- Documentation updated for error format usage

## Commit Conventions

- `feat(errors): add error formatter with actionable suggestions`
- `feat(errors): implement VSCode-compatible file references`
- `feat(errors): add URL formatting for browser compatibility`
- `test(errors): add tests for error formatting`
