---
story_id: "02-001"
story_title: "Minimal Default Schemas"
story_name: "minimal-schemas"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260708-cli-go-aix/story-02-001-minimal-schemas"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["output-formats", "cli-commands"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "output", "axi"]
due: "2026-06-16"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement minimal default output schemas (3-4 fields) for all CLI commands to reduce token consumption in agent mode. Add field selection logic via `--fields` flag to allow agents to request additional fields explicitly when needed. This applies to both TOON and JSON output formats.

## Sub-Tasks

- [ ] Define default output schema for each CLI command (identifier, title, status)
- [ ] Create schema definition structure for command outputs
- [ ] Implement field selection logic for output formatting
- [ ] Add `--fields` flag to CLI argument parser
- [ ] Parse comma-separated field names from `--fields` flag
- [ ] Validate field names against available fields for each command
- [ ] Apply schema to TOON output formatting
- [ ] Apply schema to JSON output formatting
- [ ] Set default limits for list outputs (e.g., 100 items)
- [ ] Ensure long-form content (bodies, descriptions) is excluded from list views by default
- [ ] Update all command outputs to use default schemas
- [ ] Write unit tests for schema definition and validation
- [ ] Write unit tests for field selection logic
- [ ] Write integration tests for `--fields` flag functionality
- [ ] Write tests for default schema application to all commands
- [ ] Update CLI help text to document `--fields` flag
- [ ] Add examples of field selection in documentation

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/schema/definition.go` — Schema definition structures (new file)
- `boilerplate/apps/cli/go/core/files/internal/schema/definition_test.go` — Tests for schema definitions (new file)
- `boilerplate/apps/cli/go/core/files/internal/schema/selector.go` — Field selection logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/schema/selector_test.go` — Tests for field selection (new file)
- `boilerplate/apps/cli/go/core/files/internal/output/formatter.go` — Update to apply schemas
- `boilerplate/apps/cli/go/core/files/internal/output/formatter_test.go` — Tests for schema application
- `boilerplate/apps/cli/go/core/files/cli/commands/*.go` — Update each command to define its schema
- `boilerplate/apps/cli/go/core/files/cli/commands/*_test.go` — Update tests for schema compliance

## Acceptance Criteria

- [ ] Each CLI command has a defined default schema with 3-4 fields
- [ ] Default schemas include identifier, title, and status fields
- [ ] `--fields` flag successfully selects custom field sets
- [ ] Field validation rejects invalid field names with clear error messages
- [ ] Schema application works correctly for TOON output
- [ ] Schema application works correctly for JSON output
- [ ] Default limits are applied to list outputs
- [ ] Long-form content is excluded from list views by default
- [ ] All commands comply with default schema requirements
- [ ] All schema functionality has test coverage
- [ ] Help text documents `--fields` flag usage

## Test Plan

- Unit: `go test ./internal/schema/...`
- Unit: `go test ./internal/output/...`
- Integration: `go test ./cli/commands/...`
- Manual: Test `--fields` flag with various field combinations
- Manual: Verify default schemas reduce output size appropriately

## Observability

- Add logging for schema application decisions at debug level
- Add metrics for field selection patterns
- Add metrics for output size reduction from schemas

## Compliance

- Ensure schema validation doesn't leak sensitive field information
- Validate that field selection doesn't bypass security controls

## Risks & Mitigations

- Risk: Schema definitions may be inconsistent across commands — Mitigation: Create schema definition guidelines and lint rules
- Risk: Field selection may break existing integrations — Mitigation: Document breaking changes clearly, provide migration guide

## Dependencies

- Requires: TOON format implementation (01-002) for schema application to TOON output
- No other dependencies (can be developed in parallel with 02-002, 02-003, 02-004)

## Notes

- Schema definitions should be centralized for easy maintenance
- Consider adding schema validation to CI/CD pipeline
- Document recommended field sets for common use cases
