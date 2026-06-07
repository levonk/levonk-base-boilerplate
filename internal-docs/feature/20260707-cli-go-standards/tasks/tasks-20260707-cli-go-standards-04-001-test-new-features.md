---
story_id: "04-001"
story_title: "Test Coverage for New Features"
story_name: "test-new-features"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 4
parallel_id: 1
branch: "feature/current/20260707-cli-go-standards/story-04-001-test-new-features"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-007", "02-007", "03-006"]
parallel_safe: true
modules: ["all"]
priority: "MUST"
risk_level: "medium"
tags: ["test", "coverage"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement comprehensive test coverage for all new CLI features added in Phases 1-3. Ensure 90%+ test coverage for new code including unit tests, integration tests, and end-to-end tests for all 29 CLI standards.

## Sub-Tasks

- [ ] Test config file initialization — `core/files/config_test.go.jinja`
- [ ] Test install/uninstall flag — `core/files/install_test.go.jinja`
- [ ] Test color control (auto/always/never) — `core/files/logger_test.go.jinja`
- [ ] Test NO_COLOR env var precedence — `core/files/logger_test.go.jinja`
- [ ] Test debug flag behavior — `core/files/logger_test.go.jinja`
- [ ] Test shell completion generation — `core/files/completion_test.go.jinja`
- [ ] Test config precedence chain — `core/files/config_test.go.jinja`
- [ ] Test config validation — `core/files/config_test.go.jinja`
- [ ] Test dry-run mode — `core/files/dryrun_test.go.jinja`
- [ ] Test confirmation prompts — `core/files/prompt_test.go.jinja`
- [ ] Test progress indicators — `core/files/progress_test.go.jinja`
- [ ] Test error message formatting — `core/files/errors_test.go.jinja`
- [ ] Test man page generation — `core/files/docs_test.go.jinja`
- [ ] Test pager integration — `core/files/pager_test.go.jinja`
- [ ] Test terminal size awareness — `core/files/terminal_test.go.jinja`
- [ ] Test TUI mode — `core/files/tui_test.go.jinja`
- [ ] Test daemon process support — `core/files/daemon_test.go.jinja`
- [ ] Test file reference formatting — `core/files/refs_test.go.jinja`
- [ ] Test URL formatting — `core/files/urls_test.go.jinja`
- [ ] Test credential/secret handling — `core/files/secrets_test.go.jinja`
- [ ] Test config auto-migration — `core/files/migration_test.go.jinja`
- [ ] Run test coverage analysis — `Makefile.jinja`
- [ ] Ensure 90%+ coverage for new code — All test files

## Relevant Files

- `apps/cli/go/core/files/config_test.go.jinja` — Config tests
- `apps/cli/go/core/files/install_test.go.jinja` — Install tests
- `apps/cli/go/core/files/logger_test.go.jinja` — Logger tests
- `apps/cli/go/core/files/completion_test.go.jinja` — Completion tests
- `apps/cli/go/core/files/dryrun_test.go.jinja` — Dry-run tests
- `apps/cli/go/core/files/prompt_test.go.jinja` — Prompt tests
- `apps/cli/go/core/files/progress_test.go.jinja` — Progress tests
- `apps/cli/go/core/files/errors_test.go.jinja` — Error tests
- `apps/cli/go/core/files/docs_test.go.jinja` — Docs tests
- `apps/cli/go/core/files/pager_test.go.jinja` — Pager tests
- `apps/cli/go/core/files/terminal_test.go.jinja` — Terminal tests
- `apps/cli/go/core/files/tui_test.go.jinja` — TUI tests
- `apps/cli/go/core/files/daemon_test.go.jinja` — Daemon tests
- `apps/cli/go/core/files/refs_test.go.jinja` — Refs tests
- `apps/cli/go/core/files/urls_test.go.jinja` — URLs tests
- `apps/cli/go/core/files/secrets_test.go.jinja` — Secrets tests
- `apps/cli/go/core/files/migration_test.go.jinja` — Migration tests
- `apps/cli/go/core/files/Makefile.jinja` — Add coverage target

## Acceptance Criteria

- [ ] All new features have unit tests
- [ ] All new features have integration tests
- [ ] Test coverage is 90%+ for new code
- [ ] All tests pass consistently
- [ ] Tests are maintainable and clear

## Test Plan

- Unit: Run all unit tests with `go test ./...`
- Coverage: Run coverage analysis with `go test -cover ./...`
- Integration: Run integration tests
- Lint: `go vet ./...`

## Observability

- Test coverage reported in CI
- Test results logged

## Compliance

- Ensure tests don't expose sensitive data
- Ensure tests are deterministic

## Risks & Mitigations

- Risk: Test coverage may be difficult to achieve — Mitigation: Focus on critical paths
- Risk: Tests may be flaky — Mitigation: Make tests deterministic

## Dependencies & Sequencing

- Depends on: 01-007 (Configuration Validation), 02-007 (Terminal Size Awareness), 03-006 (Config Auto-Migration)
- Unblocks: 04-003 (Integration Testing)

## Definition of Done

- All new features tested
- 90%+ coverage achieved
- All tests pass
- Coverage target added to Makefile

## Commit Conventions

- `test(all): add comprehensive tests for new features`
- `test(all): ensure 90%+ test coverage`
