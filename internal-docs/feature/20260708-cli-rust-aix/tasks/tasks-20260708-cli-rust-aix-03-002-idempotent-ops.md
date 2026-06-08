---
story_id: "03-002"
story_title: "Idempotent Operations"
story_name: "idempotent-ops"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260708-cli-rust-aix/story-03-002-idempotent-ops"
status: "todo"
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

- [ ] Identify all state-changing operations (create, update, delete, close, etc.)
- [ ] Design idempotency strategy for each operation type
- [ ] Implement state checking before applying changes
- [ ] Add idempotent handling for create operations (skip if exists)
- [ ] Add idempotent handling for update operations (skip if unchanged)
- [ ] Add idempotent handling for delete operations (skip if already deleted)
- [ ] Add idempotent handling for close operations (skip if already closed)
- [ ] Implement success acknowledgment for no-op operations
- [ ] Ensure exit code 0 for idempotent no-ops
- [ ] Add descriptive messages for idempotent operations
- [ ] Update all state-changing commands to be idempotent
- [ ] Write unit tests for idempotent operation logic
- [ ] Write integration tests for idempotent command behavior
- [ ] Write tests for exit code behavior with idempotent operations
- [ ] Update CLI help text to document idempotent behavior

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/idempotency/handler.rs` — Idempotency logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/idempotency/tests.rs` — Tests for idempotency (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/create.rs` — Update create operations
- `boilerplate/apps/cli/rust/core/src/cli/commands/update.rs` — Update update operations
- `boilerplate/apps/cli/rust/core/src/cli/commands/delete.rs` — Update delete operations
- `boilerplate/apps/cli/rust/core/src/cli/commands/close.rs` — Update close operations
- `boilerplate/apps/cli/rust/core/src/cli/commands/*_tests.rs` — Update tests for idempotency

## Acceptance Criteria

- [ ] All state-changing operations are idempotent
- [ ] State checking happens before applying changes
- [ ] No-op operations return exit code 0
- [ ] No-op operations provide descriptive acknowledgment messages
- [ ] Idempotent handling works for all operation types
- [ ] Exit code 0 is reserved for successful no-ops
- [ ] Non-zero exit codes are only for unresolvable situations
- [ ] All idempotent functionality has test coverage
- [ ] Help text documents idempotent behavior

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
