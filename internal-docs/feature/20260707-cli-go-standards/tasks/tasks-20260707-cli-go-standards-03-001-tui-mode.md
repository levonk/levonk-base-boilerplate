---
story_id: "03-001"
story_title: "TUI Mode"
story_name: "tui-mode"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260707-cli-go-standards/story-03-001-tui-mode"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: true
modules: ["tui", "main"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "tui"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement TUI (Terminal User Interface) mode using bubbletea library that allows interactive configuration and execution. Trigger via `--interactive` or `--tui` flag. The TUI should allow users to view and modify all arguments before execution with intuitive navigation.

## Sub-Tasks

- [x] Add bubbletea library dependency — `core/files/go.mod.jinja`
- [x] Add --interactive and --tui flags — `core/files/main.go.jinja`
- [x] Create TUI application structure — `core/files/tui.go.jinja`
- [x] Implement argument selection UI — `core/files/tui.go.jinja`
- [x] Implement argument modification UI — `core/files/tui.go.jinja`
- [x] Add execution confirmation in TUI — `core/files/tui.go.jinja`
- [x] Handle keyboard navigation — `core/files/tui.go.jinja`
- [x] Test TUI launches correctly — `core/files/tui_test.go.jinja`
- [x] Test TUI argument modification — `core/files/tui_test.go.jinja`
- [x] Test TUI execution flow — `core/files/tui_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/go.mod.jinja` — Add bubbletea dependency
- `apps/cli/go/core/files/main.go.jinja` — Add TUI flags
- `apps/cli/go/core/files/tui.go.jinja` — New file for TUI logic
- `apps/cli/go/core/files/tui_test.go.jinja` — New file for TUI tests

## Acceptance Criteria

- [x] `--interactive` and `--tui` flags launch TUI
- [x] TUI allows viewing all arguments
- [x] TUI allows modifying arguments
- [x] TUI has intuitive keyboard navigation
- [x] TUI confirms before execution
- [x] TUI respects color settings
- [x] TUI works in different terminal sizes

## Test Plan

- Unit: Test TUI components
- Integration: Test TUI interaction flow
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when TUI mode is launched
- Log TUI user actions

## Compliance

- Ensure TUI works in different terminal types
- Handle TUI errors gracefully

## Risks & Mitigations

- Risk: TUI may not work in all terminals — Mitigation: Test on multiple terminals
- Risk: TUI complexity may be high — Mitigation: Keep TUI simple and focused

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization), 01-006 (Configuration Precedence Chain)
- Unblocks: None

## Definition of Done

- TUI mode works for all arguments
- TUI navigation is intuitive
- All tests pass

## Commit Conventions

- `feat(tui): add TUI mode with bubbletea`
- `feat(tui): add argument selection UI`
- `test(tui): add tests for TUI mode`
