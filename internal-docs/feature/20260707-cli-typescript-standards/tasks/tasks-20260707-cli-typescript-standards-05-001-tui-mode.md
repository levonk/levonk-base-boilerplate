---
story_id: "05-001"
story_title: "TUI Mode"
story_name: "tui-mode"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 5
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-05-001-tui-mode"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["tui/"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "cli", "ux"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add Terminal User Interface (TUI) mode with `--interactive` or `--tui` flag. Allow interactive configuration and execution, enabling users to view and modify all arguments before execution. Use blessed, ink, or similar TUI library for TypeScript. This implements CLI Tool Standards ADR requirement #9.

## Sub-Tasks

- [x] Evaluate and select TUI library (blessed, ink, or similar)
- [x] Add selected TUI library to package.json.jinja
- [x] Create TUI module with interactive interface
- [x] Add `--interactive` and `--tui` flags to index.ts
- [x] Implement interactive argument configuration screen
- [x] Implement argument modification interface
- [x] Add execution confirmation in TUI mode
- [x] Implement TUI help and navigation
- [x] Add TUI fallback for non-TTY environments
- [x] Add unit tests for TUI components
- [x] Add integration tests for TUI mode
- [x] Update help text to document TUI mode
- [x] Add keyboard shortcuts for common actions

## Relevant Files

- `apps/cli/typescript/core/files/src/tui.ts.jinja` - New TUI module with Ink-based interactive interface
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with --interactive and --tui flags
- `apps/cli/typescript/core/files/src/tui.test.ts.jinja` - Unit tests for TUI components
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for TUI mode
- `apps/cli/typescript/core/files/package.json.jinja` - Added Ink, ink-text-input, ink-select-input, and React dependencies

## Acceptance Criteria

- [x] `--interactive` and `--tui` flags launch TUI mode
- [x] TUI allows viewing all arguments
- [x] TUI allows modifying all arguments
- [x] TUI provides execution confirmation
- [x] TUI has help and navigation
- [x] TUI falls back gracefully for non-TTY environments
- [x] TUI has keyboard shortcuts for common actions
- [x] TUI is responsive and user-friendly

## Test Plan

- Unit: `vitest run src/tui.test.ts` - Test TUI components
- Integration: `vitest run src/index.test.ts` - Test TUI mode
- Manual: Launch TUI mode and test argument modification
- Manual: Test TUI with various terminal sizes

## Observability

- Log TUI mode activation in debug mode
- Track TUI usage for analytics
- Add metrics for TUI performance

## Compliance

- Follows CLI Tool Standards ADR requirement #9 (TUI Mode Preference)
- Provides interactive configuration experience

## Risks & Mitigations

- Risk: TUI library compatibility issues
  - Mitigation: Choose well-maintained library, test thoroughly
- Risk: TUI doesn't work on all terminals
  - Mitigation: Provide fallback to CLI mode, document requirements
- Risk: TUI development is complex and time-consuming
  - Mitigation: Start with basic features, iterate based on feedback

## Dependencies

- None - this can be developed in parallel with other Phase 5 stories

## Notes

- Consider using ink (React-based) or blessed (traditional) for TUI
- TUI should support keyboard navigation
- TUI should have a clean, intuitive interface
- Consider using a component-based approach for maintainability
