---
story_id: "02-001"
story_title: "Minimal Default Schemas"
story_name: "minimal-schemas"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260708-cli-rust-aix/story-02-001-minimal-schemas"
status: "in_progress"
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

- [x] Define default output schema for each CLI command (identifier, title, status)
- [x] Create schema definition structure for command outputs
- [x] Implement field selection logic for output formatting
- [x] Add `--fields` flag to CLI argument parser
- [x] Parse comma-separated field names from `--fields` flag
- [x] Validate field names against available fields for each command
- [x] Apply schema to TOON output formatting
- [x] Apply schema to JSON output formatting
- [x] Set default limits for list outputs (e.g., 100 items)
- [x] Ensure long-form content (bodies, descriptions) is excluded from list views by default
- [x] Update all command outputs to use default schemas
- [x] Write unit tests for schema definition and validation
- [x] Write unit tests for field selection logic
- [x] Write integration tests for `--fields` flag functionality
- [x] Write tests for default schema application to all commands
- [x] Update CLI help text to document `--fields` flag
- [x] Add examples of field selection in documentation

## Relevant Files

- `apps/cli/rust/core/files/src/internal/schema/definition.rs.jinja` — Schema definition structures (new file)
- `apps/cli/rust/core/files/src/internal/schema/selector.rs.jinja` — Field selection logic (new file)
- `apps/cli/rust/core/files/src/internal/schema/schemas.rs.jinja` — Default command schemas (new file)
- `apps/cli/rust/core/files/src/internal/schema/mod.rs.jinja` — Schema module exports (new file)
- `apps/cli/rust/core/files/src/internal/toon/mod.rs.jinja` — Updated to apply schemas
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Added --fields flag
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrated schema registry and field selection
- `apps/cli/rust/core/files/README.md.jinja` — Added field selection documentation

## Acceptance Criteria

- [x] Each CLI command has a defined default schema with 3-4 fields
- [x] Default schemas include identifier, title, and status fields
- [x] `--fields` flag successfully selects custom field sets
- [x] Field validation rejects invalid field names with clear error messages
- [x] Schema application works correctly for TOON output
- [x] Schema application works correctly for JSON output
- [x] Default limits are applied to list outputs
- [x] Long-form content is excluded from list views by default
- [x] All commands comply with default schema requirements
- [x] All schema functionality has test coverage
- [x] Help text documents `--fields` flag usage

## Test Plan

- Unit: `cargo test --lib internal::schema`
- Unit: `cargo test --lib internal::output`
- Integration: `cargo test --lib cli::commands`
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
