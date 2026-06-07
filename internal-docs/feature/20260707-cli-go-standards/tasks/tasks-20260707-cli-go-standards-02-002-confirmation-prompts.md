---
story_id: "02-002"
story_title: "Confirmation Prompts"
story_name: "confirmation-prompts"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260707-cli-go-standards/story-02-002-confirmation-prompts"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["main", "prompt"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "prompt"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Require confirmation for destructive operations (delete, overwrite) with a `--force` flag to bypass prompts. Implement consistent prompt format across all operations that modify user data.

## Sub-Tasks

- [ ] Add --force flag to root command — `core/files/main.go.jinja`
- [ ] Create prompt utility functions — `core/files/prompt.go.jinja`
- [ ] Implement confirmation prompt for delete operations — `core/files/main.go.jinja`
- [ ] Implement confirmation prompt for overwrite operations — `core/files/main.go.jinja`
- [ ] Add --force bypass logic — `core/files/main.go.jinja`
- [ ] Test confirmation prompts work — `core/files/prompt_test.go.jinja`
- [ ] Test --force bypasses prompts — `core/files/prompt_test.go.jinja`
- [ ] Test prompts respect --quiet flag — `core/files/prompt_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add prompts and force flag
- `apps/cli/go/core/files/prompt.go.jinja` — New file for prompt logic
- `apps/cli/go/core/files/prompt_test.go.jinja` — New file for prompt tests

## Acceptance Criteria

- [ ] Destructive operations require confirmation
- [ ] `--force` flag bypasses confirmation prompts
- [ ] Prompt format is consistent across operations
- [ ] Prompts respect --quiet flag
- [ ] Prompts show what will be affected
- [ ] Default answer is safe (usually "no")

## Test Plan

- Unit: Test prompt functions
- Integration: Test confirmation in actual operations
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log when confirmation is requested
- Log when --force is used
- Log user's response to prompts

## Compliance

- Ensure prompts are clear about what will happen
- Provide safe default responses

## Risks & Mitigations

- Risk: Prompts may be annoying in scripts — Mitigation: Provide --force flag
- Risk: Users may not read prompts — Mitigation: Make prompts clear and concise

## Dependencies & Sequencing

- Depends on: 01-001 (Config File Initialization)
- Unblocks: None

## Definition of Done

- Confirmation prompts work for all destructive operations
- --force flag bypasses prompts
- All tests pass

## Commit Conventions

- `feat(prompt): add confirmation prompts for destructive operations`
- `feat(prompt): add --force flag to bypass prompts`
- `test(prompt): add tests for confirmation prompts`
