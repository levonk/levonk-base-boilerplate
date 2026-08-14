---
type: Practice
title: cargo doc Generation
description: Generating and CI-checking Rust documentation with cargo doc — --no-deps, --open, --document-private-items as a lint, intra-doc links across crates, feature-gated docs, and hosted output on docs.rs.
tags: [documentation, rust, cargo, rustdoc, ci, docs-rs, feature-flags]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"

sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# cargo doc Generation

## Failure Mode

`cargo doc` builds documentation for the current crate **and every
dependency** by default, producing a huge `target/doc/` tree and masking
broken intra-doc links in your own code behind thousands of upstream pages.
Teams that run only `cargo doc` in CI miss broken links because dependency
docs swallow the warnings, and published crates ship to docs.rs with
unresolved `[`Type`]` references that render as plain text — surfacing only
when a reader clicks a link and lands nowhere.

## Practice

### `cargo doc --no-deps` for the project only

`--no-deps` restricts generation to the current workspace, skipping
dependencies. This is the command to run locally and in CI — it is fast and
surfaces broken intra-doc links in **your** code. `--open` launches the
browser at the crate's index page for local preview:

```bash
cargo doc --no-deps          # generate docs for the current crate only
cargo doc --no-deps --open   # generate and preview in the browser
```

### Rustdoc renders public items only — hide internal re-exports

rustdoc documents items reachable from the crate's public API. Internal
re-exports that must be `pub` for the module system but are not part of the
API should be marked `#[doc(hidden)]`:

```rust
#[doc(hidden)] // re-exported for internal use, not part of the public API
pub use crate::engine::internals;

/// The public entry point — this is what shows up in the docs.
pub fn run() { /* ... */ }
```

### `--document-private-items` as a CI lint step

In CI, run with `--document-private-items` to force rustdoc to process
private items too — this catches broken intra-doc links that reference
private types before they fail publicly. Treat rustdoc warnings as errors:

```bash
RUSTDOCFLAGS="-D rustdoc::broken_intra_doc_links" \
  cargo doc --no-deps --document-private-items
```

### Hosted documentation: `--output-dir` and docs.rs

For CI artifacts, `--output-dir` writes to a known path for upload:

```bash
cargo doc --no-deps --output-dir ./artifacts/docs
```

For published crates, **docs.rs** builds and hosts documentation
automatically on publish. Configure the build via
`[package.metadata.docs.rs]` in `Cargo.toml`:

```toml
[package.metadata.docs.rs]
all-features = true                    # render feature-gated items
rustdoc-args = ["--cfg", "docsrs"]     # activate doc-only code paths
```

### Intra-doc links work across crate boundaries

In a workspace, intra-doc links resolve across crates with
`[crate::Type]` or `[other_crate::Type]` syntax, keeping links
compiler-verified:

```rust
/// Delegates to [`project_lint::Rule`] for the public-facing rule type.
/// See [`crate::engine::validate`] for the internal validation loop.
pub fn run() { /* ... */ }
```

### Document feature flags with `cfg_attr` and `#[doc = "..."]`

Feature-gated items should document **which feature** enables them. Add a
`## Feature Flags` section in the crate-level docs, annotate gated items, and
use `cfg_attr` with `#[doc = "..."]` for feature-conditional docs:

```rust
//! # Feature Flags
//! - `json` — enables JSON rule serialization (see [`Rule::to_json`]).
//! - `daemon` — enables background daemon mode (see [`Daemon`]).

/// Serializes a rule to JSON. Only available with the `json` feature.
#[cfg(feature = "json")]
pub fn to_json(rule: &Rule) -> Result<String, serde_json::Error> { /* ... */ # Ok(String::new()) }

#[cfg_attr(feature = "json", doc = "Requires the `json` feature.")]
pub struct Rule { /* ... */ }
```

## Related Concepts

- [rust-doc-comment-patterns](rust-doc-comment-patterns.md) — the `///` and `//!` conventions and rustdoc-recognized sections that this command renders.
- [Mermaid Practices](mermaidjs.md) — embedding architecture diagrams in the crate-level `//!` docs that `cargo doc` generates.
