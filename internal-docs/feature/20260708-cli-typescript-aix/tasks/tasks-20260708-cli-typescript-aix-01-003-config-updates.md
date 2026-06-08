---
story_id: "01-003"
story_title: "Config File Updates for Mode"
story_name: "config-updates"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260708-cli-typescript-aix/story-01-003-config-updates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config", "mode"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "config", "mode"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Update config file system to support mode setting (`mode = "agent" | "human"`), truncation limits, and other AXI-specific configuration options. Extend existing config schema while maintaining backward compatibility.

## Sub-Tasks

- [ ] Add `mode` field to config schema — `src/config/schema.mts`
- [ ] Add `truncationLimit` field to config schema — `src/config/schema.mts`
- [ ] Add `defaultFormat` field to config schema — `src/config/schema.mts`
- [ ] Update config validation to include new fields — `src/config/validator.mts`
- [ ] Update default config template with new settings — `config.default.yaml.jinja`
- [ ] Add config migration logic for existing configs — `src/config/migration.mts`
- [ ] Add tests for new config fields — `tests/config/schema.test.mts`
- [ ] Add tests for config migration — `tests/config/migration.test.mts`
- [ ] Update config documentation — `docs/config.md`

## Relevant Files

- `apps/cli/typescript/core/files/src/config/schema.mts.jinja` — Config schema (updated with AXI fields)
- `apps/cli/typescript/core/files/src/config/validator.mts.jinja` — Config validator (updated)
- `apps/cli/typescript/core/files/src/config/migration.mts.jinja` — New file for config migration
- `apps/cli/typescript/core/files/config.default.yaml.jinja` — Default config template (updated)
- `apps/cli/typescript/core/files/tests/config/schema.test.mts.jinja` — Config schema tests (updated)
- `apps/cli/typescript/core/files/tests/config/migration.test.mts.jinja` — New file for migration tests
- `apps/cli/typescript/core/files/docs/config.md.jinja` — Config documentation (updated)

## Acceptance Criteria

- [ ] Config schema includes `mode` field with values "agent" or "human"
- [ ] Config schema includes `truncationLimit` field with default 1000
- [ ] Config schema includes `defaultFormat` field with values "toon", "json", or "human"
- [ ] Config validation accepts new fields
- [ ] Config validation rejects invalid mode values
- [ ] Config migration handles existing configs without new fields
- [ ] Default config template includes all new settings with comments
- [ ] All tests pass
- [ ] Backward compatibility maintained

## Test Plan

- Unit: Test config schema validation with new fields
- Unit: Test config migration from old to new schema
- Integration: Test config loading with new fields
- Integration: Test config loading with old schema (migration)
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log config file location on startup
- Log config mode setting
- Log config truncation limit
- Log config default format

## Compliance

- No regulatory constraints
- No sensitive data handling
- Maintain backward compatibility

## Risks & Mitigations

- Risk: Config migration may fail for corrupted configs — Mitigation: Add error handling and fallback to defaults
- Risk: New config fields may conflict with existing user configs — Mitigation: Use migration logic to add defaults
- Risk: Schema changes may break existing tools — Mitigation: Maintain backward compatibility

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-001 (Mode Selection), 01-002 (TOON Format), 02-002 (Content Truncation)

## Definition of Done

- Config schema updated with AXI fields
- Config validation updated
- Config migration implemented
- Default config template updated
- All tests pass
- Backward compatibility verified
- Documentation updated

## Commit Conventions

- `feat(config): add mode field to config schema`
- `feat(config): add truncation limit to config schema`
- `feat(config): add default format to config schema`
- `feat(config): implement config migration for AXI fields`
- `test(config): add tests for config schema updates`
- `test(config): add tests for config migration`
