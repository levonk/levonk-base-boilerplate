# Directory Update Log

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-19

* **Addition**: Created [standalone-scripts.md](standalone-scripts.md) covering
  PEP 723 inline script metadata, `uv run --script`, and the decision tree for
  standalone scripts vs. packages vs. services. The page documents the
  toolchain discovery pattern: resolve `uv` via the shared `cli-tool-discovery`
  script (bash and Python variants in `src/current/includes/`), fall back to
  `pip` + `python3` when `uv` is unavailable, and add `uv` to `devbox.json`
  (walking up from cwd to repo root) when a devbox environment is present.
  Cross-links to `script-materialization` (include in `src/current/includes/`,
  also published at the skills-releases URL) for the skill-authoring case
  without using a cross-tree relative path. Updated [index.md](index.md) and
  [overview.md.tmpl](overview.md.tmpl) to list the new page and reframe the
  bundle as covering services, packages, and standalone scripts.

## 2026-07-18

* **DRY**: Converted [overview.md](overview.md.tmpl) to `overview.md.tmpl` and
  added `{{{ include "includes/tech-stack-table.md" . }}}` so the canonical
  tech-stack choices table is inlined from a single source of truth at
  `src/current/includes/tech-stack-table.md.tmpl`. See the
  typescript-monorepo-best-practices log entry for the full rationale.

* **Update**: Standardized on `nx` as the monorepo orchestrator across all
  knowledge. In [nox-orchestration.md](nox-orchestration.md), replaced the
  "Turborepo Integration" section with an "Nx Integration" section that points
  at the typescript-monorepo-best-practices bundle and describes how Nx
  delegates to nox for Python tasks. Updated the frontmatter description/tags
  and the [index.md](index.md) listing to match. Turborepo is no longer
  recommended as a current orchestrator anywhere in this bundle; it is only
  referenced historically in the typescript-monorepo-best-practices bundle as a
  superseded choice (ADR-20251106001, superseded by ADR-20260419001).

## 2026-07-17

* **Initialization**: Created the `python-services-practices` knowledge bundle to consolidate Python services and packages standards from ADR-20251129003 in levonk-base-boilerplate.
* **Creation**: Authored 7 concept pages covering the Python service lifecycle.
  - [pyproject-toml-manifest.md](pyproject-toml-manifest.md) — pyproject.toml as single source of truth
  - [fastapi-service-layout.md](fastapi-service-layout.md) — standard FastAPI service layout
  - [python-package-layout.md](python-package-layout.md) — non-service library layout
  - [docker-standards.md](docker-standards.md) — multi-stage builds, non-root, env vars, healthcheck
  - [makefile-conventions.md](makefile-conventions.md) — matching up/down, standard command set
  - [pytest-testing-baseline.md](pytest-testing-baseline.md) — pytest + asyncio, Node-based E2E
  - [nox-orchestration.md](nox-orchestration.md) — nox for Python pipelines, Nx for Node/Docker/polyglot tasks
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251129003 (Python services and packages standard, 353 lines) in levonk-base-boilerplate.
