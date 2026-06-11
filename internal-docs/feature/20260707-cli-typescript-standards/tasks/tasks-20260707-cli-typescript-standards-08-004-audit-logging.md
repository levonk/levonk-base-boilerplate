---
story_id: "08-004"
story_title: "Audit Logging"
story_name: "audit-logging"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 8
parallel_id: 4
branch: "feature/current/20260707-cli-typescript-standards/story-08-004-audit-logging"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["audit/"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "audit"]
due: "2026-09-01"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement audit logging for sensitive operations. Include retention policy for audit logs, support configurable log rotation, and ensure audit logs are tamper-evident. This implements CLI Tool Standards ADR requirement #31.

## Sub-Tasks

- [x] Create audit logging module
- [x] Define sensitive operations requiring audit
- [x] Implement audit log format
- [x] Add audit log rotation support
- [x] Implement audit log retention policy
- [x] Add tamper-evident audit logs
- [x] Implement append-only audit log using SQLite or similar
- [x] Add auto-prune old data on startup
- [x] Implement audit log filtering
- [x] Add audit log export capability for external analysis
- [x] Add unit tests for audit logging
- [x] Add unit tests for log rotation
- [x] Add unit tests for append-only behavior
- [x] Add unit tests for auto-prune logic
- [x] Add integration tests for audit workflow
- [x] Update help text to document audit logging
- [x] Add audit logging configuration

## Relevant Files

- `apps/cli/typescript/core/files/src/audit.ts.jinja` - New audit logging module with SQLite-based append-only storage
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with audit integration and CLI flags
- `apps/cli/typescript/core/files/src/audit.test.ts.jinja` - Unit tests for audit logging
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for audit workflow
- `apps/cli/typescript/core/files/src/config.ts.jinja` - Config schema updated with audit settings
- `apps/cli/typescript/core/files/package.json.jinja` - Added better-sqlite3 dependency

## Acceptance Criteria

- [x] Sensitive operations are logged to audit log
- [x] Audit log format is consistent
- [x] Audit log rotation works correctly
- [x] Audit log retention policy is enforced
- [x] Audit logs are tamper-evident
- [x] Audit logs use append-only storage (SQLite or similar)
- [x] Old data is auto-pruned on startup
- [x] Audit logs can be filtered
- [x] Audit logs can be exported for external analysis
- [x] Audit logging is configurable
- [x] Audit logs are secure

## Test Plan

- Unit: `vitest run src/audit.test.ts` - Test audit logging logic
- Integration: `vitest run src/index.test.ts` - Test audit workflow
- Manual: Trigger sensitive operations and verify audit logs
- Manual: Test audit log rotation and retention

## Observability

- Audit logs provide security monitoring
- Track audit log events for security analytics
- Add metrics for audit log performance

## Compliance

- Follows CLI Tool Standards ADR requirement #31 (Audit Logging)
- Enables security auditing and compliance

## Risks & Mitigations

- Risk: Audit logging performance impact
  - Mitigation: Async logging, efficient format, configurable sampling
- Risk: Audit logs contain sensitive information
  - Mitigation: Careful field selection, encryption at rest
- Risk: Audit logs are tampered with
  - Mitigation: Tamper-evident storage, write-once media, signing

## Dependencies

- 02-001 (Enhanced Logging Modes) - Audit logging integrates with logging system

## Notes

- Audit logs should be separate from regular logs
- Consider using append-only file format for tamper evidence
- Audit log retention should be configurable
- Sensitive operations include: config changes, file operations, etc.
