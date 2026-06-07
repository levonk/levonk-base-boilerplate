---
story_id: "02-004"
story_title: "Daemon Process Support"
story_name: "daemon-support"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 2
parallel_id: 4
branch: "feature/current/20260707-cli-rust-standards/story-02-004-daemon-support"
status: "todo"
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

- [ ] Add tokio dependency to Cargo.toml for async runtime
- [ ] Create daemon.rs module with daemon process management
- [ ] Implement --daemon flag (pre-launch daemon and wait for jobs)
- [ ] Implement --no-daemon flag (force synchronous in-process operation)
- [ ] Implement auto-spawn daemon on first async operation
- [ ] Create job queue system for background tasks
- [ ] Implement --list-jobs command with optional job ID filter
- [ ] Implement --cancel-job <id> command
- [ ] Add job status tracking (pending, running, completed, failed)
- [ ] Implement job output capture and return
- [ ] Add IPC mechanism for daemon communication (Unix sockets/HTTP)
- [ ] Implement platform detection and fallback
- [ ] Add clear error messages for unsupported platforms
- [ ] Add config variable to override noisy behavior
- [ ] Create tests for daemon spawning
- [ ] Create tests for job submission and tracking
- [ ] Create tests for --list-jobs command
- [ ] Create tests for --cancel-job command
- [ ] Create tests for platform fallback

## Relevant Files

- `apps/cli/rust/src/daemon.rs` — Daemon process management
- `apps/cli/rust/src/cli.rs` — Add --daemon, --no-daemon, --list-jobs, --cancel-job
- `apps/cli/rust/src/config.rs` — Add daemon config settings
- `apps/cli/rust/Cargo.toml` — Tokio and daemon dependencies
- `apps/cli/rust/tests/daemon_test.rs` — Daemon tests

## Acceptance Criteria

- [ ] --daemon flag pre-launches daemon and waits for jobs
- [ ] --no-daemon flag forces synchronous operation
- [ ] Auto-spawn daemon on first async operation
- [ ] --list-jobs shows background job status with optional filter
- [ ] --cancel-job cancels specific background jobs
- [ ] Job output returned immediately from --list-jobs
- [ ] Platform fallback with clear error messages
- [ ] Config variable overrides noisy behavior
- [ ] All tests pass

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
