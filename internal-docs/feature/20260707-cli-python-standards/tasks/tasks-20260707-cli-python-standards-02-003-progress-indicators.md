---
story_id: "02-003"
story_title: "Progress Indicators"
story_name: "progress-indicators"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260707-cli-python-standards/story-02-003-progress-indicators"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-003"]
parallel_safe: true
modules: ["progress", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Show progress bars for long-running operations using a Python progress bar library (rich.progress or tqdm). Must respect `--quiet` flag (no progress in quiet mode) and apply to file processing, network operations, etc.

## Sub-Tasks

- [ ] Add progress bar library dependency
- [ ] Implement progress indicators for file operations
- [ ] Implement progress indicators for network operations
- [ ] Respect --quiet flag (no progress in quiet mode)
- [ ] Add tests for progress indicators
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/progress.py.jinja` - Progress module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_progress.py.jinja` - Progress tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Progress bars shown for long-running operations
- [ ] Progress bars respect --quiet flag
- [ ] Progress applies to file operations
- [ ] Progress applies to network operations
- [ ] Tests verify progress behavior

## Test Plan

- Unit: `pytest tests/test_progress.py -v -k test_progress`
- Integration: `pytest tests/test_main.py -v -k test_progress`
- Manual: Run long operation and verify progress bar

## Observability

- Log progress events
- Log progress completion

## Compliance

- Respect user preference for quiet mode
- Use accessible progress indicators

## Risks & Mitigations

- Risk: Progress bars not supported on all terminals — Mitigation: Graceful fallback
- Risk: Progress adds overhead — Mitigation: Only for long operations

## Dependencies & Sequencing

- Depends on: 01-003 (Proper Color Control)
- Unblocks: None

## Definition of Done

- Progress indicators implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add progress indicators`

## Changelog

- 2025-07-08: initialized story file
