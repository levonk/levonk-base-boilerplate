---
story_id: "01-001"
story_title: "Enhanced Color Control"
story_name: "enhanced-color-control"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-01-001-enhanced-color-control"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger.ts"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-07-14"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Replace the existing `--nocolor` flag with a comprehensive `--color=auto|always|never` flag system that implements smart TTY detection, config file integration, and proper NO_COLOR environment variable precedence. This brings the TypeScript CLI boilerplate into compliance with CLI Tool Standards ADR requirement #6.

## Sub-Tasks

- [ ] Replace `--nocolor` flag with `--color=auto|always|never` flag in index.ts
- [ ] Implement smart TTY detection in auto mode using supports-color library
- [ ] Add color mode resolution precedence logic: NO_COLOR env var > --color flag > config file setting > auto-detection
- [ ] Update logger.ts to support the new color mode system
- [ ] Add `color` setting to config file schema with modes (auto|always|never)
- [ ] Update LoggerOptions interface to include color mode
- [ ] Ensure NO_COLOR environment variable takes precedence over all other color settings
- [ ] Add unit tests for color mode resolution logic
- [ ] Add integration tests for --color flag behavior
- [ ] Add tests for NO_COLOR environment variable handling
- [ ] Update package.json.jinja to ensure supports-color dependency is present
- [ ] Update help text to document new --color flag behavior

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI entry point with flag definitions
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger implementation with color logic
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for CLI
- `apps/cli/typescript/core/files/package.json.jinja` - Dependencies including supports-color

## Acceptance Criteria

- [ ] `--color=auto` flag enables color when TTY detected, disables otherwise
- [ ] `--color=always` flag enables color regardless of TTY
- [ ] `--color=never` flag disables color regardless of TTY
- [ ] NO_COLOR environment variable overrides all --color flag settings
- [ ] Config file `color` setting is respected when no flag or env var is set
- [ ] Color mode resolution follows correct precedence order
- [ ] All existing color functionality continues to work
- [ ] Help text clearly documents the new --color flag behavior

## Test Plan

- Unit: `vitest run src/logger.test.ts` - Test color mode resolution logic
- Integration: `vitest run src/index.test.ts` - Test --color flag behavior
- Manual: Test NO_COLOR environment variable handling
- Manual: Test config file color setting integration

## Observability

- Add logging for color mode resolution in debug mode
- Log when color is disabled due to NO_COLOR or --color=never

## Compliance

- Follows CLI Tool Standards ADR requirement #6 (Output Discipline)
- Ensures backward compatibility with existing color control

## Risks & Mitigations

- Risk: Breaking existing scripts that use --nocolor flag
  - Mitigation: Add deprecation warning for --nocolor flag, maintain compatibility for one release cycle
- Risk: Color detection not working on all terminal types
  - Mitigation: Use well-tested supports-color library, add fallback logic

## Dependencies

- None - this is a foundational story for Phase 1

## Notes

- This change affects the core color control system used throughout the CLI
- Ensure all color-related code in logger.ts is updated consistently
- The supports-color library is already in package.json.jinja dependencies
