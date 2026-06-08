---
story_id: "06-002"
story_title: "Signal-Based Config Reload"
story_name: "config-reload"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 2
branch: "feature/current/cli-python-standards/story-06-002-config-reload"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["config module", "__main__.py"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement signal-based config reload using SIGHUP to reload config files without restart. Validate new config before applying, log reload events, and handle validation errors gracefully by keeping old config active.

## Sub-Tasks

- [x] Add SIGHUP signal handler to `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Implement config reload function in `config.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja`
- [x] Add config validation before applying new config — `config.py.jinja` (already implemented)
- [x] Implement graceful error handling (keep old config active on validation failure) — `config.py.jinja` (already implemented via migration)
- [x] Add reload event logging with timestamps — `__main__.py.jinja`
- [x] Add `--reload-config` command for manual config reload — `__main__.py.jinja`
- [x] Add config reload status feedback — `config.py.jinja` (already implemented)
- [x] Add tests for SIGHUP config reload — `apps/cli/python/core/files/tests/test_config_reload.py.jinja` (conditional)
- [x] Add tests for manual config reload command — `tests/test_config_reload.py.jinja` (conditional)
- [x] Add tests for config validation during reload — `tests/test_config.py.jinja` (already implemented)

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add SIGHUP handler and --reload-config command
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Implement config reload logic
- `apps/cli/python/core/files/tests/test_config.py.jinja` — Add tests for config reload

## Acceptance Criteria

- [x] SIGHUP signal triggers config reload without restart
- [x] New config validated before applying
- [x] Validation errors handled gracefully (old config kept active)
- [x] Reload events logged with timestamps
- [x] `--reload-config` command works for manual reload
- [x] Config reload status provided to user
- [x] All tests pass for config reload scenarios

## Test Plan

- Unit: `pytest tests/test_config.py::test_sighup_reload`
- Unit: `pytest tests/test_config.py::test_manual_reload`
- Unit: `pytest tests/test_config.py::test_reload_validation`
- Integration: Test config reload in running process

## Observability

- Log reload events with timestamps and config versions
- Track reload success/failure rates
- Monitor config validation errors

## Compliance

- Config reload does not expose sensitive information in logs
- Signal handling respects user permissions

## Risks & Mitigations

- Risk: Config reload may cause runtime errors — Mitigation: Validate before applying, keep old config on failure
- Risk: SIGHUP may not be available on all platforms — Mitigation: Platform detection, graceful degradation
- Risk: Config reload may be confusing for users — Mitigation: Clear logging, status feedback

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: None (standalone config enhancement)

## Definition of Done

- SIGHUP signal handler implemented
- Config reload logic implemented with validation
- Graceful error handling for validation failures
- Reload event logging implemented
- Manual reload command working
- Tests pass for all config reload scenarios
- Documentation updated for config reload usage

## Commit Conventions

- `feat(config): add SIGHUP signal handler for config reload`
- `feat(config): implement config validation during reload`
- `feat(config): add --reload-config command`
- `test(config): add tests for config reload`
