---
modeline: "vim: set ft=markdown:"
title: "ADR: Use tsup for TypeScript Library Package Builds"
adr-id: 20260802001
slug: 20260802001-tsup-for-library-package-builds
url: /internal-docs/adr/adr-20260802001-tsup-for-library-package-builds.md
synopsis: Adopt tsup as the standard build tool for TypeScript library package templates, replacing tsc-based @nx/js:build for the build target. tsc --noEmit remains the typecheck target. tsup wraps esbuild for speed and generates .d.ts via tsc under the hood, producing ESM+CJS multi-format output with tree-shaking in one step.
author: https://github.com/levonk
date-created: 2026-08-02
date-updated: 2026-08-02
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "typescript", "build-tool", "tsup", "esbuild", "library", "boilerplate"]
supersedes: []
superseded-by: []
related-to: ["adr-20260419001-nx-monorepo-build-tool", "adr-20251106002-vitest-for-testing"]
---

## Context

The TypeScript library package templates in this boilerplate currently use
`tsc -p tsconfig.json` (via `@nx/js:build`) as their `build` target. This
produces one transpiled file per source file with no tree-shaking, no
minification, no multi-format output (ESM/CJS), and no bundling. Libraries
built this way ship larger artifacts and require consumers to re-bundle.

The affected templates are:

- `packages/category/general/domain/package-name/typescript/`
- `packages/category/web/domain/package-name/typescript/`

Both currently have:
- `package.json`: `"build": "tsc -p tsconfig.json"`
- `project.json`: `"build": { "executor": "@nx/js:build", ... }`
- `exports` map pointing to `dist/index.mjs` (ESM only, no CJS)

The VSCode extension template (`apps/plugins/vscode/typescript/`) already
uses tsup successfully. The CLI template (`apps/cli/typescript/`) uses
`@nx/esbuild:esbuild` — a fast bundler, but without `.d.ts` generation.

## Constraints

- The build tool must produce both ESM and CJS output for library
  compatibility with both modern and legacy consumers.
- The build tool must generate `.d.ts` declaration files so consumers get
  type safety.
- The `typecheck` target (`tsc --noEmit`) must remain unchanged — no
  bundler performs type-checking.
- The change must go through the shared partials system
  (`_shared/partials/nx-partials/`) per the AGENTS.md rule: "To change a
  language's targets across all templates, edit the partial."
- The `exports` map in `package.json` must be updated to include both ESM
  and CJS entry points plus the types entry.

## Decision

Adopt **tsup** as the standard build tool for TypeScript library package
templates. tsup wraps esbuild for transpilation speed and adds `.d.ts`
generation via tsc under the hood — one tool, one config, multi-format
output.

### Changes

1. **New partial**: `_shared/partials/nx-partials/nx-target-nodejs-bundle.jinja`
   — defines the tsup-based `build` target for Nx library projects.
2. **`project.json.jinja`** (both library templates): replace the inline
   `@nx/js:build` build target with an include of the new partial.
3. **`package.json`** (both library templates):
   - Change `"build"` script from `"tsc -p tsconfig.json"` to `"tsup"`
   - Add `"tsup"` to `devDependencies`
   - Update `exports` map to include CJS entry (`dist/index.cjs`)
   - Add `tsup.config.ts` to the template files
4. **`typecheck` target**: unchanged — stays as `tsc --noEmit`.

### Build target (new partial)

```jinja
    "build": {
      "executor": "nx:run-commands",
      "options": {
        "command": "tsup",
        "cwd": "{projectRoot}"
      },
      "dependsOn": ["^build"],
      "cache": true
    },
```

### tsup.config.ts

```typescript
import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/index.ts'],
  format: ['esm', 'cjs'],
  dts: true,
  clean: true,
  sourcemap: true,
  treeshake: true,
})
```

### Updated exports map

```json
"exports": {
  ".": {
    "types": "./dist/index.d.mts",
    "import": "./dist/index.mjs",
    "require": "./dist/index.cjs",
    "default": "./dist/index.mjs"
  }
}
```

## Rationale

