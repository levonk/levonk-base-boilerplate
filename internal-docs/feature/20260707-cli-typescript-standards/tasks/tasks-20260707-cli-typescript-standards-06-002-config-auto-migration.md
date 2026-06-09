---
story_id: "06-002"
story_title: "Config Auto-Migration"
story_name: "config-auto-migration"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 6
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-06-002-config-auto-migration"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["02-002"]
parallel_safe: true
modules: ["config/"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-08-18"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Auto-migrate legacy configs to new format on first run. Create backup of old config (.bak suffix), log migration actions, validate migrated config before use, support both legacy and new formats for at least one release cycle, and add deprecation warnings for legacy format. This implements CLI Tool Standards ADR requirement #29.

## Sub-Tasks

- [x] Implement config version tracking
- [x] Create migration module with version-specific migrations
- [x] Implement legacy config detection
- [x] Add config backup creation (.bak suffix)
- [x] Implement config migration logic
- [x] Add migrated config validation
- [ ] Implement deprecation warnings for legacy format
- [ ] Add support for both legacy and new formats
- [ ] Log migration actions
- [ ] Add unit tests for config migration
- [ ] Add unit tests for backup creation
- [ ] Add integration tests for migration workflow
- [ ] Update help text to document config migration
- [ ] Add migration rollback capability

## Relevant Files

- `apps/cli/typescript/core/files/src/migration.ts.jinja` - Migration module (created)
- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config module with migration integration
- `apps/cli/typescript/core/files/src/validation.ts.jinja` - Config schema with _version field
- `apps/cli/typescript/core/files/src/migration.test.ts.jinja` - Unit tests for migration (to be created)
- `apps/cli/typescript/core/files/src/config.test.ts.jinja` - Integration tests for migration

## Acceptance Criteria

- [ ] Legacy configs are auto-migrated on first run
- [ ] Old config is backed up with .bak suffix
- [ ] Migration actions are logged
- [ ] Migrated config is validated before use
- [ ] Both legacy and new formats are supported
- [ ] Deprecation warnings are shown for legacy format
- [ ] Migration rollback is possible
- [ ] Config version is tracked
- [ ] Migration is idempotent (safe to run multiple times)

## Test Plan

- Unit: `vitest run src/migration.test.ts` - Test migration logic
- Integration: `vitest run src/config.test.ts` - Test migration workflow
- Manual: Create legacy config and verify migration
- Manual: Test migration rollback

## Observability

- Log migration actions in verbose mode
- Track migration success/failure for analytics
- Add metrics for migration performance

## Compliance

- Follows CLI Tool Standards ADR requirement #29 (Config File Auto-Migration)
- Enables smooth config schema evolution

## Risks & Mitigations

- Risk: Migration logic has bugs
  - Mitigation: Comprehensive testing, backup creation, validation
- Risk: Migration data loss
  - Mitigation: Backup creation, validation before use, rollback capability
- Risk: Legacy format support period is too short
  - Mitigation: Support for at least one release cycle, clear communication

## Dependencies

- 02-002 (Configuration Precedence Chain) - Config loading must be in place

## Notes

- Use semantic versioning for config schema
- Each migration should be version-specific
- Migration should be reversible where possible
- Document deprecation timeline clearly
