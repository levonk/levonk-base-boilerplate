---
story_id: "06-005"
story_title: "Audit Logging with Retention"
story_name: "audit-logging"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 6
parallel_id: 5
branch: "feature/current/cli-python-standards/story-06-005-audit-logging"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["audit module"]
priority: "SHOULD"
risk_level: "medium"
tags: ["feat", "cli", "audit"]
due: "2026-07-26"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement optional append-only audit logging using SQLite for CLIs that process significant data. Add configurable retention period, auto-prune old data on startup, support export commands for external analysis, and implement `--audit-log` flag.

## Sub-Tasks

- [ ] Add `include_audit` boolean option to `copier.yml` — `apps/cli/python/core/copier.yml`
- [ ] Create `audit.py.jinja` template file with audit logging implementation — `apps/cli/python/core/files/{{project_slug}}/audit.py.jinja`
- [ ] Implement append-only audit log using SQLite — `audit.py.jinja`
- [ ] Add configurable retention period to config file schema — `apps/cli/python/core/files/{{project_slug}}/config.py.jinja`
- [ ] Implement auto-prune old data on startup — `audit.py.jinja`
- [ ] Add export commands for external analysis — `audit.py.jinja`
- [ ] Add `--audit-log` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Integrate audit logging into data processing logic — `__main__.py.jinja`
- [ ] Add audit settings to config file initialization — `config.py.jinja`
- [ ] Add tests for audit logging functionality — `apps/cli/python/core/files/tests/test_audit.py.jinja` (conditional)
- [ ] Add tests for retention and auto-prune — `tests/test_audit.py.jinja` (conditional)
- [ ] Add tests for export functionality — `tests/test_audit.py.jinja` (conditional)

## Relevant Files

- `apps/cli/python/core/copier.yml` — Add include_audit template option
- `apps/cli/python/core/files/{{project_slug}}/audit.py.jinja` — New audit module (conditional)
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Add audit settings to config
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --audit-log flag
- `apps/cli/python/core/files/tests/test_audit.py.jinja` — New test file (conditional)

## Acceptance Criteria

- [ ] Append-only audit log implemented using SQLite
- [ ] Configurable retention period working
- [ ] Auto-prune old data on startup
- [ ] Export commands for external analysis working
- [ ] `--audit-log` flag working
- [ ] Audit settings in config file
- [ ] Audit logging optional via template choice
- [ ] All tests pass for audit logging scenarios

## Test Plan

- Unit: `pytest tests/test_audit.py::test_append_only_log` (conditional)
- Unit: `pytest tests/test_audit.py::test_retention_period` (conditional)
- Unit: `pytest tests/test_audit.py::test_auto_prune` (conditional)
- Unit: `pytest tests/test_audit.py::test_export_functionality` (conditional)
- Integration: Test audit logging with data processing (conditional)

## Observability

- Log audit logging activation
- Track audit log size and retention
- Monitor export operations

## Compliance

- Audit log respects data protection requirements
- Append-only ensures audit trail integrity
- Export functionality respects access controls

## Risks & Mitigations

- Risk: Audit log may grow large — Mitigation: Configurable retention, auto-prune
- Risk: SQLite may not be suitable for high-volume scenarios — Mitigation: Make optional, document limitations
- Risk: Export may expose sensitive data — Mitigation: Access controls, user confirmation

## Dependencies & Sequencing

- Depends on: None (standalone audit feature)
- Unblocks: None (standalone compliance feature)

## Definition of Done

- Append-only audit log implemented
- Configurable retention period working
- Auto-prune on startup working
- Export commands implemented
- `--audit-log` flag working
- Audit settings in config file
- Audit logging optional via template choice
- Tests pass for audit logging scenarios
- Documentation updated for audit logging usage

## Commit Conventions

- `feat(audit): add append-only audit logging with SQLite`
- `feat(audit): implement configurable retention period`
- `feat(audit): add auto-prune and export functionality`
- `test(audit): add tests for audit logging`
