---
story_id: "03-010"
story_title: "Privacy Mode with Anonymous Lists"
story_name: "privacy-mode"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 10
branch: "feature/current/20260707-cli-go-standards/story-03-010-privacy-mode"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["privacy", "main"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "privacy"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement privacy mode with explicit ignore lists for sensitive identifiers. Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely). Provide configurable privacy toggles to disable specific data collection types.

## Sub-Tasks

- [x] Add --privacy flag to root command — `core/files/main.go.jinja`
- [x] Create privacy mode utility — `core/files/privacy.go.jinja`
- [x] Implement ignore list for sensitive identifiers — `core/files/privacy.go.jinja`
- [x] Add distinction between unknown and anonymous — `core/files/privacy.go.jinja`
- [x] Implement configurable privacy toggles — `core/files/privacy.go.jinja`
- [x] Add privacy settings to config file — `core/files/config.default.yaml.jinja`
- [x] Update logger to respect privacy mode — `core/files/logger.go.jinja`
- [x] Test ignore list functionality — `core/files/privacy_test.go.jinja`
- [x] Test unknown vs anonymous distinction — `core/files/privacy_test.go.jinja`
- [x] Test privacy toggles work — `core/files/privacy_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add privacy flag
- `apps/cli/go/core/files/privacy.go.jinja` — New file for privacy logic
- `apps/cli/go/core/files/config.default.yaml.jinja` — Add privacy settings
- `apps/cli/go/core/files/logger.go.jinja` — Update logger for privacy
- `apps/cli/go/core/files/privacy_test.go.jinja` — New file for privacy tests
- `apps/cli/go/core/files/main.go.jinja` — Updated with privacy flag and logger integration

## Acceptance Criteria

- [x] Privacy mode ignores specified identifiers
- [x] Unknown identifiers are logged but not assigned
- [x] Anonymous identifiers are ignored entirely
- [x] Privacy toggles disable specific data collection
- [x] Privacy settings are configurable
- [x] Privacy mode respects user preferences

## Test Plan

- Unit: Test privacy mode functions
- Integration: Test privacy in actual data processing
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Privacy mode status is logged
- Privacy violations are logged

## Compliance

- Ensure privacy mode doesn't break functionality
- Provide clear documentation about privacy implications

## Risks & Mitigations

- Risk: Privacy mode may affect functionality — Mitigation: Make privacy configurable
- Risk: Anonymous vs unknown may be confusing — Mitigation: Clear documentation

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Privacy mode works correctly
- Ignore lists are effective
- Privacy toggles work
- All tests pass

## Commit Conventions

- `feat(privacy): add privacy mode with ignore lists`
- `feat(privacy): add unknown vs anonymous distinction`
- `test(privacy): add tests for privacy mode`
