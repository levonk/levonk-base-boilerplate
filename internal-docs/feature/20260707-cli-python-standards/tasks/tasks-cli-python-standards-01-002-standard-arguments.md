---
story_id: "01-002"
story_title: "Standard Arguments Enhancement"
story_name: "standard-arguments"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 1
parallel_id: 2
branch: "feature/current/cli-python-standards/story-01-002-standard-arguments"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["__main__.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "arguments"]
due: "2026-07-15"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Enhance standard CLI arguments to ensure `--help`, `--version`, and `--usage` work at root command and all major subcommands. Add `--debug` flag separate from `--verbose` for detailed debugging output.

## Sub-Tasks

- [x] Add `--debug` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Ensure `--help`/`-h` works at root command and all subcommands — `__main__.py.jinja`
- [x] Ensure `--version`/`-v` works at root command and all subcommands — `__main__.py.jinja`
- [x] Ensure `--usage` works at root command and all subcommands — `__main__.py.jinja`
- [x] Implement debug logging level separate from verbose — `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja`
- [x] Add tests for standard arguments at root and subcommand level — `apps/cli/python/core/files/tests/test_main.py.jinja`
- [x] Add tests for debug flag behavior — `tests/test_main.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Main CLI entry point, add debug flag and ensure standard args work
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` — Add debug logging level
- `apps/cli/python/core/files/tests/test_main.py.jinja` — Add tests for standard arguments and debug flag

## Acceptance Criteria

- [x] `--help`/`-h` displays help at root command and all subcommands
- [x] `--version`/`-v` displays version at root command and all subcommands
- [x] `--usage` displays brief usage summary at root command and all subcommands
- [x] `--debug` flag enables detailed debugging output separate from `--verbose`
- [x] Debug logging provides more detailed output than verbose mode
- [x] All tests pass for standard arguments and debug flag

## Test Plan

- Unit: `pytest tests/test_main.py::test_help`
- Unit: `pytest tests/test_main.py::test_version`
- Unit: `pytest tests/test_main.py::test_usage`
- Unit: `pytest tests/test_main.py::test_debug_flag`
- Integration: Test standard arguments work with subcommands

## Observability

- Debug logging provides detailed execution flow
- Standard argument usage logged for analytics

## Compliance

- Standard arguments follow CLI conventions
- Debug output does not expose sensitive information

## Risks & Mitigations

- Risk: Debug output may be too verbose — Mitigation: Separate debug from verbose, document difference
- Risk: Subcommand standard args may be inconsistent — Mitigation: Use Typer's inheritance for consistent behavior

## Dependencies & Sequencing

- Depends on: None (foundation story)
- Unblocks: All stories that depend on proper CLI argument handling

## Definition of Done

- All standard arguments work at root and subcommand level
- Debug flag implemented and tested
- Tests pass for all standard argument scenarios
- Documentation updated for debug vs verbose difference

## Commit Conventions

- `feat(cli): add --debug flag separate from --verbose`
- `feat(cli): ensure standard args work at all command levels`
- `test(cli): add tests for standard arguments and debug flag`
