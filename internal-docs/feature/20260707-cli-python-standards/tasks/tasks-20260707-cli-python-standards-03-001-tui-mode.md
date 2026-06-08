---
story_id: "03-001"
story_title: "TUI Mode"
story_name: "tui-mode"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260707-cli-python-standards/story-03-001-tui-mode"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: true
modules: ["tui", "main"]
priority: "SHOULD"
risk_level: "high"
tags: ["feat", "ux"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement `--interactive` or `--tui` flag for Terminal User Interface mode using a Python TUI library (textual). Allow interactive configuration and execution, enable viewing and modifying all arguments before execution, and provide intuitive navigation and selection.

## Sub-Tasks

- [ ] Add textual library dependency
- [ ] Implement TUI mode with --interactive flag
- [ ] Implement TUI mode with --tui flag (alias)
- [ ] Add interactive configuration UI
- [ ] Add argument viewing and modification
- [ ] Add confirmation before execution
- [ ] Add tests for TUI mode
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/tui.py.jinja` - TUI module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_tui.py.jinja` - TUI tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--interactive` flag launches TUI mode
- [ ] `--tui` flag works as alias
- [ ] TUI allows interactive configuration
- [ ] TUI shows all arguments before execution
- [ ] TUI allows argument modification
- [ ] TUI provides confirmation before execution
- [ ] Tests verify TUI functionality

## Test Plan

- Unit: `pytest tests/test_tui.py -v -k test_tui`
- Integration: `pytest tests/test_main.py -v -k test_tui_mode`
- Manual: Run with --interactive and verify TUI

## Observability

- Log TUI mode activation
- Log TUI configuration changes

## Compliance

- Provide accessible TUI interface
- Respect user configuration choices

## Risks & Mitigations

- Risk: TUI library not available — Mitigation: Graceful fallback to CLI
- Risk: TUI not supported on all terminals — Mitigation: Terminal detection

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization), 01-006 (Config Precedence Chain)
- Unblocks: None

## Definition of Done

- TUI mode implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add TUI mode`

## Changelog

- 2025-07-08: initialized story file
