---
story_id: "04-002"
story_title: "Confirmation Prompts"
story_name: "confirmation-prompts"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-04-002-confirmation-prompts"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["index.ts", "prompts/"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Require confirmation for destructive operations (delete, overwrite, etc.) with a `--force` flag to bypass prompts. Implement consistent prompt format with clear action descriptions. This implements CLI Tool Standards ADR requirement #11.

## Sub-Tasks

- [x] Create prompts module for user interaction
- [x] Add `--force` flag to index.ts
- [x] Implement confirmation prompt for delete operations
- [x] Implement confirmation prompt for overwrite operations
- [x] Implement confirmation prompt for other destructive operations
- [x] Add consistent prompt format with action descriptions
- [x] Implement prompt bypass via --force flag
- [x] Add prompt support for non-TTY environments (env var)
- [x] Add unit tests for confirmation prompts
- [x] Add unit tests for --force flag behavior
- [x] Add integration tests for confirmation workflow
- [x] Update help text to document confirmation prompts
- [x] Add prompt logging in verbose mode

## Relevant Files

- `apps/cli/typescript/core/files/src/prompts.ts.jinja` - Prompts module for user interaction
- `apps/cli/typescript/core/files/src/prompts.test.ts.jinja` - Unit tests for prompts
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with --force flag and prompts import
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for confirmation workflow
- `apps/cli/typescript/core/files/src/install.ts.jinja` - Uninstall operation with confirmation prompts

## Acceptance Criteria

- [x] Destructive operations require user confirmation
- [x] Confirmation prompts show clear action descriptions
- [x] `--force` flag bypasses confirmation prompts
- [x] Prompt format is consistent across all operations
- [x] Prompts work in TTY environments
- [x] Prompts can be bypassed via environment variable for non-TTY
- [x] Confirmation is logged in verbose mode
- [x] Prompt responses are case-insensitive

## Test Plan

- Unit: `vitest run src/prompts.test.ts` - Test prompt logic
- Integration: `vitest run src/index.test.ts` - Test confirmation workflow
- Manual: Test confirmation prompts for destructive operations
- Manual: Test --force flag bypass

## Observability

- Log confirmation prompts in verbose mode
- Track prompt responses for analytics
- Add metrics for confirmation prompt usage

## Compliance

- Follows CLI Tool Standards ADR requirement #11 (Confirmation Prompts)
- Prevents accidental destructive operations

## Risks & Mitigations

- Risk: Prompts are annoying in automated scripts
  - Mitigation: Provide --force flag and environment variable bypass
- Risk: Prompt format is inconsistent
  - Mitigation: Use single prompt function with consistent formatting
- Risk: Prompts don't work in non-TTY environments
  - Mitigation: Add environment variable for non-interactive mode

## Dependencies

- None - this can be developed in parallel with other Phase 4 stories

## Notes

- Use a prompt library like prompts or enquirer for consistent UX
- Prompt format should include: action description, target, and confirmation question
- Consider using YES/NO or y/n for responses
- Prompts should timeout with a default in automated environments
