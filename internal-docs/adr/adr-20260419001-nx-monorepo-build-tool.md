---
modeline: "vim: set ft=markdown:"
title: "ADR: Use NX for Monorepo Build Orchestration"
adr-id: "adr-20260419001"
slug: "20260419001-nx-monorepo-build-tool"
url: "/internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md"
synopsis: "Adopt NX as the unified monorepo build orchestration and caching system to enable polyglot build management across JavaScript, Docker, Python, Rust, and other technologies."
author: "https://github.com/levonk"
date-created: "2026-04-19"
date-updated: "2026-04-19"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "nx", "monorepo", "build-system", "polyglot", "caching"]
supersedes: ["adr-20251106001-pnpm-and-turborepo"]
superseded-by: []
related-to: ["adr-20260131001-standard-developer-ux-flow", "adr-20251106010-artifact-caching", "adr-20251106014-cicd-strategy"]
scope:
  impact-scope: ["all applications", "all packages", "ci/cd pipelines", "developer workflow"]
  excluded-scope: []
---

# Architecture Decision Record: Use NX for Monorepo Build Orchestration

- belongs in `internal-docs/adr/adr-20260419001-nx-monorepo-build-tool.md`

---

## Context

The monorepo has grown to include multiple technology stacks beyond TypeScript/JavaScript:

- **TypeScript/JavaScript**: Next.js applications and shared packages
- **Docker**: Containerized services (LocalNet, infrastructure components)
- **Python**: Backend services and tooling
- **Rust**: CLI tools and performance-critical components

The current build orchestration uses **Turborepo** (ADR 20251106001), which excels at JavaScript monorepos but has significant limitations:

- **No native Docker support**: Cannot cache or orchestrate Docker builds
- **No polyglot caching**: Build artifact caching limited to JavaScript outputs
- **Requires separate tools**: Nexus for Docker caching, Verdaccio for npm caching
- **Fragmented workflow**: Different build systems for different technologies

As the monorepo expands into true polyglot territory, we need a unified build system that can handle all technologies with consistent caching, task orchestration, and developer experience.

## Constraints

- Must support JavaScript/TypeScript (Next.js, Node.js) with first-class integration
- Must support Docker build caching and orchestration
- Must support Python builds and caching
- Must support Rust/Cargo builds and caching
- Must provide computation caching across all technologies
- Must integrate with pnpm workspaces (existing package management)
- Must maintain or improve current CI/CD performance
- Must not require major restructuring of existing projects

## Decision

We will adopt **NX** as the unified monorepo build orchestration and caching system for all technologies in the monorepo.

**Key components:**

1. **NX Core**: Task scheduling, computation hashing, and caching infrastructure
2. **@nx/js**: First-class JavaScript/TypeScript support (replaces Turborepo)
3. **@nx/next**: Next.js application plugin
4. **@nx/docker**: Docker build and caching support
5. **nx-plugins community**: Python and Rust plugins for polyglot support

**pnpm remains the package manager** — NX integrates seamlessly with pnpm workspaces.

## Rationale

### Why NX Over Turborepo

| Capability | Turborepo | NX |
|------------|-----------|-----|
| JavaScript caching | ✅ | ✅ |
| Docker builds | ❌ | ✅ |
| Python builds | ❌ | ✅ |
| Rust builds | ❌ | ✅ |
| Computation caching | ✅ | ✅ (more granular) |
| Remote caching | Vercel | Nx Cloud / self-hosted |
| Plugin ecosystem | Limited | Extensive |
| Graph visualization | Basic | Advanced |
| Code generation | ❌ | ✅ (generators) |

### Specific Advantages

- **Polyglot by design**: NX's plugin architecture supports any technology. Docker, Python, and Rust builds are first-class citizens, not afterthoughts.

- **Unified caching**: Single computation cache for all builds. Docker layer caching, Python wheel caching, and JS build caching use the same infrastructure.

- **Consistent developer experience**: Same `nx build`, `nx test`, `nx lint` commands work across all project types. Developers don't need to learn different tools for different parts of the monorepo.

