---
story_id: "02-004"
story_title: "Daemon Process Support"
story_name: "daemon-support"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260707-cli-rust-standards/story-02-004-daemon-support"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-002", "01-004"]
parallel_safe: true
modules: ["daemon.rs"]
priority: "MUST"
risk_level: "high"
tags: ["feat", "daemon"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive daemon process support for long-running tasks (>30 seconds) with --daemon/--no-daemon flags, auto-spawning, job management (--list-jobs, --cancel-job), and platform fallback with clear error messages.

## Sub-Tasks

- [x] Add tokio dependency to Cargo.toml for async runtime
- [x] Create daemon.rs module with daemon process management
- [x] Implement --daemon flag (pre-launch daemon and wait for jobs)
- [x] Implement --no-daemon flag (force synchronous in-process operation)
- [x] Implement auto-spawn daemon on first async operation
- [x] Create job queue system for background tasks
- [x] Implement --list-jobs command with optional job ID filter
- [x] Implement --cancel-job <id> command
- [x] Add job status tracking (pending, running, completed, failed)
- [x] Implement job output capture and return
- [x] Add IPC mechanism for daemon communication (Unix sockets/HTTP)
- [x] Implement platform detection and fallback
- [x] Add clear error messages for unsupported platforms
- [x] Add config variable to override noisy behavior
- [x] Create tests for daemon spawning
- [x] Create tests for job submission and tracking
- [x] Create tests for --list-jobs command
- [x] Create tests for --cancel-job command
- [x] Create tests for platform fallback

## Relevant Files

- `apps/cli/rust/core/files/src/daemon.rs.jinja` — Daemon process management
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Add --daemon, --no-daemon, --list-jobs, --cancel-job
- `apps/cli/rust/core/files/src/config.rs.jinja` — Add daemon config settings
- `apps/cli/rust/core/files/src/main.rs.jinja` — Integrate daemon manager
- `apps/cli/rust/core/files/src/lib.rs.jinja` — Export daemon types
- `apps/cli/rust/core/files/Cargo.toml.jinja` — Tokio and daemon dependencies
- `apps/cli/rust/core/files/templates/config.toml.jinja` — Add daemon config template
- `apps/cli/rust/core/files/tests/daemon_test.rs.jinja` — Daemon tests

## Acceptance Criteria

- [x] --daemon flag pre-launches daemon and waits for jobs
- [x] --no-daemon flag forces synchronous operation
- [x] Auto-spawn daemon on first async operation
- [x] --list-jobs shows background job status with optional filter
- [x] --cancel-job cancels specific background jobs
- [x] Job output returned immediately from --list-jobs
- [x] Platform fallback with clear error messages
- [x] Config variable overrides noisy behavior
- [x] All tests pass

## Test Plan

- Unit: `cargo test daemon`
- Integration: Test daemon spawning, job management, platform fallback
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log daemon lifecycle events, job submissions, job completions
- Metrics: Track daemon uptime, job queue length, job completion rates

## Compliance

- No regulatory constraints
- Ensure daemon runs with minimal privileges
- No sensitive data in job output logs

## Risks & Mitigations

- Risk: IPC mechanism cross-platform compatibility — Mitigation: Test on Linux/Windows/macOS, fallback to HTTP if needed
- Risk: Daemon orphaning on parent process death — Mitigation: Proper process supervision, cleanup on startup
- Risk: Job queue memory leaks — Mitigation: Job retention limits, periodic cleanup

## Dependencies & Sequencing

- Depends on: 01-002 (config management), 01-004 (logging)
- Unblocks: 03-005 (resource limits), 03-006 (health checks), 04-002 (collection/processing separation)

## Definition of Done

- Daemon process support fully implemented
- All daemon flags working
- Job management functional
- Platform fallback with clear errors
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(daemon): implement daemon process support with job management`
- `feat(daemon): add --list-jobs and --cancel-job commands`
- `test(daemon): add comprehensive daemon tests`
