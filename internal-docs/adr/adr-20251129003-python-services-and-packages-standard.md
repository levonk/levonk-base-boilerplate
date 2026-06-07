---
modeline: "vim: set ft=markdown:"
title: "ADR: Python Services and Packages Standard"
adr-id: "20251129003"
slug: "20251129003-python-services-and-packages-standard"
url: "/internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md"
synopsis: "Define standards for Python services and packages, including FastAPI apps, Docker, docker-compose, Makefiles, testing, and orchestration with turbo, Stagehand/Playwright, and nox."
author: "https://github.com/levonk"
date-created: "2025-11-29"
date-updated: "2025-11-29"
date-review: "2026-05-29"
date-triggers: ["2026-05-29"]
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "python", "fastapi", "tooling", "testing"]
supersedes: []
superseded-by: []
related-to: [
  "adr-20251106001-pnpm-and-turborepo",
  "adr-20251106002-vitest-for-testing",
  "adr-20251106012-containerization-strategy",
  "adr-20251129001-copier-based-boilerplate-standard",
  "adr-20251129002-architecture-decision-records-process"
]
scope:
  impact-scope: [
    "Python services (FastAPI and successors)",
    "Python libraries/packages in this monorepo",
    "boilerplate/apps/backend/python/*",
    "boilerplate/packages/**/*python*",
    "E2E testing harnesses touching Python backends"
  ]
  excluded-scope: [
    "Non-Python services (TypeScript, Go, etc.)",
    "Infrastructure-as-code templates (Pulumi, Terraform)",
    "One-off scripts under scripts/ not intended as reusable packages"
  ]
---

# Decision Record: Python Services and Packages Standard

- belongs in `internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md`

---

## Context

The monorepo is increasingly polyglot, with TypeScript, Python, and infrastructure code coexisting. We already have:

- A monorepo tooling baseline with **pnpm + Turborepo** (see ADR 20251106001).
- A standardized **Copier-based boilerplate** process (see ADR 20251129001).
- Frontend and Node-centric decisions for Vitest, Stagehand, Playwright, and containerization.

However, Python usage (services and libraries) has been implicit and ad-hoc. This leads to:

- Inconsistent project layout for Python apps and packages.
- Mixed use of `requirements.txt` and `pyproject.toml`.
- Divergent Docker practices (base images, users, environment variables).
- No single reference for how Python services integrate with cross-cutting tools:
  - **Stagehand + Playwright** for browser-level E2E tests.
  - **Turborepo** for monorepo-wide orchestration.
  - **nox** for Python-specific test/lint orchestration.

This ADR standardizes **Python services and packages** so that:

- Every new Python project is scaffolded consistently via Copier boilerplates.
- Tooling (Docker, docker-compose, Makefiles, testing) behaves predictably.
- Monorepo orchestration layers (turbo, nox, Stagehand/Playwright) integrate cleanly without replacing Python’s own ecosystem.

## Constraints

- Python dependencies must be managed via **`pyproject.toml` as the single source of truth**; `requirements*.txt` is deprecated except for narrowly scoped tooling (e.g., third-party templates that cannot yet be migrated).
- Python services must be **containerized** consistently with the broader containerization strategy (see ADR 20251106012), including non-root users and healthchecks.
- The monorepo already standardizes on **pnpm + Turborepo** for JavaScript/TypeScript and on **Vitest** for JS tests.
- We want to **augment** native Python tooling (pytest, uv, pip, FastAPI, etc.), not replace it with Bazel/Pants-style systems.

## Decision

We standardize Python services and packages as follows:

1. **Project manifest**: All Python apps and packages use **`pyproject.toml`** as the canonical manifest; no `requirements.txt` for core dependencies.
2. **FastAPI as the default HTTP service framework** for new Python web APIs.
3. **Copier boilerplates** define the canonical layout for Python services and packages, including:
   - `app/` module (for services) and `tests/` directory.
   - `pyproject.toml`, `README.md`, `Dockerfile`, `docker-compose.yml`, and `Makefile`.
