---
story_id: "03-001"
story_title: "Shell Completion Scripts"
story_name: "shell-completion"
prd_name: "20260707-cli-rust-standards"
prd_file: "internal-docs/feature/20260707-cli-rust-standards/20260707-cli-rust-standards.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260707-cli-rust-standards/story-03-001-shell-completion"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["completion.rs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "completion"]
due: "2026-08-04"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement shell completion scripts for bash, zsh, and fish using clap's auto-generation, with maintenance to match current command structure.

## Sub-Tasks

- [ ] Add clap_complete or clap_generate dependency to Cargo.toml
- [ ] Create completion.rs module
- [ ] Implement bash completion generation
- [ ] Implement zsh completion generation
- [ ] Implement fish completion generation
- [ ] Add --generate-completion flag to CLI
- [ ] Integrate completion generation with --install flag
- [ ] Add completion script installation to user shell config
- [ ] Create tests for bash completion
- [ ] Create tests for zsh completion
- [ ] Create tests for fish completion
- [ ] Add completion update mechanism for command structure changes

## Relevant Files

- `apps/cli/rust/src/completion.rs` — Shell completion module
- `apps/cli/rust/src/cli.rs` — Add --generate-completion flag
- `apps/cli/rust/Cargo.toml` — Completion dependencies
- `apps/cli/rust/tests/completion_test.rs` — Completion tests
- Template completion scripts: `apps/cli/rust/completions/`

## Acceptance Criteria

- [ ] Bash completion scripts generated correctly
- [ ] Zsh completion scripts generated correctly
- [ ] Fish completion scripts generated correctly
- [ ] --generate-completion flag works for all shells
- [ ] Completions installed via --install flag
- [ ] Completions match current command structure
- [ ] All tests pass

## Test Plan

- Unit: `cargo test completion`
- Integration: Test completion generation, installation, actual shell completion
- Lint: `cargo clippy`
- Types: `cargo check`

## Observability

- Logging: Log completion generation, installation events
- Metrics: Track completion usage, generation frequency

## Compliance

- No regulatory constraints
- Ensure completion scripts don't expose sensitive data

## Risks & Mitigations

- Risk: Completion scripts out of sync with command structure — Mitigation: Auto-generation on build, CI validation
- Risk: Completion installation fails due to shell config issues — Mitigation: Clear error messages, manual fallback instructions

## Dependencies & Sequencing

- Depends on: 01-001 (standard arguments)
- Unblocks: None (integration feature)

## Definition of Done

- Shell completion scripts implemented
- All three shells supported (bash, zsh, fish)
- Auto-generation working
- Installation via --install flag
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(completion): implement shell completion scripts for bash, zsh, fish`
- `feat(completion): add --generate-completion flag`
- `test(completion): add completion generation tests`
