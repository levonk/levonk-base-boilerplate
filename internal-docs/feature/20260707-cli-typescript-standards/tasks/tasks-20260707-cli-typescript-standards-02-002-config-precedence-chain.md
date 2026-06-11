---
story_id: "02-002"
story_title: "Configuration Precedence Chain"
story_name: "config-precedence-chain"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-02-002-config-precedence-chain"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-003"]
parallel_safe: true
modules: ["config/"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement full configuration precedence chain as defined in CLI Tool Standards ADR requirement #2: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults. Add support for local project config, user config, and system config locations with proper config merging logic.

## Sub-Tasks

- [x] Implement config precedence resolution logic in config module
- [x] Add support for local project config: .{{ project_slug }}/config.toml
- [x] Add support for user config: ~/.config/{{ project_slug }}/config.toml
- [x] Add support for system config: /etc/{{ project_slug }}/config.toml
- [x] Implement config merging logic with proper precedence
- [x] Add environment variable config loading with {{ PROJECT_SLUG }}_ prefix
- [x] Implement CLI args config parsing
- [x] Add config precedence logging in debug mode
- [ ] Add unit tests for config precedence resolution
- [ ] Add unit tests for config merging logic
- [ ] Add integration tests for multi-source config loading
- [x] Update help text to document config precedence
- [x] Add config source tracking for debugging

## Relevant Files

- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config module with precedence logic
- `apps/cli/typescript/core/files/src/index.ts.jinja` - CLI args and env var integration
- `apps/cli/typescript/core/files/src/config.test.ts.jinja` - Unit tests for config precedence
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for config loading

## Acceptance Criteria

- [x] Config precedence follows: CLI args > env vars > local project config > user config > system config > defaults
- [x] Local project config is loaded from .{{ project_slug }}/config.toml
- [x] User config is loaded from ~/.config/{{ project_slug }}/config.toml
- [x] System config is loaded from /etc/{{ project_slug }}/config.toml
- [x] Environment variables with {{ PROJECT_SLUG }}_ prefix override config files
- [x] CLI args override all other config sources
- [x] Config merging correctly handles nested structures
- [x] Missing config sources are gracefully skipped
- [x] Config source is logged in debug mode

## Test Plan

- Unit: `vitest run src/config.test.ts` - Test config precedence resolution
- Unit: `vitest run src/config.test.ts` - Test config merging logic
- Integration: `vitest run src/index.test.ts` - Test multi-source config loading
- Manual: Test config precedence with different config sources
- Manual: Verify environment variable overrides

## Observability

- Log config source in debug mode for troubleshooting
- Track which config source provided each setting
- Add metrics for config loading performance

## Compliance

- Follows CLI Tool Standards ADR requirement #2 (Configuration Precedence)
- Supports flexible configuration management across different contexts

## Risks & Mitigations

- Risk: Config merging complexity leads to unexpected behavior
  - Mitigation: Add comprehensive tests, document merging rules clearly
- Risk: System config requires root permissions
  - Mitigation: Gracefully handle permission errors, log warnings
- Risk: Environment variable naming conflicts
  - Mitigation: Use consistent {{ PROJECT_SLUG }}_ prefix, document env vars

## Dependencies

- 01-003 (Config File Initialization) - Config file system must be in place first

## Notes

- Config merging should be deep merge for nested structures
- Environment variables should use UPPER_CASE with {{ PROJECT_SLUG }}_ prefix
- Consider using cosmiconfig or similar library for flexible config loading
- Config precedence should be clearly documented in help text
