---
type: Practice
title: Security and Auditing
description: Regular cargo audit for dependency vulnerabilities, secrecy crate for secret handling, zeroize for secure memory clearing, input validation, and safe FFI practices.
tags: [rust, security, cargo-audit, secrecy, zeroize, ffi, input-validation]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: levonk-base-boilerplate
    resource: "internal-docs/adr/adr-20260128001-rust-package-boilerplate-requirements.md"
    title: "levonk-base-boilerplate"
---

# Security and Auditing

## Failure Mode

Vulnerable dependencies ship to production without detection. Secrets leak
through logging. Unsafe FFI causes undefined behavior. Missing input validation
allows injection attacks.

## Practice

### Security Checklist

- **Input validation**: Validate all external inputs
- **Memory safety**: Leverage Rust's memory safety guarantees
- **Dependency auditing**: Regular security audits with `cargo audit`
- **Safe FFI**: Proper error handling for foreign function interfaces
- **Secrets management**: Never commit secrets, use environment variables

### Security Dependencies

```toml
[dependencies]
secrecy = "0.8"   # For secret handling
zeroize = "1.7"   # For secure memory clearing
```

### CI/CD Security

```bash
cargo audit    # Check for known vulnerabilities
cargo outdated # Check for outdated dependencies
```

## Related Concepts

- [Cargo Configuration](cargo-configuration.md) — Dependency management
- [Quality Gates](quality-gates.md) — CI runs cargo audit
- [Container Support](container-support.md) — Non-root container
