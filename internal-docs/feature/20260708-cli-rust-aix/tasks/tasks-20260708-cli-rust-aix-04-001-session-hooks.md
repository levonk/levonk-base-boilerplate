---
story_id: "04-001"
story_title: "Session Hook Infrastructure"
story_name: "session-hooks"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260708-cli-rust-aix/story-04-001-session-hooks"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002"]
parallel_safe: true
modules: ["session-integration", "cli-commands"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "session-integration", "axi"]
due: "2026-06-18"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement session hook infrastructure for ambient context injection. Add `--session-context` command that outputs compact state in TOON format. Add `--install-agent-hooks` command to register session hooks. Support hook installation for Claude Code and Codex with portable commands and idempotent installation.

## Sub-Tasks

- [~] Design session context output format (compact TOON)
- [ ] Implement `--session-context` command
- [ ] Implement compact state generation for session context
- [ ] Ensure session context is token-budget-aware
- [ ] Make session context directory-scoped (current working directory)
- [ ] Design hook registration system
- [ ] Implement `--install-agent-hooks` command
- [ ] Implement hook installation for Claude Code (settings.json)
- [ ] Implement hook installation for Codex (hooks.json)
- [ ] Implement existing hook checking and path update
- [ ] Make hook installation idempotent (silent no-ops for same path)
- [ ] Implement portable command resolution (PATH-verified vs absolute path)
- [ ] Add session-end hook registration
- [ ] Implement session metadata capture and storage
- [ ] Write unit tests for session context generation
- [ ] Write unit tests for hook registration logic
- [ ] Write integration tests for hook installation
- [ ] Write tests for idempotent hook installation
- [ ] Update CLI help text to document session commands

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/session/context.rs` — Session context generation (new file)
- `boilerplate/apps/cli/rust/core/src/internal/session/tests.rs` — Tests for session context (new file)
- `boilerplate/apps/cli/rust/core/src/internal/session/hooks.rs` — Hook registration logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/session/hooks_tests.rs` — Tests for hook registration (new file)
- `boilerplate/apps/cli/rust/core/src/internal/session/metadata.rs` — Session metadata capture (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/session.rs` — Session commands (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/session_tests.rs` — Tests for session commands (new file)

## Acceptance Criteria

- [ ] `--session-context` command outputs compact TOON state
- [ ] Session context is token-budget-aware
- [ ] Session context is directory-scoped
- [ ] `--install-agent-hooks` command successfully registers hooks
- [ ] Hook installation works for Claude Code
- [ ] Hook installation works for Codex
- [ ] Hook installation checks existing hooks and updates paths
- [ ] Hook installation is idempotent
- [ ] Portable command resolution works correctly
- [ ] Session-end hooks are registered correctly
- [ ] Session metadata is captured and stored
- [ ] All session functionality has test coverage
- [ ] Help text documents session commands

## Test Plan

- Unit: `cargo test --lib internal::session`
- Integration: Test session context output format
- Integration: Test hook installation for Claude Code
- Integration: Test hook installation for Codex
- Manual: Verify session context token efficiency
- Manual: Test hook installation and removal

## Observability

- Add logging for session hook operations at debug level
- Add metrics for session hook installation frequency

## Compliance

- Ensure session context doesn't leak sensitive information
- Validate that hook installation doesn't introduce security vulnerabilities
- Ensure hook file permissions are secure

## Risks & Mitigations

- Risk: Hook installation may fail due to permission issues — Mitigation: Clear error messages, provide manual installation instructions
- Risk: Session context may include too much information — Mitigation: Strict token budget limits, directory scoping

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- Requires: TOON format (01-002) for session context output
- No other dependencies (can be developed in parallel with 04-002)

## Notes

- Session context should be optimized for the most common agent use cases
- Document hook file formats for each platform
- Consider adding hook validation to prevent malformed hooks
