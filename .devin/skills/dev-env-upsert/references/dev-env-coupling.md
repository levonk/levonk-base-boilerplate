# Dev Env Coupling — Why devbox.json + .envrc + justfile Are Managed Together

## The Trio

The Standard Developer UX Flow (see
`references/included/knowledge/dev-environment-practices/standard-developer-ux-flow.md`)
is `direnv → devbox → just (*_impl) → [build tool]`. Three files manifest this
flow:

| File | Role | Owned by |
|------|------|----------|
| `devbox.json` | Declares packages, `init_hook`, and devbox scripts that point to `*_impl` targets | dev-env-upsert |
| `.envrc` | Auto-activates devbox via direnv (`use_devbox` + `watch_file devbox.json`) and async-triggers `prime_impl` on directory entry | dev-env-upsert |
| `justfile` | Holds the `*_impl` targets that run the build tool inside the devbox environment, including `prime_impl` (warmup + indexing) | dev-env-upsert |

direnv auto-activation is documented in
`references/included/knowledge/dev-environment-practices/direnv-auto-activation.md`:
on `cd` into the project, direnv evaluates `.envrc`, which calls
`devbox shellenv` to put devbox packages on `PATH`, and `watch_file devbox.json`
ensures direnv reloads when the package list changes.

## The Drift Problem

Managing the three files separately causes silent drift. Each file makes
assumptions about the others, and when one changes without updating the rest,
the environment breaks in ways that surface minutes later as cryptic errors
rather than clear config errors.

### Drift case 1: package added to devbox.json, .envrc not reloaded

A developer adds `rustc` to `devbox.json` directly (bypassing this skill).
`.envrc` has `watch_file devbox.json`, so direnv *should* reload — but if the
developer is already in the shell, direnv does not re-evaluate until the next
`cd`. The developer runs `just build_impl` → `cargo build` and gets "command
not found". The fix is `direnv reload`, but the error message does not say
that. The skill's `add-packages` operation runs `devbox add` (which updates
`devbox.json`) and `update-envrc` regenerates the direnv block so the
`watch_file` set stays current.

### Drift case 2: package added, justfile *_impl not updated

A developer adds a linter to `devbox.json` but does not add it to
`lint_impl`. `just lint` now runs the old linter (or fails). The skill's
`reconcile` operation detects the mismatch: it compares `devbox.json`
packages against the stack baseline and flags packages present in devbox but
missing from the justfile's `*_impl` targets.

### Drift case 3: .envrc async trigger out of sync with prime_impl

The `.envrc` async trigger block (per
`references/included/knowledge/dev-environment-practices/async-prime-internal.md`)
calls `devbox run -- just prime_impl`. If `prime_impl` is renamed or removed
from the justfile, the async trigger fails silently in the background —
`nohup ... > /dev/null 2>&1 &` swallows the error. The developer notices only
when caches are cold on the first `just build`. The skill's `validate`
operation checks that `prime_impl` exists in the justfile and that the async
trigger block is present in `.envrc`, catching this drift before it bites.

### Drift case 4: indexer added to prime_impl, staleness check missing

A developer manually adds `codegraph index .` to `prime_impl` without the
staleness check wrapper. Now every `cd` into the project triggers a full
reindex — burning CPU on unchanged code. The skill's `add-prime-steps`
operation always wraps the indexer invocation in the staleness check (per
`references/included/knowledge/dev-environment-practices/index-staleness-check.md`),
so the indexer only runs when the DB is missing or older than 1 hour.

## Why a Single Skill Owns All Three

Because the three files are coupled, editing one without the others is a
bug. A single skill that owns all three can enforce invariants:

- `add-packages` updates `devbox.json` and the `.envrc` `watch_file` set
  together.
- `add-prime-steps` edits `prime_impl` in the justfile and ensures the
  `.envrc` async trigger will call it.
- `update-envrc` regenerates the direnv block from `devbox generate direnv`
  and re-appends the async trigger, so `.envrc` never drifts from
  `devbox.json`.
- `validate` checks all three for consistency in one pass.

This is the same coupling argument that drives `project-adopter` to delegate
the trio here rather than editing the files inline: the delegation boundary
matches the coupling boundary.

## Related

- `references/included/knowledge/dev-environment-practices/standard-developer-ux-flow.md`
- `references/included/knowledge/dev-environment-practices/direnv-auto-activation.md`
- `references/included/knowledge/dev-environment-practices/async-prime-internal.md`
- `references/indexed-ast-tool-setup.md`
