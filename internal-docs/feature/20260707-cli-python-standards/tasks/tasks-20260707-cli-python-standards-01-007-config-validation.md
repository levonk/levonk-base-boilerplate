---
story_id: "01-007"
story_title: "Configuration Validation"
story_name: "config-validation"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 7
branch: "feature/current/20260707-cli-python-standards/story-01-007-config-validation"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-006"]
parallel_safe: true
modules: ["config", "main"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "config"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement configuration file validation on load. Report clear, specific error messages with line numbers, provide suggestions for fixing configuration errors, and validate against schema before using config.

## Sub-Tasks

- [ ] Define config schema/validation rules
- [ ] Implement config validation on load
- [ ] Add line number tracking for errors
- [ ] Implement error message formatting
- [ ] Add suggestions for fixing errors
- [ ] Add schema validation
- [ ] Add tests for config validation
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `apps/cli/python/core/files/{{project_slug}}/errors.py.jinja` - Error formatting
- `tests/test_config.py.jinja` - Config tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Config files validated on load
- [ ] Error messages include line numbers
- [ ] Error messages are clear and specific
- [ ] Suggestions provided for fixing errors
- [ ] Config validated against schema
- [ ] Invalid config causes graceful error
- [ ] Tests verify validation behavior

## Test Plan

- Unit: `pytest tests/test_config.py -v -k test_validation`
- Integration: `pytest tests/test_main.py -v -k test_config_validation`
- Manual: Test with invalid config files

## Observability

- Log validation errors
- Log schema violations

## Compliance

- Use secure validation (no code injection)
- Provide helpful error messages

## Risks & Mitigations

- Risk: Schema validation too strict — Mitigation: Allow optional fields
- Risk: Error messages not helpful — Mitigation: User testing

## Dependencies & Sequencing

- Depends on: 01-006 (Config Precedence Chain)
- Unblocks: 03-005, 03-006

## Definition of Done

- Config validation implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(config): add config validation`

## Changelog

- 2025-07-08: initialized story file
