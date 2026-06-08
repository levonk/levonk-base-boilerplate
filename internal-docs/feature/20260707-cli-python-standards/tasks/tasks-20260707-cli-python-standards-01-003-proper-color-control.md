---
story_id: "01-003"
story_title: "Proper Color Control"
story_name: "proper-color-control"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260707-cli-python-standards/story-01-003-proper-color-control"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Replace `--no-color` with `--color=auto|always|never` flag for proper color control. Implement smart TTY detection in auto mode, add color setting to config file, and honor `NO_COLOR` environment variable with proper precedence.

## Sub-Tasks

- [x] Replace --no-color with --color flag (auto/always/never)
- [x] Implement TTY detection for auto mode
- [x] Add color setting to config file
- [x] Implement NO_COLOR environment variable support
- [x] Implement precedence chain (NO_COLOR > --color > config > auto-detection)
- [x] Update logging module to respect color settings
- [x] Add tests for color control
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `apps/cli/python/core/files/{{project_slug}}/logging.py.jinja` - Logging module
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `tests/test_logging.py.jinja` - Logging tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--color=auto|always|never` flag works correctly
- [ ] Auto mode detects TTY and enables/disables colors accordingly
- [ ] Config file supports color setting
- [ ] NO_COLOR environment variable takes precedence
- [ ] Precedence chain is correctly implemented
- [ ] Backward compatibility with --no-color maintained (deprecated)
- [ ] Tests verify all color modes

## Test Plan

- Unit: `pytest tests/test_logging.py -v -k test_color`
- Integration: `pytest tests/test_main.py -v -k test_color_modes`
- Manual: Test in TTY and non-TTY environments

## Observability

- Log color mode selection
- Log NO_COLOR environment variable detection

## Compliance

- Respect NO_COLOR standard (https://no-color.org/)
- Provide graceful degradation on systems without color support

## Risks & Mitigations

- Risk: TTY detection varies by platform — Mitigation: Use platform-agnostic library
- Risk: Backward compatibility issues — Mitigation: Keep --no-color as deprecated alias

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 02-003

## Definition of Done

- Color control implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): implement proper color control`

## Changelog

- 2025-07-08: initialized story file
