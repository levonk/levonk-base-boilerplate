---
type: Practice
title: Rust CI Tooling
description: cargo-deny, cargo-audit, cargo-nextest, cargo-release, and cross form the CI backbone for Rust projects. License, advisory, and ban checks gate every PR; parallel test execution with JUnit output feeds CI dashboards.
tags: [ci-cd, testing, rust, cargo-deny, cargo-audit, cargo-nextest, cargo-release, cross]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Rust CI Tooling

## Failure Mode

Rust projects inherit no license, advisory, or ban checks by default. A
transitive dependency pulls in a restricted license or a known CVE and ships
to production unnoticed. `cargo test` runs serially, starves CI cores, and
emits no machine-readable result for dashboards. Publishing relies on manual
`cargo publish` steps that drift across maintainers.

## Practice

Wire five cargo subcommands into every Rust CI pipeline. Run them in the
same script locally and in CI so behavior stays identical.

### cargo-deny — License, Advisory, and Ban Checks

Add a `deny.toml` at the repo root. Fail the build on any vulnerability or
denied license.

```toml
# deny.toml
[advisories]
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"
[licenses]
allow = ["MIT", "Apache-2.0", "BSD-3-Clause", "ISC", "Unicode-DFS-2016"]
deny = ["GPL-2.0", "GPL-3.0", "AGPL-3.0"]
[bans]
multiple-versions = "warn"
wildcards = "deny"
```

### cargo-audit — RustSec Advisory Scan

`cargo-audit 0.22.1` gives a focused, fast advisory pass alongside
cargo-deny's license and ban policy. `--deny warnings` turns unmaintained
and yanked crates into hard failures.

```bash
cargo install cargo-audit --locked --version 0.22.1
cargo audit --deny warnings
```

### cargo-nextest — Parallel Test Execution

`cargo-nextest` runs tests in parallel processes, reuses builds, and emits
JUnit XML for CI dashboards. Prefer it over `cargo test` in every CI job.

```bash
cargo nextest run --workspace --profile ci \
  --junitfile target/nextest-junit.xml
```

Set `retries = 2` and `fail-fast = false` in `.config/nextest.toml` under
`[profile.ci]` to absorb flaky tests without hiding real failures.

### cargo-release — Publishing with Trusted Publishing

`cargo-release` automates version bump, tag, and publish. Pair it with
trusted publishing on crates.io so no long-lived API token sits in CI
secrets: `cargo release patch --execute --no-confirm`.

### cross — Cross-Compilation Matrix

`cross` runs tests and builds under Docker for target triples CI cannot run
natively. Fill a matrix without self-hosted runners:

```bash
cross test --target aarch64-unknown-linux-gnu
cross build --target x86_64-pc-windows-gnu
```

### GitHub Actions Workflow

```yaml
# .github/workflows/rust-ci.yml
name: rust-ci
on: [pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: taiki-e/install-action@v2
        with:
          tool: cargo-deny,cargo-audit,cargo-nextest
      - run: cargo deny check
      - run: cargo audit --deny warnings
      - run: cargo nextest run --workspace --profile ci
          --junitfile target/nextest-junit.xml
      - uses: dorny/test-reporter@v1
        if: always()
        with:
          path: target/nextest-junit.xml
          reporter: java-junit
```

## Related Concepts

- [Pre-Commit CI Parity](pre-commit-ci-parity.md) — Run these same checks locally via the shared quality script
- [Shared Quality Scripts](shared-quality-scripts.md) — Single entry point for both hook and CI
