---
story_id: "03-007"
story_title: "Structured Logging with Format Auto-Detection"
story_name: "structured-logging"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 7
branch: "feature/current/20260707-cli-go-standards/story-03-007-structured-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logging", "main"]
priority: "COULD"
risk_level: "medium"
tags: ["feat", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement structured logging (JSON or structured text) with format auto-detection based on TTY. Support language-native env filters (e.g., LOG_LEVEL) and implement log level resolution: env vars > CLI flags > config file > defaults.

## Sub-Tasks

- [ ] Add structured logging library dependency (e.g., logrus, zap) — `core/files/go.mod.jinja`
- [ ] Implement structured logging format (JSON for non-TTY, pretty for TTY) — `core/files/logger.go.jinja`
- [ ] Add TTY detection for format auto-detection — `core/files/logger.go.jinja`
- [ ] Implement LOG_LEVEL env var support — `core/files/logger.go.jinja`
- [ ] Implement log level resolution precedence — `core/files/logger.go.jinja`
- [ ] Update existing logger to use structured logging — `core/files/logger.go.jinja`
- [ ] Test JSON format for non-TTY output — `core/files/logger_test.go.jinja`
- [ ] Test pretty format for TTY output — `core/files/logger_test.go.jinja`
- [ ] Test LOG_LEVEL env var precedence — `core/files/logger_test.go.jinja`
- [ ] Test log level resolution chain — `core/files/logger_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/go.mod.jinja` — Add structured logging library
- `apps/cli/go/core/files/logger.go.jinja` — Implement structured logging
- `apps/cli/go/core/files/logger_test.go.jinja` — Tests for structured logging

## Acceptance Criteria

- [ ] Structured logging uses JSON format for non-TTY
- [ ] Structured logging uses pretty format for TTY
- [ ] LOG_LEVEL env var is supported
- [ ] Log level resolution follows precedence: env vars > CLI flags > config > defaults
- [ ] Structured logs include consistent fields (timestamp, level, module, message)
- [ ] Format auto-detection works correctly

## Test Plan

- Unit: Test structured logging functions
- Integration: Test format auto-detection in different contexts
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Structured logs are parseable by log aggregators
- Log levels are consistent across the application

## Compliance

- Ensure structured logging doesn't expose sensitive data
- Support both JSON and pretty formats appropriately

## Risks & Mitigations

- Risk: Structured logging may be complex — Mitigation: Use established Go libraries
- Risk: Format detection may fail — Mitigation: Provide manual override

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Structured logging works correctly
- Format auto-detection is reliable
- Log level resolution is correct
- All tests pass

## Commit Conventions

- `feat(logging): add structured logging with format auto-detection`
- `feat(logging): add LOG_LEVEL env var support`
- `test(logging): add tests for structured logging`
