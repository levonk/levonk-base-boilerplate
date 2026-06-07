---
story_id: "01-006"
story_title: "Configuration Precedence Chain"
story_name: "config-precedence-chain"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 6
branch: "feature/current/20260707-cli-go-standards/story-01-006-config-precedence-chain"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config", "main"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "config"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement the full configuration precedence chain as specified in the ADR: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults. Extend the existing viper usage to support all precedence levels.

## Sub-Tasks

- [ ] Add viper or koanf dependency to go.mod — `core/files/go.mod.jinja`
- [ ] Add local project config path detection — `core/files/config.go.jinja`
- [ ] Add system/enterprise config path detection — `core/files/config.go.jinja`
- [ ] Implement config precedence loading logic using viper or koanf — `core/files/config.go.jinja`
- [ ] Add hardcoded defaults for all settings — `core/files/config.go.jinja`
- [ ] Update initConfig to use full precedence chain — `core/files/main.go.jinja`
- [ ] Test CLI args override env vars — `core/files/config_test.go.jinja`
- [ ] Test env vars override local config — `core/files/config_test.go.jinja`
- [ ] Test local config overrides user config — `core/files/config_test.go.jinja`
- [ ] Test user config overrides system config — `core/files/config_test.go.jinja`
- [ ] Test system config overrides defaults — `core/files/config_test.go.jinja`
- [ ] Test full precedence chain end-to-end — `core/files/config_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update config initialization
- `apps/cli/go/core/files/config.go.jinja` — Implement precedence logic
- `apps/cli/go/core/files/config_test.go.jinja` — Tests for precedence

## Acceptance Criteria

- [ ] CLI args take highest precedence
- [ ] Environment variables override config files
- [ ] Local project config (`.config/{project_slug}/config.yaml`) is supported
- [ ] User config (XDG) is supported
- [ ] System/enterprise config (`/etc/{project_slug}/config.yaml`) is supported
- [ ] Hardcoded defaults are used when no config exists
- [ ] Precedence chain is correctly implemented in order

## Test Plan

- Unit: Test each precedence level
- Integration: Test full precedence chain
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log which config file is being used
- Log when multiple config files are found
- Log when environment variables override config

## Compliance

- Respect XDG Base Directory specification
- Handle missing config files gracefully
- Support both TOML and YAML formats

## Risks & Mitigations

- Risk: Config precedence may be confusing — Mitigation: Log which config is being used
- Risk: Multiple config files may conflict — Mitigation: Clear precedence documentation

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-007 (Configuration Validation), 02-001 (Dry-Run Mode), 02-002 (Confirmation Prompts), 03-001 (TUI Mode), 03-002 (Daemon Process Support), 03-005 (Credential/Secret Handling), 03-006 (Config Auto-Migration)

## Definition of Done

- Full precedence chain implemented
- All precedence levels tested
- Clear logging of config selection
- All tests pass

## Commit Conventions

- `feat(config): implement full config precedence chain`
- `feat(config): add local project config support`
- `feat(config): add system/enterprise config support`
- `test(config): add tests for config precedence`
