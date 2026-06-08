---
story_id: "01-001"
story_title: "Configuration Management System"
story_name: "config-management"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 1
parallel_id: 1
branch: "feature/current/cli-python-standards/story-01-001-config-management"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config module"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "backend", "config"]
due: "2026-07-15"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement a comprehensive configuration management system that supports config file initialization, validation, auto-migration, and proper precedence handling (CLI args > env vars > local config > user config > system config > defaults). This foundation is required by all other CLI features.

## Sub-Tasks

- [x] Create `config.py.jinja` template file with ConfigManager class — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja`
- [x] Implement config file initialization with default commented settings on first run — `config.py.jinja`
- [x] Add config file validation with clear error messages including line numbers — `config.py.jinja`
- [x] Implement config file auto-migration with backup and logging — `config.py.jinja`
- [x] Add configuration precedence logic (CLI args > env vars > local > user > system > defaults) — `config.py.jinja`
- [x] Add TOML parsing support with pydantic validation — `config.py.jinja`
- [x] Update `copier.yml` to add `include_advanced_config` boolean option — `apps/cli/python/core/copier.yml`
- [x] Update `pyproject.toml.jinja` to add pydantic and toml dependencies — `apps/cli/python/core/files/pyproject.toml.jinja`
- [x] Integrate ConfigManager into `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Add tests for config initialization, validation, and migration — `apps/cli/python/core/files/tests/test_config.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — New config management module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Main CLI entry point, needs config integration
- `apps/cli/python/core/files/pyproject.toml.jinja` — Add pydantic and toml dependencies
- `apps/cli/python/core/copier.yml` — Add include_advanced_config template option
- `apps/cli/python/core/files/tests/test_config.py.jinja` — New test file for config functionality

## Acceptance Criteria

- [x] Config file is auto-created with commented default settings on first run
- [x] Config validation provides clear error messages with line numbers
- [x] Config auto-migration creates `.bak` backup and logs migration actions
- [x] Configuration precedence follows: CLI args > env vars > local config > user config > system config > defaults
- [x] TOML format is primary with YAML support for complex structures
- [x] Config manager supports both legacy and new formats for one release cycle
- [x] All tests pass with 90%+ coverage for config module

## Test Plan

- Unit: `pytest tests/test_config.py` (new test file)
- Integration: Test config precedence with CLI args, env vars, and config files
- Validation: Test config validation error messages and line numbers
- Migration: Test config auto-migration with backup creation

## Observability

- Add logging for config file creation, validation errors, and migration actions
- Log config file location and precedence resolution

## Compliance

- No sensitive data in config files by default
- Secure handling of credentials if present in config
- Config files respect XDG directory standards

## Risks & Mitigations

- Risk: Config migration may break existing user configs — Mitigation: Backup old config, support both formats for one release
- Risk: Config validation errors may be unclear — Mitigation: Include line numbers and actionable suggestions in error messages
- Risk: Config precedence complexity may confuse users — Mitigation: Document precedence clearly in config file comments

## Dependencies & Sequencing

- Depends on: None (foundation story)
- Unblocks: 02-001 (Install/Uninstall), 02-002 (Color Control), 02-003 (Error Formatting), all advanced features

## Definition of Done

- ConfigManager class implemented with all required functionality
- Config file initialization, validation, and migration working
- Configuration precedence correctly implemented
- Tests written and passing with 90%+ coverage
- Documentation updated in config file comments
- Template options added to copier.yml

## Commit Conventions

- `feat(config): add ConfigManager class with initialization and validation`
- `feat(config): implement config auto-migration with backup`
- `feat(config): add configuration precedence logic`
- `test(config): add comprehensive config tests`
