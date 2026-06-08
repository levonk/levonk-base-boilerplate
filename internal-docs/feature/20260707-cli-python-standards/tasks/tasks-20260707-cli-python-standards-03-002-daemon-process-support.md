---
story_id: "03-002"
story_title: "Daemon Process Support"
story_name: "daemon-process-support"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260707-cli-python-standards/story-03-002-daemon-process-support"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: false
modules: ["daemon", "main"]
priority: "SHOULD"
risk_level: "high"
tags: ["feat", "daemon"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement `--daemon` and `--no-daemon` flags as opposites. Auto-spawn daemon on first async operation, pre-launch daemon with `--daemon`, force synchronous with `--no-daemon`, include `--list-jobs` and `--cancel-job` commands, and return job ID immediately for background operations.

## Sub-Tasks

- [x] Add daemon process implementation
- [x] Implement --daemon flag
- [x] Implement --no-daemon flag
- [x] Implement auto-spawn on async operations
- [x] Implement --list-jobs command
- [x] Implement --cancel-job command
- [x] Return job ID for background operations
- [x] Add tests for daemon mode
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/daemon.py.jinja` - Daemon module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_daemon.py.jinja` - Daemon tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--daemon` flag pre-launches daemon
- [ ] `--no-daemon` flag forces synchronous
- [ ] Daemon auto-spawns on async operations
- [ ] `--list-jobs` shows background jobs
- [ ] `--cancel-job` cancels specific jobs
- [ ] Job ID returned immediately for background ops
- [ ] Tests verify daemon functionality

## Test Plan

- Unit: `pytest tests/test_daemon.py -v -k test_daemon`
- Integration: `pytest tests/test_main.py -v -k test_daemon_mode`
- Manual: Test daemon mode with background jobs

## Observability

- Log daemon start/stop
- Log job status changes

## Compliance

- Handle unsupported platforms gracefully
- Provide clear error messages

## Risks & Mitigations

- Risk: Daemon not supported on Windows — Mitigation: Platform detection with fallback
- Risk: Daemon process leaks — Mitigation: Proper cleanup on exit

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization), 01-006 (Config Precedence Chain)
- Unblocks: None

## Definition of Done

- Daemon support implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(daemon): add daemon process support`

## Changelog

- 2025-07-08: initialized story file
