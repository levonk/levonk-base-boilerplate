# Handoff: Add submodule-integrity pre-commit hook to repo boilerplates

**Date**: 2026-08-12
**Session**: Post-incident — infrahub levonk submodule was accidentally converted from `160000 commit` to `040000 tree`. A pre-commit hook was added to infrahub manually. This handoff updates the two `repo/` boilerplate templates so new projects generated from them start with submodule-integrity protection.
**Status**: Done — implemented, verified, and committed (commit `ae4655c`). Ready to archive.

## Current State

### ✅ Completed
- **Root-cause analysis**: Commit `9704d5e` in infrahub accidentally ran `git add` on the `levonk/` submodule directory, converting it from a gitlink (`160000 commit`) to a regular tree (`040000 tree`).
- **Forward-fix in infrahub**: Submodule tracking restored. Pre-commit hook created at `scripts/hooks/pre-commit` and wired via `core.hooksPath=scripts/hooks`.
- **Reference implementation**: The infrahub pre-commit hook is a bash script that writes the staged index to a tree (`git write-tree`), then checks each `.gitmodules` submodule path's mode — must be `160000 commit`, not `040000 tree`.

### ❌ Blocking Issues
1. **The `repo/git-repo` and `repo/pnpm-monorepo` boilerplate templates do not include a pre-commit hook for submodule integrity.** New projects generated from these templates are unprotected. The templates have a `.pre-commit-config.yaml.jinja` (for pre-commit framework hooks) but no `core.hooksPath` setup or native git hook for submodule-as-tree detection.

## Git State

- **Repo HEAD**: `ae4655c` (work committed); handoff was captured at `6791c2a0c96598c7104841234a3edee860f616e4`
- **Branch**: `main`
- **Date captured**: 2026-08-12 17:52 PT (handoff); 2026-08-12 18:09 PT (completion)

## Required Reading

Before any other action, read `/Users/micro/p/gh/levonk/levonk-base-boilerplate/AGENTS.md` — it is the root of this project's progressively-disclosed informational files. Pay special attention to the Copier template structure and the `_shared/partials/` convention.

## Project Overview

### Objective

Update the two `repo/` boilerplate templates to include:
1. A `scripts/hooks/pre-commit` git hook script (the submodule-integrity hook, generalized for any `.gitmodules` submodule)
2. `core.hooksPath=scripts/hooks` setup in the justfile `setup` recipe (so `just setup` configures the hooks path)
3. A `doctor` check for `core.hooksPath` status (so `just doctor` reports whether hooks are configured)

The two boilerplate templates to update:
- `repo/git-repo/` — standalone git repository template
- `repo/pnpm-monorepo/` — pnpm monorepo template

### Current Status

Both templates have a `justfile.jinja` with `setup` and `doctor` recipes, and a `.pre-commit-config.yaml.jinja` for pre-commit framework hooks. Neither has a native git hook directory or `core.hooksPath` configuration. The `_shared/partials/pre-commit/` directory contains pre-commit framework partials (yaml configs for the `pre-commit` tool), not native git hooks.

## Key Decisions Made

