# Project Adopter

Adopt and standardize a project onto the canonical developer UX flow
(`direnv → devbox → just (auto-detecting) → [build tool]`, per ADR 20260131001).
The skill detects the project's stack, writes the standard environment files,
installs knowledge bundles, generates ignore files, and commits the adoption
changeset — overwriting existing preferences with the standardized workflow.

## Quick Start

```bash
# Adopt the project in the current directory (auto-detects stack)
uv run --script scripts/adopt-project.sh .

# Standardize mode (full ecosystem packages, enforces our standards)
FORCE_ADOPTION=true ./scripts/adopt-project.sh . --mode standardize

# Adopt a 3rd-party project conservatively (preserve existing configs)
./scripts/adopt-project.sh ./vendor/project --mode adopt
```

After adoption the project has: `.envrc`, `devbox.json`, `justfile`,
`README.md`, `LICENSE.md`, `AGENTS.md`, `docker-compose.yml`, CI workflow,
generated ignore files (`.gitignore`, `.dockerignore`, `.codeiumignore`,
`.cursorignore`, `.aiexclude`, `.npmignore`, VS Code excludes, ripgrep
config), and a single `project-adoption` commit on a rollback-safe tag.

## Two Modes

| Mode | Behavior | Use For |
|------|----------|---------|
| `adopt` (conservative) | Essential packages only, preserves existing configurations, basic tooling | 3rd-party / vendor projects |
| `standardize` (comprehensive) | Full ecosystem packages, enforces our standards, complete tooling and docs | Our own projects |

## What It Sets Up

1. **Detect** stack via `project-detection` (50+ build systems / CI platforms)
2. **devbox.json** with language-appropriate packages (`nodejs_22`, `rustc`,
   `python3`, `go`, etc.)
3. **justfile** with auto-detecting targets: `just build` →
   `_devbox build_impl` → (in devbox) `just build_impl` → `[build tool]`
4. **.envrc** for direnv auto-activation
5. **Technology-specific build tools** (cargo, nx, pytest, etc.)
6. **Shared quality scripts** (ADR 20251218002)
7. **Testing framework** (Vitest for TypeScript per ADR 20251106002)
8. **GitHub Actions CI/CD** (ADR 20251106014)
9. **README.md** generated or updated via **readme-upsert** (greenfield: from template; brownfield: preserve accurate sections, update stale ones; runs README↔AGENTS.md consistency check)
10. **docker-compose.yml**, **LICENSE.md** (Proprietary), **AGENTS.md** (created before README so readme-upsert can link to it)
11. **Knowledge bundles** installed into `.agents/knowledge/bundles/`
    (universal by default; stack-matched via `--bundles`)

## Delegations

This skill **delegates** three concerns to dedicated skills rather than
reimplementing them:

| Concern | Delegated To | Why |
|---------|--------------|-----|
| README.md creation or update | **readme-upsert** | Owns the README template, required-sections list, and README↔AGENTS.md consistency checker. Handles greenfield (from template) and brownfield (preserve + update) cases. Hand-writing README content via heredocs duplicates the template and bypasses the consistency check. |
| Ignore file generation | **ignorefile-manager** | Single source of truth across git, docker, jj, AI tools, npm, IDE, search. Hand-writing `.gitignore` duplicates concern sources and diverges over time. |
| Repo init + adoption commit | **git-repository-management** | `git-repo-init.bash` + `git-collect.sh` + `git-commit-batch.sh --slug project-adoption` + `git-push.sh` provide secret scanning, vertical grouping, and pre/post auto-tags for rollback safety. Calling `git init` / `git add` / `git commit` directly bypasses those guarantees. |

