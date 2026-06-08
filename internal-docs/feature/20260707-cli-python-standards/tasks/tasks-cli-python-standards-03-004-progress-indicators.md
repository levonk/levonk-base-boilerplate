---
story_id: "03-004"
story_title: "Progress Indicators"
story_name: "progress-indicators"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 3
parallel_id: 4
branch: "feature/current/cli-python-standards/story-03-004-progress-indicators"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["progress module"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-07-19"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement progress indicators (progress bars or spinners) for long-running operations. Ensure progress indicators respect the `--quiet` flag and are suppressed in quiet mode.

## Sub-Tasks

- [x] Create `progress.py.jinja` template file with progress utilities — `apps/cli/python/core/files/{{project_slug}}/progress.py.jinja`
- [x] Implement progress bar using rich.progress for file operations — `progress.py.jinja`
- [x] Implement spinner for indeterminate operations — `progress.py.jinja`
- [x] Ensure progress indicators respect `--quiet` flag — `progress.py.jinja`
- [x] Add progress indicator integration to long-running operations in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Add progress indicator for file processing operations — `__main__.py.jinja`
- [x] Add tests for progress indicators — `apps/cli/python/core/files/tests/test_progress.py.jinja`
- [x] Add tests for quiet mode suppression — `tests/test_progress.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/progress.py.jinja` — New progress module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Integrate progress indicators
- `apps/cli/python/core/files/tests/test_progress.py.jinja` — New test file for progress functionality

## Acceptance Criteria

- [x] Progress bars shown for file operations (>30 seconds)
- [x] Spinners shown for indeterminate operations (>30 seconds)
- [x] Progress indicators respect `--quiet` flag (no progress in quiet mode)
- [x] Progress indicators provide clear status information
- [x] Progress indicators do not interfere with output
- [x] All tests pass for progress indicator scenarios

## Test Plan

- Unit: `pytest tests/test_progress.py::test_progress_bar`
- Unit: `pytest tests/test_progress.py::test_spinner`
- Unit: `pytest tests/test_progress.py::test_quiet_mode_suppression`
- Integration: Test progress indicators with long-running operations

## Observability

- Progress indicators provide user feedback
- Track operation completion times

## Compliance

- Progress indicators do not expose sensitive information
- Quiet mode respected for automated environments

## Risks & Mitigations

- Risk: Progress indicators may clutter output — Mitigation: Only show for operations >30 seconds, respect quiet mode
- Risk: Progress detection may be inaccurate — Mitigation: Use time-based threshold, allow manual override

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone UX enhancement)

## Definition of Done

- Progress indicators implemented using rich.progress
- Progress bars and spinners working correctly
- Quiet mode suppression working
- Progress indicators integrated into long-running operations
- Tests pass for all progress scenarios
- Documentation updated for progress indicator usage

## Commit Conventions

- `feat(progress): add progress bars for file operations`
- `feat(progress): add spinners for indeterminate operations`
- `feat(progress): ensure quiet mode suppresses progress`
- `test(progress): add tests for progress indicators`
