---
story_id: "01-003"
story_title: "Proper Color Control"
story_name: "proper-color-control"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 3
branch: "feature/current/20260707-cli-go-standards/story-01-003-proper-color-control"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["logger", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "logging"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Replace `--no-color` flag with `--color=auto|always|never` flag following the ADR specification. Implement smart TTY detection in auto mode, add color setting to config file, and honor NO_COLOR environment variable with proper precedence.

## Sub-Tasks

- [ ] Add fatih/color or aurora dependency to go.mod — `core/files/go.mod.jinja`
- [ ] Replace --no-color flag with --color=auto|always|never — `core/files/main.go.jinja`
- [ ] Add color mode enum and constants — `core/files/logger.go.jinja`
- [ ] Implement smart TTY detection using mattn/go-isatty — `core/files/logger.go.jinja`
- [ ] Add NO_COLOR environment variable support — `core/files/logger.go.jinja`
- [ ] Implement color mode precedence logic — `core/files/logger.go.jinja`
- [ ] Add color setting to config file template — `core/files/config.default.yaml.jinja`
- [ ] Update logger to use new color mode system with fatih/color or aurora — `core/files/logger.go.jinja`
- [ ] Test --color=auto with TTY detection — `core/files/logger_test.go.jinja`
- [ ] Test --color=always forces color — `core/files/logger_test.go.jinja`
- [ ] Test --color=never disables color — `core/files/logger_test.go.jinja`
- [ ] Test NO_COLOR env var precedence — `core/files/logger_test.go.jinja`
- [ ] Test config file color setting — `core/files/logger_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update color flag
- `apps/cli/go/core/files/logger.go.jinja` — Implement color mode logic using fatih/color or aurora
- `apps/cli/go/core/files/config.default.yaml.jinja` — Add color setting
- `apps/cli/go/core/files/go.mod.jinja` — Add fatih/color or aurora dependency
- `apps/cli/go/core/files/logger_test.go.jinja` — New file for logger tests

## Acceptance Criteria

- [ ] `--color=auto` enables color when TTY detected, disables otherwise
- [ ] `--color=always` forces color output regardless of TTY
- [ ] `--color=never` disables all color output
- [ ] NO_COLOR environment variable takes precedence over all other settings
- [ ] Config file color setting is respected
- [ ] Precedence: NO_COLOR > --color flag > config > auto-detection
- [ ] Backward compatibility maintained for existing --no-color usage

## Test Plan

- Unit: Test color mode logic and precedence
- Integration: Test color output in different terminal contexts
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log color mode on startup
- Log when NO_COLOR is detected

## Compliance

- Respect user's NO_COLOR preference
- Provide clear color control documentation

## Risks & Mitigations

- Risk: Breaking existing --no-color usage — Mitigation: Support --no-color as alias for --color=never
- Risk: TTY detection may fail in some environments — Mitigation: Provide manual override

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 02-003 (Progress Indicators), 02-004 (Error Message Formatting)

## Definition of Done

- Color control follows ADR specification exactly
- All color modes work correctly
- NO_COLOR precedence is correct
- All tests pass

## Commit Conventions

- `feat(logger): replace --no-color with --color=auto|always|never`
- `feat(logger): add NO_COLOR environment variable support`
- `test(logger): add tests for color mode precedence`
