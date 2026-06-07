---
story_id: "06-006"
story_title: "Legacy Deprecation Policy"
story_name: "deprecation-policy"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 6
branch: "feature/current/cli-python-standards/story-06-006-deprecation-policy"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["config module"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "deprecation"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement legacy deprecation policy for breaking changes and config format deprecations. Specify clear end-of-support dates (minimum 6 months), log deprecation warnings to stderr, and remove legacy support only after specified date.

## Sub-Tasks

- [ ] Add deprecation tracking system to `config.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja`
- [ ] Implement end-of-support date specification (minimum 6 months) — `config.py.jinja`
- [ ] Add deprecation warning logging to stderr — `config.py.jinja`
- [ ] Implement deprecation warnings in config validation — `config.py.jinja`
- [ ] Add deprecation warnings for legacy config formats — `config.py.jinja`
- [ ] Add deprecation warnings for deprecated CLI flags — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Implement legacy support removal logic based on date — `config.py.jinja`
- [ ] Add deprecation settings to config file schema — `config.py.jinja`
- [ ] Add tests for deprecation warning display — `apps/cli/python/core/files/tests/test_config.py.jinja`
- [ ] Add tests for legacy support removal — `tests/test_config.py.jinja`
- [ ] Add tests for end-of-support date enforcement — `tests/test_config.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Implement deprecation tracking and warnings
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add deprecation warnings for CLI flags
- `apps/cli/python/core/files/tests/test_config.py.jinja` — Add tests for deprecation functionality

## Acceptance Criteria

- [ ] Deprecation tracking system implemented
- [ ] End-of-support dates specified (minimum 6 months)
- [ ] Deprecation warnings logged to stderr
- [ ] Config validation includes deprecation warnings
- [ ] Legacy config formats trigger deprecation warnings
- [ ] Deprecated CLI flags trigger deprecation warnings
- [ ] Legacy support removed only after specified date
- [ ] Deprecation settings in config file
- [ ] All tests pass for deprecation scenarios

## Test Plan

- Unit: `pytest tests/test_config.py::test_deprecation_warnings`
- Unit: `pytest tests/test_config.py::test_legacy_support_removal`
- Unit: `pytest tests/test_config.py::test_end_of_support_enforcement`
- Integration: Test deprecation warnings with various scenarios

## Observability

- Log deprecation warnings for monitoring
- Track usage of deprecated features
- Monitor legacy format usage

## Compliance

- Deprecation policy provides clear migration path
- End-of-support dates respect user migration needs

## Risks & Mitigations

- Risk: Users may ignore deprecation warnings — Mitigation: Clear warnings, documentation, extended support period
- Risk: Legacy support removal may break existing setups — Mitigation: Minimum 6 months, clear communication

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone policy feature)

## Definition of Done

- Deprecation tracking system implemented
- End-of-support date specification working
- Deprecation warnings logged to stderr
- Config and CLI deprecation warnings working
- Legacy support removal based on date
- Deprecation settings in config file
- Tests pass for deprecation scenarios
- Documentation updated for deprecation policy

## Commit Conventions

- `feat(deprecation): add deprecation tracking system`
- `feat(deprecation): implement end-of-support date specification`
- `feat(deprecation): add deprecation warnings to stderr`
- `test(deprecation): add tests for deprecation policy`
