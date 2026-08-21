---
story_id: "01-002"
story_title: "Wire cargo audit into package rust justfile validate + add outdated"
story_name: "package-justfile"
prd_name: "cargo-audit-wiring"
phase: 1
parallel_id: 2
branch: "feature/current/cargo-audit-wiring/story-01-002-package-justfile"
status: "todo"
dependencies: []
parallel_safe: true
modules: ["package-rust", "justfile"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "rust", "security", "justfile"]
---

## Summary

Wire `cargo audit` into the `validate` target of the package Rust template's
justfile, and add a new `outdated` target that shows available dependency updates.

## Sub-Tasks

- [ ] Add `just audit_impl` call to the `validate` target in `packages/category/general/domain/package-name/rust/core/files/justfile`
- [ ] Add a new `outdated` target that runs `cargo update --dry-run`
- [ ] Ensure audit is non-fatal if cargo-audit is not installed (existing pattern: check command -v)

## Relevant Files

- `packages/category/general/domain/package-name/rust/core/files/justfile` — the package Rust justfile (not a jinja template)

## Acceptance Criteria

- Given the package Rust justfile, When `just validate` is run, Then `cargo audit` is executed as part of validation
- Given the package Rust justfile, When `just outdated` is run, Then `cargo update --dry-run` shows available dependency updates
- If cargo-audit is not installed, `just validate` warns but does not fail
