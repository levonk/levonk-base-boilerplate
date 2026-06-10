---
story_id: "03-003"
story_title: "No Interactive Prompts in Agent Mode"
story_name: "no-prompts"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 3
parallel_id: 3
branch: "feature/current/20260708-cli-rust-aix/story-03-003-no-prompts"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["cli-commands", "user-interaction"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli-commands", "axi"]
due: "2026-06-17"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement suppression of interactive prompts in agent mode. Every operation must be completable with flags alone. If a required value is missing, fail immediately with a clear error. Suppress prompts from wrapped tools. Human mode retains prompts (unless `--force` is used).

## Sub-Tasks

- [x] Identify all interactive prompts in CLI commands
- [x] Identify all wrapped tool invocations that may prompt
- [x] Implement prompt suppression based on mode detection
- [x] Add flag-based alternatives for all prompted operations
- [x] Implement immediate failure with clear error for missing required values
- [x] Add `--force` flag to bypass prompts in human mode
- [x] Suppress prompts from wrapped tools in agent mode
- [x] Update all commands with interactive prompts to support flag-based completion
- [x] Ensure prompts work normally in human mode
- [x] Ensure prompts are suppressed in agent mode
- [x] Write unit tests for prompt suppression logic
- [x] Write integration tests for flag-based completion
- [x] Write tests for prompt behavior in different modes
- [x] Update CLI help text to document prompt behavior

## Relevant Files

- `boilerplate/apps/cli/rust/core/files/src/internal/prompts/mod.rs.jinja` — Prompt suppression module (new file)
- `boilerplate/apps/cli/rust/core/files/src/internal/prompts/suppressor.rs.jinja` — Prompt suppression logic (new file)
- `boilerplate/apps/cli/rust/core/files/src/internal/prompts/tests.rs.jinja` — Tests for prompt suppression (new file)
- `boilerplate/apps/cli/rust/core/files/src/internal/mod.rs.jinja` — Added prompts module export
- `boilerplate/apps/cli/rust/core/files/src/main.rs.jinja` — Updated to use PromptSuppressor
- `boilerplate/apps/cli/rust/core/files/src/cli.rs.jinja` — Already has `--force` flag

## Acceptance Criteria

- [x] All interactive prompts are identified
- [x] Prompt suppression works correctly in agent mode
- [x] Prompt suppression works correctly in human mode
- [x] Flag-based alternatives exist for all prompted operations
- [x] Missing required values fail immediately with clear error
- [x] `--force` flag successfully bypasses prompts in human mode
- [x] Prompts from wrapped tools are suppressed in agent mode
- [x] Prompts work normally in human mode
- [x] All prompt functionality has test coverage
- [x] Help text documents prompt behavior

## Test Plan

- Unit: `cargo test --lib internal::prompts`
- Integration: Test prompt behavior in agent mode
- Integration: Test prompt behavior in human mode
- Manual: Verify flag-based completion for prompted operations

## Observability

- Add logging for prompt suppression decisions at debug level
- Add metrics for prompt frequency and suppression

## Compliance

- Ensure prompt suppression doesn't bypass security controls
- Validate that error messages for missing values don't leak sensitive information

## Risks & Mitigations

- Risk: Prompt suppression may make CLI less user-friendly for humans — Mitigation: Clear documentation, `--force` flag available
- Risk: Flag-based alternatives may be complex — Mitigation: Provide clear examples in help text

## Dependencies

- Requires: Mode selection (01-001) for mode detection
- No other dependencies (can be developed in parallel with 03-001, 03-002)

## Notes

- Prompt suppression should be consistent across all commands
- Document which commands require flags in agent mode
- Consider adding prompt suppression to CI/CD validation tests
