---
story_id: "01-001"
story_title: "Add audit target to nx-target-rust partial"
story_name: "nx-audit-target"
prd_name: "cargo-audit-wiring"
phase: 1
parallel_id: 1
branch: "feature/current/cargo-audit-wiring/story-01-001-nx-audit-target"
status: "todo"
dependencies: []
parallel_safe: true
modules: ["nx-partials"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "nx", "rust", "security"]
---

## Summary

Add an `audit` Nx target to the shared `nx-target-rust.jinja` partial so all
Rust templates that use Nx get a cargo audit target.

## Sub-Tasks

- [ ] Add `audit` target to `_shared/partials/nx-partials/nx-target-rust.jinja`
- [ ] Ensure the target uses `nx:run-commands` with `cargo audit`
- [ ] Set `cache: false` (audit results change as new advisories are published)

## Relevant Files

- `_shared/partials/nx-partials/nx-target-rust.jinja` — the shared Nx target partial for Rust

## Acceptance Criteria

- Given the nx-target-rust partial, When included in a project.json.jinja, Then an `audit` target is present
- The audit target runs `cargo audit` via `nx:run-commands`
- The audit target has `cache: false`
