---
story_id: "03-005"
story_title: "Resource Limits"
story_name: "resource-limits"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 3
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-03-005-resource-limits"
status: "in_progress"
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

- [x] Add --max-memory flag to CLI
- [x] Add --max-cpu flag to CLI
- [x] Implement memory limit enforcement
- [x] Implement CPU limit enforcement
- [x] Add resource limit validation
- [x] Integrate resource limits with daemon job management
- [x] Add resource limit monitoring
- [x] Implement resource limit violation handling
- [x] Create tests for memory limits
- [x] Create tests for CPU limits
- [x] Create tests for resource limit enforcement

## Relevant Files

- `apps/cli/rust/core/files/src/resource.rs.jinja` — Resource management module (new)
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Added --max-memory and --max-cpu flags
- `apps/cli/rust/core/files/src/daemon.rs.jinja` — Integrated resource limits with job management
- `apps/cli/rust/core/files/src/config.rs.jinja` — Added daemon resource limit config fields
- `apps/cli/rust/core/files/src/main.rs.jinja` — Added resource limit parsing and validation
- `apps/cli/rust/core/files/src/lib.rs.jinja` — Exported resource types
- `apps/cli/rust/core/files/tests/resource_test.rs.jinja` — Comprehensive resource limit tests

## Acceptance Criteria

- [x] --max-memory flag enforces memory limits
- [x] --max-cpu flag enforces CPU limits
- [x] Resource limits validated before execution
- [x] Resource limits enforced in daemon mode
- [x] Resource limit violations handled gracefully
- [x] All tests pass

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