4. **Docker**:
   - Multi-stage builds on top of the monorepo **base-alpine** image, running as a **non-root user**.
   - Standard environment variables: `PUID`, `PGID`, `TZ`, and `PORT` for services.
5. **docker-compose**:
   - One service per Python app, named from Copier answers.
   - Passes `PUID`, `PGID`, `TZ`, `NODE_ENV`, and `PORT` into the container.
6. **Makefiles**:
   - Any Makefile that defines `up` **must** also define `down`.
   - Python services expose a standard command set: `dev`, `test`, `lint`, `format`, `typecheck`, `build`, `up`, `down`.
7. **Testing baseline**:
   - Python-native tests use **pytest** (+ plugins such as `pytest-asyncio` and `httpx/TestClient` as needed).
   - Browser/E2E tests use **Stagehand + Playwright** in a **Node test harness**, not from Python.
8. **Orchestration**:
   - **Turborepo** orchestrates Node/TS tasks and any future Python tasks that are conveniently expressed as scripts.
   - **nox** is the primary orchestration layer for Python test/lint pipelines across projects, using `pyproject.toml` dev extras.

## Technical Approach

### Standard FastAPI Service Layout

New FastAPI services follow this canonical layout (schematic example):

```text
apps/
  active/
    job/
      privacy-id/
        backend/
          python/
            fastapi/
              app/
                __init__.py
                main.py
              tests/
                test_main.py
              Dockerfile
              docker-compose.yml
              Makefile
              pyproject.toml
              README.md
              .gitignore

boilerplate/
  apps/
    backend/
      python/
        fastapi/
          copier.yml
          app/
            main.py.tmpl
          tests/
            test_main.py.tmpl
          Dockerfile.tmpl
          docker-compose.yml.tmpl
          Makefile.tmpl
          pyproject.toml.tmpl
          README.md
          .gitignore
```

Key points:

- `app/main.py` defines the FastAPI application object (e.g., `app = FastAPI(...)`) and exposes a `/health` endpoint for healthchecks.
- `tests/test_main.py` exercises the `/health` endpoint and any core behavior using `TestClient` and/or `httpx`.
- `pyproject.toml`:
  - Declares the app package (`app`) and dependencies (`fastapi`, `uvicorn`, etc.).
  - `dev` optional-dependencies include pytest, pytest-asyncio, httpx, mypy, ruff, black, isort, and related tooling.
- `README.md` documents:
  - Overview and purpose.
  - Local development flow (`uv`/`pip`, `pytest`).
  - Docker build/run via Makefile.

### Python Package Layout (Non-service Libraries)

Python libraries (non-HTTP services) follow an analogous layout, adapted from existing package boilerplates. A representative example:

```text
packages/
  active/
    features/
      documents/
        api-python/
          document-service/
            src/
              my_package/
                __init__.py
                models.py
                services.py
                ...
            tests/
              test_models.py
              test_services.py
            pyproject.toml
            README.md
            .gitignore
```

Differences from services:

- No `Dockerfile` or `docker-compose.yml` by default (unless explicitly containerized).
- No `Makefile` is required, but recommended where packages have non-trivial workflows.

### Docker

Python service Dockerfiles must:

- Use the monorepo **base-alpine** image as the base (per containerization ADR 20251106012).
- Implement a multi-stage build:
  - **Builder stage** installs dependencies (`.[dev]` during image build is acceptable for now; future optimization may use wheels and `.[prod]` or minimal subsets).
  - **Runtime stage** installs only what is needed to run, copies artifacts from builder, and drops to a non-root user.
- Honor environment variables:
  - `PUID`, `PGID` to configure user/group IDs.
  - `TZ` for timezone.
  - `PORT` for the HTTP listener.
