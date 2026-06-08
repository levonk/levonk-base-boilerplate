---
story_id: "02-002"
story_title: "Content Truncation with Escape Hatches"
story_name: "content-truncation"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260708-cli-typescript-aix/story-02-002-content-truncation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002", "01-003"]
parallel_safe: true
modules: ["truncation", "output"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "truncation", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement content truncation for large text fields (descriptions, bodies, logs) with configurable limits, truncation metadata, and `--full` flag to disable truncation. Never omit fields entirely—always include truncated preview.

## Sub-Tasks

- [ ] Implement truncation utility function — `src/truncation/truncator.mts`
- [ ] Add truncation metadata formatting — `src/truncation/formatter.mts`
- [ ] Add `--full` flag to CLI — `src/cli/flags.mts`
- [ ] Integrate truncation into output pipeline — `src/output/pipeline.mts`
- [ ] Apply truncation to all large text fields — `src/output/processor.mts`
- [ ] Add help suggestions for truncated content — `src/output/suggestions.mts`
- [ ] Make truncation limit configurable via config — `src/config/schema.mts`
- [ ] Add tests for truncation logic — `tests/truncation/truncator.test.mts`
- [ ] Add tests for truncation metadata — `tests/truncation/formatter.test.mts`
- [ ] Add integration tests for `--full` flag — `tests/truncation/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/truncation/truncator.mts.jinja` — New file for truncation logic
- `apps/cli/typescript/core/files/src/truncation/formatter.mts.jinja` — New file for truncation metadata
- `apps/cli/typescript/core/files/src/cli/flags.mts.jinja` — CLI flags (updated with --full)
- `apps/cli/typescript/core/files/src/output/pipeline.mts.jinja` — Output pipeline (updated)
- `apps/cli/typescript/core/files/src/output/processor.mts.jinja` — Output processor (updated)
- `apps/cli/typescript/core/files/src/output/suggestions.mts.jinja` — New file for help suggestions
- `apps/cli/typescript/core/files/src/config/schema.mts.jinja` — Config schema (updated with truncation limit)
- `apps/cli/typescript/core/files/tests/truncation/truncator.test.mts.jinja` — New file for truncator tests
- `apps/cli/typescript/core/files/tests/truncation/formatter.test.mts.jinja` — New file for formatter tests
- `apps/cli/typescript/core/files/tests/truncation/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Large text fields are truncated by default (500-1500 chars, default 1000)
- [ ] Truncated fields include metadata: `... (truncated, 8432 chars total)`
- [ ] Truncation never omits fields entirely
- [ ] `--full` flag disables truncation and shows complete content
- [ ] Help suggestions appear when content is truncated
- [ ] Truncation limit is configurable via config file
- [ ] Truncation applies to both agent and human modes
- [ ] All tests pass

## Test Plan

- Unit: Test truncation logic with various field sizes
- Unit: Test truncation metadata formatting
- Unit: Test truncation with different limits
- Integration: Test CLI output with truncated fields
- Integration: Test CLI output with `--full` flag
- Integration: Test truncation with config file setting
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log truncation events
- Log truncation limit used
- Log when `--full` flag is used

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Truncation may cut off important information — Mitigation: Choose appropriate default limit, provide `--full` escape hatch
- Risk: Truncation metadata may be confusing — Mitigation: Clear format with total char count
- Risk: Help suggestions may be noisy — Mitigation: Only show when content is actually truncated

## Dependencies & Sequencing

- Depends on: 01-002 (TOON Format), 01-003 (Config Updates)
- Unblocks: 02-003 (Aggregates)

## Definition of Done

- Truncation logic implemented
- Truncation metadata implemented
- `--full` flag works
- Help suggestions implemented
- Configurable truncation limit
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(truncation): implement content truncation logic`
- `feat(truncation): add truncation metadata formatting`
- `feat(cli): add --full flag to disable truncation`
- `feat(output): integrate truncation into output pipeline`
- `feat(output): add help suggestions for truncated content`
- `test(truncation): add tests for truncation system`
