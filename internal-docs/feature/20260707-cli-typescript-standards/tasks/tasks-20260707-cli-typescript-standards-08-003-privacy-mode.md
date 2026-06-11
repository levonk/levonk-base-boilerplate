---
story_id: "08-003"
story_title: "Privacy Mode"
story_name: "privacy-mode"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 8
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-08-003-privacy-mode"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["logger.ts", "config/"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "privacy"]
due: "2026-09-01"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add privacy mode for anonymous usage. Ensure no sensitive data is included in telemetry or logs, and provide clear documentation about data collection policies. This implements CLI Tool Standards ADR requirement #30.

## Sub-Tasks

- [x] Add `--privacy` flag to index.ts
- [x] Implement privacy mode logic
- [x] Add sensitive data detection
- [x] Implement data redaction in logs
- [x] Implement data redaction in telemetry
- [x] Add privacy mode config option
- [x] Add explicit ignore lists (identifiers to never log or process)
- [x] Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely)
- [x] Add configurable privacy toggles to disable specific data collection
- [x] Update logging to respect privacy mode
- [x] Add privacy policy documentation
- [x] Add unit tests for privacy mode
- [x] Add unit tests for data redaction
- [x] Add unit tests for ignore lists
- [x] Add unit tests for unknown vs anonymous distinction
- [x] Add integration tests for privacy behavior
- [x] Update help text to document privacy mode
- [x] Add privacy mode logging

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with privacy flag
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger with privacy mode
- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config with privacy option
- `apps/cli/typescript/core/files/src/privacy.ts.jinja` - Privacy mode implementation
- `apps/cli/typescript/core/files/src/privacy.test.mts.jinja` - Unit tests for privacy mode
- `apps/cli/typescript/core/files/src/privacy.integration.test.mts.jinja` - Integration tests for privacy behavior
- `apps/cli/typescript/core/files/PRIVACY.md.jinja` - Privacy policy documentation

## Acceptance Criteria

- [x] `--privacy` flag enables privacy mode
- [x] Privacy mode can be set in config
- [x] Sensitive data is detected correctly
- [x] Sensitive data is redacted from logs
- [x] Sensitive data is redacted from telemetry
- [x] Privacy policy is documented
- [x] Data collection policies are clear
- [x] Privacy mode is logged in debug mode
- [x] Privacy mode works across all features
- [x] Ignore lists work correctly (identifiers never logged or processed)
- [x] Unknown vs anonymous distinction works correctly
- [x] Configurable privacy toggles disable specific data collection

## Test Plan

- Unit: Test privacy mode logic and data redaction
- Integration: Test privacy behavior across CLI features
- Manual: Enable privacy mode and verify data redaction
- Manual: Review privacy policy documentation

## Observability

- Log privacy mode activation
- Track privacy mode usage for analytics
- Add metrics for data redaction events

## Compliance

- Follows CLI Tool Standards ADR requirement #30 (Privacy Mode)
- Ensures user privacy and data protection

## Risks & Mitigations

- Risk: Privacy mode breaks functionality
  - Mitigation: Comprehensive testing, graceful degradation
- Risk: Data redaction is incomplete
  - Mitigation: Regular security reviews, user feedback
- Risk: Privacy policy is unclear
  - Mitigation: Legal review, user testing, clear language

## Dependencies

- 02-001 (Enhanced Logging Modes) - Privacy mode integrates with logging

## Notes

- Privacy mode should be opt-in by default
- Sensitive data includes: PII, credentials, file contents, etc.
- Privacy policy should be clear and accessible
- Consider privacy by design principles
