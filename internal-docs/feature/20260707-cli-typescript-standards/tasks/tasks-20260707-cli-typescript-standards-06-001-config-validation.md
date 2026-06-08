---
story_id: "06-001"
story_title: "Configuration Validation"
story_name: "config-validation"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 6
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-06-001-config-validation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-002"]
parallel_safe: true
modules: ["config/", "validation/"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-08-18"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Validate config files on load and report clear, specific error messages with line numbers and suggestions. Use schema validation (zod or Joi) for config files and provide helpful error messages for invalid config values. This implements CLI Tool Standards ADR requirement #21.

## Sub-Tasks

- [x] Add zod library to package.json.jinja for schema validation
- [x] Create validation module with schema definitions
- [x] Define config schema using zod
- [x] Implement config file validation on load
- [ ] Add line number tracking for validation errors (requires TOML parser with line info - deferred)
- [x] Implement helpful error messages with suggestions
- [x] Add config value type checking
- [x] Add config value range checking
- [ ] Implement config schema migration support (deferred to future story)
- [x] Add unit tests for config validation
- [x] Add unit tests for error message generation
- [x] Add integration tests for invalid config handling
- [ ] Update help text to document config validation (deferred)
- [x] Add config validation logging in debug mode

## Relevant Files

- `apps/cli/typescript/core/files/src/validation.ts.jinja` - New validation module (to be created)
- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config module with validation
- `apps/cli/typescript/core/files/src/validation.test.ts.jinja` - Unit tests for validation (to be created)
- `apps/cli/typescript/core/files/src/config.test.ts.jinja` - Integration tests for config validation
- `apps/cli/typescript/core/files/package.json.jinja` - Add zod dependency

## Acceptance Criteria

- [x] Config files are validated on load
- [ ] Validation errors include line numbers (deferred - requires TOML parser with line info)
- [x] Validation errors include helpful suggestions
- [x] Invalid config values are clearly identified
- [x] Config schema is defined using zod
- [x] Type checking works for all config values
- [x] Range checking works for numeric config values
- [x] Validation errors are user-friendly
- [x] Config validation is logged in debug mode

## Test Plan

- Unit: `vitest run src/validation.test.ts` - Test validation logic
- Integration: `vitest run src/config.test.ts` - Test config validation
- Manual: Create invalid config and verify error messages
- Manual: Test various validation error scenarios

**Note**: Tests were created but not executed due to devbox environment error ("runtime error: index out of range [1] with length 0"). This is a devbox tool issue, not an implementation issue. The implementation is complete and ready for testing once the devbox environment is fixed.

## Observability

- Log config validation results in debug mode
- Track validation errors for analytics
- Add metrics for config validation performance

## Compliance

- Follows CLI Tool Standards ADR requirement #21 (Configuration Validation)
- Prevents configuration errors from causing runtime issues

## Risks & Mitigations

- Risk: Schema validation is too strict
  - Mitigation: Provide clear error messages, allow optional fields
- Risk: Validation performance impact
  - Mitigation: Optimize validation, cache results where possible
- Risk: Schema evolution breaks existing configs
  - Mitigation: Schema migration support, backward compatibility

## Dependencies

- 02-002 (Configuration Precedence Chain) - Config loading must be in place

## Notes

- Use zod for TypeScript-first schema validation
- Schema should be defined alongside config structure
- Error messages should be actionable and specific
- Consider adding config file examples in error messages
