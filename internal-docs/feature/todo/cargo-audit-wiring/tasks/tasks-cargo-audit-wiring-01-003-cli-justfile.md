---
story_id: "01-003"
story_title: "Wire cargo audit into CLI rust justfile quality/release + add outdated + audit target"
story_name: "cli-justfile"
prd_name: "cargo-audit-wiring"
phase: 1
parallel_id: 3
branch: "feature/current/cargo-audit-wiring/story-01-003-cli-justfile"
status: "todo"
dependencies: []
parallel_safe: true
modules: ["cli-rust", "justfile"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "rust", "security", "justfile"]
---

## Summary

Wire `cargo audit` into the `quality` and `release` targets of the CLI Rust
template's justfile, add a public `audit` target, and add an `outdated` target.

## Sub-Tasks

- [ ] Add `audit` public target (wrapping `audit_impl` via `_devbox`) in `apps/cli/rust/core/files/justfile.jinja`
- [ ] Add `just audit_impl` call to `quality_impl`
- [ ] Add `just audit_impl` call to `release_impl`
- [ ] Add `outdated` public target + `outdated_impl` that runs `cargo update --dry-run`
- [ ] Update the `help` target to list `just audit` and `just outdated`

## Relevant Files

- `apps/cli/rust/core/files/justfile.jinja` — the CLI Rust justfile template

## Acceptance Criteria

- Given the CLI Rust justfile, When `just quality` is run, Then `cargo audit` is executed
- Given the CLI Rust justfile, When `just release` is run, Then `cargo audit` is executed
- Given the CLI Rust justfile, When `just audit` is run, Then `cargo audit` is executed
- Given the CLI Rust justfile, When `just outdated` is run, Then `cargo update --dry-run` shows available updates
- The `help` target lists `just audit` and `just outdated`
