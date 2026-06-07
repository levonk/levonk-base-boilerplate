---
story_id: "01-004"
story_title: "Debug Flag"
story_name: "debug-flag"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 4
branch: "feature/current/20260707-cli-go-standards/story-01-004-debug-flag"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add a separate `--debug` flag for detailed diagnostic logging, distinct from the existing `--verbose` flag. Debug mode should enable stack traces, internal state information, and detailed operational logs for troubleshooting.

## Sub-Tasks

- [ ] Add --debug flag to root command — `core/files/main.go.jinja`
- [ ] Add debug log level to logger — `core/files/logger.go.jinja`
- [ ] Implement Debug logging method — `core/files/logger.go.jinja`
- [ ] Add stack trace support in debug mode — `core/files/logger.go.jinja`
- [ ] Add internal state logging in debug mode — `core/files/logger.go.jinja`
- [ ] Update logger initialization to handle debug mode — `core/files/main.go.jinja`
- [ ] Test debug flag enables debug logs — `core/files/logger_test.go.jinja`
- [ ] Test debug mode includes stack traces — `core/files/logger_test.go.jinja`
- [ ] Test debug is separate from verbose — `core/files/logger_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add debug flag
- `apps/cli/go/core/files/logger.go.jinja` — Add debug logging support
- `apps/cli/go/core/files/logger_test.go.jinja` — Tests for debug functionality

## Acceptance Criteria

- [ ] `--debug` flag enables detailed diagnostic logging
- [ ] Debug mode includes stack traces on errors
- [ ] Debug mode logs internal state information
- [ ] Debug is separate from verbose (can be used independently)
- [ ] Debug output is clearly distinguishable from normal logs
- [ ] Debug respects color control settings

## Test Plan

- Unit: Test debug flag behavior
- Integration: Test debug output in error scenarios
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Debug logs include timestamps and module names
- Debug logs include function names and line numbers where possible

## Compliance

- Ensure no sensitive data in debug output
- Debug mode should be clearly indicated in logs

## Risks & Mitigations

- Risk: Debug output may be too verbose — Mitigation: Make debug opt-in only
- Risk: Stack traces may expose internal structure — Mitigation: Document that debug is for development only

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None (standalone feature)

## Definition of Done

- Debug flag works independently from verbose
- Debug output is useful for troubleshooting
- All tests pass

## Commit Conventions

- `feat(logger): add --debug flag for diagnostic logging`
- `feat(logger): add stack trace support in debug mode`
- `test(logger): add tests for debug flag functionality`
