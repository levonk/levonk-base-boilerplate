---
story_id: "01-003"
story_title: "Config Updates for Agent Mode"
story_name: "config-updates"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260708-cli-python-aix/story-01-003-config-updates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "config"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Update config system to support agent mode settings. Add mode configuration option, TOON format preferences, truncation limits, and other agent-specific settings. Ensure config validation and migration for existing configs.

## Sub-Tasks

- [ ] Add `mode` setting to config schema (agent|human) — `config/schema.py`
- [ ] Add `default_format` setting to config schema (toon|json|human) — `config/schema.py`
- [ ] Add `truncation_limit` setting to config schema (default 1000) — `config/schema.py`
- [ ] Add `fields_default` setting to config schema — `config/schema.py`
- [ ] Update config validation to include new agent settings — `config/validation.py`
- [ ] Add config migration logic for existing configs — `config/migration.py`
- [ ] Update default config template with agent settings — `config/default.yaml.jinja`
- [ ] Add config documentation for agent mode settings — `config/README.md`
- [ ] Test config loading with new settings — `tests/test_config.py`
- [ ] Test config migration from old to new schema — `tests/test_migration.py`

## Relevant Files

- `apps/cli/python/core/files/config/schema.py.jinja` — Config schema with agent settings
- `apps/cli/python/core/files/config/validation.py.jinja` — Config validation
- `apps/cli/python/core/files/config/migration.py.jinja` — Config migration logic
- `apps/cli/python/core/files/config/default.yaml.jinja` — Default config template
- `apps/cli/python/core/files/config/README.md.jinja` — Config documentation
- `apps/cli/python/core/files/tests/test_config.py.jinja` — Config tests
- `apps/cli/python/core/files/tests/test_migration.py.jinja` — Migration tests

## Acceptance Criteria

- [ ] Config supports `mode` setting (agent|human)
- [ ] Config supports `default_format` setting (toon|json|human)
- [ ] Config supports `truncation_limit` setting (default 1000)
- [ ] Config supports `fields_default` setting
- [ ] Config validation includes new agent settings
- [ ] Config migration works for existing configs
- [ ] Default config template includes all agent settings
- [ ] All tests pass

## Test Plan

- Unit: Test config loading with new settings
- Unit: Test config validation with agent settings
- Unit: Test config migration from old to new schema
- Integration: Test actual config file creation and loading
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log config loading events
- Log config migration events
- Log config validation errors

## Compliance

- No regulatory constraints
- Config files should have secure permissions (0600)
- No sensitive data in default config template

## Risks & Mitigations

- Risk: Config migration fails for existing users — Mitigation: Add rollback, clear error messages
- Risk: Invalid config values break agent mode — Mitigation: Validate on load, use safe defaults
- Risk: Config schema changes break compatibility — Mitigation: Version config schema, support migration

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-001 (Mode Selection), 01-002 (TOON Format)

## Definition of Done

- Config system updated with agent settings
- Config validation includes new settings
- Config migration works correctly
- Default config template updated
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(config): add agent mode settings to config schema`
- `feat(config): add config migration for agent settings`
- `test(config): add tests for agent config settings`
