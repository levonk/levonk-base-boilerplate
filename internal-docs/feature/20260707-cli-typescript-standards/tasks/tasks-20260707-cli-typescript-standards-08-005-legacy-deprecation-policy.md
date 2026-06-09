---
story_id: "08-005"
story_title: "Legacy Deprecation Policy"
story_name: "legacy-deprecation-policy"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 8
parallel_id: 5
branch: "feature/current/20260707-cli-typescript-standards/story-08-005-legacy-deprecation-policy"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config/", "deprecation/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "maintenance"]
due: "2026-09-01"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement legacy deprecation policy with clear end-of-support dates (minimum 6 months from announcement). Log deprecation warnings to stderr during deprecation period and remove legacy support only after specified date. This implements CLI Tool Standards ADR requirement #35.

## Sub-Tasks

- [x] Create deprecation module for managing legacy features
- [x] Implement deprecation warning system
- [x] Add end-of-support date tracking
- [x] Implement deprecation warning logging to stderr
- [x] Add deprecation configuration
- [x] Implement legacy feature detection
- [x] Add deprecation status reporting
- [x] Implement legacy support removal logic
- [x] Add unit tests for deprecation warnings
- [x] Add unit tests for end-of-support enforcement
- [x] Add integration tests for deprecation workflow
- [x] Update help text to document deprecation policy
- [x] Add deprecation policy documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/deprecation.ts.jinja` - New deprecation module
- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config with deprecation settings
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with deprecation checks
- `apps/cli/typescript/core/files/src/deprecation.test.ts.jinja` - Unit tests for deprecation
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for deprecation
- `apps/cli/typescript/core/files/docs/deprecation-policy.md.jinja` - Deprecation policy documentation

## Acceptance Criteria

- [x] Deprecation warnings are logged to stderr
- [x] End-of-support dates are clearly specified
- [x] Minimum 6-month deprecation period is enforced
- [x] Legacy features are detected correctly
- [x] Deprecation status is reported
- [x] Legacy support is removed after specified date
- [x] Deprecation timeline is documented
- [x] Deprecation warnings are user-friendly

## Test Plan

- Unit: `vitest run src/deprecation.test.ts` - Test deprecation logic
- Integration: `vitest run src/index.test.ts` - Test deprecation workflow
- Manual: Test deprecation warnings for legacy features
- Manual: Verify legacy support removal after end-of-support date

## Observability

- Deprecation warnings inform users of upcoming changes
- Track deprecation status for analytics
- Add metrics for legacy feature usage

## Compliance

- Follows CLI Tool Standards ADR requirement #35 (Legacy Deprecation Policy)
- Provides clear migration path for users

## Risks & Mitigations

- Risk: Deprecation period is too short
  - Mitigation: Enforce minimum 6-month period, document clearly
- Risk: Users miss deprecation warnings
  - Mitigation: Prominent warnings, multiple notification points
- Risk: Legacy removal breaks existing workflows
  - Mitigation: Clear communication, migration guides, extended support if needed

## Dependencies

- None - this can be developed in parallel with other Phase 8 stories

## Notes

- Deprecation warnings should be prominent but not annoying
- Consider using semantic versioning for deprecation
- Document migration paths clearly
- Provide grace period after end-of-support date
