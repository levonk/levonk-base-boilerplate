---
story_id: "01-001"
story_title: "Mode Selection Implementation"
story_name: "mode-selection"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260708-cli-typescript-aix/story-01-001-mode-selection"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["mode", "main"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "mode"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement mode selection system with agent mode as default, human mode via explicit flags, auto-detection based on TTY and agent session environment variables, and a clear precedence chain for mode determination.

## Sub-Tasks

- [ ] Add mode detection utility functions — `src/mode/detector.mts`
- [ ] Implement TTY detection using `isTTY` from Node.js — `src/mode/detector.mts`
- [ ] Implement agent session detection (CLAUDE_SESSION, CODEX_SESSION) — `src/mode/detector.mts`
- [ ] Add `--human` flag to force human mode — `src/cli/flags.mts`
- [ ] Add `--interactive` and `--tui` flags to force human mode — `src/cli/flags.mts`
- [ ] Implement mode precedence chain logic — `src/mode/selector.mts`
- [ ] Add environment variable support (MYTOOL_MODE) — `src/mode/selector.mts`
- [ ] Integrate mode selection into main CLI entry point — `src/index.mts`
- [ ] Add mode detection tests — `tests/mode/detector.test.mts`
- [ ] Add mode precedence tests — `tests/mode/selector.test.mts`
- [ ] Add integration tests for mode selection scenarios — `tests/mode/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/mode/detector.mts.jinja` — New file for mode detection logic
- `apps/cli/typescript/core/files/src/mode/selector.mts.jinja` — New file for mode selection logic
- `apps/cli/typescript/core/files/src/cli/flags.mts.jinja` — CLI flags definition (updated with mode flags)
- `apps/cli/typescript/core/files/src/index.mts.jinja` — Main entry point (updated with mode selection)
- `apps/cli/typescript/core/files/tests/mode/detector.test.mts.jinja` — New file for detector tests
- `apps/cli/typescript/core/files/tests/mode/selector.test.mts.jinja` — New file for selector tests
- `apps/cli/typescript/core/files/tests/mode/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] Agent mode is default when no explicit mode selection provided
- [ ] Agent mode auto-detects when TTY is not present
- [ ] Agent mode auto-detects when CLAUDE_SESSION or CODEX_SESSION env var is set
- [ ] `--human` flag forces human mode
- [ ] `--interactive` or `--tui` flags force human mode
- [ ] Human mode auto-detects when TTY is present AND no agent session detected
- [ ] Config file setting `mode = "agent" | "human"` is respected
- [ ] Environment variable `MYTOOL_MODE=agent|human` is respected
- [ ] Mode precedence chain works: CLI flags > env var > config > auto-detection
- [ ] All tests pass

## Test Plan

- Unit: Test TTY detection with various scenarios
- Unit: Test agent session detection with environment variables
- Unit: Test mode precedence chain logic
- Integration: Test actual CLI behavior with different mode triggers
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log detected mode on startup
- Log mode selection reason (flag, env var, config, auto-detection)
- Log TTY detection result
- Log agent session detection result

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: TTY detection may fail in some terminal environments — Mitigation: Test across different terminal emulators
- Risk: Agent session detection may miss new agent types — Mitigation: Make detection extensible for future agents
- Risk: Mode precedence chain may be confusing — Mitigation: Clear documentation and logging

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-002 (TOON Format), 01-003 (Config Updates), 02-001 (Minimal Schemas), 03-001 (Structured Errors)

## Definition of Done

- Mode selection system fully implemented
- Auto-detection works correctly
- All mode triggers (flags, env var, config) work
- Precedence chain is correct
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(mode): add mode selection with agent/human modes`
- `feat(mode): add TTY and agent session detection`
- `feat(mode): implement mode precedence chain`
- `test(mode): add tests for mode selection`
