---
story_id: "03-011"
story_title: "Audit Logging with Retention"
story_name: "audit-logging"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 11
branch: "feature/current/20260707-cli-python-standards/story-03-011-audit-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["audit", "main"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "audit"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Provide optional append-only audit log (SQLite or similar). Implement configurable retention period, auto-prune old data on startup, and support export commands for external analysis.

## Sub-Tasks

- [ ] Implement SQLite audit log
- [ ] Add append-only constraint
- [ ] Implement configurable retention period
- [ ] Implement auto-prune on startup
- [ ] Add export commands (JSON/CSV)
- [ ] Add tests for audit logging
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/audit.py.jinja` - Audit module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_audit.py.jinja` - Audit tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Audit log uses SQLite
- [ ] Audit log is append-only
- [ ] Retention period configurable
- [ ] Auto-prune on startup works
- [ ] Export to JSON works
- [ ] Export to CSV works
- [ ] Tests verify audit logging

## Test Plan

- Unit: `pytest tests/test_audit.py -v -k test_audit`
- Integration: `pytest tests/test_main.py -v -k test_audit_logging`
- Manual: Test audit log creation and export

## Observability

- Log audit events
- Log prune operations

## Compliance

- Ensure audit log integrity
- Respect retention policies

## Risks & Mitigations

- Risk: Audit log grows too large — Mitigation: Auto-prune and retention
- Risk: SQLite not available — Mitigation: Graceful fallback

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Audit logging implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(audit): add audit logging with retention`

## Changelog

- 2025-07-08: initialized story file
