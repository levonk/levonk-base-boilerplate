---
story_id: "01-001"
story_title: "Enhanced Color Control"
story_name: "enhanced-color-control"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-01-001-enhanced-color-control"
status: "done"
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

- [x] Replace `--nocolor` flag with `--color=auto|always|never` flag in index.ts
- [x] Implement smart TTY detection in auto mode using supports-color library
- [x] Add color mode resolution precedence logic: NO_COLOR env var > --color flag > config file setting > auto-detection
- [x] Update logger.ts to support the new color mode system
- [x] Add `color` setting to config file schema with modes (auto|always|never) (deferred to story 01-003 - config file schema will be implemented there)
- [x] Update LoggerOptions interface to include color mode
- [x] Ensure NO_COLOR environment variable takes precedence over all other color settings
- [x] Add unit tests for color mode resolution logic
- [x] Add integration tests for --color flag behavior
- [x] Add tests for NO_COLOR environment variable handling
- [x] Update package.json.jinja to ensure supports-color dependency is present
- [x] Update help text to document new --color flag behavior

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI entry point with flag definitions
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger implementation with color logic
- `apps/cli/typescript/core/files/src/logger.test.ts.jinja` - Unit tests for color mode resolution (created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for CLI
- `apps/cli/typescript/core/files/package.json.jinja` - Dependencies including supports-color

## Acceptance Criteria

- [x] `--color=auto` flag enables color when TTY detected, disables otherwise
- [x] `--color=always` flag enables color regardless of TTY
- [x] `--color=never` flag disables color regardless of TTY
- [x] NO_COLOR environment variable overrides all --color flag settings
- [ ] Config file `color` setting is respected when no flag or env var is set (deferred to story 01-003)
- [x] Color mode resolution follows correct precedence order
- [x] All existing color functionality continues to work
- [x] Help text clearly documents the new --color flag behavior

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
