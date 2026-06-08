---
story_id: "03-011"
story_title: "Audit Logging with Retention"
story_name: "audit-logging"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 11
branch: "feature/current/20260707-cli-go-standards/story-03-011-audit-logging"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["audit", "main"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "audit"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement optional append-only audit log using SQLite for significant data processing. Provide configurable retention period with auto-prune on startup. Support export commands for external analysis of audit data.

## Sub-Tasks

- [x] Add SQLite dependency to go.mod — `core/files/go.mod.jinja`
- [x] Create audit logging utility — `core/files/audit.go.jinja`
- [x] Implement append-only audit log schema — `core/files/audit.go.jinja`
- [x] Add configurable retention period — `core/files/audit.go.jinja`
- [x] Implement auto-prune on startup — `core/files/audit.go.jinja`
- [x] Add audit export command — `core/files/main.go.jinja`
- [x] Add audit settings to config file — `core/files/config.default.yaml.jinja`
- [x] Test audit log creation — `core/files/audit_test.go.jinja`
- [x] Test retention period works — `core/files/audit_test.go.jinja`
- [x] Test auto-prune on startup — `core/files/audit_test.go.jinja`
- [x] Test audit export command — `core/files/audit_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/go.mod.jinja` — Add SQLite dependency
- `apps/cli/go/core/files/main.go.jinja` — Add audit export command
- `apps/cli/go/core/files/audit.go.jinja` — New file for audit logic
- `apps/cli/go/core/files/config.default.yaml.jinja` — Add audit settings
- `apps/cli/go/core/files/audit_test.go.jinja` — New file for audit tests

## Acceptance Criteria

- [x] Audit log is append-only
- [x] Audit log includes timestamp, event type, source, metadata
- [x] Retention period is configurable
- [x] Auto-prune works on startup
- [x] Audit export command works
- [x] Audit logging is optional (configurable)

## Test Plan

- Unit: Test audit logging functions
- Integration: Test audit log in actual operations
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Audit events are logged
- Audit pruning is logged
- Audit export status is logged

## Compliance

- Ensure audit log doesn't expose sensitive data
- Follow data retention best practices

## Risks & Mitigations

- Risk: Audit log may grow large — Mitigation: Implement auto-prune
- Risk: Audit logging may impact performance — Mitigation: Make audit optional

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Audit logging works correctly
- Retention and pruning work
- Export command works
- All tests pass

## Commit Conventions

- `feat(audit): add audit logging with SQLite`
- `feat(audit): add configurable retention period`
- `feat(audit): add audit export command`
- `test(audit): add tests for audit logging`