- Expose the service port and define a `HEALTHCHECK` hitting `/health`.

### docker-compose

Per-service `docker-compose.yml` files (for Python services) must:

- Define a service whose name is derived from Copier answers (e.g., `{{ service_name | replace(" ", "-") | lower }}`).
- Use a `build` block pointing to the service’s Dockerfile.
- Pass `PUID`, `PGID`, `TZ`, `NODE_ENV`, and `PORT` via `environment`.
- Map `PORT:PORT` via `ports` for local development.
- Use `restart: unless-stopped` for persistence in local/dev environments.

The exact build context (service-local vs monorepo-root) can vary by template, but must be explicit in boilerplates and guided by containerization ADRs.

### Makefiles

Makefiles associated with services must:

- Always define **matching** `up` and `down` targets if either is present.
- Use `docker compose` (not `docker-compose`) with a configurable `COMPOSE_FILE` and `SERVICE_NAME`.
- For FastAPI services, provide at least:
  - `dev` (run uvicorn locally without Docker).
  - `test` (run pytest).
  - `lint` (ruff + mypy).
  - `format` (black + isort + ruff autofix).
  - `typecheck` (mypy).
  - `build`, `up`, `down` for Dockerized workflows.

This creates a predictable CLI contract across all Python services.

### Testing: pytest, Stagehand, Playwright

- **Python unit/integration tests**:
  - Use `pytest` as the default test runner.
  - Tests live under `tests/` and follow a consistent naming convention (`test_*.py`, `*_test.py`).
- **Browser/E2E tests** for Python backends:
  - Use **Stagehand** and **Playwright** from a **Node-based test harness**, not from Python.
  - Typically live under an appropriate web app boilerplate (e.g., `boilerplate/apps/web/typescript/nextjs/__test__/e2e/...`).
  - Target Python backends via HTTP (e.g., hitting `http://localhost:<PORT>/...`) and rely on the service being up (via `docker compose`, `make up`, or CI orchestration).

This keeps browser automation concerns in the TypeScript/Node ecosystem where Stagehand/Playwright are first-class, while Python focuses on API-level and unit-level correctness.

### Orchestration: Turborepo and nox

- **Turborepo** (per ADR 20251106001):
  - Remains the orchestrator for Node/TypeScript tasks.
  - May invoke Python service commands via `package.json` scripts when appropriate, but does **not** replace Python’s build system.
- **nox** (root `noxfile.py`):
  - Discovers Python projects by scanning for `pyproject.toml`.
  - For each project, installs `-e .[dev]`.
  - Provides standard sessions:
    - `tests`: run pytest for all projects with `tests/`.
    - `lint`: run ruff + mypy for `app/` and `tests/` where present.

This combination allows monorepo-wide Python checks without giving up native Python tools or the ability to extract a project into its own repository.

## Affected Components

- All existing and future Python services under `apps/`.
- All Python packages under `packages/active` (and their boilerplates).
- Copier templates under `boilerplate/apps/backend/python/*` and `boilerplate/packages/...python...`.
- CI/CD pipelines that run Python tests, lint, or builds.
- E2E harnesses that exercise Python backends.

## Consequences

### Positive

- **Consistency**: New Python projects follow the same layout and tooling expectations.
- **Discoverability**: Developers can quickly find `app/`, `tests/`, `Dockerfile`, and `Makefile` for any service.
- **Interoperability**: Python projects integrate cleanly with Turborepo, Vitest, Stagehand, and Playwright without awkward cross-tool hacks.
- **Maintainability**: Copier boilerplates + ADRs make it possible to push cross-cutting improvements (e.g., Docker hardening, Makefile tweaks) into many projects.

### Negative

- **Initial Migration Cost**: Existing Python projects that don’t conform will require refactoring.
- **Template Lock-in**: Boilerplates become a de facto standard; divergence should be justified and documented.
- **Tooling Surface Area**: Developers must understand pytest, Docker, docker-compose, Makefiles, nox, and the Node E2E stack.

