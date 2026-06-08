---
story_id: "02-001"
story_title: "Enhanced Logging Modes"
story_name: "enhanced-logging-modes"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-02-001-enhanced-logging-modes"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["logger.ts"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add `--debug` flag for debug-level logging and enhance the existing logging system. Ensure `--quiet` suppresses all non-essential output including progress indicators. Implement structured logging support (JSON format for logs) and establish a clear log level hierarchy: debug < info < warn < error < fatal.

## Sub-Tasks

- [~] Add `--debug` flag to index.ts command line options
- [~] Add debug log level to logger.ts
- [x] Implement log level hierarchy (debug < info < warn < error < fatal)
- [x] Ensure --quiet flag suppresses all non-essential output including progress indicators
- [x] Add structured logging support (JSON format for logs)
- [x] Add --log-format flag to choose between text and JSON logging
- [x] Update LoggerOptions interface to include debug and log format options
- [x] Implement JSON log formatter with structured fields
- [x] Add timestamp, level, module, and message fields to JSON logs
- [x] Implement format auto-detection based on TTY
- [x] Support language-native env filters (NODE_ENV, LOG_LEVEL)
- [~] Implement log level resolution: env vars > CLI flags > config file > defaults
- [ ] Add unit tests for debug logging behavior
- [ ] Add unit tests for quiet mode behavior
- [ ] Add unit tests for JSON log formatting
- [ ] Add unit tests for format auto-detection
- [ ] Add unit tests for env filter support
- [ ] Add unit tests for log level resolution
- [ ] Add integration tests for logging mode combinations
- [ ] Update help text to document new logging options

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI entry point with logging flags
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger implementation with enhanced modes
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for logging modes
- `apps/cli/typescript/core/files/src/logger.test.ts.jinja` - Unit tests for logger (to be created)

## Acceptance Criteria

- [ ] `--debug` flag enables debug-level logging
- [ ] Debug logs show more detailed information than info logs
- [ ] `--quiet` flag suppresses all non-essential output including progress indicators
- [ ] `--log-format=json` flag enables structured JSON logging
- [ ] JSON logs include timestamp, level, module, and message fields
- [ ] Log level hierarchy is correctly enforced (debug < info < warn < error < fatal)
- [ ] All existing logging functionality continues to work
- [ ] Help text clearly documents new logging options

## Test Plan

- Unit: `vitest run src/logger.test.ts` - Test log level hierarchy and formatting
- Integration: `vitest run src/index.test.ts` - Test logging mode combinations
- Manual: Test --debug flag output
- Manual: Test --quiet flag behavior
- Manual: Test JSON log format output

## Observability

- JSON logs enable better log parsing and analysis
- Debug logs provide detailed troubleshooting information
- Log levels allow filtering based on severity

## Compliance

- Follows CLI Tool Standards ADR requirement #7 (Logging Modes)
- Enables structured logging for better observability

## Risks & Mitigations

- Risk: Debug logs may expose sensitive information
  - Mitigation: Ensure debug logs don't include secrets or credentials
- Risk: JSON log format may break existing log parsers
  - Mitigation: Make JSON format opt-in via --log-format flag
- Risk: Performance impact from structured logging
  - Mitigation: Optimize JSON serialization, use efficient logging library

## Dependencies

- 01-001 (Enhanced Color Control) - Logger changes should integrate with color system

## Notes

- Debug logging should be comprehensive but not expose sensitive data
- JSON logging should follow common structured logging conventions
- Consider using pino or winston for structured logging (already in devDependencies)
- Log format should be consistent across all log levels
