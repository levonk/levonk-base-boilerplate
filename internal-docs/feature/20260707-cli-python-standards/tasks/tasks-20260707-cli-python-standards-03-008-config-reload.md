---
story_id: "03-008"
story_title: "Signal-Based Config Reload"
story_name: "config-reload"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 8
branch: "feature/current/20260707-cli-python-standards/story-03-008-config-reload"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-007"]
parallel_safe: true
modules: ["config", "main"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "config"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Support SIGHUP to reload config files without restart. Validate new config before applying, log reload events, and handle validation errors gracefully (keep old config active).

## Sub-Tasks

- [ ] Implement SIGHUP signal handler
- [ ] Implement config reload logic
- [ ] Add config validation before reload
- [ ] Add reload event logging
- [ ] Handle validation errors gracefully
- [ ] Keep old config on validation failure
- [ ] Add tests for config reload
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_config_reload.py.jinja` - Config reload tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] SIGHUP triggers config reload
- [ ] New config validated before applying
- [ ] Reload events logged
- [ ] Validation errors handled gracefully
- [ ] Old config kept on validation failure
- [ ] Tests verify config reload

## Test Plan

- Unit: `pytest tests/test_config_reload.py -v -k test_reload`
- Integration: `pytest tests/test_main.py -v -k test_sighup`
- Manual: Send SIGHUP and verify reload

## Observability

- Log SIGHUP reception
- Log reload results

## Compliance

- Handle signals safely
- Validate before applying changes

## Risks & Mitigations

- Risk: Signal handling not supported on Windows — Mitigation: Platform detection
- Risk: Reload causes instability — Mitigation: Validation and rollback

## Dependencies & Sequencing

- Depends on: 01-007 (Config Validation)
- Unblocks: None

## Definition of Done

- Config reload implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(config): add signal-based config reload`

## Changelog

- 2025-07-08: initialized story file
