---
story_id: "04-001"
story_title: "Session Hook Infrastructure"
story_name: "session-hooks"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260708-cli-typescript-aix/story-04-001-session-hooks"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002", "03-003"]
parallel_safe: true
modules: ["hooks", "session"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "hooks", "session"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement session hook infrastructure for ambient context injection. Add `--session-context` command for compact state output in TOON format, `--install-agent-hooks` command for hook registration, and lifecycle capture for session-end hooks.

## Sub-Tasks

- [ ] Implement session context generator — `src/session/context-generator.mts`
- [ ] Add `--session-context` command — `src/commands/session-context.mts`
- [ ] Implement session context in TOON format — `src/session/toon-formatter.mts`
- [ ] Implement hook installer for Claude Code — `src/hooks/claude-installer.mts`
- [ ] Implement hook installer for Codex — `src/hooks/codex-installer.mts`
- [ ] Add `--install-agent-hooks` command — `src/commands/install-hooks.mts`
- [ ] Implement session-end hook registration — `src/hooks/session-end.mts`
- [ ] Implement session metadata storage — `src/session/metadata-store.mts`
- [ ] Add tests for session context generation — `tests/session/context-generator.test.mts`
- [ ] Add tests for hook installation — `tests/hooks/installer.test.mts`
- [ ] Add integration tests for session hooks — `tests/session/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/session/context-generator.mts.jinja` — New file for context generation
- `apps/cli/typescript/core/files/src/session/toon-formatter.mts.jinja` — New file for TOON context formatting
- `apps/cli/typescript/core/files/src/commands/session-context.mts.jinja` — New file for session-context command
- `apps/cli/typescript/core/files/src/hooks/claude-installer.mts.jinja` — New file for Claude hook installer
- `apps/cli/typescript/core/files/src/hooks/codex-installer.mts.jinja` — New file for Codex hook installer
- `apps/cli/typescript/core/files/src/commands/install-hooks.mts.jinja` — New file for install-hooks command
- `apps/cli/typescript/core/files/src/hooks/session-end.mts.jinja` — New file for session-end hooks
- `apps/cli/typescript/core/files/src/session/metadata-store.mts.jinja` — New file for metadata storage
- `apps/cli/typescript/core/files/tests/session/context-generator.test.mts.jinja` — New file for context tests
- `apps/cli/typescript/core/files/tests/hooks/installer.test.mts.jinja` — New file for installer tests
- `apps/cli/typescript/core/files/tests/session/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] `--session-context` outputs compact state in TOON format
- [ ] Session context is token-budget-aware (ruthlessly minimized)
- [ ] Session context includes just enough for agent to orient and act
- [ ] Session context is directory-scoped (relevant to current working directory)
- [ ] Example output: `tasks[2]{id,title,status}: 1,Fix bug,open 2,Add feature,closed help[1]: Run mytool view <id> for details`
- [ ] `--install-agent-hooks` registers hooks for Claude Code and Codex
- [ ] Hook installation checks existing hooks and updates executable path if changed
- [ ] Hook installation is idempotent (repeated installs with same path are silent no-ops)
- [ ] Hook installation uses portable commands (PATH-verified binary name)
- [ ] Hook installation is explicit opt-in (only from setup command)
- [ ] Session-end hooks capture lifecycle metadata
- [ ] Session metadata stored for future context enrichment
- [ ] All tests pass

## Test Plan

- Unit: Test session context generation
- Unit: Test TOON context formatting
- Unit: Test hook installation logic
- Unit: Test session metadata storage
- Integration: Test `--session-context` command
- Integration: Test `--install-agent-hooks` command
- Integration: Test hook registration in Claude Code
- Integration: Test hook registration in Codex
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log session context generation
- Log hook installation events
- Log session metadata storage

## Compliance

- No regulatory constraints
- No sensitive data handling
- Respect user's home directory permissions

## Risks & Mitigations

- Risk: Hook installation may fail due to permissions — Mitigation: Clear error messages, suggest manual installation
- Risk: Session context may be too verbose — Mitigation: Token budget awareness, ruthless minimization
- Risk: Session metadata may grow unbounded — Mitigation: Implement retention policy, cleanup logic

## Dependencies & Sequencing

- Depends on: 01-001 (Mode Selection), 01-002 (TOON Format), 03-003 (Output Channels)
- Unblocks: 04-002 (Agent Skills)

## Definition of Done

- Session context generation implemented
- `--session-context` command implemented
- Hook installation implemented for Claude Code and Codex
- `--install-agent-hooks` command implemented
- Session-end hooks implemented
- Session metadata storage implemented
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(session): implement session context generator`
- `feat(session): add --session-context command`
- `feat(hooks): implement Claude Code hook installer`
- `feat(hooks): implement Codex hook installer`
- `feat(hooks): add --install-agent-hooks command`
- `feat(hooks): implement session-end hooks`
- `feat(session): implement session metadata storage`
- `test(session): add tests for session hooks`