- **Hook script location**: `scripts/hooks/pre-commit` in the generated project (matching the infrahub pattern). This is a versioned, committed hook — not in `.git/hooks/` (which isn't tracked).
- **`core.hooksPath` config**: `scripts/hooks` — set via `git config core.hooksPath scripts/hooks` in the justfile `setup` recipe.
- **Template file**: `repo/git-repo/files/scripts/hooks/pre-commit` (no `.jinja` suffix — it's a static file, not templated). Same for `repo/pnpm-monorepo/files/scripts/hooks/pre-commit`.
- **Shared hook content**: The hook script is identical for both templates. Consider putting it in `_shared/` and including it, but since it's a single static file, duplicating it in both templates is simpler and avoids Copier include complexity. **Recommendation**: duplicate in both templates for now; if a third repo template is added later, refactor to `_shared/`.
- **Justfile integration**: Add `git config core.hooksPath scripts/hooks` to the existing `setup` recipe in each template's `justfile.jinja`. Add a `doctor` check line for `core.hooksPath` status.
- **Coexistence with pre-commit framework**: The native git hook (`scripts/hooks/pre-commit`) and the pre-commit framework (`.pre-commit-config.yaml`) can coexist. `core.hooksPath` takes precedence over `.git/hooks/`. If the user runs `pre-commit install`, it writes to `.git/hooks/pre-commit` which is shadowed by `core.hooksPath`. **Recommendation**: document this in a comment in the hook file; the native hook is the submodule-integrity check, the pre-commit framework handles language-specific linting.

## Technical Context

### Stack/Tools
- Copier templates with Jinja2 (`.jinja` suffix)
- `_shared/partials/` for shared partials included via `{% include "partials.bak/partials/..." %}`
- Just + Devbox for build/test
- Static files (no `.jinja` suffix) are copied verbatim by Copier

### Reference Implementation (infrahub pre-commit hook)

The working bash implementation lives at `~/p/gh/levonk/infrahub/scripts/hooks/pre-commit`. Key logic:

```bash
# 1. Read .gitmodules for submodule paths
# 2. Write staged index to tree: git write-tree → tree_sha
# 3. For each submodule path, git ls-tree "$tree_sha" -- "$sm_path":
#    - mode 160000 + type commit → OK
#    - mode 040000 + type tree → VIOLATION
#    - path missing but files under "$sm_path/" → VIOLATION
#    - any other mode → VIOLATION
# 4. Exit 1 on violation, 0 otherwise
```

The full script is ~140 lines of bash. It should be copied into both boilerplate templates as a static file (no `.jinja` suffix).

### Important Files

**repo/git-repo:**
- `repo/git-repo/files/justfile.jinja` — add `core.hooksPath` setup to `setup` recipe, add `doctor` check
- `repo/git-repo/files/scripts/hooks/pre-commit` — NEW static file (the hook script)
- `repo/git-repo/files/.pre-commit-config.yaml.jinja` — existing pre-commit framework config (no change needed, but add a comment about coexistence)

**repo/pnpm-monorepo:**
- `repo/pnpm-monorepo/files/justfile.jinja` — add `core.hooksPath` setup to `setup` recipe, add `doctor` check
- `repo/pnpm-monorepo/files/scripts/hooks/pre-commit` — NEW static file (the hook script)
- `repo/pnpm-monorepo/files/.pre-commit-config.yaml.jinja` — existing pre-commit framework config (no change needed)

**_shared (optional, if refactoring to shared):**
- `_shared/partials/git-hooks/pre-commit` — potential shared location if refactoring (not recommended for this handoff — see Key Decisions)

### Environment Notes
- Copier templates use Jinja2 with `{% %}` and `{{ }}` delimiters (NOT the `{{{`/`}}}` from skills-src — this is a different repo with different conventions)
- Static files (no `.jinja` suffix) are copied verbatim — the hook script should be a static file
- Test template generation with `devbox run -- rtk ./boilerplate/copier-wrapper.sh copy ./boilerplate/repo/git-repo /tmp/test-git-repo --data @copier-answers.yml`
- The `partials.bak/` directories are legacy backup partials — do NOT modify them; modify `_shared/partials/` instead

### Existing justfile patterns

**repo/git-repo justfile.jinja** — current `setup` recipe:
```jinja
# Development setup (OPTIONAL)
setup:
    # Project-specific setup
    echo "Development environment ready!"
```

**repo/pnpm-monorepo justfile.jinja** — current `setup` recipe:
```jinja
# Development setup (OPTIONAL)
setup:
    @just bootstrap
    echo "✅ pnpm monorepo development environment ready!"
```

Both need a `git config core.hooksPath scripts/hooks` line added to `setup`, and a `doctor` check line.

## Next Steps (Priority Order)

1. Read the infrahub reference implementation at `~/p/gh/levonk/infrahub/scripts/hooks/pre-commit`
2. Create `repo/git-repo/files/scripts/hooks/pre-commit` (static file, no `.jinja` suffix)
3. Update `repo/git-repo/files/justfile.jinja` — add `core.hooksPath` setup to `setup` recipe, add `doctor` check
4. Create `repo/pnpm-monorepo/files/scripts/hooks/pre-commit` (same static file)
5. Update `repo/pnpm-monorepo/files/justfile.jinja` — add `core.hooksPath` setup to `setup` recipe, add `doctor` check
6. Test template generation for both boilerplates (generate a test project, verify the hook file exists and `just setup` configures `core.hooksPath`)
7. Test the hook in a generated project (simulate a submodule-as-tree violation, verify the hook blocks the commit)
8. Commit the changes

## Task List

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

```markdown
- [x] Read AGENTS.md and the boilerplate template structure (repo/git-repo, repo/pnpm-monorepo)
- [x] Read the infrahub reference implementation at ~/p/gh/levonk/infrahub/scripts/hooks/pre-commit
- [x] Create repo/git-repo/files/scripts/hooks/pre-commit (static file, chmod +x)
- [x] Update repo/git-repo/files/justfile.jinja setup recipe (add git config core.hooksPath scripts/hooks)
- [x] Update repo/git-repo/files/justfile.jinja doctor recipe (add core.hooksPath status check)
- [x] Create repo/pnpm-monorepo/files/scripts/hooks/pre-commit (same static file, chmod +x)
- [x] Update repo/pnpm-monorepo/files/justfile.jinja setup recipe (add git config core.hooksPath scripts/hooks)
- [x] Update repo/pnpm-monorepo/files/justfile.jinja doctor recipe (add core.hooksPath status check)
- [x] Test: generate a project from repo/git-repo template, verify hook file exists and just setup configures core.hooksPath
- [x] Test: generate a project from repo/pnpm-monorepo template, verify hook file exists and just setup configures core.hooksPath
- [x] Test: simulate a submodule-as-tree violation in a generated project, verify the hook blocks the commit
- [x] Commit the changes
```

**Maintenance protocol (receiving session):**
1. **Verify in-progress marks.** Re-check every `[~]` task. If work is not actually underway, demote to `[ ]`.
2. **Start the next available task.** Pick the first `[ ]` task in priority order. Mark `[~]` before starting.
3. **Prefer subagents for parallel work.** The two boilerplate templates are independent — `repo/git-repo` and `repo/pnpm-monorepo` can be updated in parallel via subagents.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after verification (template generates correctly, hook works).
5. **Record blockers inline.** Mark blocked tasks `[!]` with the blocker in parentheses.
6. **Update the list as work reveals new tasks.** Append new tasks as `[ ]` in priority order.

## Definition of Done

- [x] **[manual]** Every Task List item is `[x]` or marked `[x]` with an obsolete note
- [x] **[script]** `git status --porcelain` shows no uncommitted changes for this task's files (the 4 hook/justfile files are committed in `ae4655c`; pre-existing unrelated devbox changes in the repo were not touched)
- [x] **[manual]** The handoff document's Git State commit SHA matches `git rev-parse HEAD` (`ae4655c`)
- [x] **[manual]** Each completed task's deliverable matches what was described
- [x] **[manual]** `repo/git-repo` template generates a project with `scripts/hooks/pre-commit` and `just setup` sets `core.hooksPath`
- [x] **[manual]** `repo/pnpm-monorepo` template generates a project with `scripts/hooks/pre-commit` and `just setup` sets `core.hooksPath`
- [x] **[manual]** The generated pre-commit hook detects submodule-as-tree violations (tested with a simulated broken state — `040000 tree` blocked with exit 1; proper `160000 commit` allowed with exit 0)

## Open Questions/Blockers
- Should the hook script be shared via `_shared/partials/` or duplicated in both templates? **Recommendation**: duplicate for now (simpler, avoids Copier include complexity for a single static file). Refactor to `_shared/` only if a third repo template is added. — Impact: minimal duplication (one file, ~140 lines).
- Should the `.pre-commit-config.yaml.jinja` be updated to document coexistence with the native hook? **Recommendation**: add a comment in the yaml file noting that `core.hooksPath=scripts/hooks` takes precedence over `.git/hooks/` and that the native hook handles submodule integrity while pre-commit framework handles language-specific linting. — Impact: user clarity.
- Should the hook be added to other boilerplate templates beyond `repo/git-repo` and `repo/pnpm-monorepo`? **Recommendation**: no — only repo-level templates need submodule integrity hooks. App/package templates are subdirectories of repos, not repos themselves. — Impact: scope control.

## Do Not
- Do NOT modify `partials.bak/` directories — they are legacy backups; modify `_shared/partials/` instead
- Do NOT add `.jinja` suffix to the hook script — it's a static file copied verbatim by Copier
- Do NOT hardcode submodule paths in the hook — read from `.gitmodules`
- Do NOT use `{{`/`}}` in template files unless they are Jinja2 templates (`.jinja` suffix) — this repo uses Jinja2, NOT the `{{{`/`}}}` from skills-src
- Do NOT add AI attribution to commits
- Do NOT forget to `chmod +x` the hook script (Copier preserves file permissions)

## Suggested Skills
- `git-repository-management` — for committing the boilerplate changes
- `code-quality-validation` — for validating the template generates correctly
- `project-adopter` — the skill that uses these boilerplates (reference for how the templates are consumed)

## Additional Context

### The infrahub pre-commit hook (reference implementation)

The working bash implementation lives at `~/p/gh/levonk/infrahub/scripts/hooks/pre-commit`. It is ~140 lines of bash. The hook:
1. Reads `.gitmodules` via `git config -f .gitmodules --get-regexp 'path$'`
2. Writes the staged index to a tree via `git write-tree`
3. For each submodule path, checks the tree entry mode via `git ls-tree`
4. Flags `040000` (tree) as a violation, flags leaked files under a submodule path
5. Exits 1 on violation with a clear error message and fix command

This script should be copied (verbatim or lightly adapted) into both boilerplate templates as a static file at `files/scripts/hooks/pre-commit`.

### Related work in other repos

Three companion handoffs are being created in parallel:
- **project-lint**: Codify the detection logic as a Rust scanner in `project-lint-core` (the canonical lint-time check)
- **skills-src**: Add pre-commit hook installation to the `project-adopter` skill (so adopting an existing project installs the hook)
- **This handoff (levonk-base-boilerplate)**: Update the `repo/git-repo` and `repo/pnpm-monorepo` boilerplate templates so new projects start with the hook

These three are independent and can be worked in parallel. The project-lint scanner is the canonical detection logic; the skills-src handoff distributes the hook via the skill system; this handoff ensures new projects start protected from day one.

### Existing pre-commit framework coexistence

Both boilerplate templates already have a `.pre-commit-config.yaml.jinja` that configures the `pre-commit` framework (pre-commit-hooks repo for yaml/json validation, whitespace, etc.). The native git hook (`scripts/hooks/pre-commit`) is a separate, complementary check:
- **Native git hook** (`scripts/hooks/pre-commit`): submodule-integrity check (structural — prevents submodule-as-tree bugs)
- **Pre-commit framework** (`.pre-commit-config.yaml`): language-specific linting, file hygiene (yaml/json validation, whitespace, EOF)

When `core.hooksPath=scripts/hooks` is set, git uses `scripts/hooks/pre-commit` instead of `.git/hooks/pre-commit`. If the user also runs `pre-commit install`, it writes to `.git/hooks/pre-commit` which is shadowed by `core.hooksPath`. The native hook should call `pre-commit run --hook-stage pre-commit` at the end if pre-commit is installed, to chain the framework hooks. **However**, this chaining is optional for this handoff — the primary goal is the submodule-integrity check. Document the coexistence in a comment.
