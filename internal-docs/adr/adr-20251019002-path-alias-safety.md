---
modeline: "vim: set ft=markdown:"
title: "ADR: Ban Ambiguous @ Path Alias"
adr-id: adr-20251019002
slug: path-alias-safety
url: https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019002-path-alias-safety.md
synopsis: Ban ambiguous @/* path alias in favor of explicit aliases like @/core/*, @/features/* to prevent conflicts with npm scoped packages
author: https://github.com/levonk
date-created: 2025-10-19
date-updated: 2025-10-19
version: 1.0.0
status: "accepted"
aliases: []
tags: [doc/architecture/adr, typescript, eslint, imports, path-aliases]
supersedes: []
superseded-by: []
related-to: [adr-20251019001-explicit-file-extensions, adr-20251019003-plugin-composition]
applies-to: [packages/active/tools/lint/eslint-config/typescript]
---

# Architecture Decision Record: Ban Ambiguous @ Path Alias

- belongs in `internal-docs/architecture/adr/*.md`

---

## Context

TypeScript path aliases allow importing with shortcuts like `@/utils` instead of `../../../utils`. The common pattern is using `@/*` as a catch-all alias, but this creates ambiguity and conflicts.

**Problems with `@/*` alias**:
1. **Conflicts with npm scoped packages**: `@company/package` vs `@/utils` - which is which?
2. **Import confusion**: Is `import { api } from "@/lib/api"` a local file or npm package?
3. **Tooling issues**: IDEs and bundlers struggle to differentiate
4. **Monorepo problems**: Unclear if importing from workspace package or local file
5. **Maintenance**: Hard to refactor when alias meaning is unclear

**Current state**: Many projects use `"@/*": ["./src/*"]` in `tsconfig.json`.

## Constraints

- Must work with existing TypeScript path resolution
- Must be enforceable via ESLint
- Must not break existing build tools (Vite, Webpack, etc.)
- Must support monorepo workspace packages
- Must allow actual npm scoped packages (`@radix-ui/*`, `@trpc/*`, etc.)

## Decision

**Ban ambiguous path aliases**:
- ❌ `@` (bare `@`)
- ❌ `@/*` (too generic)

**Require explicit category-based aliases**:
- ✅ `@/core/*` - Core application code
- ✅ `@/features/*` - Feature modules
- ✅ `@/components/*` - UI components
- ✅ `@/utils/*` - Utility functions
- ✅ `@/lib/*` - Library code
- ✅ `@/types/*` - Type definitions

**Or project-specific prefix**:
- ✅ `@/job-aide/*` - Project-scoped alias
- ✅ `@/app/*` - Application-specific alias

**Implemented via ESLint**:
```ts
"no-restricted-imports": [
  "error",
  {
    patterns: [
      {
        group: ["@", "@/*"],
        message: "Don't use ambiguous '@' or '@/*' path alias..."
      }
    ]
  }
]
```

## Rationale

**Why explicit aliases**:
1. **Clear intent**: `@/components/button` is obviously a component
2. **No conflicts**: Never confused with `@radix-ui/button`
3. **Better tooling**: IDEs can provide better autocomplete
4. **Monorepo safe**: Clear distinction between workspace packages and local files
5. **Maintainable**: Easier to refactor and reorganize code

**Why not allow `@/*`**:
- Too ambiguous in monorepos with actual `@scope/package` dependencies
- Unclear what `@` represents (project? app? workspace?)
- Causes real-world import confusion

**Trade-offs accepted**:
- Slightly more verbose `tsconfig.json` paths configuration
- Must choose appropriate categories upfront
- Migration effort for existing `@/*` usage

## Consequences

### Positive
- **Clarity**: Import source immediately obvious
- **No conflicts**: Never confused with scoped packages
- **Better tooling**: IDEs handle correctly
- **Monorepo safe**: Clear workspace vs local distinction
- **Maintainable**: Easy to refactor by category

### Negative
- **Migration cost**: Update `tsconfig.json` and all imports
- **Configuration**: More path aliases to configure
- **Learning curve**: Team must understand category system
- **Verbosity**: `@/components/*` vs `@/*` is longer

### Impact Areas
- **Operations**: Build configs need path alias updates
- **Security**: No direct impact
- **Performance**: No runtime impact
- **Developer Experience**: Initial friction, long-term clarity

## Alternatives Considered

### Option A: Allow `@/*` with naming convention
**Pros**:
- No migration needed
- Simpler configuration

**Cons**:
- Doesn't solve ambiguity
- Relies on discipline, not enforcement
- **Rejected**: Ambiguity remains

### Option B: Use tilde `~/*` instead of `@/*`
**Pros**:
- No conflict with scoped packages
- Single character prefix

**Cons**:
- Still too generic
- Doesn't indicate category
- **Rejected**: Doesn't provide enough clarity

### Option C: Use relative imports only
**Pros**:
- No configuration needed
- Explicit file relationships

**Cons**:
- Verbose: `../../../../utils/api`
- Hard to refactor
- **Rejected**: Too cumbersome for large projects

### Option D: Project-specific prefix only (`@/job-aide/*`)
**Pros**:
- Clear project scope
- Single alias to configure

**Cons**:
- Doesn't categorize imports
- Still somewhat ambiguous
- **Considered**: Valid alternative, but less organized

## Rollout / Migration

### Phase 1: Update `tsconfig.json` (Day 1)
```json
{
  "compilerOptions": {
    "paths": {
      // Remove
      // "@/*": ["./src/*"]
      
      // Add
      "@/core/*": ["./src/core/*"],
      "@/features/*": ["./src/features/*"],
      "@/components/*": ["./src/components/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"]
    }
  }
}
```

### Phase 2: Update build tool configs (Day 1)
```ts
// vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      "@/core": path.resolve(__dirname, "./src/core"),
      "@/features": path.resolve(__dirname, "./src/features"),
      "@/components": path.resolve(__dirname, "./src/components"),
      "@/utils": path.resolve(__dirname, "./src/utils"),
    },
  },
});
```

### Phase 3: Migrate imports (Week 1-2)
```bash
# Find all @/* imports
rg "from ['\"]@/" --type ts

# Update manually or use codemod
# Example: @/components/button → already correct
# Example: @/api → @/lib/api or @/core/api
```

### Phase 4: Enable ESLint rule (Week 2)
```ts
// Start with warning
rules: {
  "no-restricted-imports": "warn"
}

// Upgrade to error after migration
rules: {
  "no-restricted-imports": "error"
}
```

### Rollback Plan
- Revert `tsconfig.json` changes
- Disable ESLint rule
- Revert import updates via git
- No runtime impact

## To Investigate

- [ ] Automated codemod for import migration
- [ ] IDE plugin for auto-categorizing imports
- [ ] Impact on bundle size with longer import paths
- [ ] Compatibility with all bundlers
- [ ] Best practices for monorepo workspace vs local aliases

## Notes

- This is a linting/convention decision, not a runtime requirement
- Actual npm scoped packages (`@radix-ui/*`) are still allowed
- Can combine with workspace packages: `@job-aide/core` (workspace) vs `@/app/*` (local)
- Categories can be customized per project

## References

- [TypeScript Module Resolution](https://www.typescriptlang.org/docs/handbook/module-resolution.html)
- [Vite Path Aliases](https://vitejs.dev/config/shared-options.html#resolve-alias)
- [PATH-ALIAS-RULES.md](../../packages/active/tools/lint/eslint-config/typescript/docs/PATH-ALIAS-RULES.md)
- [ESLint no-restricted-imports](https://eslint.org/docs/latest/rules/no-restricted-imports)
- [Code Quality Config](../../packages/active/tools/lint/eslint-config/typescript/src/configs/code-quality.mts)

<!-- vim: set ft=markdown: -->
