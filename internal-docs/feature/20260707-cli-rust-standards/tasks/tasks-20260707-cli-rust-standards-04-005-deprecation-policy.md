---
story_id: "04-005"
story_title: "Legacy Deprecation Policy"
story_name: "deprecation-policy"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 4
parallel_id: 5
branch: "feature/current/20260707-cli-rust-standards/story-04-005-deprecation-policy"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["deprecation.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "deprecation"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement legacy deprecation policy with clear end-of-support dates (minimum 6 months from announcement), deprecation warnings logged to stderr during deprecation period, and removal of legacy support only after specified date.

## Sub-Tasks

- [ ] Create deprecation.rs module
- [ ] Implement deprecation tracking system
- [ ] Add deprecation announcement mechanism
- [ ] Implement end-of-support date tracking
- [ ] Add deprecation warning logging to stderr
- [ ] Implement legacy feature detection
- [ ] Add deprecation policy enforcement
- [ ] Integrate deprecation with config migration
- [ ] Create tests for deprecation warnings
- [ ] Create tests for end-of-support enforcement
- [ ] Create tests for legacy feature detection
- [ ] Add deprecation documentation

## Relevant Files

- `apps/cli/rust/src/deprecation.rs` — Deprecation policy module
- `apps/cli/rust/src/config.rs` — Integrate with config migration
- `apps/cli/rust/src/logging.rs` — Log deprecation warnings
- `apps/cli/rust/tests/deprecation_test.rs` — Deprecation tests

## Acceptance Criteria

- [ ] Deprecation announcements include end-of-support date
- [ ] End-of-support date minimum 6 months from announcement
- [ ] Deprecation warnings logged to stderr
- [ ] Legacy features detected and flagged
- [ ] Legacy support removed only after specified date
- [ ] All tests pass

## Test Plan

- Unit: `cargo test deprecation`
- Integration: Test deprecation warnings, end-of-support enforcement
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log deprecation warnings, legacy feature usage
- Metrics: Track deprecated feature usage, migration rate

## Compliance

- No regulatory constraints
- Ensure deprecation doesn't break existing users prematurely

## Risks & Mitigations

- Risk: Users miss deprecation warnings — Mitigation: Multiple warning channels (stderr, logs, config)
- Risk: Deprecation timeline too short — Mitigation: Minimum 6-month policy, clear communication

## Dependencies & Sequencing

- Depends on: 01-002 (config management)
- Unblocks: None (policy feature)

## Definition of Done

- Deprecation policy implemented
- End-of-support date tracking working
- Deprecation warnings logged to stderr
- Legacy feature detection functional
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(deprecation): implement legacy deprecation policy`
- `feat(deprecation): add end-of-support date tracking`
- `test(deprecation): add deprecation policy tests`
