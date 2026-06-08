---
story_id: "03-006"
story_title: "Config File Auto-Migration"
story_name: "config-auto-migration"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 6
branch: "feature/current/20260707-cli-python-standards/story-03-006-config-auto-migration"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-007"]
parallel_safe: true
modules: ["config", "migration"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "config"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Auto-migrate legacy configs to new format on schema changes. Create backup of old config with `.bak` suffix, log all migration actions, validate migrated config before use, support both legacy and new formats for one release cycle, and provide deprecation warnings for legacy format.

## Sub-Tasks

- [ ] Implement config version tracking
- [ ] Implement migration logic
- [ ] Add backup creation with .bak suffix
- [ ] Add migration logging
- [ ] Add migrated config validation
- [ ] Support legacy format for one cycle
- [ ] Add deprecation warnings
- [ ] Add tests for config migration
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `tests/test_config.py.jinja` - Config tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Config auto-migrates on version change
- [ ] Backup created with .bak suffix
- [ ] Migration actions logged
- [ ] Migrated config validated
- [ ] Legacy format supported for one cycle
- [ ] Deprecation warnings shown
- [ ] Tests verify migration

## Test Plan

- Unit: `pytest tests/test_config.py -v -k test_migration`
- Integration: `pytest tests/test_main.py -v -k test_config_migration`
- Manual: Test with old config version

## Observability

- Log migration events
- Log validation results

## Compliance

- Preserve user settings during migration
- Provide clear deprecation warnings

## Risks & Mitigations

- Risk: Migration fails — Mitigation: Keep old config and log error
- Risk: User settings lost — Mitigation: Backup and validation

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization), 01-007 (Config Validation)
- Unblocks: 04-001

## Definition of Done

- Config auto-migration implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(config): add config auto-migration`

## Changelog

- 2025-07-08: initialized story file
