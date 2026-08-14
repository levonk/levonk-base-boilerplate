# Standard Developer UX Flow (ADR 20260131001)

**Primary Flow**: `direnv → devbox → just (auto-detecting) → [build tool]`

**AI Agent Workflow** (automated):
```bash
just build      # → auto-detects devbox → build_impl → language-specific build command
just test       # → auto-detects devbox → test_impl → language-specific test command
just lint       # → auto-detects devbox → lint_impl → language-specific lint command
```

**Human Developer Workflow** (interactive):
```bash
just build  # → auto-detects devbox environment via _devbox helper
# Flow: just build → _devbox build_impl → devbox run -- just build_impl → [build tool]
# (or if already in devbox: just build → _devbox build_impl → just build_impl → [build tool])
```

### Devbox Setup (Based on Detection)

> **Note**: devbox.json configuration is delegated to the **dev-env-upsert** skill. The templates below are reference material for what dev-env-upsert produces — do NOT hand-write devbox.json when dev-env-upsert is available.

Configure `devbox.json` based on detected systems:

```json
{
  "packages": [
    "just",
    "nodejs_22",
    "pnpm"
  ],
  "shell": {
    "init_hook": [
      "just bootstrap_impl"
    ]
  },
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "clean": "just clean_impl"
  }
}
```

**Language-specific packages:**
- **Rust**: Add `"rustc"`, `"cargo"`, `"clippy"`
- **TypeScript/Node**: Add `"nodejs_22"`, `"pnpm"`, `"typescript"`
- **Python**: Add `"python3"`, `"poetry"`, `"black"`, `"ruff"`
- **Go**: Add `"go"`, `"gopls"`

### Indexed AST Tool Setup

Indexed AST tool selection is **delegated to the dev-env-upsert skill** via its `setup` operation. The detection logic is file-type-aware:

| Detection signal | Tool | Notes |
|------------------|------|-------|
| Source code files (`.ts`, `.tsx`, `.js`, `.py`, `.rs`, `.go`, `.java`, etc.) | **CodeGraph** | Default for code-bearing projects |
| Multi-repo workspace (pnpm workspaces, Nx monorepo, git submodules) | **GitNexus** | Procure a commercial license for business use before setup |
| Non-code docs, PDFs, video, slides | **Graphify** | For knowledge-base / documentation-heavy projects |

**Do NOT install all three by default** — the detection logic picks exactly one tool based on the project's file-type profile.

**dev-env-upsert `setup` operation** (one call — batch: add-packages + add-prime-steps + update-envrc):

```bash
uv run --script <dev-env-upsert>/scripts/dev_env_upsert.py setup \
    --packages <tool>,direnv,just \
    --prime-steps "<tool> index .:<tool>" \
    --envrc-async-prime \
    --target .
```

**Critical**: indexing folds into the existing `prime_impl` target — do NOT create new `index` / `index_impl` targets. The staleness check lives INSIDE `prime_impl` so that `just prime` runs the indexer only when the index is stale. See `async-prime-internal.md` for the async prime_impl trigger that `.envrc` appends, and `index-staleness-check.md` for the staleness-check logic.

### Justfile Configuration (Standard Targets)

Create `justfile` with standard targets following ADR 20260131001:

