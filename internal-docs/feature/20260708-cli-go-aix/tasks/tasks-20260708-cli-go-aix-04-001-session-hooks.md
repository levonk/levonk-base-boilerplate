---
story_id: "04-001"
story_title: "Session Hook Infrastructure"
story_name: "session-hooks"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260708-cli-go-aix/story-04-001-session-hooks"
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

- [x] Design session context output format (compact TOON)
- [x] Implement `--session-context` command
- [x] Implement compact state generation for session context
- [x] Ensure session context is token-budget-aware
- [x] Make session context directory-scoped (current working directory)
- [x] Design hook registration system
- [x] Implement `--install-agent-hooks` command
- [x] Implement hook installation for Claude Code (settings.json)
- [x] Implement hook installation for Codex (hooks.json)
- [x] Implement existing hook checking and path update
- [x] Make hook installation idempotent (silent no-ops for same path)
- [x] Implement portable command resolution (PATH-verified vs absolute path)
- [x] Add session-end hook registration
- [x] Implement session metadata capture and storage
- [x] Write unit tests for session context generation
- [x] Write unit tests for hook registration logic
- [x] Write integration tests for hook installation
- [x] Write tests for idempotent hook installation
- [x] Update CLI help text to document session commands

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/session/context.go.jinja` — Session context generation (new file)
- `boilerplate/apps/cli/go/core/files/internal/session/context_test.go.jinja` — Tests for session context (new file)
- `boilerplate/apps/cli/go/core/files/internal/session/hooks.go.jinja` — Hook registration logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/session/hooks_test.go.jinja` — Tests for hook registration (new file)
- `boilerplate/apps/cli/go/core/files/internal/session/metadata.go.jinja` — Session metadata capture (new file)
- `boilerplate/apps/cli/go/core/files/session.go.jinja` — Session commands (new file)
- `boilerplate/apps/cli/go/core/files/session_test.go.jinja` — Tests for session commands (new file)

## Acceptance Criteria

- [x] `--session-context` command outputs compact TOON state
- [x] Session context is token-budget-aware
- [x] Session context is directory-scoped
- [x] `--install-agent-hooks` command successfully registers hooks
- [x] Hook installation works for Claude Code
- [x] Hook installation works for Codex
- [x] Hook installation checks existing hooks and updates paths
- [x] Hook installation is idempotent
- [x] Portable command resolution works correctly
- [x] Session-end hooks are registered correctly
- [x] Session metadata is captured and stored
- [x] All session functionality has test coverage
- [x] Help text documents session commands

## Test Plan

- Unit: `go test ./internal/session/...`
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
