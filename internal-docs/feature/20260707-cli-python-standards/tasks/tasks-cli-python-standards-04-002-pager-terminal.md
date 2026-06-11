---
story_id: "04-002"
story_title: "Pager Integration and Terminal Awareness"
story_name: "pager-terminal"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 4
parallel_id: 2
branch: "feature/current/cli-python-standards/story-04-002-pager-terminal"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["__main__.py", "terminal module"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-07-22"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement auto-pager for long output and terminal size awareness. Respect `PAGER` environment variable with default to `less`, provide `--no-pager` flag, and handle terminal resize events where possible.

## Sub-Tasks

- [x] Create `terminal.py.jinja` template file with terminal utilities — `apps/cli/python/core/files/{{project_slug}}/terminal.py.jinja`
- [x] Implement terminal size detection on startup — `terminal.py.jinja`
- [x] Implement terminal resize event handling where possible — `terminal.py.jinja`
- [x] Add responsive output formatting based on terminal width — `terminal.py.jinja`
- [x] Implement auto-pager for long output in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Respect `PAGER` environment variable with default to `less` — `terminal.py.jinja`
- [x] Add `--no-pager` flag to bypass paging — `__main__.py.jinja`
- [x] Detect when output exceeds terminal height and auto-pager — `terminal.py.jinja`
- [x] Add tests for pager integration — `apps/cli/python/core/files/tests/test_terminal.py.jinja`
- [x] Add tests for terminal size awareness — `tests/test_terminal.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/terminal.py.jinja` — New terminal module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Integrate pager and terminal awareness
- `apps/cli/python/core/files/tests/test_terminal.py.jinja` — New test file for terminal functionality

## Acceptance Criteria

- [x] Terminal size detected on startup
- [x] Terminal resize events handled where possible
- [x] Output formatting responsive to terminal width
- [x] Auto-pager activates for long output
- [x] `PAGER` environment variable respected with default to `less`
- [x] `--no-pager` flag bypasses paging
- [x] Auto-pager triggers when output exceeds terminal height
- [x] All tests pass for pager and terminal scenarios

## Test Plan

- Unit: `pytest tests/test_terminal.py::test_terminal_size_detection`
- Unit: `pytest tests/test_terminal.py::test_resize_handling`
- Unit: `pytest tests/test_terminal.py::test_auto_pager`
- Unit: `pytest tests/test_terminal.py::test_pager_env_var`
- Unit: `pytest tests/test_terminal.py::test_no_pager_flag`
- Integration: Test pager with various output lengths

## Observability

- Log terminal size detection for debugging
- Track pager usage patterns

## Compliance

- Pager respects user environment preferences
- Terminal awareness does not break functionality in non-TTY environments

## Risks & Mitigations

- Risk: Terminal resize handling may not work on all platforms — Mitigation: Graceful degradation, optional feature
- Risk: Auto-pager may interfere with piped output — Mitigation: Detect pipe/redirection, disable auto-pager

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone UX enhancement)

## Definition of Done

- Terminal size detection implemented
- Terminal resize handling implemented where possible
- Responsive output formatting based on terminal width
- Auto-pager implemented with PAGER support
- `--no-pager` flag implemented
- Tests pass for all terminal scenarios
- Documentation updated for terminal features

## Commit Conventions

- `feat(terminal): add terminal size detection and resize handling`
- `feat(terminal): implement responsive output formatting`
- `feat(terminal): add auto-pager with PAGER support`
- `test(terminal): add tests for pager and terminal awareness`
