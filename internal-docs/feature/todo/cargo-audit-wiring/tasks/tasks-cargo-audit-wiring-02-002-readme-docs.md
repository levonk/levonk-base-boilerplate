---
story_id: "02-002"
story_title: "Update README docs to reflect audit in validation"
story_name: "readme-docs"
prd_name: "cargo-audit-wiring"
phase: 2
parallel_id: 2
branch: "feature/current/cargo-audit-wiring/story-02-002-readme-docs"
status: "todo"
dependencies: ["01-002", "01-003"]
parallel_safe: true
modules: ["docs"]
priority: "SHOULD"
risk_level: "low"
tags: ["docs", "rust", "security"]
---

## Summary

Update the README templates for both Rust templates to document that `cargo audit`
is now part of the validation pipeline and that `just outdated` is available.

## Sub-Tasks

- [ ] Update `packages/category/general/domain/package-name/rust/core/files/README.md.jinja` to mention audit is part of validate
- [ ] Update `apps/cli/rust/core/files/README.md.jinja` Development section to list `just audit` and `just outdated`

## Relevant Files

- `packages/category/general/domain/package-name/rust/core/files/README.md.jinja`
- `apps/cli/rust/core/files/README.md.jinja`

## Acceptance Criteria

- The package Rust README mentions that `just validate` includes cargo audit
- The CLI Rust README lists `just audit` and `just outdated` in the development commands
