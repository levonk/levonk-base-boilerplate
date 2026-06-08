---
story_id: "06-004"
story_title: "Privacy Mode with Anonymous Lists"
story_name: "privacy-mode"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 4
branch: "feature/current/cli-python-standards/story-06-004-privacy-mode"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["privacy module"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "privacy"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement privacy mode with explicit ignore lists for CLIs that collect sensitive data. Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely), add configurable privacy toggles, and implement `--privacy-mode` flag.

## Sub-Tasks

- [x] Add `include_privacy` boolean option to `copier.yml` — `apps/cli/python/core/copier.yml`
- [x] Create `privacy.py.jinja` template file with privacy mode implementation — `apps/cli/python/core/files/{{project_slug}}/privacy.py.jinja`
- [x] Implement explicit ignore lists for sensitive data — `privacy.py.jinja`
- [x] Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely) — `privacy.py.jinja`
- [x] Add configurable privacy toggles to disable specific data collection — `privacy.py.jinja`
- [N/A] Add privacy settings to config file schema — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` (N/A: config not in this boilerplate)
- [x] Add `--privacy-mode` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Integrate privacy mode into data collection logic — `__main__.py.jinja`
- [x] Add tests for privacy mode with ignore lists — `apps/cli/python/core/files/tests/test_privacy.py.jinja` (conditional)
- [x] Add tests for unknown vs anonymous distinction — `tests/test_privacy.py.jinja` (conditional)

## Relevant Files

- `apps/cli/python/core/copier.yml` — Add include_privacy template option
- `apps/cli/python/core/files/{{project_slug}}/privacy.py.jinja` — New privacy module (conditional)
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Add privacy settings to config
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --privacy-mode flag
- `apps/cli/python/core/files/tests/test_privacy.py.jinja` — New test file (conditional)

## Acceptance Criteria

- [x] Privacy mode implemented with explicit ignore lists
- [x] "Unknown" data logged but not assigned
- [x] "Anonymous" data ignored entirely
- [x] Configurable privacy toggles for specific data collection
- [N/A] Privacy settings in config file (N/A for this boilerplate)
- [x] `--privacy-mode` flag working
- [x] Privacy mode optional via template choice
- [x] All tests pass for privacy mode scenarios

## Test Plan

- Unit: `pytest tests/test_privacy.py::test_ignore_lists` (conditional)
- Unit: `pytest tests/test_privacy.py::test_unknown_vs_anonymous` (conditional)
- Unit: `pytest tests/test_privacy.py::test_privacy_toggles` (conditional)
- Integration: Test privacy mode with data collection (conditional)

## Observability

- Log privacy mode activation
- Track privacy mode usage patterns

## Compliance

- Privacy mode respects user data protection requirements
- Anonymous data never logged or processed

## Risks & Mitigations

- Risk: Privacy mode may break functionality — Mitigation: Make optional, clear documentation
- Risk: Ignore lists may be complex to maintain — Mitigation: Provide sensible defaults, allow customization

## Dependencies & Sequencing

- Depends on: None (standalone privacy feature)
- Unblocks: None (standalone data protection feature)

## Definition of Done

- Privacy mode implemented with ignore lists
- Unknown vs anonymous distinction working
- Configurable privacy toggles implemented
- Privacy settings in config file
- `--privacy-mode` flag working
- Privacy mode optional via template choice
- Tests pass for privacy mode scenarios
- Documentation updated for privacy mode usage

## Commit Conventions

- `feat(privacy): add privacy mode with ignore lists`
- `feat(privacy): implement unknown vs anonymous distinction`
- `feat(privacy): add configurable privacy toggles`
- `test(privacy): add tests for privacy mode`
