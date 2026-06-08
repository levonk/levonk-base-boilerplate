---
story_id: "04-003"
story_title: "Integration Testing"
story_name: "integration-testing"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 4
parallel_id: 3
branch: "feature/current/20260707-cli-go-standards/story-04-003-integration-testing"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["04-001", "04-002"]
parallel_safe: true
modules: ["all"]
priority: "MUST"
risk_level: "medium"
tags: ["test", "integration"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive integration tests that verify the entire CLI tool works end-to-end with all features working together. Test complete workflows, config file interactions, shell completion installation, and cross-platform behavior.

## Sub-Tasks

- [x] Create integration test framework — `core/files/integration_test.go.jinja`
- [x] Test complete CLI workflow end-to-end — `core/files/integration_test.go.jinja`
- [x] Test config file initialization and loading — `core/files/integration_test.go.jinja`
- [x] Test config precedence chain end-to-end — `core/files/integration_test.go.jinja`
- [x] Test install/uninstall workflow — `core/files/integration_test.go.jinja`
- [x] Test shell completion installation — `core/files/integration_test.go.jinja`
- [x] Test color control in real terminal — `core/files/integration_test.go.jinja`
- [x] Test daemon process lifecycle — `core/files/integration_test.go.jinja`
- [x] Test TUI mode interaction — `core/files/integration_test.go.jinja`
- [x] Test error handling in real scenarios — `core/files/integration_test.go.jinja`
- [x] Test cross-platform path handling — `core/files/integration_test.go.jinja`
- [x] Test config migration workflow — `core/files/integration_test.go.jinja`
- [x] Add integration test to Makefile — `core/files/Makefile.jinja`
- [x] Run all integration tests — `Makefile.jinja`

## Relevant Files

- `apps/cli/go/core/files/integration_test.go.jinja` — New file for integration tests
- `apps/cli/go/core/files/Makefile.jinja` — Add integration test target

## Acceptance Criteria

- [x] Integration tests cover complete workflows
- [x] All features work together correctly
- [x] Integration tests pass consistently
- [x] Integration tests are maintainable
- [x] Integration tests can run in CI

## Test Plan

- Integration: Run all integration tests
- End-to-end: Test complete user workflows
- Cross-platform: Test on multiple platforms
- Lint: `go vet ./...`

## Observability

- Integration test results logged
- Integration test coverage reported

## Compliance

- Ensure integration tests don't require external dependencies
- Ensure integration tests are deterministic

## Risks & Mitigations

- Risk: Integration tests may be slow — Mitigation: Keep tests focused
- Risk: Integration tests may be flaky — Mitigation: Make tests deterministic
- Risk: Integration tests may require specific environment — Mitigation: Use test fixtures

## Dependencies & Sequencing

- Depends on: 04-001 (Test Coverage for New Features), 04-002 (Test Coverage for Existing Features)
- Unblocks: None

## Definition of Done

- Integration tests cover all major workflows
- All integration tests pass
- Integration tests run in CI
- All acceptance criteria met

## Commit Conventions

- `test(integration): add integration tests`
- `test(integration): add end-to-end workflow tests`
- `test(integration): add cross-platform tests`
