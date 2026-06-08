---
story_id: "01-003"
story_title: "Configuration File Initialization"
story_name: "config-file-initialization"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-01-003-config-file-initialization"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["config/"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-07-14"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement automatic configuration file initialization on first run. When no config file exists in the expected location, create a default config file with all settings commented out, including default values and explanations for each option. Support XDG config directory structure at ~/.config/{{ project_slug }}/config.toml.

## Sub-Tasks

- [x] Create config module with config file detection and creation logic
- [x] Implement XDG config directory path resolution
- [x] Create default config template with all settings commented out
- [x] Add config file existence check on CLI initialization
- [x] Implement config file creation with proper permissions
- [x] Add TOML library to package.json.jinja dependencies
- [x] Create config schema with default values and descriptions
- [x] Add config file loading logic in index.ts
- [x] Add unit tests for config file detection
- [x] Add unit tests for config file creation
- [x] Add integration tests for first-run initialization
- [x] Update help text to mention config file location
- [x] Add logging for config file creation in verbose mode

## Relevant Files

- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config module with XDG path resolution, file detection, and creation logic
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI entry point with config initialization and merging
- `apps/cli/typescript/core/files/src/config.test.ts.jinja` - Unit tests for config module
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for config initialization
- `apps/cli/typescript/core/files/package.json.jinja` - Added @iarna/toml dependency

## Acceptance Criteria

- [x] Config file is auto-created on first run if none exists
- [x] Config file is created in XDG directory: ~/.config/{{ project_slug }}/config.toml
- [x] Default config file has all settings commented out
- [x] Default config file includes default values and explanations
- [x] Config file creation respects directory permissions
- [x] Config file is not overwritten if it already exists
- [x] Config file creation is logged in verbose mode
- [x] Config file follows TOML format standards

## Test Plan

- Unit: `vitest run src/config.test.ts` - Test config file detection and creation
- Integration: `vitest run src/index.test.ts` - Test first-run initialization
- Manual: Remove config file and run CLI to verify auto-creation
- Manual: Verify config file content and format

## Observability

- Log config file creation in verbose mode
- Log config file location in debug mode
- Add metrics for config file creation events

## Compliance

- Follows CLI Tool Standards ADR requirement #3 (Config File Initialization)
- Follows XDG Base Directory specification for config file location

## Risks & Mitigations

- Risk: Config file creation fails due to permission issues
  - Mitigation: Add graceful error handling with clear error messages
- Risk: Config file location conflicts with user expectations
  - Mitigation: Document config file location clearly in help text
- Risk: TOML library compatibility issues
  - Mitigation: Choose well-maintained TOML library with good TypeScript support

## Dependencies

- None - this is a foundational story for Phase 1

## Notes

- Use TOML format for human-editable config as specified in ADR
- Consider using toml or @iarna/toml library for TOML parsing
- Config template should be comprehensive and include all possible settings
- Ensure config file creation is idempotent (safe to run multiple times)
