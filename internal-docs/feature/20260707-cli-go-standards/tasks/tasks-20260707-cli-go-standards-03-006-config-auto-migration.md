---
story_id: "03-006"
story_title: "Config File Auto-Migration"
story_name: "config-auto-migration"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 6
branch: "feature/current/20260707-cli-go-standards/story-03-006-config-auto-migration"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-007"]
parallel_safe: true
modules: ["config", "migration"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "config"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement automatic config file migration when config schema evolves. Auto-migrate legacy configs to new format on first run, create backup of old config with `.bak` suffix, log migration actions, validate migrated config before use, and support both legacy and new formats for one release cycle with deprecation warnings.

## Sub-Tasks

- [x] Create config migration system — `core/files/migration.go.jinja`
- [x] Define config versioning scheme — `core/files/migration.go.jinja`
- [x] Implement migration from legacy format — `core/files/migration.go.jinja`
- [x] Add backup creation with .bak suffix — `core/files/migration.go.jinja`
- [x] Implement migration logging — `core/files/migration.go.jinja`
- [x] Add migrated config validation — `core/files/migration.go.jinja`
- [x] Add legacy format support — `core/files/config.go.jinja`
- [x] Add deprecation warnings for legacy format — `core/files/migration.go.jinja`
- [x] Integrate migration into config loading — `core/files/main.go.jinja`
- [x] Test migration from legacy format — `core/files/migration_test.go.jinja`
- [x] Test backup creation — `core/files/migration_test.go.jinja`
- [x] Test migration logging — `core/files/migration_test.go.jinja`
- [x] Test migrated config validation — `core/files/migration_test.go.jinja`
- [x] Test legacy format support — `core/files/migration_test.go.jinja`
- [x] Test deprecation warnings — `core/files/migration_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Integrate migration into config loading
- `apps/cli/go/core/files/config.go.jinja` — Add legacy format support and parsing helpers
- `apps/cli/go/core/files/migration.go.jinja` — New file for migration logic (versioning, backup, validation, deprecation warnings)
- `apps/cli/go/core/files/migration_test.go.jinja` — New file for migration tests (backup, migration, idempotency, legacy detection)

## Acceptance Criteria

- [x] Legacy configs auto-migrate to new format
- [x] Old config backed up with .bak suffix
- [x] Migration actions are logged
- [x] Migrated config is validated before use
- [x] Legacy format supported for one release cycle
- [x] Deprecation warnings shown for legacy format
- [x] Migration handles errors gracefully
- [x] Migration is idempotent

## Test Plan

- Unit: Test migration functions
- Integration: Test migration in config loading
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log migration start and completion
- Log migration errors
- Log when legacy format is detected

## Compliance

- Ensure user data is preserved during migration
- Provide clear warnings about deprecation
- Handle migration failures gracefully

## Risks & Mitigations

- Risk: Migration may corrupt user config — Mitigation: Backup before migration
- Risk: Migration may fail mid-process — Mitigation: Validate before using migrated config
- Risk: Legacy support may be complex — Mitigation: Limit to one release cycle

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization), 01-007 (Configuration Validation)
- Unblocks: None

## Definition of Done

- Config migration works correctly
- Backups are created
- Legacy format is supported
- All tests pass

## Commit Conventions

- `feat(migration): add config auto-migration`
- `feat(migration): add backup creation`
- `feat(migration): add legacy format support`
- `test(migration): add tests for config migration`
