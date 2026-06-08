---
story_id: "02-001"
story_title: "Minimal Default Schemas"
story_name: "minimal-schemas"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260708-cli-typescript-aix/story-02-001-minimal-schemas"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002"]
parallel_safe: true
modules: ["schema", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "schema", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement minimal default output schemas (3-4 fields) for list commands, with field selection via `--fields` flag. Define default schemas for each command and apply to both TOON and JSON output formats.

## Sub-Tasks

- [ ] Define default output schema interface — `src/schema/types.mts`
- [ ] Define default schemas for list commands — `src/schema/defaults.mts`
- [ ] Implement field selection logic — `src/schema/selector.mts`
- [ ] Add `--fields` flag to CLI — `src/cli/flags.mts`
- [ ] Implement field name validation — `src/schema/validator.mts`
- [ ] Integrate schema system into output formatter — `src/output/formatter.mts`
- [ ] Apply schemas to TOON output — `src/output/toon-formatter.mts`
- [ ] Apply schemas to JSON output — `src/output/json-formatter.mts`
- [ ] Add tests for default schemas — `tests/schema/defaults.test.mts`
- [ ] Add tests for field selection — `tests/schema/selector.test.mts`
- [ ] Add tests for field validation — `tests/schema/validator.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/schema/types.mts.jinja` — New file for schema type definitions
- `apps/cli/typescript/core/files/src/schema/defaults.mts.jinja` — New file for default schemas
- `apps/cli/typescript/core/files/src/schema/selector.mts.jinja` — New file for field selection
- `apps/cli/typescript/core/files/src/schema/validator.mts.jinja` — New file for field validation
- `apps/cli/typescript/core/files/src/cli/flags.mts.jinja` — CLI flags (updated with --fields)
- `apps/cli/typescript/core/files/src/output/formatter.mts.jinja` — Output formatter (updated)
- `apps/cli/typescript/core/files/src/output/toon-formatter.mts.jinja` — TOON formatter (updated)
- `apps/cli/typescript/core/files/src/output/json-formatter.mts.jinja` — JSON formatter (updated)
- `apps/cli/typescript/core/files/tests/schema/defaults.test.mts.jinja` — New file for schema tests
- `apps/cli/typescript/core/files/tests/schema/selector.test.mts.jinja` — New file for selector tests
- `apps/cli/typescript/core/files/tests/schema/validator.test.mts.jinja` — New file for validator tests

## Acceptance Criteria

- [ ] Default list schemas have 3-4 fields (identifier, title, status)
- [ ] Default schemas exclude long-form content (bodies, descriptions)
- [ ] `--fields` flag accepts comma-separated field names
- [ ] `--fields` flag validates field names against available fields
- [ ] Field selection works for both TOON and JSON output
- [ ] Invalid field names are rejected with clear error
- [ ] Default limits are appropriate for common cases (e.g., 100 items)
- [ ] All tests pass

## Test Plan

- Unit: Test default schema definitions
- Unit: Test field selection logic
- Unit: Test field validation
- Integration: Test CLI output with `--fields` flag
- Integration: Test CLI output with invalid field names
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log selected fields for each command
- Log schema application
- Log field validation errors

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Default schemas may not cover all use cases — Mitigation: Provide `--fields` flag for customization
- Risk: Field validation may be too strict — Mitigation: Allow flexible field selection
- Risk: Schema system may add complexity — Mitigation: Keep interface simple, document well

## Dependencies & Sequencing

- Depends on: 01-001 (Mode Selection), 01-002 (TOON Format)
- Unblocks: 02-002 (Content Truncation), 02-003 (Aggregates)

## Definition of Done

- Default schemas defined for all list commands
- Field selection implemented
- Field validation implemented
- `--fields` flag works
- Schemas applied to TOON and JSON output
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(schema): define default output schemas`
- `feat(schema): implement field selection logic`
- `feat(schema): add field validation`
- `feat(cli): add --fields flag`
- `feat(output): apply schemas to TOON and JSON output`
- `test(schema): add tests for schema system`