```just
# _devbox helper — DRY auto-detection of devbox environment
# All normal targets delegate to this. Checks DEVBOX_SHELL_ENABLED and either
# runs the _impl target directly, re-execs via devbox run, or falls back to doctor.
_devbox target *args:
    #!/usr/bin/env bash
    if [ "${DEVBOX_SHELL_ENABLED:-0}" = "1" ]; then
        exec just "{{target}}" {{args}}
    elif command -v devbox >/dev/null 2>&1; then
        exec devbox run -- just "{{target}}" {{args}}
    else
        echo "❌ devbox not found in PATH." >&2
        echo "💡 Running doctor to diagnose environment issues..." >&2
        just doctor 2>/dev/null || true
        exit 1
    fi

# Normal targets - Developer interface (REQUIRED) — one-liners delegating to _devbox
clean:
    just _devbox clean_impl

dev:
    just _devbox dev_impl

build:
    just _devbox build_impl

test:
    just _devbox test_impl

lint:
    just _devbox lint_impl

typecheck:
    just _devbox typecheck_impl

# Bootstrap recipes (REQUIRED)
bootstrap:
    just _devbox bootstrap_impl

# doctor runs DIRECTLY — it's the fallback when devbox is missing
doctor:
    #!/usr/bin/env bash
    echo "🔍 Checking development environment..."
    command -v devbox >/dev/null 2>&1 && echo "✅ devbox: $(devbox version 2>&1 | head -1)" || echo "❌ devbox: NOT FOUND"
    command -v just >/dev/null 2>&1 && echo "✅ just: $(just --version 2>&1)" || echo "❌ just: NOT FOUND"
    [ "${DEVBOX_SHELL_ENABLED:-0}" = "1" ] && echo "✅ devbox env: ACTIVE" || echo "⚠️  devbox env: NOT ACTIVE"

# Implementation targets (REQUIRED) — hidden from just --list via _ prefix
bootstrap_impl:
    # Language-specific setup
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo build
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm install
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry install
    {{{ "{{" }}}#/if{{{ "}}" }}}
    echo "Development environment ready!"

build_impl:
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo build --release
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm run build
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry build
    {{{ "{{" }}}#/if{{{ "}}" }}}

test_impl:
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo test
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm run test
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry run pytest
    {{{ "{{" }}}#/if{{{ "}}" }}}

dev_impl:
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo run
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm run dev
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry run python -m src
    {{{ "{{" }}}#/if{{{ "}}" }}}

lint_impl:
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo clippy
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm run lint
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry run ruff check
    {{{ "{{" }}}#/if{{{ "}}" }}}

typecheck_impl:
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    pnpm run typecheck
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    poetry run mypy
    {{{ "{{" }}}#/if{{{ "}}" }}}

clean_impl:
    {{{ "{{" }}}#if is_rust{{{ "}}" }}}
    cargo clean
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_typescript{{{ "}}" }}}
    rm -rf dist node_modules/.cache
    {{{ "{{" }}}#/if{{{ "}}" }}}
    {{{ "{{" }}}#if is_python{{{ "}}" }}}
    rm -rf build dist .pytest_cache
    {{{ "{{" }}}#/if{{{ "}}" }}}
```

### direnv Configuration

Create `.envrc` based on ticketr pattern:

```bash
# Project Environment Configuration

# FIRST: Exit existing devbox shell if we're in one (prevents shell inception)
if [[ "$DEVBOX_SHELL_ENABLED" == "1" ]]; then
    echo "🔄 Exiting existing devbox shell to prevent shell inception..."
    exit 0
fi

# Helper functions to modify PATH idempotently
path_prepend() {
  local p="$1"
  if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
    export PATH="$p:$PATH"
  fi
}

path_append() {
  local p="$1"
  if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
    export PATH="$PATH:$p"
  fi
}

# Ensure nix profile bin is on PATH for direnv hooks
path_prepend "/nix/var/nix/profiles/default/bin"

if ! command -v nix >/dev/null 2>&1; then
    path_append "$HOME/.nix-profile/bin"
fi

# Ensure devbox is available
if ! command -v devbox >/dev/null 2>&1; then
    if [ -d "$HOME/.nix-profile/bin" ]; then
        path_append "$HOME/.nix-profile/bin"
    fi
fi

use_devbox() {
    watch_file devbox.json
    eval "$(devbox shellenv)"
}

if command -v devbox >/dev/null 2>&1; then
    use devbox
fi

echo "🚀 Project environment initialized"
echo "💡 Run 'just --list' to see available commands"
```

### README.md Structure

README.md creation and update is **delegated to the readme-upsert skill**. Do NOT hand-write README content in `adopt-project.sh` or `configure-*.sh` — that duplicates readme-upsert's template, required-sections list, and consistency checks, and diverges over time.

**Invocation** (run AFTER AGENTS.md is in place so the README can link to it and `verify_consistency.py` can check name/section agreement):

```bash
# Delegate to readme-upsert — it handles both greenfield and brownfield cases:
#   Greenfield: creates README from references/README-project-root-template.md.tmpl
#   Brownfield: preserves accurate sections, updates stale ones
# Then runs scripts/verify_consistency.py {REPO_ROOT} to check README<->AGENTS.md agreement
# See <readme-upsert>/SKILL.md for the full 5-phase workflow.
```

**Required sections** (owned by readme-upsert, not by this skill):
- Project name + overview (1-2 paragraphs)
- Quick Start (copy-paste ready setup commands)
- Build/Test Commands
- Project Structure
- AI Agent Documentation (link to `AGENTS.md`)

**Optional sections** (included by readme-upsert if relevant): Development Workflow, Testing, Package Management, Troubleshooting, Contributing, License.

