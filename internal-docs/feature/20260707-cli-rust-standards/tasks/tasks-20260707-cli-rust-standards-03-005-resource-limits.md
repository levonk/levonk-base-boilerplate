---
story_id: "03-005"
story_title: "Resource Limits"
story_name: "resource-limits"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 3
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-03-005-resource-limits"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-004"]
parallel_safe: true
modules: ["daemon.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "daemon"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement --max-memory and --max-cpu flags for long-running operations where applicable, with resource limit enforcement in daemon mode.

## Sub-Tasks

- [ ] Add --max-memory flag to CLI
- [ ] Add --max-cpu flag to CLI
- [ ] Implement memory limit enforcement
- [ ] Implement CPU limit enforcement
- [ ] Add resource limit validation
- [ ] Integrate resource limits with daemon job management
- [ ] Add resource limit monitoring
- [ ] Implement resource limit violation handling
- [ ] Create tests for memory limits
- [ ] Create tests for CPU limits
- [ ] Create tests for resource limit enforcement

## Relevant Files

- `apps/cli/rust/src/daemon.rs` — Resource limit enforcement
- `apps/cli/rust/src/cli.rs` — Add --max-memory and --max-cpu flags
- `apps/cli/rust/src/resource.rs` — Resource management (new module)
- `apps/cli/rust/tests/resource_test.rs` — Resource limit tests

## Acceptance Criteria

- [ ] --max-memory flag enforces memory limits
- [ ] --max-cpu flag enforces CPU limits
- [ ] Resource limits validated before execution
- [ ] Resource limits enforced in daemon mode
- [ ] Resource limit violations handled gracefully
- [ ] All tests pass

## Test Plan

- Unit: `cargo test resource`
- Integration: Test resource limit enforcement, violation handling
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log resource limit enforcement, violations
- Metrics: Track resource usage, limit violations

## Compliance

- No regulatory constraints
- Ensure resource limits don't cause data corruption

## Risks & Mitigations

- Risk: Resource limit enforcement not available on all platforms — Mitigation: Platform detection, graceful fallback
- Risk: Resource limits cause unexpected termination — Mitigation: Clear warnings, graceful shutdown with cleanup

## Dependencies & Sequencing

- Depends on: 02-004 (daemon support)
- Unblocks: None (operational feature)

## Definition of Done

- Resource limits implemented
- --max-memory and --max-cpu flags working
- Resource limit enforcement in daemon mode
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(daemon): implement resource limits with --max-memory and --max-cpu`
- `feat(daemon): add resource limit enforcement in daemon mode`
- `test(daemon): add resource limit tests`