Invocation pattern (paths resolved by the consumer's skill installer):

```bash
# 1. Generate or update README.md (readme-upsert) — run AFTER AGENTS.md exists
#    greenfield: creates from template; brownfield: preserves accurate sections
#    then runs verify_consistency.py to check README<->AGENTS.md agreement

# 2. Generate ignore files (ignorefile-manager)
uv run --script <ignorefile-manager>/scripts/generate_ignores.py reconcile --target . --auto-assign
uv run --script <ignorefile-manager>/scripts/generate_ignores.py audit --target .
uv run --script <ignorefile-manager>/scripts/generate_ignores.py generate --target .

# 3. Init repo + commit adoption changeset (git-repository-management)
./<git-repository-management>/scripts/git-collect.sh .                         # NOT_A_GIT_REPO + exit 2 if not a repo
bash ./<git-repository-management>/scripts/git-repo-init.bash .               # if NOT_A_GIT_REPO fired
./<git-repository-management>/scripts/git-collect.sh .                         # re-collect after init
./<git-repository-management>/scripts/git-commit-batch.sh --slug project-adoption .
./<git-repository-management>/scripts/git-push.sh .                            # optional, if remote configured
```

## Knowledge Bundles

```bash
# Universal bundles only (default)
uv run --script scripts/install-knowledge-bundles.py .

# Stack-matched (TypeScript + containers detected)
uv run --script scripts/install-knowledge-bundles.py . --bundles typescript-monorepo-best-practices,container-best-practices

# Private distribution repo
uv run --script scripts/install-knowledge-bundles.py . --private --bundles secrets-egress-security
```

| Tier | Bundles | When |
|------|---------|------|
| Universal | `software-architecture-essentials`, `dev-environment-practices`, `devsecops-codeguard`, `cicd-testing-practices`, `build-system-essentials` | Installed by default |
| Stack-matched | `typescript-monorepo-best-practices`, `rust-development-practices`, `python-services-practices`, `java-best-practices`, `frontend-stack-practices`, `nix-build-practices`, `container-best-practices`, `data-engineering-best-practices` | Added via `--bundles` based on detection |
| Domain-specific | `api-auth-payment-practices`, `infrastructure-networking-practices`, `cloud-provider-essentials`, `web-resource-catalog`, `upstream-contribution-practices`, `ai-primitives` | NOT installed — URL-referenced in AGENTS.md by agent-file-upsert (bundled skill) for on-demand fetch |

## Per-Language Configuration Scripts

| Script | Stack |
|--------|-------|
| `scripts/configure-nodejs.sh` | Node.js / TypeScript / Next.js |
| `scripts/configure-rust.sh` | Rust |
| `scripts/configure-python.sh` | Python |
| `scripts/configure-go.sh` | Go |
| `scripts/configure-java.sh` | Java |
| `scripts/configure-kotlin.sh` | Kotlin |
| `scripts/configure-dart.sh` | Dart / Flutter |
| `scripts/configure-dotnet.sh` | .NET / C# |
| `scripts/configure-generic.sh` | Fallback / unknown stack |

## Dependencies

- **Skills**: `project-detection`, `surgical-config`, `git-repository-management`,
  `ignorefile-manager`, `readme-upsert` (required); `repository-health-review`,
  `ai-development-loop` (optional)
- **Templates**: `boilerplates` —
  https://github.com/lrepo52/job-aide/tree/main/boilerplate
- **Tools**: `devbox`, `just`, `direnv`

## References

- `SKILL.md.tmpl` — full skill definition and Quick Start (19 steps)
- `EXAMPLES.md` — worked examples (TypeScript from scratch, etc.)
- `REFERENCE.md` — configuration templates (devbox.json, justfile, yq patterns) per language
- `references/developer-ux-flow.md` — ADR 20260131001 flow details
- `references/skill-integrations.md` — integration with each dependency skill
- `references/technology-build-tools.md` — build tool table per language
- `references/adr-references.md` — ADR index
- `doc/` — ADRs and per-language change documentation

## Development

This skill is authored in the `skills-src` monorepo using Go `text/template`
files (`.tmpl`). The templater renders `.tmpl` files into final output.

```bash
just build current   # render all skills → build/current/skills/
just validate        # check frontmatter + leaked delimiters
```

See the repository's `AGENTS.md` for authoring conventions, the
`src/current/skills/AGENTS.md` for skill-specific patterns, and
`.agents/knowledge/developer.md` for the developer guide.
