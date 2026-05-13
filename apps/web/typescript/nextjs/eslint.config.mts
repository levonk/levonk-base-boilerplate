/**
 * ESLint Configuration for Next.js Application
 *
 * Uses @job-aide/tools-lint-eslint-config with Next.js-specific settings
 *
 * Path alias strategy:
 * - Aliases are defined in tsconfig `compilerOptions.paths` (scoped: `@/app/*`, `@/components/*`, `@/lib/*`, `@/utils/*`, `@/types/*`).
 * - Avoid ambiguous `@/*` per repo rules; tests mirror aliases in `vitest.config.mts` resolve.alias.
 * - If adding new categories, update both tsconfig and Vitest alias mapping.
 */
import jobAideEslintConfig from "@job-aide/tools-lint-eslint-config";

export default jobAideEslintConfig({
  antfuOptions: {
    type: "app",
    nextjs: true,
  },
});
