---
story_id: "03-002"
story_title: "Daemon Process Support"
story_name: "daemon-process-support"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260707-cli-go-standards/story-03-002-daemon-process-support"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: false
modules: ["daemon", "main"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "daemon"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement daemon process support for long-running tasks with comprehensive job management. Provide `--daemon` and `--no-daemon` flags, auto-spawn daemon on first async operation, `--list-jobs` command, `--cancel-job <id>` command, and platform fallback with clear error messages.

## Sub-Tasks

- [x] Add kardianos/service or fvbock/endless dependency to go.mod — `core/files/go.mod.jinja`
- [x] Add --daemon and --no-daemon flags — `core/files/main.go.jinja`
- [x] Create daemon process manager using kardianos/service or fvbock/endless — `core/files/daemon.go.jinja`
- [x] Implement auto-spawn daemon logic — `core/files/daemon.go.jinja`
- [x] Implement job queue management — `core/files/daemon.go.jinja`
- [x] Add --list-jobs command — `core/files/main.go.jinja`
- [x] Add --cancel-job <id> command — `core/files/main.go.jinja`
- [x] Implement job ID generation and tracking — `core/files/daemon.go.jinja`
- [x] Add platform detection for daemon support — `core/files/daemon.go.jinja`
- [x] Implement platform fallback with error messages — `core/files/daemon.go.jinja`
- [x] Add config variable for noisy behavior override — `core/files/daemon.go.jinja`
- [x] Test daemon spawns correctly — `core/files/daemon_test.go.jinja`
- [x] Test job management — `core/files/daemon_test.go.jinja`
- [x] Test list-jobs command — `core/files/daemon_test.go.jinja`
- [x] Test cancel-job command — `core/files/daemon_test.go.jinja`
- [x] Test platform fallback — `core/files/daemon_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add daemon flags and commands
- `apps/cli/go/core/files/daemon.go.jinja` — New file for daemon logic
- `apps/cli/go/core/files/daemon_test.go.jinja` — New file for daemon tests
- `apps/cli/go/core/files/config.default.yaml.jinja` — Add daemon config settings

## Acceptance Criteria

- [ ] `--daemon` flag pre-launches daemon in background
- [ ] `--no-daemon` flag forces synchronous operation
- [ ] Daemon auto-spawns on first async operation
- [ ] `--list-jobs` shows background job status
- [ ] `--cancel-job <id>` cancels specific jobs
- [ ] Job ID returned immediately for background operations
- [ ] Platform fallback works with clear error messages
- [ ] Config variable overrides noisy behavior
- [ ] Job management works correctly

## Test Plan

- Unit: Test daemon process management
- Integration: Test daemon lifecycle and job management
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log daemon spawn events
- Log job creation and completion
- Log job cancellation

## Compliance

- Handle daemon cleanup properly
- Respect platform limitations
- Provide clear error messages

## Risks & Mitigations

- Risk: Daemon may not work on all platforms — Mitigation: Clear platform fallback
- Risk: Job management may be complex — Mitigation: Keep job model simple
- Risk: Daemon may leak resources — Mitigation: Proper cleanup on exit

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization), 01-006 (Configuration Precedence Chain)
- Unblocks: None

## Definition of Done

- Daemon mode works on supported platforms
- Job management is reliable
- Platform fallback is clear
- All tests pass

## Commit Conventions

- `feat(daemon): add daemon process support`
- `feat(daemon): add job management`
- `feat(daemon): add platform fallback`
- `test(daemon): add tests for daemon support`
