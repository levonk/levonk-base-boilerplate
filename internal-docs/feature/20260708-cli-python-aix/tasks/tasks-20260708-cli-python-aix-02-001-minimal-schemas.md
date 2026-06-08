---
story_id: "02-001"
story_title: "Minimal Default Schemas"
story_name: "minimal-schemas"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260708-cli-python-aix/story-02-001-minimal-schemas"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["output.py", "schema.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "schema", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement minimal default output schemas (3-4 fields) for list commands. Add `--fields` flag for explicit field selection. Define default schemas for each command, implement field selection logic, and apply to both TOON and JSON formats.

## Sub-Tasks

- [ ] Define default output schemas for each command (3-4 fields) — `output/schema.py`
- [ ] Implement field selection logic — `output/schema.py`
- [ ] Add `--fields` flag to CLI using click/typer — `cli/main.py`
- [ ] Support comma-separated field names in `--fields` flag — `output/schema.py`
- [ ] Validate field names against available fields — `output/schema.py`
- [ ] Apply schema to TOON output format — `output/toon.py`
- [ ] Apply schema to JSON output format — `output/json.py`
- [ ] Set default limits for list commands (e.g., 100 items) — `output/schema.py`
- [ ] Move long-form content to detail views only — `output/schema.py`
- [ ] Test default schemas for all commands — `tests/test_schema.py`
- [ ] Test field selection with `--fields` flag — `tests/test_schema.py`
- [ ] Test schema application to TOON and JSON — `tests/test_schema.py`

## Relevant Files

- `apps/cli/python/core/files/output/schema.py.jinja` — Schema definition and field selection
- `apps/cli/python/core/files/output/toon.py.jinja` — TOON output with schema application
- `apps/cli/python/core/files/output/json.py.jinja` — JSON output with schema application
- `apps/cli/python/core/files/cli/main.py.jinja` — CLI with --fields flag
- `apps/cli/python/core/files/tests/test_schema.py.jinja` — Schema tests

## Acceptance Criteria

- [ ] Default list schemas have 3-4 fields (identifier, title, status)
- [ ] `--fields` flag allows explicit field selection
- [ ] Field names are comma-separated
- [ ] Invalid field names are rejected with clear error
- [ ] Schema applies to both TOON and JSON formats
- [ ] Default limits are appropriate for common cases
- [ ] Long-form content only in detail views
- [ ] All tests pass

## Test Plan

- Unit: Test default schema definitions
- Unit: Test field selection logic
- Unit: Test field validation
- Integration: Test actual CLI output with default schemas
- Integration: Test actual CLI output with --fields flag
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log selected fields for each command
- Log schema application events
- Track field usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Default schemas too minimal for some use cases — Mitigation: Provide --fields escape hatch
- Risk: Field validation too strict — Mitigation: Clear error messages, suggest valid fields
- Risk: Schema changes break existing scripts — Mitigation: Document clearly, version schemas

## Dependencies & Sequencing

- Depends on: 01-002 (TOON Format)
- Unblocks: 02-002 (Content Truncation), 02-003 (Aggregates)

## Definition of Done

- Default schemas defined for all commands
- Field selection works correctly
- Schema applies to both formats
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add minimal default schemas`
- `feat(cli): add --fields flag for field selection`
- `test(output): add tests for schema system`
