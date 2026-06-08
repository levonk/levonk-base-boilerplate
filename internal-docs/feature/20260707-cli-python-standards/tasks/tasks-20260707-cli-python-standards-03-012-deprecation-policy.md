---
story_id: "03-012"
story_title: "Legacy Deprecation Policy"
story_name: "deprecation-policy"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 12
branch: "feature/current/20260707-cli-python-standards/story-03-012-deprecation-policy"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["deprecation", "main"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "maintenance"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Specify clear end-of-support date (minimum 6 months from announcement). Log deprecation warnings to stderr during deprecation period, and remove legacy support only after specified date.

## Sub-Tasks

- [x] Implement deprecation tracking system
- [x] Add deprecation date specification
- [x] Implement deprecation warnings to stderr
- [x] Add minimum 6-month deprecation period
- [x] Implement legacy removal after date
- [x] Add tests for deprecation policy
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_deprecation.py.jinja` - Deprecation tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Deprecation dates specified clearly
- [ ] Minimum 6-month deprecation period
- [ ] Warnings logged to stderr
- [ ] Legacy removed only after date
- [ ] Tests verify deprecation policy

## Test Plan

- Unit: `pytest tests/test_deprecation.py -v -k test_deprecation`
- Integration: `pytest tests/test_main.py -v -k test_deprecation_warnings`
- Manual: Test deprecation warnings

## Observability

- Log deprecation warnings
- Log legacy removal

## Compliance

- Provide clear deprecation notices
- Respect deprecation timelines

## Risks & Mitigations

- Risk: Deprecation too short — Mitigation: Minimum 6-month period
- Risk: Users ignore warnings — Mitigation: Clear, prominent warnings

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Deprecation policy implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(maintenance): add legacy deprecation policy`

## Changelog

- 2025-07-08: initialized story file
