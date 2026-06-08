---
story_id: "02-007"
story_title: "Terminal Size Awareness"
story_name: "terminal-size-awareness"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 7
branch: "feature/current/20260707-cli-python-standards/story-02-007-terminal-size-awareness"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "terminal"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Detect terminal size on startup, format output based on terminal width, handle resize events where possible, and fall back to 80-column default.

## Sub-Tasks

- [ ] Add terminal size detection
- [ ] Format output based on terminal width
- [ ] Handle resize events
- [ ] Implement 80-column default fallback
- [ ] Add tests for terminal awareness
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/terminal.py.jinja` - Terminal module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_terminal.py.jinja` - Terminal tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Terminal size detected on startup
- [ ] Output formatted based on terminal width
- [ ] Resize events handled where possible
- [ ] 80-column default fallback works
- [ ] Tests verify terminal awareness

## Test Plan

- Unit: `pytest tests/test_terminal.py -v -k test_size`
- Integration: `pytest tests/test_main.py -v -k test_terminal`
- Manual: Test in different terminal sizes

## Observability

- Log terminal size detection
- Log resize events

## Compliance

- Handle terminals without size detection gracefully
- Provide reasonable defaults

## Risks & Mitigations

- Risk: Size detection fails — Mitigation: Use default width
- Risk: Resize events not supported — Mitigation: Best effort only

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 04-001

## Definition of Done

- Terminal awareness implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add terminal size awareness`

## Changelog

- 2025-07-08: initialized story file
