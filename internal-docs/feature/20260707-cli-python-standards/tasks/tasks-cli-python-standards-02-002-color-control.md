---
story_id: "02-002"
story_title: "Color Control Enhancement"
story_name: "color-control"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 2
parallel_id: 2
branch: "feature/current/cli-python-standards/story-02-002-color-control"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["logging.py", "__main__.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "color"]
due: "2026-07-17"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Replace the basic `--nocolor` flag with proper `--color=auto|always|never` flag support. Implement smart TTY detection in auto mode, add color setting to config file, and ensure NO_COLOR environment variable takes precedence over all other color settings.

## Sub-Tasks

- [ ] Replace `--nocolor` flag with `--color=auto|always|never` in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Implement smart TTY detection for auto mode in `logging.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja`
- [ ] Add `color` setting to config file schema in `config.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja`
- [ ] Implement color mode resolution precedence: NO_COLOR > --color > config > auto-detection — `logging.py.jinja`
- [ ] Update color detection logic to respect NO_COLOR environment variable — `logging.py.jinja`
- [ ] Add color mode to config file initialization — `config.py.jinja`
- [ ] Add tests for color control (auto/always/never modes) — `apps/cli/python/core/files/tests/test_logging.py.jinja`
- [ ] Add tests for NO_COLOR environment variable handling — `tests/test_logging.py.jinja`
- [ ] Add tests for TTY detection in auto mode — `tests/test_logging.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Replace --nocolor with --color flag
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` — Implement color mode resolution and TTY detection
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Add color setting to config schema
- `apps/cli/python/core/files/tests/test_logging.py.jinja` — Add tests for color control

## Acceptance Criteria

- [ ] `--color=auto` enables color based on TTY detection
- [ ] `--color=always` forces color output regardless of TTY
- [ ] `--color=never` disables all color output
- [ ] Config file supports `color` setting with auto|always|never modes
- [ ] NO_COLOR environment variable takes precedence over all other color settings
- [ ] Color mode resolution follows correct precedence
- [ ] Smart TTY detection works correctly in auto mode
- [ ] All tests pass for color control scenarios

## Test Plan

- Unit: `pytest tests/test_logging.py::test_color_auto`
- Unit: `pytest tests/test_logging.py::test_color_always`
- Unit: `pytest tests/test_logging.py::test_color_never`
- Unit: `pytest tests/test_logging.py::test_no_color_env_var`
- Unit: `pytest tests/test_logging.py::test_tty_detection`
- Integration: Test color control with different terminal configurations

## Observability

- Log color mode resolution for debugging
- Track color mode usage in analytics

## Compliance

- NO_COLOR environment variable respected per standard
- Color control does not affect functionality, only presentation

## Risks & Mitigations

- Risk: TTY detection may be unreliable in some environments — Mitigation: Provide manual override via --color flag
- Risk: Color precedence may confuse users — Mitigation: Document precedence clearly in help text

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone enhancement)

## Definition of Done

- `--color=auto|always|never` flag implemented and working
- Smart TTY detection implemented for auto mode
- Config file supports color setting
- NO_COLOR environment variable takes precedence
- Color mode resolution follows correct precedence
- Tests pass for all color control scenarios
- Documentation updated for color control usage

## Commit Conventions

- `feat(cli): replace --nocolor with --color=auto|always|never`
- `feat(logging): implement smart TTY detection for color auto mode`
- `feat(config): add color setting to config file`
- `test(logging): add tests for color control and NO_COLOR handling`
