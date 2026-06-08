---
story_id: "02-003"
story_title: "Progress Indicators"
story_name: "progress-indicators"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260707-cli-go-standards/story-02-003-progress-indicators"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-003"]
parallel_safe: true
modules: ["progress", "main"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "progress"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Show progress bars or spinners for long-running operations using a Go progress bar library. Progress indicators must respect the `--quiet` flag (no progress indicators in quiet mode) and apply to file processing, network operations, and other long-running tasks.

## Sub-Tasks

- [x] Add schollz/progressbar or bubbletea dependency to go.mod — `core/files/go.mod.jinja`
- [x] Create progress wrapper utility — `core/files/progress.go.jinja`
- [x] Implement progress bar for file processing — `core/files/main.go.jinja`
- [x] Implement progress bar for network operations — `core/files/main.go.jinja`
- [x] Add quiet mode check to progress display — `core/files/progress.go.jinja`
- [x] Test progress bar displays correctly — `core/files/progress_test.go.jinja`
- [x] Test progress respects --quiet flag — `core/files/progress_test.go.jinja`
- [x] Test progress bar updates accurately — `core/files/progress_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/go.mod.jinja` — Add progress bar dependency
- `apps/cli/go/core/files/main.go.jinja` — Add progress indicators
- `apps/cli/go/core/files/progress.go.jinja` — New file for progress logic
- `apps/cli/go/core/files/progress_test.go.jinja` — New file for progress tests

## Acceptance Criteria

- [x] Progress bars show for long-running operations
- [x] Progress bars respect --quiet flag
- [x] Progress bars update accurately
- [x] Progress bars work for file processing
- [x] Progress bars work for network operations
- [x] Progress bars are visually clear

## Test Plan

- Unit: Test progress bar functions
- Integration: Test progress in actual operations
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Progress bars show current operation
- Progress bars show percentage complete
- Progress bars show estimated time remaining

## Compliance

- Ensure progress bars don't break in non-TTY environments
- Respect user's preference for quiet mode

## Risks & Mitigations

- Risk: Progress bars may not work in all terminals — Mitigation: Graceful fallback
- Risk: Progress may be inaccurate — Mitigation: Use reasonable estimates

## Dependencies & Sequencing

- Depends on: 01-003 (Proper Color Control)
- Unblocks: None

## Definition of Done

- Progress indicators work for all long-running operations
- Progress respects --quiet flag
- All tests pass

## Commit Conventions

- `feat(progress): add progress indicators for long-running operations`
- `feat(progress): add progress bar library`
- `test(progress): add tests for progress indicators`
