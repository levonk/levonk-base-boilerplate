---
type: Practice
title: Dependency Supply Chain — Lockfile Pinning, Integrity Verification, and Provenance
description: Pin dependencies with Cargo.lock for binaries, verify integrity with cargo-deny and cargo-audit, configure private registries with authentication, verify SLSA provenance, and review dependencies in CI at PR time.
tags: [security, devsecops, rust, cargo, supply-chain, cargo-deny, cargo-audit, slsa, dependencies]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Dependency Supply Chain

## Failure Mode

Unpinned or unverified dependencies let an attacker inject malicious code
through the build. A compromised upstream crate, a typosquatted package, or
a stolen registry token can ship backdoored code to production without a
code change in the consuming repository. Lockfile drift hides the exact
version that shipped.

## Practice

### Lockfile Pinning

Commit `Cargo.lock` for binaries and applications. Do not commit it for
libraries — the consumer's lockfile controls the build. A committed lockfile
makes the build reproducible and makes dependency changes visible in review.

```toml
# Cargo.toml — binary or application: commit Cargo.lock
[dependencies]
serde = { version = "1.0.209", features = ["derive"] }
toml = "0.8.19"
```

```bash
# Verify the lockfile is up to date in CI
cargo generate-lockfile --locked && git diff --exit-code Cargo.lock
```

### Integrity Verification

Run `cargo-audit` 0.22.1 for RustSec advisories and `cargo-deny` for
advisories, license compliance, and banned crates. Both must run in CI and
fail the build on a critical advisory.

```toml
# deny.toml — cargo-deny configuration
[advisories]
db-urls = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-3-Clause"]
deny = ["GPL-3.0"]

[bans]
multiple-versions = "warn"
wildcards = "deny"
```

```bash
cargo audit       # RustSec advisory database
cargo deny check  # advisories + licenses + bans
```

### Private Registries

For internal crates, configure an alternative registry. Store the auth token
in the environment, never in a committed config file.

```toml
# ~/.cargo/config.toml
[registries.levonk]
index = "sparse+https://crates.levonk.example/index/"
```

```bash
read -s CARGO_REGISTRIES_LEVONK_TOKEN && export CARGO_REGISTRIES_LEVONK_TOKEN
cargo publish --registry levonk
```

### SLSA Provenance

Verify the build provenance of dependencies when the registry provides it.
SLSA provenance attests that a crate was built from a specific source commit
on a specific builder. Reject crates that lack provenance in high-trust
environments.

```bash
cargo verify-provenance --registry levonk crate-name@1.0.0
```

### Dependency Review in CI

Run `cargo-deny` on every PR that changes `Cargo.toml` or `Cargo.lock`. Block
the merge on a new vulnerability or a banned license, and surface the
dependency diff in the PR check output.

```yaml
# .github/workflows/dependency-review.yml
- { name: cargo-deny, run: cargo deny check }
- { name: cargo-audit, run: cargo audit }
- name: lockfile up-to-date
  run: cargo generate-lockfile --locked && git diff --exit-code Cargo.lock
```

## Related Concepts

- [Security Audit Playbook](security-audit-playbook.md) — final validation that dependency checks ran and passed before deployment.
- [tree-sitter-grammar-supply-chain](../secrets-egress-security/tree-sitter-grammar-supply-chain.md) — supply-chain controls specific to vendored tree-sitter grammars.
- [Security-Aware Static Analysis](security-aware-static-analysis.md) — auditing the analysis tool's own dependencies with these practices.
