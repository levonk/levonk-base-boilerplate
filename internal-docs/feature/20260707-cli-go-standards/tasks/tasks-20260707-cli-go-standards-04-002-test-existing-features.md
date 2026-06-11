---
story_id: "04-002"
story_title: "Test Coverage for Existing Features"
story_name: "test-existing-features"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260707-cli-go-standards/story-04-002-test-existing-features"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["all"]
priority: "MUST"
risk_level: "low"
tags: ["test", "coverage"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Ensure comprehensive test coverage for all existing CLI functionality that was already implemented before this standards compliance work. This includes testing existing features like --verbose, --quiet, --no-color, globbing, stdin handling, SIGINT handling, environment variable naming, cross-platform paths, and subcommand organization.

## Sub-Tasks

- [x] Test existing --verbose flag — `core/files/main_test.go.jinja`
- [x] Test existing --quiet flag — `core/files/main_test.go.jinja`
- [x] Test existing --no-color flag (backward compatibility) — `core/files/logger_test.go.jinja`
- [x] Test existing globbing with doublestar or glob — `core/files/main_test.go.jinja`
- [x] Test existing stdin handling — `core/files/main_test.go.jinja`
- [x] Test existing SIGINT handling (fix exit code to 130) — `core/files/main_test.go.jinja`
- [x] Test existing environment variable naming — `core/files/config_test.go.jinja`
- [x] Test existing cross-platform path handling — `core/files/main_test.go.jinja`
- [x] Test existing subcommand organization — `core/files/main_test.go.jinja`
- [x] Test existing help output — `core/files/main_test.go.jinja`
- [x] Test existing version output — `core/files/main_test.go.jinja`
- [x] Test existing usage output — `core/files/main_test.go.jinja`
- [x] Run test coverage analysis for existing code — `Makefile.jinja`
- [x] Ensure existing features have adequate coverage — All test files

## Relevant Files

- `apps/cli/go/core/files/main_test.go.jinja` — Main tests
- `apps/cli/go/core/files/logger_test.go.jinja` — Logger tests
- `apps/cli/go/core/files/config_test.go.jinja` — Config tests
- `apps/cli/go/core/files/Makefile.jinja` — Add coverage target

## Acceptance Criteria

- [x] All existing features have tests
- [x] SIGINT exit code is fixed to 130
- [x] Test coverage is adequate for existing code
- [x] All existing tests still pass
- [x] Backward compatibility maintained

## Test Plan

- Unit: Run all existing tests with `go test ./...`
- Coverage: Run coverage analysis for existing code
- Regression: Ensure no existing functionality broken
- Lint: `go vet ./...`

## Observability

- Test coverage reported for existing code
- Regression test results logged

## Compliance

- Ensure tests don't break existing behavior
- Maintain backward compatibility

## Risks & Mitigations

- Risk: Tests may expose existing bugs — Mitigation: Fix bugs found during testing
- Risk: SIGINT exit code change may break scripts — Mitigation: Document change clearly

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 04-003 (Integration Testing)

## Definition of Done

- All existing features tested
- SIGINT exit code fixed
- All tests pass
- Coverage adequate

## Commit Conventions

- `test(existing): add tests for existing features`
- `fix(main): fix SIGINT exit code to 130`
- `test(existing): ensure backward compatibility`
