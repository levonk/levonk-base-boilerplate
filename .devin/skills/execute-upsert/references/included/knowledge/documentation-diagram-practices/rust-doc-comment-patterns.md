---
type: Practice
title: Rust Doc Comment Patterns
description: Conventions for /// item-level and //! module-level doc comments, rustdoc-recognized sections (Examples, Errors, Panics), intra-doc links, doc tests, and documenting error variants in Rust 2021 edition.
tags: [documentation, rust, rustdoc, doc-comments, intra-doc-links, doc-tests, cargo]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Rust Doc Comment Patterns

## Failure Mode

Rust has two doc-comment markers (`///` and `//!`) that look almost identical
but attach to different scopes. Mixing them up silently misattributes
documentation — a crate-level overview lands on a stray struct, or a
function's contract never renders because it was written as module docs. The
failure is invisible until `cargo doc` runs and the output is missing
sections, links are broken, or doc tests fail on the wrong annotation.

## Practice

### `///` is item-level — `//!` is module-level

`///` documents the **item** immediately below it (struct, function, enum,
trait, `impl`, `const`). `//!` documents the **enclosing module** — the crate
root (`lib.rs` / `main.rs`) or a module file. The distinction is
compiler-enforced; getting it wrong produces a misplaced doc block. Never use
`//` where a doc comment is intended — plain comments are not rendered by
rustdoc.

```rust
//! Crate-level docs live at the top of lib.rs.
//! This crate validates lint configurations.

/// Validates a single lint rule. Returns `Ok(())` on pass,
/// or a [`LintError`] describing the first violation.
pub fn validate(rule: &Rule) -> Result<(), LintError> { /* ... */ # Ok(()) }
```

### Use the rustdoc-recognized section names

rustdoc recognizes a fixed set of headers and renders them with consistent
styling and anchor links. Use these **exact** names: **Examples** (a runnable
sample that becomes a doc test), **Errors** (when and why this returns
`Err`), and **Panics** (when and why this panics).

```rust
/// Parses a lint rule from a TOML fragment.
///
/// # Examples
///
/// ```
/// let rule = Rule::parse("severity = \"error\"")?;
/// # Ok::<(), Box<dyn std::error::Error>>(())
/// ```
///
/// # Errors
/// Returns [`LintError::InvalidToml`] on invalid TOML, or
/// [`LintError::MissingField`] if a required key is absent.
///
/// # Panics
/// Panics if `input` contains a NUL byte — a programmer error.
pub fn parse(input: &str) -> Result<Rule, LintError> { /* ... */ # Ok(Rule { severity: Severity::Error }) }
```

### Intra-doc links use `[`Type::method`]` syntax

Intra-doc links resolve to the actual item and produce broken-link warnings
(surfaced by `cargo doc`) when the target is missing — prefer them over
hand-written URLs (`/// See [`RuleSet::validate`] ...`). Disambiguate with
paths when names collide: `[`std::io::Read`]`, `[`crate::engine::Rule`]`.

### Doc tests: `cargo test` runs them — pick the right attribute

Code blocks inside doc comments are compiled and executed by `cargo test`.
Three annotations control execution: **no annotation** (compiled and run),
**`no_run`** (compiled but not executed — for examples needing external
state/network), and **`ignore`** (not compiled or run — platform-specific,
needs a GPU/TTY).

```rust
/// ```no_run
/// let daemon = Daemon::connect("127.0.0.1:8080")?; // needs a running server
/// ```
/// ```ignore
/// let _key = registry_key()?; // only compiles on Windows
/// ```
```

Use `#` to hide setup lines from rendered output while keeping the test compilable.

### Document every `#[error("...")]` variant in the enum's doc

When an enum derives `thiserror::Error`, document each **variant** so the
generated page lists every failure mode alongside its display string:

```rust
/// Errors returned by lint validation.
pub enum LintError {
    /// The input was not valid TOML.
    #[error("invalid TOML: {0}")]
    InvalidToml(String),
    /// A required field was missing from the rule definition.
    #[error("missing required field: {0}")]
    MissingField(&'static str),
}
```

## Related Concepts

- [cargo-doc-generation](cargo-doc-generation.md) — building, previewing, and CI-checking the docs these comments produce.
- [Mermaid Practices](mermaidjs.md) — embedding diagrams inside doc comments for architecture overviews.
