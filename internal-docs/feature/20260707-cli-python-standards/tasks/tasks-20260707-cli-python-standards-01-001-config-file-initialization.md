---
story_id: "01-001"
story_title: "Config File Initialization"
story_name: "config-file-initialization"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260707-cli-python-standards/story-01-001-config-file-initialization"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config", "main"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "config"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement automatic config file initialization on first run for the Python CLI boilerplate. The config file should be created at `~/.config/{project_slug}/config.toml` with all settings commented out with default values and explanations. This is a core infrastructure feature that enables other advanced config features.

## Sub-Tasks

- [x] Add config initialization logic to `config.py` module
- [x] Implement XDG config directory detection and creation
- [x] Create default config template with commented settings
- [x] Add first-run detection mechanism
- [x] Integrate initialization into CLI entry point
- [x] Add tests for config initialization
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Main config management module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_config.py.jinja` - Config module tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [x] Config file is auto-created at `~/.config/{project_slug}/config.toml` on first run
- [x] Config file contains all settings with default values and explanations
- [x] Config file uses TOML format
- [x] XDG config directory is created if it doesn't exist
- [x] Existing config files are not overwritten
- [x] Initialization is silent (no output unless --verbose)
- [x] Tests verify config file creation and content

## Test Plan

- Unit: `pytest tests/test_config.py -v -k test_init`
- Integration: `pytest tests/test_main.py -v -k test_first_run`
- Manual: Run generated CLI and verify config file creation

## Observability

- Add logging for config initialization events
- Log config file path when created
- Log if config file already exists

## Compliance

- Respect XDG Base Directory specification
- Use secure file permissions (0600 for config files)
- No sensitive data in default config

## Risks & Mitigations

- Risk: Config directory creation fails on restricted systems — Mitigation: Graceful fallback to current directory
- Risk: TOML library not available — Mitigation: Include in dependencies

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-007, 02-001, 02-002, 03-001, 03-002, 03-005, 03-006

## Definition of Done

- Config initialization implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(config): add config file initialization`

## Changelog

- 2025-07-08: initialized story file
