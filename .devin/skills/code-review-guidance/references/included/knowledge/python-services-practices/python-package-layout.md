---
type: Practice
title: Python Package Layout
description: Non-service Python library layout with src/ directory, tests/, pyproject.toml, and README. No Dockerfile or Makefile by default unless explicitly containerized.
tags: [python, package-layout, library, src-layout, project-structure]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# Python Package Layout

## Failure Mode

Python libraries without consistent layout have missing `__init__.py` files,
inconsistent test placement, and unclear module boundaries.

## Practice

Python libraries (non-HTTP services) follow this layout:

```text
package/
├── src/
│   ├── my_package/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── services.py
├── tests/
│   ├── test_models.py
│   ├── test_services.py
├── pyproject.toml
├── README.md
└── .gitignore
```

### Differences from Services

- No `Dockerfile` or `docker-compose.yml` by default (unless explicitly
  containerized)
- No `Makefile` required, but recommended where packages have non-trivial
  workflows
- Uses `src/` layout (PEP 621 compatible) instead of flat layout

## Related Concepts

- [FastAPI Service Layout](fastapi-service-layout.md) — Service counterpart
- [pyproject.toml Manifest](pyproject-toml-manifest.md) — Manifest for the package
