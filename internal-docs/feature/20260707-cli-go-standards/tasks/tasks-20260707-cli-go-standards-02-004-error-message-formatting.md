---
story_id: "02-004"
story_title: "Error Message Formatting"
story_name: "error-message-formatting"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260707-cli-go-standards/story-02-004-error-message-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "error-handling"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Standardize error message format to `ERROR: <description> - <suggestion>` with actionable suggestions for resolution. Include context (file, line number) where applicable and use consistent error types and exit codes.

## Sub-Tasks

- [x] Define error message format constants — `core/files/errors.go.jinja`
- [x] Create error formatting function — `core/files/errors.go.jinja`
- [x] Add suggestion generation for common errors — `core/files/errors.go.jinja`
- [x] Update logger to use new error format — `core/files/logger.go.jinja`
- [x] Add context (file, line) to errors — `core/files/errors.go.jinja`
- [x] Define standard exit codes — `core/files/errors.go.jinja`
- [x] Update error handling throughout codebase — `core/files/main.go.jinja`
- [x] Test error format is consistent — `core/files/errors_test.go.jinja`
- [x] Test suggestions are helpful — `core/files/errors_test.go.jinja`
- [x] Test exit codes are correct — `core/files/errors_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update error handling
- `apps/cli/go/core/files/logger.go.jinja` — Update error logging
- `apps/cli/go/core/files/errors.go.jinja` — New file for error formatting
- `apps/cli/go/core/files/errors_test.go.jinja` — New file for error tests

## Acceptance Criteria

- [x] Error messages follow `ERROR: <description> - <suggestion>` format
- [x] Errors include actionable suggestions
- [x] Errors include context (file, line) where applicable
- [x] Exit codes are consistent (0, 1, 2, 130 for SIGINT)
- [x] Error types are consistent across codebase
- [x] Error messages are clear and helpful

## Test Plan

- Unit: Test error formatting functions
- Integration: Test error messages in actual scenarios
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Error messages include timestamps
- Error messages include module names
- Error messages are logged consistently

## Compliance

- Ensure error messages don't expose sensitive data
- Provide helpful suggestions without exposing internals

## Risks & Mitigations

- Risk: Suggestions may not always be accurate — Mitigation: Keep suggestions generic but helpful
- Risk: Error format may break existing code — Mitigation: Update all error handling consistently

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 03-003 (File Reference Formatting)

## Definition of Done

- All error messages follow standard format
- Suggestions are helpful and accurate
- Exit codes are correct
- All tests pass

## Commit Conventions

- `feat(errors): standardize error message format`
- `feat(errors): add suggestion generation`
- `test(errors): add tests for error formatting`
