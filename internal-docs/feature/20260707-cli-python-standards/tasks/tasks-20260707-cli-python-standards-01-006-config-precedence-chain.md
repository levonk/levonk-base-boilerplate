---
story_id: "01-006"
story_title: "Configuration Precedence Chain"
story_name: "config-precedence-chain"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 6
branch: "feature/current/20260707-cli-python-standards/story-01-006-config-precedence-chain"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
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

Implement full configuration precedence chain: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults. Support local project config at `.config/{project_slug}/config.toml` and system config at `/etc/{project_slug}/config.toml`.

## Sub-Tasks

- [ ] Implement config loading from multiple sources
- [ ] Add local project config support
- [ ] Add system/enterprise config support
- [ ] Implement precedence chain logic
- [ ] Add environment variable support
- [ ] Add CLI argument support
- [ ] Add tests for precedence chain
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` - Config module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_config.py.jinja` - Config tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Config loads from all sources in correct precedence
- [ ] CLI args override env vars
- [ ] Env vars override local config
- [ ] Local config overrides user config
- [ ] User config overrides system config
- [ ] System config overrides defaults
- [ ] Tests verify full precedence chain

## Test Plan

- Unit: `pytest tests/test_config.py -v -k test_precedence`
- Integration: `pytest tests/test_main.py -v -k test_config_precedence`
- Manual: Test with config at each precedence level

## Observability

- Log config source for each setting
- Log config merge process

## Compliance

- Follow XDG Base Directory specification
- Use secure file permissions
- Respect system config locations

## Risks & Mitigations

- Risk: Config merge conflicts — Mitigation: Clear precedence rules
- Risk: System config requires root — Mitigation: Graceful fallback

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-007, 02-001, 03-001, 03-002

## Definition of Done

- Config precedence chain implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(config): implement config precedence chain`

## Changelog

- 2025-07-08: initialized story file
