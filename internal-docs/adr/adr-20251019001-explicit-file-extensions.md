---
modeline: "vim: set ft=markdown:"
title: "ADR: Explicit File Extensions for TypeScript Modules"
adr-id: adr-20251019001
slug: explicit-file-extensions-typescript
url: https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019001-explicit-file-extensions.md
synopsis: Enforce explicit module system file extensions (.mts, .cts, .tsx) instead of ambiguous .ts/.js extensions
author: https://github.com/levonk
date-created: 2025-10-19
date-updated: 2025-10-19
version: 1.0.0
status: "accepted"
aliases: []
tags: [doc/architecture/adr, typescript, eslint, modules, file-extensions]
supersedes: []
superseded-by: []
related-to: [adr-20251019002-path-alias-safety, adr-20251019003-plugin-composition]
applies-to: [packages/active/tools/lint/eslint-config/typescript]
---

# Architecture Decision Record: Explicit File Extensions for TypeScript Modules

- belongs in `internal-docs/architecture/adr/*.md`

---

## Context

TypeScript and JavaScript files can use various extensions (`.ts`, `.js`, `.mts`, `.mjs`, `.cts`, `.cjs`), but `.ts` and `.js` are ambiguous because their module system (ESM vs CommonJS) depends on the `package.json` `type` field.

**Problems with ambiguous extensions**:
1. **Unclear module system**: Is `utils.ts` ESM or CommonJS? Must check `package.json`
2. **Tooling confusion**: Some tools don't respect `package.json` `type`
3. **Mixed module systems**: Can't mix ESM and CommonJS in same package
4. **Import errors**: Accidentally using `require()` in ESM or `import` in CommonJS
5. **Monorepo complexity**: Different packages may have different `type` settings

**Current state**: Most TypeScript projects use `.ts` files, relying on `package.json` `type` field.

## Constraints

- Must work with existing TypeScript tooling (tsc, bundlers, IDEs)
- Must support both ESM and CommonJS when needed
- Must be enforceable via ESLint
- Must not break existing build pipelines
- Must work in monorepos with mixed module systems

## Decision

**Enforce explicit file extensions that indicate module system**:
- `.mts` for TypeScript ESM modules
- `.cts` for TypeScript CommonJS modules  
- `.tsx` for React components (always ESM)
- `.mjs` for JavaScript ESM modules
- `.cjs` for JavaScript CommonJS modules
- `.d.ts` for type declarations (standard)

**Ban ambiguous extensions**:
- `.ts` files (except `.d.ts`, `.config.ts`, `.test.ts`)
- `.js` files (except `.config.js`)

**Implemented via ESLint rules** in `@job-aide/tools-lint-eslint-config`:
- `job-aide/ban-ambiguous-ts` - Flags `.ts` files
- `job-aide/ban-ambiguous-js` - Flags `.js` files
- `job-aide/mts-must-be-esm` - Enforces ESM syntax in `.mts`
- `job-aide/cts-must-be-commonjs` - Enforces CommonJS syntax in `.cts`
- `react/jsx-filename-extension` - Requires `.tsx` for JSX

## Rationale

**Why explicit extensions**:
1. **Self-documenting**: File extension immediately shows module system
2. **Tool-agnostic**: Works regardless of `package.json` settings
3. **Mix module systems**: Can have both ESM and CommonJS in same package
4. **Prevent errors**: ESLint catches module system mismatches
5. **Future-proof**: Aligns with Node.js ESM best practices

**Why not rely on `package.json` `type`**:
- Global setting affects all files
- Can't mix ESM and CommonJS
- Some tools ignore it
- Requires checking external file to understand module system

**Trade-offs accepted**:
- Migration effort for existing `.ts` files
- Slightly longer file extensions
- Must update imports when renaming files

## Consequences

### Positive
- **Clarity**: Module system obvious at a glance
- **Safety**: ESLint prevents module system mismatches
- **Flexibility**: Can mix ESM and CommonJS when needed
- **Better errors**: Clear error messages about module system
- **Tooling**: IDEs provide better autocomplete and validation

### Negative
- **Migration cost**: Existing projects must rename files
- **Learning curve**: Developers must understand extension meanings
- **Verbosity**: `.mts` vs `.ts` is longer
- **Ecosystem**: Some tools may not fully support `.mts`/`.cts` yet

### Impact Areas
- **Operations**: Build scripts may need updates
- **Security**: No direct impact
- **Performance**: No runtime impact
- **Developer Experience**: Initial friction, long-term clarity

## Alternatives Considered

### Option A: Keep using `.ts` with `package.json` `type`
**Pros**:
- No migration needed
- Shorter file extensions
- Standard practice

**Cons**:
- Ambiguous module system
- Can't mix ESM and CommonJS
- Tooling inconsistencies
- **Rejected**: Ambiguity causes too many issues

### Option B: Use `.mts` only for ESM, keep `.ts` for CommonJS
**Pros**:
- Smaller migration (only ESM files)
- `.ts` remains default

**Cons**:
- Still ambiguous (is `.ts` CommonJS or just old?)
- Inconsistent pattern
- **Rejected**: Half-measure doesn't solve core problem

### Option C: Use tilde prefix (`~`) instead of extensions
**Pros**:
- No file renaming needed
- Works with path aliases

**Cons**:
- Non-standard
- Doesn't solve module system ambiguity
- **Rejected**: Doesn't address root cause

## Rollout / Migration

### Phase 1: Enable rules with warnings (Week 1)
```ts
{
  fileExtensions: true, // Default
  rules: {
    "job-aide/ban-ambiguous-ts": "warn", // Start with warnings
  }
}
```

### Phase 2: Automated migration (Week 2-3)
```bash
# Rename .ts to .mts
find src -name "*.ts" ! -name "*.d.ts" ! -name "*.config.ts" \
  -exec sh -c 'mv "$1" "${1%.ts}.mts"' _ {} \;

# Rename .test.ts to .test.mts
find src -name "*.test.ts" \
  -exec sh -c 'mv "$1" "${1%.test.ts}.test.mts"' _ {} \;
```

### Phase 3: Upgrade to errors (Week 4)
```ts
{
  rules: {
    "job-aide/ban-ambiguous-ts": "error", // Enforce
  }
}
```

### Rollback Plan
- Disable `fileExtensions: false` in config
- Revert file renames via git
- No breaking changes to runtime behavior

## To Investigate

- [ ] Full compatibility with all bundlers (Vite, Webpack, esbuild, Rollup)
- [ ] IDE support across VS Code, WebStorm, Vim
- [ ] Impact on source maps and debugging
- [ ] Performance impact of longer file paths
- [ ] Compatibility with Jest/Vitest test runners

## Notes

- TypeScript natively supports `.mts`/`.cts` since v4.7
- Node.js has supported `.mjs`/`.cjs` since v12
- This is a linting/convention decision, not a runtime requirement
- Config files (`.config.ts`) are exempted for tool compatibility

## References

- [TypeScript Module Resolution](https://www.typescriptlang.org/docs/handbook/module-resolution.html)
- [Node.js ESM Documentation](https://nodejs.org/api/esm.html)
- [FILE-EXTENSION-RULES.md](../../packages/active/tools/lint/eslint-config/typescript/docs/FILE-EXTENSION-RULES.md)
- [ESLint Config Implementation](../../packages/active/tools/lint/eslint-config/typescript/src/configs/file-extensions.mts)

<!-- vim: set ft=markdown: -->