- **Speed**: tsup uses esbuild for transpilation — significantly faster than
  tsc for emit. Declaration generation uses tsc but only for `.d.ts` files.
- **Multi-format**: One command produces ESM (`.mjs`) and CJS (`.cjs`)
  output, supporting both modern and legacy consumers.
- **Tree-shaking**: esbuild bundles and tree-shakes, producing smaller
  artifacts than tsc's one-file-per-source output.
- **`.d.ts` in one step**: tsup generates declaration files via tsc under
  the hood — no separate `tsc --declaration` pass needed.
- **Proven in this boilerplate**: The VSCode extension template already
  uses tsup successfully.
- **Consistency with knowledge bundle**: The
  `typescript-monorepo-best-practices/build-tool-selection.md` concept page
  documents tsup as the canonical library bundler choice.

## Consequences

- **Positive**:
  - Library packages ship smaller, tree-shaken artifacts.
  - Both ESM and CJS consumers are supported from a single build.
  - Build speed improves (esbuild vs tsc for emit).
  - One config file (`tsup.config.ts`) replaces scattered tsc emit options.
  - Consistent with the VSCode extension template's existing tsup usage.

- **Negative**:
  - Adds `tsup` as a devDependency to every library package.
  - Adds a `tsup.config.ts` file to each library package.
  - Bundled output means errors in published code point to bundled lines,
    not source — sourcemaps mitigate this but add build output size.

## Alternatives Considered

- **Keep `tsc` / `@nx/js:build`**: No new dependency, but produces
  one-file-per-source output with no tree-shaking, no minification, and
  ESM-only. Consumers must re-bundle. Rejected — the output quality is
  inferior for published libraries.

- **esbuild directly (`@nx/esbuild:esbuild`)**: Fast, but does not generate
  `.d.ts` files — requires a separate `tsc --declaration` pass, meaning two
  build steps and two config files. Rejected for libraries — tsup wraps
  esbuild and adds `.d.ts` in one step. (Still valid for CLIs where `.d.ts`
  is not needed — the CLI template keeps `@nx/esbuild:esbuild`.)

- **Rolldown**: Full Rust-based bundler with Rollup plugin compatibility.
  Excellent for applications and CLIs, but overkill for simple library
  publishing where tsup's zero-config `.d.ts` generation is sufficient.
  Rejected for library templates — Rolldown is the choice for
  application/CLI templates (see
  `typescript-monorepo-best-practices/build-tool-selection.md`).

- **Rollup**: Mature and correct, but 10-30x slower than Rolldown/esbuild
  on large projects and requires more configuration. Rejected — tsup
  provides the same library output quality with less config and faster
  builds.

## Rollout / Migration

1. Create `_shared/partials/nx-partials/nx-target-nodejs-bundle.jinja`
   with the tsup build target definition.
2. Update `packages/category/general/domain/package-name/typescript/files/project.json.jinja`
   to include the new partial instead of the inline `@nx/js:build` target.
3. Update `packages/category/web/domain/package-name/typescript/files/project.json.jinja`
   similarly.
4. Update both templates' `package.json` files:
   - Change `build` script to `tsup`
   - Add `tsup` to devDependencies
   - Update `exports` map with CJS entry
5. Add `tsup.config.ts` to both templates' `files/` directories.
6. Existing materialized projects update via
   `copier-wrapper.sh update --vcs-ref=HEAD`.

## To Investigate

- Evaluate tsup's `--watch` mode for development-time rebuilds.
- Consider whether the CLI template (`apps/cli/typescript/`) should
  migrate from `@nx/esbuild:esbuild` to tsup for `.d.ts` support, or to
  Rolldown for plugin compatibility.

## References

- [tsup documentation](https://tsup.egoist.dev/)
- [esbuild](https://esbuild.github.io/)
- [Build Tool Selection knowledge bundle concept](https://github.com/levonk/skills-releases/blob/main/knowledge/typescript-monorepo-best-practices/build-tool-selection.md)
- [ADR-20260419001: Nx Monorepo Build Tool](./adr-20260419001-nx-monorepo-build-tool.md)

<!-- vim: set ft=markdown: -->
