---
story_id: "06-004"
story_title: "Signal-Based Config Reload"
story_name: "signal-based-config-reload"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 6
parallel_id: 4
branch: "feature/current/20260707-cli-typescript-standards/story-06-004-signal-based-config-reload"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-002", "06-001"]
parallel_safe: true
modules: ["config/"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "config"]
due: "2026-08-18"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Support SIGHUP to reload config files without restart. Validate new config before applying, log reload events, and handle validation errors gracefully by keeping old config active. This implements CLI Tool Standards ADR requirement #31.

## Sub-Tasks

- [ ] Implement SIGHUP signal handler
- [ ] Add config reload logic
- [ ] Implement new config validation before applying
- [ ] Add config reload event logging
- [ ] Implement graceful error handling (keep old config active)
- [ ] Add config reload status reporting
- [ ] Implement config diff logging
- [ ] Add unit tests for signal handling
- [ ] Add unit tests for config reload logic
- [ ] Add unit tests for validation error handling
- [ ] Add integration tests for SIGHUP workflow
- [ ] Update help text to document config reload
- [ ] Add config reload documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config module with reload logic
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with signal handling
- `apps/cli/typescript/core/files/src/config.test.ts.jinja` - Unit tests for config reload
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for signals

## Acceptance Criteria

- [ ] SIGHUP signal triggers config reload
- [ ] New config is validated before applying
- [ ] Config reload events are logged
- [ ] Validation errors keep old config active
- [ ] Config reload status is reported
- [ ] Config diff is logged in verbose mode
- [ ] Reload works without process restart
- [ ] Signal handling is platform-appropriate

## Test Plan

- Unit: `vitest run src/config.test.ts` - Test config reload logic
- Integration: `vitest run src/index.test.ts` - Test SIGHUP workflow
- Manual: Send SIGHUP signal and verify config reload
- Manual: Test validation error handling

## Observability

- Log config reload events
- Track reload success/failure for analytics
- Add metrics for config reload performance

## Compliance

- Follows CLI Tool Standards ADR requirement #31 (Signal-Based Config Reload)
- Enables runtime configuration updates without restart

## Risks & Mitigations

- Risk: Signal handling differs between platforms
  - Mitigation: Platform detection, fallback behavior
- Risk: Config reload causes runtime errors
  - Mitigation: Validation before apply, keep old config active
- Risk: Signal handling conflicts with other libraries
  - Mitigation: Careful signal management, documentation

## Dependencies

- 02-002 (Configuration Precedence Chain) - Config loading must be in place
- 06-001 (Configuration Validation) - Validation logic must be in place

## Notes

- SIGHUP is the standard Unix signal for config reload
- Windows may use different signal mechanism
- Config reload should be atomic (all-or-nothing)
- Consider adding a --reload-config flag for manual reload
