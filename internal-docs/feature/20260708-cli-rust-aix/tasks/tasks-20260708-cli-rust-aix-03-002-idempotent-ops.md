---
story_id: "03-002"
story_title: "Idempotent Operations"
story_name: "idempotent-ops"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260708-cli-rust-aix/story-03-002-idempotent-ops"
status: "in_progress"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["cli-commands", "business-logic"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli-commands", "axi"]
due: "2026-06-17"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement idempotent operations so that repeating commands doesn't cause errors when the desired state already exists. If an agent closes something already closed, acknowledge and move on with exit code 0. Reserve non-zero exit codes for situations where the agent's intent cannot be satisfied.

## Sub-Tasks

- [x] Identify all state-changing operations (create, update, delete, close, etc.)
- [x] Design idempotency strategy for each operation type
- [x] Implement state checking before applying changes
- [x] Add idempotent handling for create operations (skip if exists)
- [x] Add idempotent handling for update operations (skip if unchanged)
- [x] Add idempotent handling for delete operations (skip if already deleted)
- [x] Add idempotent handling for close operations (skip if already closed)
- [x] Implement success acknowledgment for no-op operations
- [x] Ensure exit code 0 for idempotent no-ops
- [x] Add descriptive messages for idempotent operations
- [x] Update all state-changing commands to be idempotent
- [x] Write unit tests for idempotent operation logic
- [x] Write integration tests for idempotent command behavior
- [x] Write tests for exit code behavior with idempotent operations
- [x] Update CLI help text to document idempotent behavior

## Relevant Files

- `apps/cli/rust/core/files/src/internal/idempotency/mod.rs.jinja` — Idempotency module exports (new file)
- `apps/cli/rust/core/files/src/internal/idempotency/handler.rs.jinja` — Idempotency logic with operation types and state checking (new file)
- `apps/cli/rust/core/files/src/internal/idempotency/tests.rs.jinja` — Integration tests for idempotency (new file)
- `apps/cli/rust/core/files/src/internal/mod.rs.jinja` — Added idempotency module export
- `apps/cli/rust/core/files/src/main.rs.jinja` — Added idempotent handling for --install and --uninstall flags
- `apps/cli/rust/core/files/src/cli.rs.jinja` — Added idempotent behavior documentation to help text

## Acceptance Criteria

- [x] All state-changing operations are idempotent
- [x] State checking happens before applying changes
- [x] No-op operations return exit code 0
- [x] No-op operations provide descriptive acknowledgment messages
- [x] Idempotent handling works for all operation types
- [x] Exit code 0 is reserved for successful no-ops
- [x] Non-zero exit codes are only for unresolvable situations
- [x] All idempotent functionality has test coverage
- [x] Help text documents idempotent behavior

## Test Plan

- Unit: `cargo test --lib internal::idempotency`
- Integration: Test idempotent behavior for all state-changing commands
- Manual: Verify idempotent operations with various scenarios

## Observability

- Add logging for idempotent operation detection at debug level
- Add metrics for idempotent operation frequency

## Compliance

- Ensure idempotent operations don't bypass security controls
- Validate that no-op acknowledgments don't leak sensitive information

## Risks & Mitigations

- Risk: Idempotency may hide actual errors — Mitigation: Clear distinction between no-op and error states
- Risk: State checking may impact performance — Mitigation: Optimize state queries, add caching where appropriate

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- No other dependencies (can be developed in parallel with 03-001, 03-003)

## Notes

- Idempotency should be consistent across all state-changing operations
- Document which operations are idempotent and their behavior
- Consider adding idempotency to CI/CD validation tests
