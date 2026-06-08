---
story_id: "01-001"
story_title: "Config File Initialization"
story_name: "config-file-initialization"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260707-cli-go-standards/story-01-001-config-file-initialization"
status: "in_progress"
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

Implement automatic config file initialization on first run. When no config file exists in the expected location, create a default config file with all settings commented out, including default values and explanations for each option. This ensures users have a working configuration from the start.

## Sub-Tasks

- [x] Add config initialization function to detect first run — `core/files/config.go.jinja`
- [x] Create default config template with all settings commented — `core/files/config.default.yaml.jinja`
- [~] Implement config file creation logic in initConfig — `core/files/main.go.jinja`
- [ ] Add config file path detection and validation — `core/files/config.go.jinja`
- [ ] Test config file creation on first run — `core/files/main_test.go.jinja`
- [ ] Test config file is not overwritten if exists — `core/files/main_test.go.jinja`
- [ ] Test default config template contains all required settings — `core/files/config_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Main entry point, needs config initialization logic
- `apps/cli/go/core/files/config.go.jinja` — New file for config management functions
- `apps/cli/go/core/files/config.default.yaml.jinja` — New template for default config
- `apps/cli/go/core/files/main_test.go.jinja` — Tests for config initialization
- `apps/cli/go/core/files/config_test.go.jinja` — New file for config-specific tests

## Acceptance Criteria

- [ ] Config file is auto-created on first run at `$HOME/.config/{project_slug}/config.yaml`
- [ ] Default config contains all settings commented with default values
- [ ] Each setting has explanatory comments
- [ ] Config file is not overwritten if it already exists
- [ ] Config file creation respects XDG config directory
- [ ] Error handling for permission issues during config creation

## Test Plan

- Unit: Test config initialization function with various scenarios
- Integration: Test actual config file creation in temporary directory
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log config file creation event
- Log config file location on startup
- Log if using default config vs existing config

## Compliance

- Ensure config file permissions are secure (0600)
- No sensitive data in default config template
- Respect user's XDG config directory

## Risks & Mitigations

- Risk: Permission errors when creating config directory — Mitigation: Handle gracefully with clear error message
- Risk: Race condition in concurrent first-run detection — Mitigation: Use file locking or atomic operations

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-007 (Configuration Validation), 02-001 (Dry-Run Mode), 02-002 (Confirmation Prompts), 03-001 (TUI Mode), 03-002 (Daemon Process Support), 03-005 (Credential/Secret Handling), 03-006 (Config Auto-Migration)

## Definition of Done

- Config file auto-creates on first run
- Default config template is complete and well-documented
- All tests pass
- No breaking changes to existing config handling

## Commit Conventions

- `feat(config): add config file initialization on first run`
- `feat(config): add default config template`
- `test(config): add tests for config initialization`
