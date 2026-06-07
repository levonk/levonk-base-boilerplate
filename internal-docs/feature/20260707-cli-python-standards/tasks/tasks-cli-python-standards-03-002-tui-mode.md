---
story_id: "03-002"
story_title: "TUI Mode Support"
story_name: "tui-mode"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 3
parallel_id: 2
branch: "feature/current/cli-python-standards/story-03-002-tui-mode"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["tui module"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "tui"]
due: "2026-07-19"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement Terminal User Interface (TUI) mode for interactive configuration and execution. Add `--interactive` or `--tui` flag that allows users to view and modify all arguments before execution. Make TUI mode optional via template choice.

## Sub-Tasks

- [ ] Add `include_tui` boolean option to `copier.yml` — `apps/cli/python/core/copier.yml`
- [ ] Add textual dependency to `pyproject.toml.jinja` conditional on include_tui — `apps/cli/python/core/files/pyproject.toml.jinja`
- [ ] Create `tui.py.jinja` template file with TUI implementation — `apps/cli/python/core/files/{{project_slug}}/tui.py.jinja`
- [ ] Implement `--interactive` flag in `__main__.py.jinja` (conditional on include_tui) — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Implement `--tui` flag as alias for `--interactive` — `__main__.py.jinja`
- [ ] Create TUI interface using textual library — `tui.py.jinja`
- [ ] Implement argument viewing and modification in TUI — `tui.py.jinja`
- [ ] Add confirmation before execution in TUI mode — `tui.py.jinja`
- [ ] Add tests for TUI mode functionality — `apps/cli/python/core/files/tests/test_tui.py.jinja` (conditional)
- [ ] Add TUI usage documentation to README — `apps/cli/python/core/README.md`

## Relevant Files

- `apps/cli/python/core/copier.yml` — Add include_tui template option
- `apps/cli/python/core/files/pyproject.toml.jinja` — Add textual dependency conditionally
- `apps/cli/python/core/files/{{project_slug}}/tui.py.jinja` — New TUI module (conditional)
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add TUI flags (conditional)
- `apps/cli/python/core/files/tests/test_tui.py.jinja` — New test file (conditional)
- `apps/cli/python/core/README.md` — Add TUI documentation

## Acceptance Criteria

- [ ] `--interactive` flag launches TUI mode when include_tui is enabled
- [ ] `--tui` flag works as alias for `--interactive`
- [ ] TUI allows viewing all arguments before execution
- [ ] TUI allows modifying all arguments before execution
- [ ] TUI requires confirmation before execution
- [ ] TUI mode is optional via include_tui template choice
- [ ] TUI works correctly with all CLI arguments
- [ ] Tests pass for TUI functionality when enabled

## Test Plan

- Unit: `pytest tests/test_tui.py::test_tui_launch` (conditional)
- Unit: `pytest tests/test_tui.py::test_argument_modification` (conditional)
- Unit: `pytest tests/test_tui.py::test_confirmation_before_execution` (conditional)
- Integration: Test TUI with various argument combinations (conditional)

## Observability

- Log TUI mode activation for analytics
- Track TUI usage patterns

## Compliance

- TUI mode respects user terminal capabilities
- TUI does not expose sensitive information in plain text

## Risks & Mitigations

- Risk: TUI may not work in all terminal environments — Mitigation: Add terminal capability detection, fallback to CLI mode
- Risk: TUI adds complexity and dependencies — Mitigation: Make TUI optional via template choice, use lightweight library

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone advanced feature)

## Definition of Done

- TUI mode implemented with textual library
- `--interactive` and `--tui` flags working
- Argument viewing and modification working in TUI
- Confirmation before execution in TUI
- TUI mode optional via template choice
- Tests pass for TUI functionality
- Documentation updated for TUI usage

## Commit Conventions

- `feat(tui): add --interactive flag for TUI mode`
- `feat(tui): implement argument viewing and modification`
- `feat(tui): add confirmation before execution`
- `test(tui): add tests for TUI functionality`
