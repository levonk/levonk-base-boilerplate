---
story_id: "01-001"
story_title: "Mode Selection and Auto-detection"
story_name: "mode-selection"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 1
parallel_id: 1
branch: "feature/current/20260708-cli-rust-aix/story-01-001-mode-selection"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["cli-core", "config"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "core", "axi"]
due: "2026-06-15"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement agent mode as the default behavior with auto-detection based on environment (TTY presence, agent session detection) and human mode available via explicit flags (`--human`, `--interactive`). This establishes the foundation for all other AXI features by ensuring the CLI operates in the correct mode automatically.

## Sub-Tasks

- [ ] Add mode configuration to config struct with `mode` field supporting "agent" and "human" values
- [ ] Implement environment variable detection for `MYTOOL_MODE` with highest precedence after CLI args
- [ ] Add `--human` flag to CLI argument parser to force human mode
- [ ] Add `--interactive` flag to CLI argument parser to force human mode (alias for --human)
- [ ] Implement TTY detection using `atty` or `is-terminal` crate
- [ ] Implement agent session detection by checking for `CLAUDE_SESSION`, `CODEX_SESSION` environment variables
- [ ] Implement process parent detection to identify agent-specific process parents
- [ ] Create mode detection logic with precedence chain: CLI flags > env vars > config file > auto-detection
- [ ] Update config file loading to support mode setting
- [ ] Add mode context to CLI execution context for use by other features
- [ ] Write unit tests for mode detection logic
- [ ] Write integration tests for mode precedence chain
- [ ] Write tests for TTY detection scenarios
- [ ] Write tests for agent session detection scenarios
- [ ] Update CLI help text to document mode selection

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/config.rs` — Configuration struct and loading logic
- `boilerplate/apps/cli/rust/core/src/config/tests.rs` — Tests for configuration
- `boilerplate/apps/cli/rust/core/src/cli/root.rs` — Root CLI command and flag definitions
- `boilerplate/apps/cli/rust/core/src/cli/tests.rs` — Tests for root command
- `boilerplate/apps/cli/rust/core/src/internal/mode/detection.rs` — Mode detection logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/mode/tests.rs` — Tests for mode detection (new file)
- `boilerplate/apps/cli/rust/core/src/internal/context.rs` — CLI execution context (new file)
- `boilerplate/apps/cli/rust/core/Cargo.toml` — Add dependencies (atty, is-terminal)

## Acceptance Criteria

- [ ] Agent mode is the default behavior when no explicit mode selection is provided
- [ ] Auto-detection correctly identifies agent vs human mode based on TTY and session detection
- [ ] `--human` flag successfully forces human mode
- [ ] `--interactive` flag successfully forces human mode
- [ ] `MYTOOL_MODE` environment variable overrides auto-detection
- [ ] Config file mode setting is respected when no CLI flags or env vars are set
- [ ] Mode precedence chain works correctly in all scenarios
- [ ] All mode detection scenarios have test coverage
- [ ] Help text documents mode selection options

## Test Plan

- Unit: `cargo test --lib internal::mode`
- Unit: `cargo test --lib config`
- Integration: `cargo test --lib cli`
- Manual: Test mode detection with various TTY/non-TTY scenarios
- Manual: Test agent session detection with environment variables

## Observability

- Add logging for mode detection decisions at debug level
- Add metrics for mode selection (agent vs human mode usage)

## Compliance

- Ensure no sensitive information is logged during mode detection
- Respect user privacy when detecting process parent information

## Risks & Mitigations

- Risk: TTY detection may fail in certain container environments — Mitigation: Add fallback to environment variable detection
- Risk: Agent session detection may not cover all agent platforms — Mitigation: Document extensibility for adding new platforms

## Dependencies

- Requires: Rust 1.70+ for modern crate ecosystem
- Requires: Core CLI standards implementation (20260707-cli-rust-standards) to be complete

## Notes

- Mode detection must be fast (<5ms) to avoid impacting CLI startup time
- Consider caching mode detection result for the duration of CLI execution
- Document all supported agent session environment variables
