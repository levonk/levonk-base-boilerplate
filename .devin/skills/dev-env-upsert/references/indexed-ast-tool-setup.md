# Indexed AST Tool Setup — Canonical Recipe

This is the canonical recipe for adding CodeGraph, Graphify, or GitNexus to a
project via `dev-env-upsert`. These three tools are code/document indexers
that produce an AST-based index DB used for semantic code search and
graph-based navigation.

## File-Type-Aware Detection

`dev-env-upsert add-prime-steps` only adds the indexer line if the indexer
handles the project's detected file types. The detection logic scans the
`--target` directory for files matching each indexer's extensions.

| Indexer | Handles | File types |
|---------|---------|------------|
| CodeGraph | Source code | `.rs`, `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.java`, `.kt`, `.swift`, `.c`, `.cpp`, `.h`, `.hpp` |
| GitNexus | Multi-repo source code | Same as CodeGraph + detects multi-repo workspace (multiple `.git` dirs in parent) |
| Graphify | Non-code docs | `.pdf`, `.md`, `.docx`, `.pptx`, `.mp4`, `.mov`, `.png`, `.jpg`, `.svg` |

If no matching files are found, the step is skipped with a notice. No silent
insertion, no error.

## The setup Operation (One Call)

The `setup` operation does everything in one call — add the indexer package
to devbox, fold the indexer into `prime_impl` with the staleness check, and
append the async `prime_impl` trigger to `.envrc`:

```bash
uv run --script <dev-env-upsert>/scripts/dev_env_upsert.py setup \
    --packages <indexer>,direnv,just \
    --prime-steps "<indexer> index .:<indexer>" \
    --envrc-async-prime \
    --target .
```

Replace `<dev-env-upsert>` with the installed skill path and `<indexer>` with
`codegraph`, `graphify`, or `gitnexus`.

## Do NOT Install All Three by Default

The detection logic picks ONE indexer based on file types:

- Source code repo (`.rs`, `.ts`, etc. present) → **CodeGraph**.
- Multi-repo workspace (multiple `.git` dirs in parent) → **GitNexus** (but
  see the license note below).
- Docs-heavy repo (`.pdf`, `.md`, `.docx`, etc. present, no source) →
  **Graphify**.

Installing all three wastes disk and CPU: each maintains its own index DB and
re-indexing all three on every `prime_impl` run is redundant. Pick the one
that matches the project's file types.

## Do NOT Create New index / index_impl Targets

Indexing folds into the existing `prime_impl` per the Standard Developer UX
Flow. Do NOT create new `index` or `index_impl` justfile targets. The
reasons:

1. **Single trigger surface**: all three paths that warm the project (manual
   `just prime`, bootstrap, `.envrc` async trigger) go through `prime_impl`.
   A separate `index` target would need its own trigger wiring, duplicating
   the async logic.
2. **Staleness check belongs with warmup**: `prime_impl` already runs
   warmup jobs (package downloads, build, recipe list). Indexing is another
   warmup job — it belongs in the same target.
3. **`*_impl` naming invariant**: the justfile convention (per
   `references/included/knowledge/dev-environment-practices/internal-vs-normal-targets.md`)
   is one `*_impl` per action. "Index" is not a separate action from "prime"
   — it is a step inside prime.

## The Staleness Check Lives INSIDE prime_impl

The staleness check wraps the indexer invocation inside `prime_impl`, not in
`.envrc`. `.envrc` just async-triggers `prime_impl` (per
`references/included/knowledge/dev-environment-practices/async-prime-internal.md`).

```just
    # Inside prime_impl (added by dev-env-upsert add-prime-steps)
    INDEX_DB=".codegraph/codegraph.db"
    if [ ! -f "$INDEX_DB" ] || [ $(find "$INDEX_DB" -mmin +60 2>/dev/null | wc -l) -gt 0 ]; then
        codegraph index .
    fi
```

The check: is the index DB missing OR older than 1 hour? If either, reindex.
The 1-hour threshold balances freshness against CPU cost. See
`references/included/knowledge/dev-environment-practices/index-staleness-check.md`
for the full rationale.

If the check lived in `.envrc`, it would only apply to the `.envrc` path, not
to manual `just prime` or bootstrap. Putting it inside `prime_impl` means
every path gets it for free.

## GitNexus License Note

GitNexus is distributed under the **PolyForm Noncommercial** license. This
requires commercial license procurement for business use. **Do NOT install
GitNexus by default.** Only install it when:

1. The project is a multi-repo workspace (multiple `.git` dirs in the
   parent directory), AND
2. The user has confirmed they have (or do not need) a commercial license.

For single-repo source code repos, use CodeGraph instead. For docs-heavy
repos, use Graphify. Both are safe defaults; GitNexus is opt-in.

## Related

- `references/included/knowledge/dev-environment-practices/standard-developer-ux-flow.md`
- `references/included/knowledge/dev-environment-practices/async-prime-internal.md`
- `references/included/knowledge/dev-environment-practices/index-staleness-check.md`
- `references/included/knowledge/dev-environment-practices/internal-vs-normal-targets.md`
- `EXAMPLES.md`
