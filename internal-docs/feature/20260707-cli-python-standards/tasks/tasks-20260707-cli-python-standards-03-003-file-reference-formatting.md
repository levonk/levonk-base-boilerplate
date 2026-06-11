---
story_id: "03-003"
story_title: "File Reference Formatting"
story_name: "file-reference-formatting"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260707-cli-python-standards/story-03-003-file-reference-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-004"]
parallel_safe: true
modules: ["main", "output"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Use VSCode-compatible format `file:///absolute/path/to/file:line:column` for file references. Support standard `file:line:column` format for terminal linking and apply to all error messages and file references.

## Sub-Tasks

- [x] Implement VSCode-compatible file reference format
- [x] Implement standard file:line:column format
- [x] Apply to all error messages
- [x] Apply to all file references
- [x] Add tests for file reference formatting
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/errors.py.jinja` - Error formatting
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_errors.py.jinja` - Error tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] File references use VSCode-compatible format
- [ ] Standard file:line:column format supported
- [ ] All error messages include file references
- [ ] All file references properly formatted
- [ ] Tests verify file reference formatting

## Test Plan

- Unit: `pytest tests/test_errors.py -v -k test_file_references`
- Integration: `pytest tests/test_main.py -v -k test_file_formatting`
- Manual: Trigger errors and verify file references

## Observability

- Log file reference formatting

## Compliance

- Use standard file reference formats
- Ensure cross-platform compatibility

## Risks & Mitigations

- Risk: Format varies by platform — Mitigation: Platform-specific handling
- Risk: File paths too long — Mitigation: Truncate if necessary

## Dependencies & Sequencing

- Depends on: 02-004 (Error Message Formatting)
- Unblocks: None

## Definition of Done

- File reference formatting implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add file reference formatting`

## Changelog

- 2025-07-08: initialized story file
