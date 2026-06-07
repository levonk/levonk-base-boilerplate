---
story_id: "03-003"
story_title: "File Reference Formatting"
story_name: "file-reference-formatting"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260707-cli-go-standards/story-03-003-file-reference-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-004"]
parallel_safe: true
modules: ["main", "output"]
priority: "COULD"
risk_level: "low"
tags: ["feat", "output"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement VSCode-compatible file reference formatting using `file:///absolute/path/to/file:line:column` format. Support standard `file:line:column` format for terminal linking. Apply to all error messages and file references throughout the CLI.

## Sub-Tasks

- [ ] Create file reference formatting utility — `core/files/refs.go.jinja`
- [ ] Implement VSCode-compatible format — `core/files/refs.go.jinja`
- [ ] Implement standard file:line:column format — `core/files/refs.go.jinja`
- [ ] Update error messages to use file references — `core/files/main.go.jinja`
- [ ] Update logger to use file references — `core/files/logger.go.jinja`
- [ ] Test VSCode format generation — `core/files/refs_test.go.jinja`
- [ ] Test standard format generation — `core/files/refs_test.go.jinja`
- [ ] Test file references in error messages — `core/files/refs_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update error messages
- `apps/cli/go/core/files/logger.go.jinja` — Update logger
- `apps/cli/go/core/files/refs.go.jinja` — New file for reference formatting
- `apps/cli/go/core/files/refs_test.go.jinja` — New file for reference tests

## Acceptance Criteria

- [ ] File references use VSCode-compatible format
- [ ] Standard file:line:column format is supported
- [ ] All error messages include file references
- [ ] File references include line and column numbers
- [ ] File references work with absolute paths
- [ ] Terminal linking works where supported

## Test Plan

- Unit: Test reference formatting functions
- Integration: Test file references in error messages
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- File references are consistent across all output
- File references are clickable in supported terminals

## Compliance

- Ensure file references don't expose sensitive paths
- Handle relative paths correctly

## Risks & Mitigations

- Risk: File references may not work in all terminals — Mitigation: Support both formats
- Risk: Path resolution may be complex — Mitigation: Use absolute paths

## Dependencies & Sequencing

- Depends on: 02-004 (Error Message Formatting)
- Unblocks: None

## Definition of Done

- File references are formatted correctly
- VSCode format works
- Standard format works
- All tests pass

## Commit Conventions

- `feat(output): add VSCode-compatible file references`
- `feat(output): add standard file:line:column format`
- `test(output): add tests for file reference formatting`