### Neutral

- **Framework Choice**: FastAPI is the default for now, but this ADR can be superseded if another framework becomes more appropriate; the structural decisions (pyproject, Docker, Makefile, nox) can outlive specific framework choices.

## Alternatives Considered

- **Bazel or Pants as a unified build system**:
  - Pros: Strong build graph semantics, remote caching, and multi-language support.
  - Cons: Replace rather than augment existing tooling; higher mental model and migration cost; harder to extract projects into standalone repos.
  - Rejected in favor of **augmenters** (Turborepo, nox) that preserve native Python workflows.

- **`requirements.txt` + virtualenv per project**:
  - Pros: Familiar to many Python developers.
  - Cons: Duplicative manifests; harder to standardize tooling; weaker integration with modern Python packaging (PEP 621) and tools like uv.
  - Rejected in favor of `pyproject.toml` as the single source of truth.

- **Python-native browser automation only (e.g., Playwright Python bindings)**:
  - Pros: Single-language testing story for some services.
  - Cons: Duplicates E2E stack already decided for web (Stagehand, Playwright JS, Vitest); splits ecosystem knowledge.
  - Rejected; we standardize on **Node-based E2E** against any backend, including Python.

## Rollout / Migration

1. **Boilerplates**:
   - Finalize FastAPI and package boilerplates under `boilerplate/apps/backend/python/fastapi` and related paths.
   - Ensure they include `pyproject.toml`, Docker, docker-compose, Makefile, README, and tests as described.
2. **New Projects**:
   - All new Python services and packages must use the Copier boilerplates and conform to this ADR.
3. **Existing Projects**:
   - Audit existing Python services/packages.
   - For each, create a migration plan to:
     - Introduce `pyproject.toml` if missing.
     - Align Docker/Dockerfile with base-alpine and non-root user.
     - Add or normalize Makefile and docker-compose.
     - Integrate with nox sessions.
4. **CI/CD**:
   - Add `nox -s tests` and `nox -s lint` to CI jobs for Python projects.
   - Ensure E2E pipelines use Stagehand/Playwright to hit Python backends where applicable.

## To Investigate

- Using **uv** more deeply for Python project management (install, test, run) while keeping `pyproject.toml` as canonical metadata.
- Refining Docker images to separate dev/tooling dependencies from production runtime dependencies.
- Deeper integration points between Turborepo and Python tasks (e.g., `turbo test` invoking `nox -s tests`).

## Validation

This decision will be evaluated based on:

- Reduction in Python-specific "how do I set this up?" questions during onboarding.
- Consistency of layout and tooling across new Python services/packages.
- CI stability and performance for Python pipelines (nox-based runs).
- Ease of applying cross-cutting changes via Copier updates.

## Review Schedule

- **Initial review**: 6 months after adoption (target: 2026-05-29).
- Trigger a review earlier if:
  - We adopt a significantly different Python framework.
  - Tooling changes (e.g., uv becomes the dominant orchestrator and replaces parts of this stack).

## References

- [ADR 20251106001: Use pnpm and Turborepo for Monorepo Management](./adr-20251106001-pnpm-and-turborepo.md)
- [ADR 20251106002: Vitest for Testing](./adr-20251106002-vitest-for-testing.md)
- [ADR 20251106012: Containerization Strategy](./adr-20251106012-containerization-strategy.md)
- [ADR 20251129001: Copier-Based Boilerplate Standard](./adr-20251129001-copier-based-boilerplate-standard.md)
- [ADR 20251129002: Architecture Decision Records Process](./adr-20251129002-architecture-decision-records-process.md)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [pytest Documentation](https://docs.pytest.org/)
- [nox Documentation](https://nox.thea.codes/en/stable/)
- [Stagehand](https://github.com/browserbase/stagehand)
- [Playwright](https://playwright.dev/)
