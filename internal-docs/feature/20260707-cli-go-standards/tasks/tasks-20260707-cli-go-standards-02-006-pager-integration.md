---
story_id: "02-006"
story_title: "Pager Integration"
story_name: "pager-integration"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 6
branch: "feature/current/20260707-cli-go-standards/story-02-006-pager-integration"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "output"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "output"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement auto-pager for long output that respects the `PAGER` environment variable (defaulting to `less`) and provides a `--no-pager` flag to bypass. Detect when output exceeds terminal height and automatically invoke the pager.

## Sub-Tasks

- [x] Add --no-pager flag to root command — `core/files/main.go.jinja`
- [x] Create pager detection utility — `core/files/pager.go.jinja`
- [x] Implement terminal height detection — `core/files/pager.go.jinja`
- [x] Add auto-pager logic for long output — `core/files/pager.go.jinja`
- [x] Implement PAGER env var support — `core/files/pager.go.jinja`
- [x] Add --no-pager bypass logic — `core/files/main.go.jinja`
- [x] Test pager activates for long output — `core/files/pager_test.go.jinja`
- [x] Test --no-pager bypasses pager — `core/files/pager_test.go.jinja`
- [x] Test PAGER env var is respected — `core/files/pager_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add --no-pager flag
- `apps/cli/go/core/files/pager.go.jinja` — New file for pager logic
- `apps/cli/go/core/files/pager_test.go.jinja` — New file for pager tests

## Acceptance Criteria

- [x] Auto-pager activates for long output
- [x] PAGER environment variable is respected
- [x] Default pager is `less`
- [x] `--no-pager` flag bypasses pager
- [x] Pager detects terminal height correctly
- [x] Pager doesn't activate for short output

## Test Plan

- Unit: Test pager detection and activation
- Integration: Test pager with actual long output
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when pager is activated
- Log which pager is being used

## Compliance

- Respect user's PAGER preference
- Handle missing pager gracefully

## Risks & Mitigations

- Risk: Pager may not work in all environments — Mitigation: Graceful fallback
- Risk: Terminal height detection may fail — Mitigation: Use reasonable default

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Auto-pager works for long output
- PAGER env var is respected
- --no-pager flag works
- All tests pass

## Commit Conventions

- `feat(output): add auto-pager for long output`
- `feat(output): add PAGER environment variable support`
- `test(output): add tests for pager integration`
