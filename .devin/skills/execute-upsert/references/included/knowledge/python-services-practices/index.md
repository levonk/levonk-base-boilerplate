---
okf_version: "0.2"
---

# Python Services Practices

A compounding knowledge base documenting practices for Python services,
packages, and standalone scripts in the monorepo — project layout,
pyproject.toml, FastAPI services, PEP 723 scripts, Docker, testing, and
orchestration with nox. Each concept captures specific standards sourced from
the Python services ADR and the PEP 723 ecosystem.

## Concepts

* [Overview](overview.md) - Synthesis of the full Python services practice set
* [standalone-scripts](standalone-scripts.md) - PEP 723 inline script metadata with `uv run --script`; decision tree for script vs. package vs. service; cli-tool-discovery for `uv` with pip fallback
* [pyproject-toml-manifest](pyproject-toml-manifest.md) - pyproject.toml as single source of truth; requirements.txt deprecated
* [fastapi-service-layout](fastapi-service-layout.md) - Standard FastAPI service layout with app/, tests/, Dockerfile, Makefile
* [python-package-layout](python-package-layout.md) - Non-service library layout with src/ and tests/
* [docker-standards](docker-standards.md) - Multi-stage builds on base-alpine, non-root user, PUID/PGID/TZ/PORT env vars
* [makefile-conventions](makefile-conventions.md) - Matching up/down targets, standard command set: dev/test/lint/format/typecheck/build/up/down
* [pytest-testing-baseline](pytest-testing-baseline.md) - pytest with asyncio and httpx/TestClient; browser E2E via Node harness
* [nox-orchestration](nox-orchestration.md) - nox for Python test/lint pipelines across projects; Nx handles Node/Docker/polyglot tasks at the monorepo root
