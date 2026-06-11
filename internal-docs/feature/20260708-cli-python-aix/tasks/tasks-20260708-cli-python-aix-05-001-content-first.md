---
story_id: "05-001"
story_title: "Content First No-Args"
story_name: "content-first"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 5
parallel_id: 1
branch: "feature/current/20260708-cli-python-aix/story-05-001-content-first"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["04-002"]
parallel_safe: false
modules: ["cli.py", "output.py"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "content-first", "ux"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement content-first no-args behavior. Running CLI with no arguments shows most relevant live content, not usage manual. When agent sees actual state, it can act immediately. Move detailed help to `--help` flag. Apply to both agent and human modes.

## Sub-Tasks

- [x] Identify no-args invocation in CLI — `cli/main.py`
- [x] Redesign no-args to show state summary — `cli/noargs.py`
- [x] Show most relevant live content for current directory — `output/noargs.py`
- [x] Move detailed help to `--help` flag only — `cli/help.py`
- [x] Apply content-first to agent mode — `cli/noargs.py`
- [x] Apply content-first to human mode — `cli/noargs.py`
- [x] Show different content based on current directory/context — `output/noargs.py`
- [x] Format output in TOON for agent mode — `output/noargs.py`
- [x] Format output in human-readable for human mode — `output/noargs.py`
- [x] Test no-args output in agent mode — `tests/test_noargs.py`
- [x] Test no-args output in human mode — `tests/test_noargs.py`
- [x] Test context-aware content display — `tests/test_noargs.py`

## Relevant Files

- `apps/cli/python/core/files/cli/main.py.jinja` — Main CLI with no-args handling
- `apps/cli/python/core/files/cli/noargs.py.jinja` — No-args logic
- `apps/cli/python/core/files/cli/help.py.jinja` — Help logic
- `apps/cli/python/core/files/output/noargs.py.jinja` — No-args output
- `apps/cli/python/core/files/tests/test_noargs.py.jinja` — No-args tests

## Acceptance Criteria

- [x] No-args shows most relevant live content
- [x] No-args does not show usage manual
- [x] Agent sees actual state and can act immediately
- [x] Detailed help available via `--help` flag
- [x] Content-first applies to agent mode
- [x] Content-first applies to human mode
- [x] Content varies based on directory/context
- [x] Output in TOON for agent mode
- [x] Output in human-readable for human mode
- [x] All tests pass

## Test Plan

- Unit: Test no-args content selection
- Unit: Test context-aware content display
- Integration: Test actual CLI no-args behavior
- Integration: Test actual CLI --help behavior
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log no-args invocation events
- Log content selection events
- Track no-args usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data in no-args output

## Risks & Mitigations

- Risk: No-args content not relevant — Mitigation: Context-aware selection, test with real scenarios
- Risk: Users confused by missing help — Mitigation: Clear message, suggest --help
- Risk: Context detection unreliable — Mitigation: Fallback to safe default, document behavior

## Dependencies & Sequencing

- Depends on: 04-002 (Agent Skills)
- Unblocks: 05-002 (Contextual Disclosure)

## Definition of Done

- Content-first no-args implemented
- State summary shown on no-args
- Help moved to --help flag
- Context-aware content display
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(cli): implement content-first no-args behavior`
- `feat(cli): move detailed help to --help flag`
- `test(cli): add tests for content-first no-args`