For the canonical README template, see [`<readme-upsert>/references/README-project-root-template.md.tmpl`](../../../ai/readme-upsert/references/README-project-root-template.md.tmpl).

### Docker Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - .:/app
      - /app/node_modules  # For Node.js projects
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: just dev_impl
```

Create `docker/Dockerfile`:

```dockerfile
# Multi-stage build for production
FROM node:22-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:22-alpine as runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["just", "dev_impl"]
```

### LICENSE.md

Create proprietary license:

```markdown
# Proprietary License

Copyright (c) 2026 [Your Company Name]

All rights reserved. This software and its documentation are proprietary
and confidential. Unauthorized copying, distribution, or disclosure is
strictly prohibited.
```

### AGENTS.md Configuration (AI Workflow Integration)

Create `AGENTS.md` that integrates with **ai-development-loop** skill:

```markdown
# Agent Documentation: Project Name

## Overview

Brief description of the project and its purpose.

## Development Workflow

### AI Agent Loop

1. **Setup**: Ensure clean state and latest code
2. **Plan**: Understand requirements and create implementation plan
3. **Implement**: Write code following project patterns
4. **Test**: Run tests and verify functionality
5. **Review**: Check code quality and documentation
6. **Commit**: Commit changes with clear messages

### Commands

```bash
just build_impl    # Build project (inside devbox)
just test_impl     # Run tests (inside devbox)
just lint_impl     # Run linting (inside devbox)
just typecheck_impl # Run type checking (inside devbox)
```

### Project Structure

Description of key directories and files.

### Dependencies

List of key dependencies and their purposes.

## Development Guidelines

### Code Style

- Follow established patterns in the codebase
- Use meaningful variable names
- Write tests for new features
- Update documentation

### Testing

- Write unit tests for all new functions
- Integration tests for user workflows
- Performance tests for critical paths

### Security

- No hardcoded secrets
- Input validation
- Proper error handling
```

### Dependency Management

#### TypeScript/Node.js Projects

External dependency versions are centralized in the `catalog:` block of the
root `pnpm-workspace.yaml` (per the `typescript-monorepo-best-practices` bundle
— `pnpm-nx-monorepo` concept). Sub-package `package.json` files reference them
via `"catalog:"` and **never** duplicate a version range. `"*"` does NOT inherit
from root — it resolves to the latest registry release and is forbidden.

`configure-nodejs.sh` creates `pnpm-workspace.yaml` with the catalog and
`catalogMode: strict` automatically. To rewrite an existing `package.json`'s
external deps to `catalog:` references, run with
`PROJECT_ADOPTER_CATALOG_REFS=1`; otherwise the catalog is created but the
package.json versions are left as-is (unreferenced catalog).

Use `yq-go` to update `package.json`:

```bash
# Add standard dependencies — internal workspace packages use workspace:*
yq eval '.devDependencies["@job-aide/tools-lint-eslint-config"] = "workspace:*"' package.json -i
yq eval '.devDependencies["@job-aide/tools-vitest-config"] = "workspace:*"' package.json -i
# External registry deps use catalog: (version pinned in pnpm-workspace.yaml)
yq eval '.devDependencies["typescript"] = "catalog:"' package.json -i
yq eval '.devDependencies["vitest"] = "catalog:"' package.json -i

