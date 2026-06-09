---
story_id: "01-003"
story_title: "Configuration System Updates"
story_name: "config-updates"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260708-cli-rust-aix/story-01-003-config-updates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "config", "axi"]
due: "2026-06-15"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Update the configuration system to support agent mode settings, TOON format preferences, truncation limits, and other AXI-related configuration options. This ensures the config system can handle all new AXI features and provides a consistent way for users to customize agent behavior.

## Sub-Tasks

- [x] Add `mode` field to config struct with "agent" and "human" values
- [x] Add `default_format` field to config struct with "toon", "json", "human" values
- [x] Add `truncation_limit` field to config struct with integer value (default 1000)
- [x] Add `enable_contextual_help` field to config struct with boolean value (default true)
- [x] Add `session_context_enabled` field to config struct with boolean value (default false)
- [x] Update config file template to include new AXI-related settings
- [x] Add comments explaining each new AXI configuration option
- [x] Update config validation to validate new AXI fields
- [x] Add config migration logic for adding new fields to existing configs
- [x] Update config precedence chain documentation
- [x] Write unit tests for new config fields
- [x] Write integration tests for config loading with AXI settings
- [x] Write tests for config validation of AXI settings
- [x] Update config file examples in documentation

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/config.rs` — Configuration struct and loading logic
- `boilerplate/apps/cli/rust/core/src/config/tests.rs` — Tests for configuration
- `boilerplate/apps/cli/rust/core/src/config/validation.rs` — Config validation logic
- `boilerplate/apps/cli/rust/core/src/config/migration.rs` — Config migration logic
- `boilerplate/apps/cli/rust/core/templates/config.yaml.template` — Config file template
- `boilerplate/apps/cli/rust/core/src/internal/config/schema.rs` — Config schema definitions

## Acceptance Criteria

- [x] Config struct includes all new AXI-related fields
- [x] Config file template includes all new AXI settings with comments
- [x] Config validation correctly validates new AXI fields
- [x] Config migration successfully adds new fields to existing configs
- [x] Config loading correctly reads and applies AXI settings
- [x] Config precedence chain works correctly with new settings
- [x] All new config functionality has test coverage
- [x] Documentation explains all new AXI configuration options

## Test Plan

- Unit: `cargo test --lib config`
- Integration: Test config loading with various AXI settings
- Manual: Verify config file template generates valid config
- Manual: Test config migration with existing config files

## Observability

- Add logging for config loading decisions at debug level
- Add metrics for config usage patterns

## Compliance

- Ensure config migration doesn't break existing user configurations
- Validate that config values don't introduce security vulnerabilities

## Risks & Mitigations

- Risk: Config migration may fail for existing configs — Mitigation: Add robust error handling and fallback logic
- Risk: New config fields may confuse users — Mitigation: Provide clear documentation and examples

## Dependencies

- Requires: Mode selection story (01-001) for mode field integration
- No other dependencies (can be developed in parallel with 01-001 and 01-002)

## Notes

- Config migration should be idempotent (safe to run multiple times)
- Consider adding config validation warnings for deprecated settings
- Document recommended config values for different use cases
