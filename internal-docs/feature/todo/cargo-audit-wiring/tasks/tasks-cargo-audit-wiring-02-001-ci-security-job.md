---
story_id: "02-001"
story_title: "Add cargo audit security job to CLI rust CI workflow"
story_name: "ci-security-job"
prd_name: "cargo-audit-wiring"
phase: 2
parallel_id: 1
branch: "feature/current/cargo-audit-wiring/story-02-001-ci-security-job"
status: "todo"
dependencies: ["01-003"]
parallel_safe: true
modules: ["cli-rust", "ci"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "rust", "security", "ci"]
---

## Summary

Add a `security` job to the CLI Rust CI workflow that installs `cargo-audit`
and runs `cargo audit` on every push and PR.

## Sub-Tasks

- [ ] Add a `security` job to `apps/cli/rust/core/files/.github/workflows/ci.yml.jinja`
- [ ] The job installs `cargo-audit` via `cargo install cargo-audit`
- [ ] The job runs `cargo audit`
- [ ] The job runs on `ubuntu-latest` only (no need for matrix)

## Relevant Files

- `apps/cli/rust/core/files/.github/workflows/ci.yml.jinja` — the CLI Rust CI workflow

## Acceptance Criteria

- Given the CLI Rust CI workflow, When a push or PR triggers CI, Then a `security` job runs
- The security job installs cargo-audit and runs `cargo audit`
- The security job fails if cargo audit finds vulnerabilities