# Add scripts. Build tool depends on project type (build-tool-selection concept):
#   library → tsup (ESM+CJS+.d.ts via esbuild)
#   app/CLI → next build (Rolldown-backed from Next 15) or rolldown
# tsc --noEmit is always the type-check layer, never the build layer.
yq eval '.scripts.build = "tsup"' package.json -i          # library
yq eval '.scripts.test = "vitest"' package.json -i
yq eval '.scripts.lint = "eslint . --ext .ts,.tsx"' package.json -i
yq eval '.scripts.typecheck = "tsc --noEmit"' package.json -i
```

For supply-chain hardening (`overrides`, `patchedDependencies`,
`onlyBuiltDependencies`, `.pnpmfile.mjs`, `packageExtensions`), edit
`pnpm-workspace.yaml` — these settings are silently ignored in `package.json#pnpm`
on pnpm 11+ (issue #11536). See the `pnpm-supply-chain` knowledge concept.

#### Rust Projects

Update `Cargo.toml`:

```bash
# Add standard dependencies
yq eval '.dependencies["tokio"] = { version = "^1.0", features = ["full"] }' Cargo.toml -i
yq eval '.dependencies["anyhow"] = "^1.0"' Cargo.toml -i
yq eval '.dependencies["serde"] = { version = "^1.0", features = ["derive"] }' Cargo.toml -i
yq eval '.devDependencies["cargo-watch"] = "^8.0"' Cargo.toml -i
```

### GitHub Configuration

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: jetify-com/devbox-action@v0.10.0
      - run: just test
      - run: just lint
      - run: just typecheck
```

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly
  - package-ecosystem: cargo
    directory: /
    schedule:
      interval: weekly
```

### Ignore File Generation (Delegated to ignorefile-manager)

Ignore file generation is **delegated to the [ignorefile-manager](../../../general/ignorefile-manager/SKILL.md) skill**. Do NOT hand-write `.gitignore` (or `.dockerignore`, `.codeiumignore`, `.cursorignore`, `.aiexclude`, `.npmignore`, VS Code excludes, ripgrep config) — that duplicates ignorefile-manager's modular concern sources and diverges over time.

ignorefile-manager generates all outputs from small concern files in `assets/concerns/` (secrets, build-artifacts, os-files, editor-files, dependencies, ai-generated, dev-local, binaries, vcs-meta, logs, lockfiles) composed via `assets/outputs.yaml`. It covers git, docker, jj (`.jj/` is in `vcs-meta.ignorefile`), AI indexing tools (`.codeiumignore`, `.cursorignore`, `.aiexclude`), npm packaging, VS Code, and ripgrep.

**Adoption workflow** (run between configuration and the final commit):

```bash
# 1. Reconcile — harvest orphan patterns from any existing deployed ignore files
uv run --script <ignorefile-manager>/scripts/generate_ignores.py reconcile --target . --auto-assign

# 2. Audit — check which outputs are missing or stale
uv run --script <ignorefile-manager>/scripts/generate_ignores.py audit --target .

# 3. Generate — dry-run first, then apply
uv run --script <ignorefile-manager>/scripts/generate_ignores.py generate --target . --dry-run
uv run --script <ignorefile-manager>/scripts/generate_ignores.py generate --target .

# 4. (Optional) Update VS Code workspace files and ripgrep config
uv run --script <ignorefile-manager>/scripts/generate_ignores.py workspace --target .
uv run --script <ignorefile-manager>/scripts/generate_ignores.py ripgrep
```

The `<ignorefile-manager>` path is resolved by the consumer's skill installer; this skill does not hardcode it. Generated content is wrapped between `# ===== BEGIN GENERATED CONTENT =====` and `# ===== END GENERATED CONTENT =====` markers so project-specific entries above the marker are preserved across re-runs.

## Examples

### Example: New TypeScript Project

```bash
# 1. Initialize project
mkdir my-app && cd my-app
npm init -y

# 2. Apply skill
# (This skill would detect TypeScript and set up everything)
```

### Example: Migrating Existing Rust Project

```bash
# 1. Add devbox
devbox init
devbox add rustc cargo just

# 2. Create justfile
# (Skill creates standard justfile with Rust targets)

# 3. Configure .envrc
# (Skill creates direnv configuration)

# 4. Generate or update README (delegated to readme-upsert)
# (readme-upsert creates from template for greenfield, preserves accurate
#  sections for brownfield, then runs verify_consistency.py)
```

## Quality Checklist

- [ ] Used project-detection skill for comprehensive analysis
- [ ] Devbox configuration created with appropriate packages
- [ ] Justfile with standard targets (ADR 20260131001 compliant)
- [ ] direnv configuration (.envrc)
- [ ] AGENTS.md integrates with ai-development-loop skill
- [ ] README.md generated or updated via readme-upsert (greenfield: from template; brownfield: preserve accurate sections, update stale ones); verify_consistency.py passes (README<->AGENTS.md name match, no content duplication, no wrong sections)
- [ ] Docker configuration (if needed)
- [ ] LICENSE.md (Proprietary)
- [ ] Dependencies configured correctly
- [ ] GitHub workflows set up
- [ ] Ignore files generated via ignorefile-manager (reconcile → audit → generate; covers .gitignore, .dockerignore, .codeiumignore, .cursorignore, .aiexclude, .npmignore, VS Code excludes, ripgrep config)
- [ ] Git repo initialized (if needed) via git-repository-management `git-repo-init.bash`
- [ ] Adoption changeset committed via git-repository-management `git-commit-batch.sh --slug project-adoption` (with pre/post auto-tags for rollback safety)
- [ ] Remote push via git-repository-management `git-push.sh` (if remote configured)
- [ ] Project follows standard UX flow
- [ ] Ready for ai-development-loop systematic workflow
