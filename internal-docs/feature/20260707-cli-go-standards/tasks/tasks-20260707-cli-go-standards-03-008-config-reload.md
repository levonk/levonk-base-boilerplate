---
story_id: "03-008"
story_title: "Signal-Based Config Reload"
story_name: "config-reload"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 8
branch: "feature/current/20260707-cli-go-standards/story-03-008-config-reload"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-007"]
parallel_safe: true
modules: ["config", "main"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "config"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement SIGHUP signal handling to reload config files without restart. Validate new config before applying, log reload events, and handle validation errors gracefully by keeping the old config active.

## Sub-Tasks

- [x] Add signal handling for SIGHUP — `core/files/main.go.jinja`
- [x] Implement config reload function — `core/files/config.go.jinja`
- [x] Add config validation before applying — `core/files/config.go.jinja`
- [x] Implement graceful error handling (keep old config) — `core/files/config.go.jinja`
- [x] Add logging for reload events — `core/files/config.go.jinja`
- [x] Test SIGHUP triggers config reload — `core/files/config_test.go.jinja`
- [x] Test invalid config keeps old config — `core/files/config_test.go.jinja`
- [x] Test valid config is applied — `core/files/config_test.go.jinja`
- [x] Test reload events are logged — `core/files/config_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add signal handling for SIGHUP
- `apps/cli/go/core/files/config.go.jinja` — Implement ReloadConfig function with validation
- `apps/cli/go/core/files/config_test.go.jinja` — Tests for config reload (valid, invalid, missing file)
- `apps/cli/go/core/files/docs.go.jinja` — Fixed date filter issue
- `apps/cli/go/core/files/man.1.jinja` — Fixed date filter issue

## Acceptance Criteria

- [x] SIGHUP signal triggers config reload
- [x] New config is validated before applying
- [x] Invalid config keeps old config active
- [x] Reload events are logged
- [x] Validation errors are handled gracefully
- [x] Reload works without restart

## Test Plan

- Unit: Test config reload functions
- Integration: Test SIGHUP signal handling
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log config reload attempts
- Log reload success/failure
- Log validation errors

## Compliance

- Ensure reload doesn't cause data loss
- Handle platform differences in signal handling

## Risks & Mitigations

- Risk: Signal handling may be platform-specific — Mitigation: Test on multiple platforms
- Risk: Reload may cause inconsistent state — Mitigation: Validate thoroughly before applying

## Dependencies & Sequencing

- Depends on: 01-007 (Configuration Validation)
- Unblocks: None

## Definition of Done

- SIGHUP reload works correctly
- Invalid config is handled gracefully
- All tests pass

## Commit Conventions

- `feat(config): add SIGHUP config reload`
- `feat(config): add config validation before reload`
- `test(config): add tests for config reload`
