---
modeline: "vim: set ft=markdown:"
title: "ADR: Flexible Plugin Composition API for ESLint Config"
adr-id: adr-20251019003
slug: plugin-composition-api
url: https://github.com/levonk/job-aide/blob/main/internal-docs/adr/adr-20251019003-plugin-composition-api.md
synopsis: Provide flexible API for composing ESLint configs with custom plugins (Drizzle, Tailwind, etc.) via options and rest parameters
author: https://github.com/levonk
date-created: 2025-10-19
date-updated: 2025-10-19
version: 1.0.0
status: "accepted"
aliases: []
tags: [doc/architecture/adr, eslint, api-design, plugin-system, composition]
supersedes: []
superseded-by: []
related-to: [adr-20251019001-explicit-file-extensions, adr-20251019002-path-alias-safety]
applies-to: [packages/active/tools/lint/eslint-config/typescript]
---

# Architecture Decision Record: Flexible Plugin Composition API for ESLint Config

- belongs in `internal-docs/architecture/adr/*.md`

---

## Context

ESLint configs need to support project-specific plugins (Drizzle ORM, Tailwind CSS, Prisma, etc.) without forcing users to fork or eject from the shared config.

**Problems with rigid configs**:
1. **No customization**: Users can't add project-specific plugins
2. **Fork required**: Must copy entire config to add one plugin
3. **Maintenance burden**: Forked configs diverge from upstream
4. **Monorepo complexity**: Different packages need different plugins
5. **Framework-specific**: Next.js, Remix, Astro need different setups

**Current state**: Many shared configs are all-or-nothing with limited customization.

## Constraints

- Must support custom ESLint plugins (Drizzle, Tailwind, Prisma, etc.)
- Must allow file-specific rules (e.g., database files only)
- Must work with ESLint flat config format
- Must maintain type safety with TypeScript
- Must not break existing usage patterns
- Must support framework-specific configs (Vue, Svelte, Next.js)

## Decision

**Provide three levels of customization**:

### Level 1: Direct Usage (Zero Config)
```ts
export { default } from "@job-aide/tools-lint-eslint-config/eslint.config.mts";
```

### Level 2: Options-Based Customization
```ts
jobAideEslintConfig({
  // Toggle features
  react: false,
  vitest: false,
  
  // Add custom plugins
  plugins: { drizzle },
  rules: {
    "drizzle/enforce-delete-with-where": "error",
  },
  
  // Override antfu base config
  antfuOptions: {
    type: "app",
    vue: true,
  },
})
```

### Level 3: Full Composition with Rest Parameters
```ts
jobAideEslintConfig(
  { plugins: { drizzle } },
  // Additional configs
  {
    files: ["src/db/**"],
    rules: { "drizzle/enforce-update-with-where": "error" },
  }
)
```

**API Signature**:
```ts
function jobAideEslintConfig(
  options?: ConfigOptions,
  ...userConfigs: Linter.Config[]
): Linter.Config[]

interface ConfigOptions {
  react?: boolean;
  vitest?: boolean;
  runtimeGuard?: boolean;
  fileExtensions?: boolean;
  plugins?: Record<string, any>;
  rules?: Linter.RulesRecord;
  antfuOptions?: OptionsConfig;
  overrides?: Linter.Config[];
}
```

## Rationale

**Why three levels**:
1. **Progressive disclosure**: Start simple, add complexity as needed
2. **Flexibility**: Supports all use cases from zero-config to advanced
3. **Type safety**: Full TypeScript support at all levels
4. **Composability**: Can combine multiple configs easily

**Why `plugins` and `rules` in options**:
- Common use case deserves first-class support
- Cleaner than always using `...userConfigs`
- Better type inference

**Why `...userConfigs` rest parameter**:
- File-specific rules are common
- Allows unlimited composition
- Matches ESLint flat config mental model

**Why `antfuOptions` passthrough**:
- Leverage antfu's framework support (Vue, Svelte, etc.)
- Don't reimplement what antfu already does well
- Allow overriding defaults (type: "lib" → "app")

**Trade-offs accepted**:
- More complex API surface
- Must document all options clearly
- Potential for misuse (conflicting configs)

## Consequences

### Positive
- **Flexibility**: Supports all customization needs
- **No forking**: Users can extend without copying
- **Type safe**: Full TypeScript support
- **Composable**: Easy to combine multiple configs
- **Framework support**: Leverage antfu for Vue, Svelte, etc.
- **Monorepo friendly**: Different packages can use different plugins

### Negative
- **Complexity**: More options to understand
- **Documentation burden**: Must explain all patterns
- **Potential conflicts**: User configs can override built-ins
- **Testing surface**: More combinations to test

### Impact Areas
- **Operations**: No impact
- **Security**: No direct impact
- **Performance**: Minimal (config composition is one-time)
- **Developer Experience**: Better customization, steeper learning curve

## Alternatives Considered

### Option A: Single options object only (no rest params)
**Pros**:
- Simpler API
- Single pattern to learn

**Cons**:
- File-specific rules awkward
- Can't easily append configs
- **Rejected**: Too limiting

### Option B: Builder pattern
```ts
config()
  .withReact()
  .withPlugin(drizzle)
  .addRules({ ... })
  .build()
```

**Pros**:
- Fluent API
- Discoverable methods

**Cons**:
- More code to maintain
- Doesn't match ESLint patterns
- **Rejected**: Over-engineered

### Option C: Multiple named exports
```ts
import { base, withReact, withDrizzle } from "...";
export default [...base, ...withReact(), ...withDrizzle()];
```

**Pros**:
- Explicit composition
- Tree-shakeable

**Cons**:
- Verbose
- Hard to type correctly
- **Rejected**: Too manual

### Option D: Config file with imports
```ts
// eslint.config.mjs
import config from "./my-eslint-config.json";
export default jobAideEslintConfig(config);
```

**Pros**:
- Separation of config and code

**Cons**:
- Can't import plugins in JSON
- Less flexible
- **Rejected**: Doesn't solve plugin problem

## Rollout / Migration

### Phase 1: Release with all three patterns (Week 1)
- Document all usage patterns
- Provide examples for common plugins
- Add comprehensive tests

### Phase 2: Gather feedback (Week 2-4)
- Monitor usage patterns
- Identify pain points
- Collect feature requests

### Phase 3: Iterate on API (Month 2)
- Add convenience helpers if needed
- Improve error messages
- Add more examples

### Rollback Plan
- Can deprecate features without breaking changes
- Options are optional, so can be ignored
- Worst case: users can use Level 1 (direct usage)

## To Investigate

- [ ] Performance impact of many configs
- [ ] Best practices for plugin ordering
- [ ] Conflict detection between user configs
- [ ] Helper functions for common patterns
- [ ] Auto-detection of installed plugins

## Notes

- This is an API design decision, not a runtime change
- All three levels produce the same ESLint config array
- Users can mix patterns (options + rest params)
- Type safety maintained throughout

## References

- [API-REFERENCE.md](../../packages/active/tools/lint/eslint-config/typescript/docs/API-REFERENCE.md)
- [USAGE-EXAMPLES.md](../../packages/active/tools/lint/eslint-config/typescript/docs/USAGE-EXAMPLES.md)
- [ESLint Flat Config](https://eslint.org/docs/latest/use/configure/configuration-files-new)
- [@antfu/eslint-config](https://github.com/antfu/eslint-config)
- [Implementation](../../packages/active/tools/lint/eslint-config/typescript/src/index.mts)

<!-- vim: set ft=markdown: -->