- **Atomic task graph**: Cross-technology dependencies are properly modeled. A Docker service can depend on a TypeScript package build, and NX will orchestrate them correctly.

- **Reduced infrastructure**: Consolidates Verdaccio (npm) + Nexus (Docker) + Turborepo into a single caching layer. Can use Nx Cloud or self-hosted cache.

- **Future-proof**: As we add Go, Java, or other technologies, NX plugins will handle them without architectural changes.

### Trade-offs Accepted

- **Learning curve**: NX is more complex than Turborepo. The `project.json` or `nx` key in `package.json` configuration requires understanding.

- **Configuration overhead**: More configuration required per project compared to Turborepo's minimal setup.

- **Migration effort**: Existing projects need `project.json` files or `nx` configuration added.

## Consequences

### Positive

- **True polyglot monorepo**: One build system for JavaScript, Docker, Python, Rust, and future technologies.

- **Simplified infrastructure**: Eliminates need for separate Nexus for Docker caching (NX handles it).

- **Better Docker support**: Docker builds are cached at the layer level and integrated into the task graph.

- **Cross-technology pipelines**: Can express dependencies like "Docker image build depends on TypeScript compilation."

- **Advanced tooling**: Graph visualization, affected commands, code generators, and distributed task execution available.

- **Industry alignment**: NX is widely adopted for large polyglot monorepos (enterprise, Google-scale projects).

### Negative

- **Migration complexity**: All projects need NX configuration. Not a drop-in replacement.

- **Tooling lock-in**: NX configuration is more invasive than Turborepo's `turbo.json` at the root.

- **Potential overkill**: For purely JavaScript projects, Turborepo was simpler. NX adds capabilities we may not immediately need.

- **Cache storage costs**: Unified caching for all technologies may increase cache storage requirements.

### Neutral

- **pnpm retained**: Package management doesn't change — NX works with existing pnpm workspace structure.

- **CI/CD updates**: GitHub Actions workflows need updates to use `nx` commands instead of `turbo`.

## Alternatives Considered

### Keep Turborepo + Enhance

- *Approach*: Add custom scripts for Docker/Python builds alongside Turborepo
- *Pros*: Minimal disruption to existing setup
- *Cons*: Fragmented tooling, no unified caching, custom script maintenance burden
- *Verdict*: Rejected — doesn't solve the core polyglot problem

### Bazel

- *Approach*: Google's build system with polyglot support
- *Pros*: Excellent caching, proven at massive scale, true hermetic builds
- *Cons*: Extremely steep learning curve, complex configuration, poor JavaScript/TypeScript ergonomics, Starlark language barrier
- *Verdict*: Rejected — too heavy for our needs, poor DX for JS-focused team

### Pants

- *Approach*: Polyglot build system with Python/Docker/JS support
- *Pros*: Built for polyglot, strong Python support, good caching
- *Cons*: Smaller community than NX, less mature JavaScript/TypeScript support, different paradigm
- *Verdict*: Rejected — NX has better ecosystem and Next.js integration

### Nx + Turborepo Hybrid

- *Approach*: Use NX for Docker/Python, keep Turborepo for JavaScript
- *Pros*: Incremental migration, keep existing JS workflow
- *Cons*: Two build systems to maintain, fragmented caching, confusing developer experience
- *Verdict*: Rejected — defeats the purpose of unified orchestration

## Technical Approach

### 1. Repository Structure

```
job-aide/
├── nx.json                    # NX workspace configuration
├── package.json               # pnpm workspace root (unchanged)
├── pnpm-workspace.yaml        # pnpm workspace definition (unchanged)
├── turbo.json                 # DEPRECATED - remove after migration
└── apps/
    ├── active/
    │   ├── cli/tkr/          # Rust project → project.json
    │   ├── devops/localnet/  # Docker project → project.json
    │   └── web/biziq/        # Next.js → @nx/next plugin
└── packages/
    └── active/
        ├── core/lib-a/       # JS library → @nx/js
        └── python/service/   # Python → nx-python plugin
```

