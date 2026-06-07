---
story_id: "02-007"
story_title: "Terminal Size Awareness"
story_name: "terminal-size-awareness"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 7
branch: "feature/current/20260707-cli-go-standards/story-02-007-terminal-size-awareness"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "terminal"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "terminal"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement responsive output formatting based on terminal width. Detect terminal size on startup and handle resize events where possible. Fall back to 80-column default when terminal size cannot be detected.

## Sub-Tasks

- [ ] Create terminal size detection utility — `core/files/terminal.go.jinja`
- [ ] Implement terminal width detection on startup — `core/files/terminal.go.jinja`
- [ ] Add resize event handling — `core/files/terminal.go.jinja`
- [ ] Implement responsive output formatting — `core/files/terminal.go.jinja`
- [ ] Add 80-column default fallback — `core/files/terminal.go.jinja`
- [ ] Update output formatting to use terminal width — `core/files/main.go.jinja`
- [ ] Test terminal width detection — `core/files/terminal_test.go.jinja`
- [ ] Test responsive formatting — `core/files/terminal_test.go.jinja`
- [ ] Test fallback to 80 columns — `core/files/terminal_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update output formatting
- `apps/cli/go/core/files/terminal.go.jinja` — New file for terminal logic
- `apps/cli/go/core/files/terminal_test.go.jinja` — New file for terminal tests

## Acceptance Criteria

- [ ] Terminal size is detected on startup
- [ ] Output formatting responds to terminal width
- [ ] Resize events are handled where possible
- [ ] Falls back to 80-column default
- [ ] Output is readable at all terminal sizes
- [ ] Terminal detection doesn't break in non-TTY environments

## Test Plan

- Unit: Test terminal size detection
- Integration: Test responsive formatting
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log detected terminal size on startup
- Log when terminal resize is detected

## Compliance

- Handle non-TTY environments gracefully
- Provide reasonable defaults

## Risks & Mitigations

- Risk: Terminal size detection may fail — Mitigation: Use 80-column default
- Risk: Resize handling may be complex — Mitigation: Handle where possible, fallback otherwise

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Terminal size is detected correctly
- Output formatting is responsive
- Fallback works correctly
- All tests pass

## Commit Conventions

- `feat(terminal): add terminal size detection`
- `feat(terminal): add responsive output formatting`
- `test(terminal): add tests for terminal awareness`
