# tsup Migration, pnpm Catalog, and Copier Template Fixes

**Date**: 2026-08-03
**Session**: Build tool knowledge bundle ingest + boilerplate tsup migration + pnpm catalog + copier fixes
**Status**: In progress — refactoring needed

## Current State

### Completed
- Knowledge bundle: `typescript-monorepo-best-practices/build-tool-selection.md` ingested into skills-src (commit `2cb35c7`)
- ADR-20260802001 drafted for tsup adoption in library package templates
- tsup build target partial created (`_shared/partials/nx-partials/nx-target-nodejs-bundle.jinja`)
- Both library templates (general + web) migrated from `@nx/js:build` to tsup
- `tsup.config.ts.jinja` added to `_shared/` for both library template paths
- pnpm catalog added (`_shared/partials/pnpm-workspace-partials/catalog.yaml.jinja`)
- 15 package.json templates migrated from `"*"`/hardcoded versions to `"catalog:"` (177 specifiers)
- `packageManager` bumped from `pnpm@8.15.6` to `pnpm@9.15.0`
- 9 `.tmpl` files with Jinja syntax renamed to `.jinja` via `git mv`
- Broken copier settings fixed (go duplicate, docker-linux duplicate, web dynamic `_subdirectory`)
- Bats test written: `tests/test-copier-settings.bats` (6 checks, all passing)
- All changes committed (commit `0cdb93c`)

### Blocking Issues
1. **`_shared` partials for package.json are unused** — `_shared/partials/package-json-partials/` has `package-json-global-devdependencies.partial.json.jinja` and `package-json-tooling.partial.json.jinja` but NO package.json template includes them. All 15 package.json files are standalone with duplicated content. This is a refactoring opportunity.
2. **Catalog versions are guesses** — The catalog in `catalog.yaml.jinja` uses version ranges that were not verified against actual installed versions or latest stable releases. Some may be too old or too new.
3. **Some templates may not need pnpm-workspace.yaml** — Library templates (packages/category/*/typescript) are monorepo sub-packages, not standalone projects. They use `workspace:*` deps and expect a parent `pnpm-workspace.yaml`. Adding `pnpm-workspace.yaml.jinja` to them would be wrong — but I only added it to standalone app templates, so this may be fine. Verify.

## Git State

**Commit at handoff**: `0cdb93cce6cb7ec3740876e48b48f53e201765e6` (levonk-base-boilerplate)
**skills-src commit**: `2cb35c7` (already committed and pushed)

## Required Reading

Before any other action, read `/Users/micro/p/gh/levonk/levonk-base-boilerplate/AGENTS.md` — it is the root of this project's progressively-disclosed informational files (JIT index, binding contracts, conventions). Follow its Usage Protocol and re-read the chain for any path you touch.

## Project Overview

### Objective
Migrate TypeScript library package templates from tsc-based builds to tsup, add pnpm catalog for centralized dependency management, and fix broken copier template settings across the boilerplate repository.

### Current Status
All planned changes are committed. The bats test passes (6/6). Both library templates generate correctly with `copier copy`. The refactoring opportunity is to consolidate duplicated package.json content via `_shared` partials.

## Key Decisions Made
- **tsup over tsc for library builds** — tsup wraps esbuild for speed + generates `.d.ts` via tsc under the hood, produces ESM+CJS in one step. ADR-20260802001 documents the rationale.
- **tsup over Rolldown for libraries** — Rolldown is for apps/CLIs (Rust speed, Rollup plugins). tsup's zero-config `.d.ts` generation is sufficient for libraries.
- **pnpm catalog over hardcoded versions** — Centralizes all dependency versions in `pnpm-workspace.yaml`. Requires pnpm 9.5+.
- **`"catalog:"` over `"*"`** — `"*` was used everywhere as a placeholder. Catalog provides real version management.
- **`.jinja` over `.tmpl`** — Copier only renders `.jinja` suffix files as Jinja templates. `.tmpl` files with `{{ }}` syntax were silently copied verbatim without rendering.
- **`_subdirectory: files` over dynamic paths** — Dynamic `_subdirectory` values like `"{{category}}/web/{{domain}}/{{package_name}}/typescript/"` resolve to paths that don't exist, causing `FileNotFoundError`.

## Technical Context

### Stack/Tools
- Copier (template engine, `copier copy` command)
- pnpm 9.15+ (catalog feature)
- Nx (task runner, `project.json` targets)
- tsup (bundler, wraps esbuild + tsc for `.d.ts`)
- bats (testing framework for shell)

### Important Files
- `_shared/partials/pnpm-workspace-partials/catalog.yaml.jinja` — shared catalog with all dependency versions
- `_shared/partials/nx-partials/nx-target-nodejs-bundle.jinja` — tsup build target partial for Nx
- `_shared/partials/package-json-partials/package-json-global-devdependencies.partial.json.jinja` — UNUSED shared partial for devDeps
- `_shared/partials/package-json-partials/package-json-tooling.partial.json.jinja` — UNUSED shared partial for tooling config
- `tests/test-copier-settings.bats` — 6 bats tests for copier config validation
- `internal-docs/adr/adr-20260802001-tsup-for-library-package-builds.md` — ADR for tsup adoption
- `repo/pnpm-monorepo/files/pnpm-workspace.yaml.jinja` — monorepo workspace config (includes catalog)
- `packages/category/general/domain/package-name/typescript/files/package.json.jinja` — general TS library template
- `packages/category/web/domain/package-name/typescript/files/package.json.jinja` — web TS library template

### Environment Notes
- Run `copier copy` via `devbox run -- copier copy` (not bare `copier`)
- bats is installed at `/usr/local/bin/bats` (via `brew install bats-core`)
- The `copier-wrapper.sh` script links `_shared/` into `partials.bak/` before running copier

## Next Steps (Priority Order)

1. **Refactor: consolidate package.json templates via `_shared` partials** — The `_shared/partials/package-json-partials/` partials exist but are unused. Wire them into the 15 standalone package.json templates so dependency lists are DRY. This is the main refactoring task for the next agent.

2. **Verify catalog versions** — The version ranges in `catalog.yaml.jinja` were written from memory/context, not verified against `pnpm list` or npm registry. Check that each version is current and compatible.

3. **Audit which templates actually need `pnpm-workspace.yaml.jinja`** — Library templates (packages/category/*/typescript) are monorepo sub-packages. They should NOT have their own `pnpm-workspace.yaml` — the monorepo root provides it. Verify that `pnpm-workspace.yaml.jinja` was only added to standalone app templates, not library templates.

4. **Consider catalog named ranges** — pnpm catalog supports named ranges (`catalog:react18`, `catalog:react19`). If different templates need different versions of the same dep, split the catalog.

5. **Run `copier copy` smoke tests on ALL templates** — Only the general and web TS library templates were tested. Test the CLI, nextjs, vscode plugin, browser-extension, and infrastructure templates to verify the catalog references resolve.

## Suggested Skills
- `git-repository-management` — to commit the refactoring changes after the next agent completes
- `refactor-planning` — to plan the package.json consolidation via `_shared` partials
- `code-review-guidance` — to review the refactoring before committing

## Open Questions
1. Should the `_shared/partials/package-json-partials/` partials be wired into all 15 package.json templates, or only into the ones that share the same dependency set?
2. Should the catalog use named ranges for React 18 vs 19, or is a single range sufficient?
3. Should the `package-json-tooling.partial.json.jinja` (devEngines, engines, packageManager) be included in every package.json, or only in root/standalone ones?
