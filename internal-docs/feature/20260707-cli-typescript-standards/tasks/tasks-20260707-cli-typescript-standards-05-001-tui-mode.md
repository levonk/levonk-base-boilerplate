---
story_id: "05-001"
story_title: "TUI Mode"
story_name: "tui-mode"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 5
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-05-001-tui-mode"
status: "todo"
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

- [ ] Evaluate and select TUI library (blessed, ink, or similar)
- [ ] Add selected TUI library to package.json.jinja
- [ ] Create TUI module with interactive interface
- [ ] Add `--interactive` and `--tui` flags to index.ts
- [ ] Implement interactive argument configuration screen
- [ ] Implement argument modification interface
- [ ] Add execution confirmation in TUI mode
- [ ] Implement TUI help and navigation
- [ ] Add TUI fallback for non-TTY environments
- [ ] Add unit tests for TUI components
- [ ] Add integration tests for TUI mode
- [ ] Update help text to document TUI mode
- [ ] Add keyboard shortcuts for common actions

## Relevant Files

- `apps/cli/typescript/core/files/src/tui.ts.jinja` - New TUI module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with TUI flags
- `apps/cli/typescript/core/files/src/tui.test.ts.jinja` - Unit tests for TUI (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for TUI
- `apps/cli/typescript/core/files/package.json.jinja` - Add TUI library dependency

## Acceptance Criteria

- [ ] `--interactive` and `--tui` flags launch TUI mode
- [ ] TUI allows viewing all arguments
- [ ] TUI allows modifying all arguments
- [ ] TUI provides execution confirmation
- [ ] TUI has help and navigation
- [ ] TUI falls back gracefully for non-TTY environments
- [ ] TUI has keyboard shortcuts for common actions
- [ ] TUI is responsive and user-friendly

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
