# TypeScript Rules Update

## Content to Add to `.windsurf/rules/typescript-rules.md`

Add the following sections to the typescript rules file:

```markdown
## File Extensions

- **MUST** use explicit file extensions that indicate module system:
  - `.mts` for TypeScript ESM modules
  - `.cts` for TypeScript CommonJS modules
  - `.tsx` for React components (always ESM)
  - `.mjs` for JavaScript ESM modules
  - `.cjs` for JavaScript CommonJS modules
  - `.d.ts` for type declarations (standard)

- **MUST NOT** use ambiguous extensions:
  - ❌ `.ts` files (except `.d.ts`, `.config.ts`, `.test.ts`)
  - ❌ `.js` files (except `.config.js`)

- **Rationale**: File extension immediately shows module system, prevents tooling confusion, allows mixing ESM and CommonJS in same package

- **See**: [ADR-20251019001](../internal-docs/adr/adr-20251019001-explicit-file-extensions.md)

## Path Aliases

- **MUST NOT** use ambiguous `@` or `@/*` path aliases
  - ❌ `"@/*": ["./src/*"]` - Too ambiguous, conflicts with npm scoped packages

- **MUST** use explicit category-based aliases:
  - ✅ `"@/core/*": ["./src/core/*"]`
  - ✅ `"@/features/*": ["./src/features/*"]`
  - ✅ `"@/components/*": ["./src/components/*"]`
  - ✅ `"@/utils/*": ["./src/utils/*"]`
  - ✅ `"@/lib/*": ["./src/lib/*"]`
  - ✅ `"@/types/*": ["./src/types/*"]`

- **OR** use project-specific prefix:
  - ✅ `"@/job-aide/*": ["./src/*"]`
  - ✅ `"@/app/*": ["./src/*"]`

- **Rationale**: Prevents conflicts with npm scoped packages (`@radix-ui/*`), provides clear intent, better tooling support

- **See**: [ADR-20251019002](../internal-docs/adr/adr-20251019002-path-alias-safety.md)

## ESLint Configuration

- **MUST** use `@job-aide/tools-lint-eslint-config` for all TypeScript projects

- **Three usage patterns** (choose based on needs):

  1. **Direct usage** (zero config):
     ```ts
     export { default } from "@job-aide/tools-lint-eslint-config/eslint.config.mts";
     ```

  2. **With options** (toggle features, add plugins):
     ```ts
     import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";
     import drizzle from "eslint-plugin-drizzle";
     
     export default jobAideEslintConfig({
       plugins: { drizzle },
       rules: {
         "drizzle/enforce-delete-with-where": "error",
       },
     });
     ```

  3. **Full composition** (file-specific rules):
     ```ts
     export default jobAideEslintConfig(
       { plugins: { drizzle } },
       {
         files: ["src/db/**"],
         rules: { "drizzle/enforce-update-with-where": "error" },
       }
     );
     ```

- **See**: [ADR-20251019003](../internal-docs/adr/adr-20251019003-plugin-composition-api.md)

## Code Style

- **MUST** use double quotes (`"`) not single quotes (`'`)
- **MUST** use 2-space indentation
- **MUST** use semicolons
- **MUST** use kebab-case for filenames (except `README.md`, `LICENSE`, etc.)
- **MUST** prefer `type` over `interface` for type definitions
- **MUST** use `import type` for type-only imports

## Module System

- **PREFER** ESM over CommonJS
- **MUST NOT** use `require()` in `.mts` files
- **MUST NOT** use `import` in `.cts` files
- **MUST NOT** access `process.env` directly (use config abstraction)
  - Current: `warn` (migration in progress)
  - Future: `error` after config abstraction implemented

## Testing

- **MUST** use `.test.mts` extension for test files (not `.test.ts`)
- **MUST** use Vitest for testing (configured in ESLint config)
- **MUST** include tests for all new features

## Documentation

- Every package **MUST** have:
  - `README.md` - Usage and examples
  - `docs/` directory - Detailed documentation
  - `internal-docs/` - ADRs, architecture decisions
  - Inline JSDoc comments for public APIs

## References

- [File Extension Rules](../packages/active/tools/lint/eslint-config/typescript/docs/FILE-EXTENSION-RULES.md)
- [Path Alias Rules](../packages/active/tools/lint/eslint-config/typescript/docs/PATH-ALIAS-RULES.md)
- [API Reference](../packages/active/tools/lint/eslint-config/typescript/docs/API-REFERENCE.md)
- [Usage Examples](../packages/active/tools/lint/eslint-config/typescript/docs/USAGE-EXAMPLES.md)
```

## Manual Steps Required

Since `.windsurf/rules/typescript-rules.md` cannot be edited programmatically, please manually add the above content to the file.

The file is located at:
```
/home/micro/p/gh/lrepo52/job-aide/.windsurf/rules/typescript-rules.md
```
