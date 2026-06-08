---
story_id: "02-006"
story_title: "Pager Integration"
story_name: "pager-integration"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 6
branch: "feature/current/20260707-cli-python-standards/story-02-006-pager-integration"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "output"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Auto-pager for long output. Respect `PAGER` environment variable (default to `less`), provide `--no-pager` flag to bypass, and detect when output exceeds terminal height.

## Sub-Tasks

- [x] Add pager integration logic
- [x] Respect PAGER environment variable
- [x] Implement --no-pager flag
- [x] Detect terminal height
- [x] Auto-pager long output
- [x] Add tests for pager integration
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_main.py.jinja` - Main tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Long output auto-paged
- [ ] PAGER environment variable respected
- [ ] Default pager is `less`
- [ ] `--no-pager` flag bypasses paging
- [ ] Terminal height detection works
- [ ] Tests verify pager behavior

## Test Plan

- Unit: `pytest tests/test_main.py -v -k test_pager`
- Integration: `pytest tests/test_main.py -v -k test_pager_integration`
- Manual: Generate long output and verify paging

## Observability

- Log pager activation
- Log pager bypass

## Compliance

- Respect user pager preference
- Provide clear feedback

## Risks & Mitigations

- Risk: Pager not available — Mitigation: Graceful fallback
- Risk: Terminal detection fails — Mitigation: Default to paging

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Pager integration implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add pager integration`

## Changelog

- 2025-07-08: initialized story file
