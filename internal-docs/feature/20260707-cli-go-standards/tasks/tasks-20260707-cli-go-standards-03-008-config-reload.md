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

- [ ] Add signal handling for SIGHUP — `core/files/main.go.jinja`
- [ ] Implement config reload function — `core/files/config.go.jinja`
- [ ] Add config validation before applying — `core/files/config.go.jinja`
- [ ] Implement graceful error handling (keep old config) — `core/files/config.go.jinja`
- [ ] Add logging for reload events — `core/files/config.go.jinja`
- [ ] Test SIGHUP triggers config reload — `core/files/config_test.go.jinja`
- [ ] Test invalid config keeps old config — `core/files/config_test.go.jinja`
- [ ] Test valid config is applied — `core/files/config_test.go.jinja`
- [ ] Test reload events are logged — `core/files/config_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add signal handling
- `apps/cli/go/core/files/config.go.jinja` — Implement reload logic
- `apps/cli/go/core/files/config_test.go.jinja` — Tests for config reload

## Acceptance Criteria

- [ ] SIGHUP signal triggers config reload
- [ ] New config is validated before applying
- [ ] Invalid config keeps old config active
- [ ] Reload events are logged
- [ ] Validation errors are handled gracefully
- [ ] Reload works without restart

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
