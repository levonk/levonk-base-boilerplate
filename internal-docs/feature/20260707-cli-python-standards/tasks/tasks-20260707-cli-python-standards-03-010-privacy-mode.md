---
story_id: "03-010"
story_title: "Privacy Mode with Anonymous Lists"
story_name: "privacy-mode"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 10
branch: "feature/current/20260707-cli-python-standards/story-03-010-privacy-mode"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["privacy", "main"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "privacy"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Support privacy mode with explicit ignore lists. Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely), and provide configurable privacy toggles to disable specific data collection.

## Sub-Tasks

- [ ] Implement privacy mode flag
- [ ] Implement anonymous ignore lists
- [ ] Distinguish unknown vs anonymous
- [ ] Add configurable privacy toggles
- [ ] Apply privacy to logging
- [ ] Apply privacy to output
- [ ] Add tests for privacy mode
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/privacy.py.jinja` - Privacy module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_privacy.py.jinja` - Privacy tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Privacy mode flag works
- [ ] Anonymous ignore lists functional
- [ ] Unknown vs anonymous distinguished
- [ ] Privacy toggles configurable
- [ ] Privacy applied to logging
- [ ] Privacy applied to output
- [ ] Tests verify privacy mode

## Test Plan

- Unit: `pytest tests/test_privacy.py -v -k test_privacy`
- Integration: `pytest tests/test_main.py -v -k test_privacy_mode`
- Manual: Test privacy mode with various data

## Observability

- Log privacy mode activation
- Log privacy filter actions

## Compliance

- Respect user privacy preferences
- Follow privacy best practices

## Risks & Mitigations

- Risk: Privacy mode too restrictive — Mitigation: Configurable toggles
- Risk: Anonymous lists incomplete — Mitigation: User-configurable lists

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Privacy mode implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(privacy): add privacy mode with anonymous lists`

## Changelog

- 2025-07-08: initialized story file
