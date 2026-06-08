---
story_id: "01-005"
story_title: "Shell Completion"
story_name: "shell-completion"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 5
branch: "feature/current/20260707-cli-go-standards/story-01-005-shell-completion"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "completion"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "completion"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Generate shell completion scripts for bash, zsh, and fish using cobra's built-in completion generation capabilities. Ensure completions are auto-generated based on command structure and included in the install flag output.

## Sub-Tasks

- [x] Add completion command to cobra root — `core/files/main.go.jinja`
- [x] Implement bash completion generation — `core/files/completion.go.jinja`
- [x] Implement zsh completion generation — `core/files/completion.go.jinja`
- [x] Implement fish completion generation — `core/files/completion.go.jinja`
- [x] Add completion installation instructions — `core/files/completion.go.jinja`
- [x] Test bash completion works — `core/files/completion_test.go.jinja`
- [x] Test zsh completion works — `core/files/completion_test.go.jinja`
- [x] Test fish completion works — `core/files/completion_test.go.jinja`
- [x] Test completions update with command changes — `core/files/completion_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add completion command
- `apps/cli/go/core/files/completion.go.jinja` — New file for completion logic
- `apps/cli/go/core/files/completion_test.go.jinja` — New file for completion tests

## Acceptance Criteria

- [x] Shell completion scripts generated for bash, zsh, and fish
- [x] Completions are auto-generated from cobra command structure
- [x] Completion command provides installation instructions
- [x] Completions work for all subcommands and flags
- [x] Completions update when command structure changes

## Test Plan

- Unit: Test completion generation functions
- Integration: Test actual completion in each shell
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when completion command is run
- Log completion file generation

## Compliance

- Completions should not expose sensitive information
- Completions should be safe to use in all environments

## Risks & Mitigations

- Risk: Completions may not work on all shell versions — Mitigation: Test on multiple versions
- Risk: Completions may become outdated — Mitigation: Auto-generate from command structure

## Dependencies & Sequencing

- Depends on: None
- Unblocks: 01-002 (Install/Uninstall Flag)

## Definition of Done

- All three shell completions work correctly
- Installation instructions are clear
- All tests pass

## Commit Conventions

- `feat(completion): add shell completion for bash, zsh, fish`
- `test(completion): add tests for shell completion`
