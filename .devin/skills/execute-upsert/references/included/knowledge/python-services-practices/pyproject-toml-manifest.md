---
type: Practice
title: pyproject.toml as Single Source of Truth
description: All Python apps and packages use pyproject.toml as the canonical manifest; requirements.txt is deprecated except for narrowly scoped tooling.
tags: [python, pyproject-toml, pep621, dependencies, manifest]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# pyproject.toml as Single Source of Truth

## Failure Mode

Mixed use of `requirements.txt` and `pyproject.toml` creates duplicative
manifests, harder tooling standardization, and weaker integration with modern
Python packaging (PEP 621) and tools like uv.

## Practice

All Python apps and packages use **`pyproject.toml`** as the canonical manifest.
`requirements*.txt` is deprecated except for narrowly scoped tooling (e.g.,
third-party templates that cannot yet be migrated).

### Required Sections

```toml
[project]
name = "app"
version = "0.1.0"
dependencies = ["fastapi", "uvicorn"]

[project.optional-dependencies]
dev = ["pytest", "pytest-asyncio", "httpx", "mypy", "ruff", "black", "isort"]
```

### Why Not requirements.txt

- Duplicative manifests
- Harder to standardize tooling
- Weaker integration with PEP 621 and uv
- No support for optional dependencies (dev vs prod)

## Related Concepts

- [FastAPI Service Layout](fastapi-service-layout.md) — Where pyproject.toml lives
- [nox Orchestration](nox-orchestration.md) — nox installs from pyproject.toml dev extras
