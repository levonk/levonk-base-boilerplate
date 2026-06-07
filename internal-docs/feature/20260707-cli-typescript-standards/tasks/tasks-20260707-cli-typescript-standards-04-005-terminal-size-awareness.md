---
story_id: "04-005"
story_title: "Terminal Size Awareness"
story_name: "terminal-size-awareness"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 4
parallel_id: 5
branch: "feature/current/20260707-cli-typescript-standards/story-04-005-terminal-size-awareness"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["terminal/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Detect terminal size on startup and handle resize events where possible. Adjust output formatting based on terminal width and wrap long lines appropriately. This implements CLI Tool Standards ADR requirement #22.

## Sub-Tasks

- [ ] Create terminal module with terminal size detection
- [ ] Implement terminal size detection on startup
- [ ] Implement terminal resize event handling
- [ ] Add output formatting based on terminal width
- [ ] Implement line wrapping for long lines
- [ ] Add table formatting adjustments for terminal width
- [ ] Add fallback for non-TTY environments
- [ ] Add unit tests for terminal size detection
- [ ] Add unit tests for line wrapping logic
- [ ] Add integration tests for terminal-aware output
- [ ] Update help text to document terminal awareness
- [ ] Add terminal size logging in debug mode

## Relevant Files

- `apps/cli/typescript/core/files/src/terminal.ts.jinja` - New terminal module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with terminal integration
- `apps/cli/typescript/core/files/src/terminal.test.ts.jinja` - Unit tests for terminal (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for terminal

## Acceptance Criteria

- [ ] Terminal size is detected on startup
- [ ] Terminal resize events are handled where possible
- [ ] Output formatting adjusts based on terminal width
- [ ] Long lines are wrapped appropriately
- [ ] Table formatting adjusts for terminal width
- [ ] Fallback behavior works for non-TTY environments
- [ ] Terminal size is logged in debug mode
- [ ] Output remains readable at various terminal widths

## Test Plan

- Unit: `vitest run src/terminal.test.ts` - Test terminal size detection
- Integration: `vitest run src/index.test.ts` - Test terminal-aware output
- Manual: Resize terminal during execution and verify output adjusts
- Manual: Test with various terminal widths

## Observability

- Log terminal size in debug mode
- Track terminal resize events
- Add metrics for terminal size distribution

## Compliance

- Follows CLI Tool Standards ADR requirement #22 (Terminal Size Awareness)
- Improves output readability across different terminal sizes

## Risks & Mitigations

- Risk: Terminal size detection fails on some systems
  - Mitigation: Provide sensible defaults, handle errors gracefully
- Risk: Resize event handling is complex
  - Mitigation: Use well-tested library, provide fallback behavior
- Risk: Line wrapping breaks output formatting
  - Mitigation: Test with various content types, preserve structure

## Dependencies

- None - this can be developed in parallel with other Phase 4 stories

## Notes

- Use a terminal size library like term-size or similar
- Resize event handling may not work on all platforms
- Consider using sigwinch event for resize detection
- Line wrapping should preserve table structure and formatting
