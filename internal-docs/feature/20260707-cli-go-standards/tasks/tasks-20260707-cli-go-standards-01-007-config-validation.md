---
story_id: "01-007"
story_title: "Configuration Validation"
story_name: "config-validation"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 7
branch: "feature/current/20260707-cli-go-standards/story-01-007-config-validation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-006"]
parallel_safe: true
modules: ["config", "main"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "config"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement configuration file validation on load with clear, specific error messages including line numbers and suggestions for resolution. Validate against a schema before using the configuration to prevent runtime errors from invalid config.

## Sub-Tasks

- [x] Define config schema/validation rules — `core/files/config.go.jinja`
- [x] Implement config validation function — `core/files/config.go.jinja`
- [x] Add line number tracking for errors — `core/files/config.go.jinja`
- [x] Implement suggestion generation for common errors — `core/files/config.go.jinja`
- [x] Integrate validation into config loading — `core/files/main.go.jinja`
- [x] Test validation catches invalid types — `core/files/config_test.go.jinja`
- [x] Test validation provides line numbers — `core/files/config_test.go.jinja`
- [x] Test validation provides suggestions — `core/files/config_test.go.jinja`
- [x] Test validation allows valid config — `core/files/config_test.go.jinja`
- [x] Test validation error messages are clear — `core/files/config_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Integrate validation
- `apps/cli/go/core/files/config.go.jinja` — Implement validation logic
- `apps/cli/go/core/files/config_test.go.jinja` — Tests for validation

## Acceptance Criteria

- [x] Config files are validated on load
- [x] Validation errors include line numbers
- [x] Validation errors include specific descriptions
- [x] Validation errors include suggestions for resolution
- [x] Invalid config prevents application startup
- [x] Valid config passes validation without errors
- [x] Validation handles both YAML and TOML formats

## Test Plan

- Unit: Test validation logic with various invalid configs
- Integration: Test validation in config loading flow
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log validation results
- Log validation errors with context
- Log when config is valid

## Compliance

- Ensure validation doesn't expose sensitive data in error messages
- Provide helpful error messages without exposing internals

## Risks & Mitigations

- Risk: Validation may be too strict — Mitigation: Allow optional fields where appropriate
- Risk: Error messages may be confusing — Mitigation: Test error messages with users

## Dependencies & Sequencing

- Depends on: 01-006 (Configuration Precedence Chain)
- Unblocks: 03-005 (Credential/Secret Handling), 03-006 (Config Auto-Migration)

## Definition of Done

- Config validation works for all config files
- Error messages are clear and actionable
- All tests pass
- Validation doesn't break valid configs

## Commit Conventions

- `feat(config): add config file validation`
- `feat(config): add line numbers to validation errors`
- `test(config): add tests for config validation`
