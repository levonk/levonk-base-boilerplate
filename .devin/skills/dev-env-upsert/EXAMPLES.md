# Dev Env Upsert Examples

## Example 1: Add CodeGraph to a Single-Project Rust Repo

### Scenario

A Rust project (`Cargo.toml` + `src/*.rs`) needs semantic code search. The
developer wants CodeGraph indexed automatically on directory entry, with a
staleness check so it only reindexes when the DB is missing or older than 1
hour.

### Before

```bash
$ ls -la
Cargo.toml
src/
  main.rs
  lib.rs
devbox.json       # has rust-toolchain, just
.envrc            # has use_devbox, no async trigger
justfile          # has build_impl, test_impl, prime_impl (no indexer)
```

### Command

```bash
uv run --script scripts/dev_env_upsert.py setup \
    --packages codegraph,direnv,just \
    --prime-steps "codegraph index .:codegraph" \
    --envrc-async-prime \
    --target .
```

### What Happens

1. **add-packages**: `devbox add codegraph`, `devbox add direnv`, `devbox add
   just` (loops internally; `just` and `direnv` are already present so devbox
   no-ops them).
2. **add-prime-steps**: detects `.rs` files → CodeGraph applies. Inserts the
   staleness check block into `prime_impl` idempotently:
   ```just
       # --- codegraph staleness check (dev-env-upsert) ---
       INDEX_DB=".codegraph/codegraph.db"
       if [ ! -f "$INDEX_DB" ] || [ $(find "$INDEX_DB" -mmin +60 2>/dev/null | wc -l) -gt 0 ]; then
           codegraph index .
       fi
   ```
3. **update-envrc**: regenerates the direnv block from `devbox generate
   direnv --print-envrc`, preserves the existing `use_devbox` block, and
   appends the async `prime_impl` trigger:
   ```bash
   # Async prime_impl trigger (per dev-environment-practices/async-prime-internal.md)
   if [ -f devbox.json ] && command -v just >/dev/null 2>&1; then
     if [ "$DEVBOX_SHELL_ENABLED" != "1" ]; then
       nohup devbox run -- just prime_impl > /dev/null 2>&1 &
     fi
   fi
   ```

### After

On the next `cd` into the project, direnv evaluates `.envrc`, which
async-triggers `prime_impl`. `prime_impl` runs the staleness check, sees no
`INDEX_DB`, and runs `codegraph index .`. Subsequent entries skip reindexing
until the DB is older than 1 hour.

---

## Example 2: Add GitNexus to a Multi-Repo Workspace

### Scenario

A workspace directory contains three git repositories (a backend, a frontend,
and a shared library). The developer wants GitNexus to index the
multi-repo source code graph. The developer has confirmed they have a
commercial GitNexus license (GitNexus is PolyForm Noncommercial — business
use requires license procurement).

### Before

```bash
$ ls -la ../
backend/    # .git, src/*.rs
frontend/   # .git, src/*.ts
shared/     # .git, src/*.rs
$ ls -la
devbox.json
.envrc
justfile
```

### Command

```bash
uv run --script scripts/dev_env_upsert.py setup \
    --packages gitnexus,direnv,just \
    --prime-steps "gitnexus index .:gitnexus" \
    --envrc-async-prime \
    --target .
```

### License Note

GitNexus is distributed under the **PolyForm Noncommercial** license. Do NOT
install GitNexus by default — only when (1) the project is a multi-repo
workspace (multiple `.git` dirs in the parent), AND (2) the user has
confirmed commercial license procurement for business use. For single-repo
source code, use CodeGraph instead.

### What Happens

1. **add-packages**: `devbox add gitnexus`, `devbox add direnv`, `devbox add
   just`.
2. **add-prime-steps**: detects `.rs`/`.ts` files AND detects the multi-repo
   workspace (multiple `.git` dirs in `../`) → GitNexus applies. Inserts the
   staleness check into `prime_impl` with `INDEX_DB=".gitnexus/gitnexus.db"`.
3. **update-envrc**: appends the async `prime_impl` trigger.

### After

`prime_impl` reindexes via `gitnexus index .` when the DB is missing or older
than 1 hour. The multi-repo graph covers all three repositories.

---

## Example 3: Add Graphify to a Project with Architecture Docs/PDFs

### Scenario

A project has a `docs/` directory full of architecture PDFs, Markdown design
docs, and presentation slides. There is no source code — the project is a
documentation hub. The developer wants Graphify to index the docs for
semantic search over non-code content.

### Before

```bash
$ ls -la
docs/
  architecture.pdf
  design.md
  roadmap.pptx
  diagram.png
devbox.json
.envrc
justfile
```

### Command

```bash
uv run --script scripts/dev_env_upsert.py setup \
    --packages graphify,direnv,just \
    --prime-steps "graphify index .:graphify" \
    --envrc-async-prime \
    --target .
```

### What Happens

1. **add-packages**: `devbox add graphify`, `devbox add direnv`, `devbox add
   just`.
2. **add-prime-steps**: detects `.pdf`, `.md`, `.pptx`, `.png` files →
   Graphify applies. No source code files are present, so CodeGraph and
   GitNexus would be skipped if requested. Inserts the staleness check into
   `prime_impl` with `INDEX_DB=".graphify/graphify.db"`.
3. **update-envrc**: appends the async `prime_impl` trigger.

### After

`prime_impl` reindexes via `graphify index .` when the DB is missing or older
than 1 hour. The doc index covers all PDFs, Markdown, slides, and images in
`docs/`.
