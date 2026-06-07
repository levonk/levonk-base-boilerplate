---
story_id: "05-002"
story_title: "Daemon Process Support"
story_name: "daemon-process-support"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 5
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-05-002-daemon-process-support"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: false
modules: ["daemon/"]
priority: "COULD"
risk_level: "high"
tags: ["feat", "cli", "daemon"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive daemon process support for long-running operations. Add `--daemon` and `--no-daemon` flags as opposites, auto-spawn daemon on first async operation, implement job management with `--list-jobs` and `--cancel-job` commands, and provide platform fallback with clear error messages. This implements CLI Tool Standards ADR requirement #13.

## Sub-Tasks

- [ ] Create daemon module with process management
- [ ] Add `--daemon` flag to index.ts
- [ ] Add `--no-daemon` flag to index.ts
- [ ] Implement daemon process spawning logic
- [ ] Implement auto-spawn on first async operation
- [ ] Add `--list-jobs` command for job status
- [ ] Add `--cancel-job <id>` command for job cancellation
- [ ] Implement job ID generation and tracking
- [ ] Add job progress monitoring
- [ ] Implement daemon IPC (inter-process communication)
- [ ] Add platform detection and fallback logic
- [ ] Add config variable for platform fallback behavior
- [ ] Implement daemon cleanup and shutdown
- [ ] Add unit tests for daemon management
- [ ] Add unit tests for job lifecycle
- [ ] Add integration tests for daemon operations
- [ ] Update help text to document daemon mode

## Relevant Files

- `apps/cli/typescript/core/files/src/daemon.ts.jinja` - New daemon module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with daemon flags
- `apps/cli/typescript/core/files/src/daemon.test.ts.jinja` - Unit tests for daemon (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for daemon

## Acceptance Criteria

- [ ] `--daemon` flag pre-launches daemon in background
- [ ] `--no-daemon` flag forces synchronous operation
- [ ] Daemon auto-spawns on first async operation
- [ ] `--list-jobs` command shows background job status
- [ ] `--cancel-job <id>` command cancels specific jobs
- [ ] Job ID is returned immediately for background operations
- [ ] Job progress can be monitored
- [ ] Daemon falls back to synchronous on unsupported platforms
- [ ] Clear error message for unsupported platforms
- [ ] Config variable overrides noisy fallback behavior
- [ ] Daemon cleanup works correctly on shutdown

## Test Plan

- Unit: `vitest run src/daemon.test.ts` - Test daemon management logic
- Integration: `vitest run src/index.test.ts` - Test daemon operations
- Manual: Test daemon spawning and job management
- Manual: Test platform fallback behavior

## Observability

- Log daemon lifecycle events
- Track job status and completion
- Add metrics for daemon performance
- Monitor daemon resource usage

## Compliance

- Follows CLI Tool Standards ADR requirement #13 (Daemon Process Support)
- Enables long-running operations without blocking CLI

## Risks & Mitigations

- Risk: Daemon process management is complex
  - Mitigation: Use well-tested library, comprehensive error handling
- Risk: Daemon doesn't work on all platforms
  - Mitigation: Platform detection, clear fallback behavior
- Risk: IPC communication fails
  - Mitigation: Robust IPC implementation, retry logic, timeouts
- Risk: Daemon resource leaks
  - Mitigation: Proper cleanup, resource monitoring, timeouts

## Dependencies

- None - this is a complex feature that should be developed separately

## Notes

- Consider using node-daemon or similar library for process management
- IPC could use Unix sockets, named pipes, or HTTP
- Job state should be persisted for recovery
- Daemon should have graceful shutdown handling
- This is marked as not parallel-safe due to complexity and potential conflicts
