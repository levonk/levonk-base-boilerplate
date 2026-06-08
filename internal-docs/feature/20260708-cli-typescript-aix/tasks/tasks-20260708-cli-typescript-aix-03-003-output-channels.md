---
story_id: "03-003"
story_title: "Output Channels Separation"
story_name: "output-channels"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260708-cli-typescript-aix/story-03-003-output-channels"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["03-001", "03-002"]
parallel_safe: true
modules: ["output", "logging"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "output", "logging"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement proper output channel separation: stdout for structured output (data, errors, suggestions), stderr for debug logging, progress indicators, and diagnostics (agents don't read this), and proper exit codes. Never mix progress messages into stdout.

## Sub-Tasks

- [ ] Implement stdout writer for structured output — `src/output/stdout-writer.mts`
- [ ] Implement stderr writer for debug logging — `src/logging/stderr-writer.mts`
- [ ] Separate progress indicators to stderr — `src/progress/indicator.mts`
- [ ] Ensure no progress messages in stdout — `src/output/pipeline.mts`
- [ ] Update all commands to use proper channels — `src/commands/*.mts`
- [ ] Add debug logging configuration — `src/logging/config.mts`
- [ ] Add tests for output channel separation — `tests/output/channels.test.mts`
- [ ] Add tests for progress indicator placement — `tests/progress/indicator.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/output/stdout-writer.mts.jinja` — New file for stdout writer
- `apps/cli/typescript/core/files/src/logging/stderr-writer.mts.jinja` — New file for stderr writer
- `apps/cli/typescript/core/files/src/progress/indicator.mts.jinja` — Progress indicator (updated to use stderr)
- `apps/cli/typescript/core/files/src/output/pipeline.mts.jinja` — Output pipeline (updated)
- `apps/cli/typescript/core/files/src/logging/config.mts.jinja` — New file for logging config
- `apps/cli/typescript/core/files/src/commands/*.mts.jinja` — All commands (updated for channel separation)
- `apps/cli/typescript/core/files/tests/output/channels.test.mts.jinja` — New file for channel tests
- `apps/cli/typescript/core/files/tests/progress/indicator.test.mts.jinja` — Progress indicator tests (updated)

## Acceptance Criteria

- [ ] stdout contains only structured output (data, errors, suggestions)
- [ ] stderr contains debug logging, progress indicators, diagnostics
- [ ] No progress messages in stdout
- [ ] Exit codes: 0 = success (including no-ops), 1 = error, 2 = usage error
- [ ] Debug logging goes to stderr
- [ ] Progress indicators go to stderr
- [ ] All commands use proper output channels
- [ ] All tests pass

## Test Plan

- Unit: Test stdout writer
- Unit: Test stderr writer
- Integration: Test output channel separation
- Integration: Test progress indicator placement
- Integration: Test debug logging placement
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log output channel usage
- Log debug logging configuration

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Progress indicators may accidentally go to stdout — Mitigation: Strict channel separation, comprehensive tests
- Risk: Debug logging may be noisy — Mitigation: Configurable log levels
- Risk: Channel separation may break existing tools — Mitigation: Clear documentation, migration guide

## Dependencies & Sequencing

- Depends on: 03-001 (Structured Errors), 03-002 (No Interactive Prompts)
- Unblocks: 04-001 (Session Hooks)

## Definition of Done

- Output channel separation implemented
- stdout writer implemented
- stderr writer implemented
- Progress indicators moved to stderr
- All commands updated
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(output): implement stdout writer for structured output`
- `feat(logging): implement stderr writer for debug logging`
- `feat(progress): move progress indicators to stderr`
- `refactor(commands): update all commands for channel separation`
- `test(output): add tests for output channel separation`
