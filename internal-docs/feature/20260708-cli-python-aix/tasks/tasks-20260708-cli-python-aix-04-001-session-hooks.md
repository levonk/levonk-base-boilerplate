---
story_id: "04-001"
story_title: "Session Hook Infrastructure"
story_name: "session-hooks"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260708-cli-python-aix/story-04-001-session-hooks"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["03-003"]
parallel_safe: true
modules: ["hooks.py", "session.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "hooks", "session"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement session hook infrastructure for ambient context injection. Add `--session-context` command for compact state output in TOON format. Add `--install-agent-hooks` command to register session hooks. Support Claude Code, Codex, and future OpenCode.

## Sub-Tasks

- [ ] Implement `--session-context` command — `cli/session.py`
- [ ] Output compact state in TOON format — `output/session.py`
- [ ] Make output token-budget-aware (ruthlessly minimized) — `output/session.py`
- [ ] Include directory-scoped state only — `output/session.py`
- [ ] Implement `--install-agent-hooks` command — `cli/hooks.py`
- [ ] Check existing hooks and update executable path — `hooks/installer.py`
- [ ] Make install idempotent (silent no-ops) — `hooks/installer.py`
- [ ] Use PATH-verified binary name, fall back to absolute path — `hooks/installer.py`
- [ ] Support Claude Code hook installation — `hooks/claude.py`
- [ ] Support Codex hook installation — `hooks/codex.py`
- [ ] Implement session-end hook registration — `hooks/lifecycle.py`
- [ ] Store session metadata in local cache — `session/cache.py`
- [ ] Test session-context output — `tests/test_session.py`
- [ ] Test hook installation for Claude Code — `tests/test_hooks.py`
- [ ] Test hook installation for Codex — `tests/test_hooks.py`
- [ ] Test hook idempotency — `tests/test_hooks.py`

## Relevant Files

- `apps/cli/python/core/files/cli/session.py.jinja` — Session context command
- `apps/cli/python/core/files/cli/hooks.py.jinja` — Hook installation command
- `apps/cli/python/core/files/output/session.py.jinja` — Session context output
- `apps/cli/python/core/files/hooks/installer.py.jinja` — Hook installer
- `apps/cli/python/core/files/hooks/claude.py.jinja` — Claude Code hooks
- `apps/cli/python/core/files/hooks/codex.py.jinja` — Codex hooks
- `apps/cli/python/core/files/hooks/lifecycle.py.jinja` — Lifecycle hooks
- `apps/cli/python/core/files/session/cache.py.jinja` — Session cache
- `apps/cli/python/core/files/tests/test_session.py.jinja` — Session tests
- `apps/cli/python/core/files/tests/test_hooks.py.jinja` — Hook tests

## Acceptance Criteria

- [ ] `--session-context` outputs compact TOON state
- [ ] Output is token-budget-aware
- [ ] Output is directory-scoped
- [ ] `--install-agent-hooks` registers hooks
- [ ] Hook installation is idempotent
- [ ] Hooks use PATH-verified binary or absolute path
- [ ] Claude Code hooks install correctly
- [ ] Codex hooks install correctly
- [ ] Session-end hooks registered
- [ ] Session metadata cached
- [ ] All tests pass

## Test Plan

- Unit: Test session context output
- Unit: Test hook installation logic
- Unit: Test hook idempotency
- Integration: Test actual hook installation
- Integration: Test actual session context output
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log hook installation events
- Log session context output events
- Log session metadata caching
- Track hook usage if telemetry added later

## Compliance

- No regulatory constraints
- Hook files should have secure permissions
- No sensitive data in session context

## Risks & Mitigations

- Risk: Hook installation fails due to permissions — Mitigation: Clear error messages, suggest manual install
- Risk: Session context too large — Mitigation: Token budget limits, ruthless minimization
- Risk: Hook paths become stale — Mitigation: Update on install, check on each run

## Dependencies & Sequencing

- Depends on: 03-003 (Idempotent Ops)
- Unblocks: 04-002 (Agent Skills)

## Definition of Done

- Session context command implemented
- Hook installation command implemented
- Hooks install for Claude Code and Codex
- Session metadata cached
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(session): add --session-context command`
- `feat(hooks): add --install-agent-hooks command`
- `test(session): add tests for session hooks`
