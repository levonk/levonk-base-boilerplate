# Boilerplate ESLint Configuration Update

All boilerplate projects have been updated to use the new `@job-aide/tools-lint-eslint-config`.

## Changes Made

### 1. VSCode Extension Boilerplate
**Location**: `boilerplate/apps/plugins/vscode/typescript/`

- ✅ Removed `.eslintrc.json`
- ✅ Created `eslint.config.mjs` (direct usage pattern)
- ✅ Updated `package.json`:
  - Changed `lint` script from `eslint src --ext ts` to `eslint .`
  - Added `lint:fix` script
  - Replaced `@typescript-eslint/eslint-plugin` and `@vitest/eslint-plugin` with `@job-aide/tools-lint-eslint-config`

### 2. Next.js App Boilerplate
**Location**: `boilerplate/apps/web/typescript/nextjs/`

- ✅ Removed `.eslintrc.js`
- ✅ Created `eslint.config.mjs` with Next.js-specific config
- ✅ Updated `package.json.tmpl`:
  - Changed `lint` script from `next lint` to `eslint .`
  - Added `lint:fix` script
  - Replaced ESLint plugins with `@job-aide/tools-lint-eslint-config`
  - Removed `eslint-config-next` dependency

**Config**:
```ts
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";

export default jobAideEslintConfig({
  antfuOptions: {
    type: "app",
    nextjs: true,
  },
});
```

### 3. MCP Server Boilerplate
**Location**: `boilerplate/apps/plugins/mcp/mcp-server/`

- ✅ Created `eslint.config.mjs` with Node.js-specific config
- ✅ Updated `package.json`:
  - Added `lint` and `lint:fix` scripts
  - Added `test` and `test:watch` scripts
  - Replaced ESLint plugins with `@job-aide/tools-lint-eslint-config`

**Config**:
```ts
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";

export default jobAideEslintConfig({
  react: false, // MCP servers don't use React
  antfuOptions: {
    type: "app",
  },
});
```

### 4. Package Boilerplate Template
**Location**: `boilerplate/packages/category/web/domain/package-name/typescript/`

- ✅ Created `eslint.config.mjs.tmpl` (direct usage pattern)
- ✅ Updated `package.json.tmpl`:
  - Added `lint:fix` script
  - Replaced all ESLint plugins with `@job-aide/tools-lint-eslint-config`

## Compliance with New Rules

All boilerplate configs now enforce:

### ✅ File Extension Rules
- Ban ambiguous `.ts` and `.js` files
- Require `.mts` for ESM modules
- Require `.cts` for CommonJS modules
- Require `.tsx` for React components

### ✅ Path Alias Rules
- Ban `@` and `@/*` path aliases
- Require explicit aliases like `@/core/*`, `@/features/*`

### ✅ Code Style
- Double quotes
- 2-space indentation
- Semicolons required
- kebab-case filenames
- Prefer `type` over `interface`

### ✅ Module System
- Prefer ESM over CommonJS
- Enforce ESM syntax in `.mts` files
- Enforce CommonJS syntax in `.cts` files

## Usage in New Projects

When creating a new project from boilerplate using `copier`:

1. The ESLint config will be automatically included
2. Run `pnpm install` to install `@job-aide/tools-lint-eslint-config`
3. Run `pnpm lint` to check for issues
4. Run `pnpm lint:fix` to auto-fix issues

## Customization Examples

Projects can customize the config by modifying `eslint.config.mjs`:

**Add Drizzle ORM rules**:
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

**Add file-specific rules**:
```ts
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";

export default jobAideEslintConfig(
  {},
  {
    files: ["src/db/**"],
    rules: { /* database-specific rules */ },
  }
);
```

## Template Variables

Template files (`.tmpl`) contain placeholders that are replaced by copier:
- `{{ plugin_name }}` - Plugin name
- `{{ package_name }}` - Package name
- `{{ category }}` - Package category
- `{{ domain }}` - Package domain
- `{{ description }}` - Description

These placeholders cause lint warnings in the template files themselves, but will be resolved when the template is instantiated.

## References

- [ESLint Config README](../packages/active/tools/lint/eslint-config/typescript/README.md)
- [API Reference](../packages/active/tools/lint/eslint-config/typescript/docs/API-REFERENCE.md)
- [Usage Examples](../packages/active/tools/lint/eslint-config/typescript/docs/USAGE-EXAMPLES.md)
- [File Extension Rules](../packages/active/tools/lint/eslint-config/typescript/docs/FILE-EXTENSION-RULES.md)
- [Path Alias Rules](../packages/active/tools/lint/eslint-config/typescript/docs/PATH-ALIAS-RULES.md)
- [ADR-20251019001](../internal-docs/adr/adr-20251019001-explicit-file-extensions.md)
- [ADR-20251019002](../internal-docs/adr/adr-20251019002-path-alias-safety.md)
- [ADR-20251019003](../internal-docs/adr/adr-20251019003-plugin-composition-api.md)
