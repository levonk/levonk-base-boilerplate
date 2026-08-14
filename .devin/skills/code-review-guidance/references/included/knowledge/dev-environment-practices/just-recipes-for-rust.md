---
type: Practice
title: Just Recipes for Rust
description: Standard justfile recipes for Rust projects — build, test, clippy, fmt, doc, bench, feature flags, cross-compilation, and workspace-aware targets with devbox auto-detection integration.
tags: [dev-environment, rust, just, cargo, build-tools, developer-experience]
date:
  created: "2026-08-05"
  knowledge-basis: "2026-08-05"
  last-used: "2026-08-05"
sources:
  - id: project-lint-audit
    resource: "project-lint/Cargo.toml"
    title: "project-lint"
---

# Just Recipes for Rust

## Failure Mode

Rust projects without a shared task runner end up with ad-hoc `cargo` invocations
scattered across READMEs, CI YAML, and shell history. Feature flags, workspace
targets, and cross-compilation triples are reinvented per repo, and contributors
guess whether `cargo test` includes doctests or whether clippy runs with
`-D warnings`. The result is drift between local, CI, and agent environments.

## Practice

Define a single `justfile` that wraps every `cargo` subcommand the project uses.
Recipes are thin, named after the developer intent (`test`, `lint`, `doc`), and
delegate to `*_impl` targets that hold the real `cargo` invocation. The
`_devbox` helper handles environment auto-detection so the same `just test`
works for agents, novices, and power users.

### Complete justfile

The `_devbox` helper re-execs through `devbox run --` when
`DEVBOX_SHELL_ENABLED` is unset, so the same `just build` works for agents, CI,
and power users without a prefix. See
[Standard Developer UX Flow](standard-developer-ux-flow.md) for the full helper.

```just
# project-lint — Rust justfile
default: build

_devbox target *args:
    #!/usr/bin/env bash
    if [ "${DEVBOX_SHELL_ENABLED:-0}" = "1" ]; then
        exec just "{{target}}" {{args}}
    elif command -v devbox >/dev/null 2>&1; then
        exec devbox run -- just "{{target}}" {{args}}
    else
        echo "devbox not found" >&2; just doctor 2>/dev/null || true; exit 1
    fi

build:        just _devbox build_impl
test:         just _devbox test_impl
lint:         just _devbox lint_impl
fmt:          just _devbox fmt_impl
doc:          just _devbox doc_impl
bench:        just _devbox bench_impl

build_impl:        cargo build
test_impl *a:      cargo nextest run {{a}} || cargo test {{a}}
lint_impl:         cargo clippy --all-targets -- -D warnings
fmt_impl:          cargo fmt --check
doc_impl:          cargo doc --no-deps
bench_impl:        cargo bench
```

`cargo nextest run` is preferred when available (faster, better diagnostics);
the `|| cargo test` fallback keeps the recipe working on toolchains without
nextest installed.

### Feature Flag Handling

Pass feature sets through a recipe argument so CI and local runs use identical
flags. Default to the release feature set; override with
`just test --features foo`.

```just
test features="release":
    just _devbox test_impl --features {{features}}
```

### Cross-Compilation

Pin the target triple in a named recipe so contributors do not memorize
`--target` strings. The devbox environment provides the cross-linker; the
recipe only supplies the triple.

```just
build-arm64:
    just _devbox build_arm64_impl

build_arm64_impl:
    cargo build --target aarch64-unknown-linux-gnu
```

### Workspace-Aware Recipes

For cargo workspaces, scope recipes with `--workspace` so a single command
covers every member crate. Per-crate recipes take the crate name as an argument.

```just
test-workspace:
    just _devbox test_workspace_impl

test_workspace_impl:
    cargo nextest run --workspace

test-crate crate:
    just _devbox test_impl -p {{crate}}
```

## Related Concepts

- [Just Over Makefiles](just-over-makefiles.md) — Why just is the task runner, not Make
- [Standard Developer UX Flow](standard-developer-ux-flow.md) — The `_devbox` auto-detection helper these recipes delegate to
