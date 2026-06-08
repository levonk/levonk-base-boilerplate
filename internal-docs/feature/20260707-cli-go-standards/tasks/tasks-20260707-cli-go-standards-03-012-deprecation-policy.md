---
story_id: "03-012"
story_title: "Legacy Deprecation Policy"
story_name: "deprecation-policy"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 12
branch: "feature/current/20260707-cli-go-standards/story-03-012-deprecation-policy"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["deprecation", "main"]
priority: "COULD"
risk_level: "low"
tags: ["feat", "deprecation"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement legacy deprecation policy that specifies clear end-of-support dates (minimum 6 months from announcement). Log deprecation warnings to stderr during the deprecation period and remove legacy support only after the specified date.

## Sub-Tasks

- [x] Create deprecation policy utility — `core/files/deprecation.go.jinja`
- [x] Implement deprecation date tracking — `core/files/deprecation.go.jinja`
- [x] Add deprecation warning logging — `core/files/deprecation.go.jinja`
- [x] Implement legacy support removal logic — `core/files/deprecation.go.jinja`
- [x] Add deprecation settings to config file — `core/files/config.default.yaml.jinja`
- [x] Update version checking for deprecation — `core/files/main.go.jinja`
- [x] Test deprecation warnings are logged — `core/files/deprecation_test.go.jinja`
- [x] Test legacy support removal after date — `core/files/deprecation_test.go.jinja`
- [x] Test deprecation policy enforcement — `core/files/deprecation_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add deprecation checking
- `apps/cli/go/core/files/deprecation.go.jinja` — New file for deprecation logic
- `apps/cli/go/core/files/config.default.yaml.jinja` — Add deprecation settings
- `apps/cli/go/core/files/deprecation_test.go.jinja` — New file for deprecation tests

## Acceptance Criteria

- [x] Deprecation dates are clearly specified
- [x] Minimum 6 months deprecation period
- [x] Deprecation warnings logged to stderr
- [x] Legacy support removed only after specified date
- [x] Deprecation policy is enforced
- [x] Users are warned about upcoming removals

## Test Plan

- Unit: Test deprecation policy functions
- Integration: Test deprecation warnings in actual usage
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Deprecation warnings are logged
- Legacy removal events are logged

## Compliance

- Ensure deprecation policy is clearly communicated
- Provide adequate notice before removal

## Risks & Mitigations

- Risk: Users may ignore deprecation warnings — Mitigation: Make warnings prominent
- Risk: Removal may break existing workflows — Mitigation: Ensure adequate notice period

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Deprecation policy works correctly
- Warnings are logged appropriately
- Legacy removal happens on schedule
- All tests pass

## Commit Conventions

- `feat(deprecation): add legacy deprecation policy`
- `feat(deprecation): add deprecation warning logging`
- `test(deprecation): add tests for deprecation policy`
