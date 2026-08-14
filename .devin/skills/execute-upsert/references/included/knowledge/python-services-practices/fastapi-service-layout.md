---
type: Practice
title: FastAPI Service Layout
description: Standard FastAPI service layout with app/ module, tests/ directory, /health endpoint, pyproject.toml, Dockerfile, docker-compose.yml, and Makefile.
tags: [python, fastapi, service-layout, project-structure, health-endpoint]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# FastAPI Service Layout

## Failure Mode

Inconsistent Python service layouts make navigation difficult. Missing health
endpoints prevent container orchestration from detecting dead services. Missing
boilerplate files (Dockerfile, Makefile) require ad-hoc setup.

## Practice

New FastAPI services follow this canonical layout:

```text
service/
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI app object + /health endpoint
├── tests/
│   ├── test_main.py     # TestClient exercises /health
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── pyproject.toml
├── README.md
└── .gitignore
```

### Key Points

- `app/main.py` defines the FastAPI application object (`app = FastAPI(...)`)
- Exposes a `/health` endpoint for healthchecks
- `tests/test_main.py` exercises `/health` and core behavior using `TestClient`
  and/or `httpx`
- `pyproject.toml` declares the app package and dependencies
- `dev` optional-dependencies include pytest, mypy, ruff, black, isort

### README Requirements

- Overview and purpose
- Local development flow (`uv`/`pip`, `pytest`)
- Docker build/run via Makefile

## Related Concepts

- [pyproject.toml Manifest](pyproject-toml-manifest.md) — Manifest for the service
- [Docker Standards](docker-standards.md) — Container for the service
- [Makefile Conventions](makefile-conventions.md) — Commands for the service
