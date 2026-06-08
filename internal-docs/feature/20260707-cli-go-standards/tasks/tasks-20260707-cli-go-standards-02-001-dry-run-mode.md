---
story_id: "02-001"
story_title: "Dry-Run Mode"
story_name: "dry-run-mode"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260707-cli-go-standards/story-02-001-dry-run-mode"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: true
modules: ["main", "cmd"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "dry-run"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement `--dry-run` flag to preview changes without executing them. The dry-run mode should show exactly what would be done without making any changes to files or system state.

## Sub-Tasks

- [x] Add --dry-run flag to root command — `core/files/main.go.jinja`
- [x] Create dry-run context/flag passing — `core/files/main.go.jinja`
- [x] Implement dry-run output formatting — `core/files/dryrun.go.jinja`
- [x] Add dry-run checks to file operations — `core/files/main.go.jinja`
- [x] Add dry-run checks to destructive operations — `core/files/main.go.jinja`
- [x] Test dry-run shows file operations — `core/files/dryrun_test.go.jinja`
- [x] Test dry-run doesn't execute changes — `core/files/dryrun_test.go.jinja`
- [x] Test dry-run output is clear — `core/files/dryrun_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add dry-run flag and checks
- `apps/cli/go/core/files/dryrun.go.jinja` — New file for dry-run logic
- `apps/cli/go/core/files/dryrun_test.go.jinja` — New file for dry-run tests

## Acceptance Criteria

- [x] `--dry-run` flag shows what would be done
- [x] Dry-run mode doesn't execute any changes
- [x] Dry-run output is clear and actionable
- [x] Dry-run applies to all file operations
- [x] Dry-run applies to all destructive operations
- [x] Dry-run output format is consistent

## Test Plan

- Unit: Test dry-run flag behavior
- Integration: Test dry-run doesn't modify files
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when dry-run mode is active
- Log dry-run operations that would be executed

## Compliance

- Ensure dry-run doesn't accidentally execute operations
- Clear indication in output when in dry-run mode

## Risks & Mitigations

- Risk: Dry-run may be accidentally ignored — Mitigation: Make dry-run explicit in code paths
- Risk: Dry-run output may be incomplete — Mitigation: Test all operation types

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization), 01-006 (Configuration Precedence Chain)
- Unblocks: None

## Definition of Done

- Dry-run flag works for all operations
- No changes are made in dry-run mode
- Dry-run output is clear
- All tests pass

## Commit Conventions

- `feat(dryrun): add --dry-run flag`
- `feat(dryrun): add dry-run output formatting`
- `test(dryrun): add tests for dry-run mode`