### 2. Configuration Pattern

**nx.json** (root configuration):
```json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "production": ["default"]
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "cache": true
    },
    "test": {
      "cache": true
    }
  },
  "plugins": [
    "@nx/js",
    "@nx/next",
    "@nx/docker"
  ]
}
```

**project.json** (per-project configuration):
```json
{
  "name": "localnet",
  "$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "apps/active/devops/localnet",
  "projectType": "application",
  "targets": {
    "build": {
      "executor": "@nx/docker:build",
      "options": {
        "dockerfile": "./Dockerfile",
        "context": "."
      }
    },
    "up": {
      "executor": "nx:run-commands",
      "options": {
        "command": "docker compose -f docker-compose.localnet.yml up -d"
      }
    }
  }
}
```

### 3. Developer Workflow Changes

| Task | Old (Turborepo) | New (NX) |
|------|-----------------|----------|
| Build all | `pnpm build` | `nx run-many -t build` |
| Build specific | `turbo run build --filter=app` | `nx build app` |
| Test affected | `turbo run test --affected` | `nx affected -t test` |
| Docker build | `docker build .` | `nx build localnet` |
| Dev server | `pnpm dev` | `nx dev app` |
| Graph visualization | `turbo run build --graph` | `nx graph` |

### 4. CI/CD Updates

**GitHub Actions**:
```yaml
# Before (Turborepo)
- run: pnpm dlx turbo run build test --affected

# After (NX)
- run: npx nx affected -t build test --parallel=3
```

## Rollout / Migration

### Phase 1: Infrastructure

1. Install NX dependencies at root:
   ```bash
   pnpm add -D nx @nx/js @nx/next @nx/workspace
   ```

2. Create `nx.json` with base configuration

3. Set up Nx Cloud or self-hosted remote cache

4. Create migration guide documentation

### Phase 2: JavaScript Projects

1. Add `@nx/js` or `@nx/next` configuration to each JS/TS project
2. Generate `project.json` or add `nx` key to existing `package.json`
3. Update package scripts to call `nx` commands
4. Verify builds, tests, and caching work correctly

### Phase 3: Docker Projects

1. Install `@nx/docker` plugin
2. Configure Docker projects with `project.json` targets
3. Migrate LocalNet and other Docker services
4. Verify Docker layer caching integration

### Phase 4: Polyglot Projects

1. Install Python plugin for Python services
2. Configure Rust projects with custom executors
3. Verify cross-technology task dependencies work

### Phase 5: Cleanup

1. Remove `turbo.json` (keep as reference for historical ADR)
2. Update all documentation references
3. Train team on new commands
4. Archive Turborepo-specific documentation

### Phase 6: Optimization

1. Fine-tune cache configuration
2. Configure distributed task execution if needed
3. Add custom generators for new projects
4. Optimize CI/CD pipeline with advanced NX features

## Validation

This ADR will be considered successful if:

- [ ] All JavaScript projects build with NX with equivalent or better performance
- [ ] Docker projects (LocalNet) build and cache correctly through NX
- [ ] Python and Rust projects integrate into the unified build graph
- [ ] CI/CD pipeline times are maintained or improved
- [ ] Developers report consistent, understandable workflow across all technologies
- [ ] Cache hit rates are monitored and optimized above 70%

## References

- [NX Documentation](https://nx.dev/)
- [NX Docker Plugin](https://nx.dev/nx-api/docker)
- [Nx Cloud](https://nx.dev/nx-cloud)
- [Superseded ADR: pnpm + Turborepo](./adr-20251106001-pnpm-and-turborepo.md)
- [Related: Standard Developer UX Flow](./adr-20260131001-standard-developer-ux-flow.md)
- [Related: Artifact Caching Strategy](./adr-20251106010-artifact-caching.md)
- [NX vs Turborepo Comparison](https://nx.dev/concepts/turbo-and-nx)

<!-- vim: set ft=markdown: -->
