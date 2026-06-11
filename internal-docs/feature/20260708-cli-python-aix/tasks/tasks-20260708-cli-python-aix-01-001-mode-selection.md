---
story_id: "01-001"
story_title: "Mode Selection Implementation"
story_name: "mode-selection"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260708-cli-python-aix/story-01-001-mode-selection"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["cli.py", "config.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "agent-mode"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement mode selection system with default agent mode, human mode triggers, and auto-detection based on TTY and agent session detection. Support mode precedence chain: CLI flags > environment variable > config file > auto-detection.

## Sub-Tasks

- [x] Add mode detection module with TTY and agent session detection — `cli/mode.py`
- [x] Implement agent session detection via environment variables (CLAUDE_SESSION, CODEX_SESSION) — `cli/mode.py`
- [x] Add process parent detection for agent-specific processes — `cli/mode.py`
- [x] Add environment variable support (MYTOOL_MODE) — `cli/mode.py`
- [x] Implement mode precedence chain logic — `cli/mode.py`
- [x] Add `--human` and `--interactive` flags to CLI using click/typer — `cli/main.py`
- [x] Add config file setting for mode preference — `config/config.py`
- [x] Add mode state to context for downstream commands — `cli/context.py`
- [x] Test auto-detection with various TTY/agent scenarios — `tests/test_mode.py`
- [x] Test mode precedence chain overrides — `tests/test_mode.py`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/mode.py.jinja` — New module for mode detection logic
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Main CLI entry point with mode flags
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Config module with mode setting
- `apps/cli/python/core/files/{{project_slug}}/context.py.jinja` — Context module with mode state
- `apps/cli/python/core/files/tests/test_mode.py.jinja` — Tests for mode selection

## Acceptance Criteria

- [ ] Agent mode is default when no explicit selection is provided
- [ ] Auto-detection uses agent mode when TTY is not present OR agent session detected
- [ ] `--human` flag forces human mode
- [ ] `--interactive` or `--tui` flag forces human mode
- [ ] Auto-detection uses human mode when TTY is present AND no agent session
- [ ] Config file setting `mode = "agent" | "human"` is respected
- [ ] Environment variable `MYTOOL_MODE=agent|human` is respected
- [ ] Mode precedence chain works correctly (CLI > ENV > Config > Auto-detect)
- [ ] All tests pass

## Test Plan

- Unit: Test mode detection with various TTY/agent combinations
- Unit: Test mode precedence chain with all override levels
- Integration: Test actual CLI behavior in different environments
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log detected mode on startup
- Log mode detection method (auto-detect, flag, env, config)
- Log mode overrides when they occur

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: False positive agent detection — Mitigation: Use multiple detection methods (env vars + process parent)
- Risk: TTY detection unreliable in some environments — Mitigation: Provide explicit mode flags as override
- Risk: Mode precedence chain confusion — Mitigation: Clear documentation and logging

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-002 (TOON Format), 01-003 (Config Updates)

## Definition of Done

- Mode selection system fully implemented
- Auto-detection works correctly
- All override mechanisms work
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(agent): add mode selection with auto-detection`
- `feat(agent): add --human and --interactive flags`
- `test(agent): add tests for mode selection`
