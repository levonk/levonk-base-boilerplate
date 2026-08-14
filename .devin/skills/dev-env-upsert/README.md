# Dev Env Upsert

Manage `devbox.json` + `.envrc` + justfile as a coupled trio per the Standard
Developer UX Flow (`direnv → devbox → just (*_impl) → [build tool]`).

## What It Does

- **Add/remove devbox packages** — loops over `devbox add` / `devbox remove`
  internally so the AI hands off a comma-separated list in one call.
- **Fold indexed AST tools into `prime_impl`** — CodeGraph, Graphify, and
  GitNexus are code/document indexers that belong in `prime_impl` (the
  canonical warmup target), not in separate `index` targets. File-type-aware
  detection picks the right indexer for the project's files.
- **Update `.envrc`** — regenerates the direnv block from `devbox generate
  direnv` and appends the async `prime_impl` trigger (per
  `async-prime-internal.md`).
- **Reconcile** — detects the project stack (nx monorepo, Python, Rust, Go,
  Java) and suggests packages.
- **Validate** — checks `devbox.json`, `.envrc`, and justfile `prime_impl`
  integrity in one pass.

## Quick Start

```bash
# setup — primary operation: does everything in one call
uv run --script scripts/dev_env_upsert.py setup \
    --packages codegraph,direnv,just \
    --prime-steps "codegraph index .:codegraph" \
    --envrc-async-prime \
    --target .

# add packages only
uv run --script scripts/dev_env_upsert.py add-packages --packages a,b,c --target .

# validate the trio
uv run --script scripts/dev_env_upsert.py validate --target .
```

## Why a Trio?

The three files are coupled: changing `devbox.json` packages without
updating `.envrc`'s `watch_file` or the justfile's `*_impl` targets breaks
the environment silently. This skill owns all three so it can enforce
invariants across them. See `references/dev-env-coupling.md` for the drift
analysis.

## Related

- `project-adopter` — delegates dev-env trio management to this skill after
  adoption.
- `nixify` — alternative for Nix flake packaging (remote install), not local
  dev environments.
- `project-detection` — used by `reconcile` to detect the project stack.
