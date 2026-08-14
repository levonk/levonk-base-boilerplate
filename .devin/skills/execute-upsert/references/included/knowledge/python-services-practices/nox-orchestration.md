---
type: Practice
title: nox Orchestration
description: nox as primary orchestration for Python test/lint pipelines across projects. Discovers pyproject.toml, installs -e .[dev], provides tests and lint sessions. Nx handles Node/Docker/polyglot tasks at the monorepo root.
tags: [python, nox, orchestration, nx, monorepo, ci-cd]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# nox Orchestration

## Failure Mode

No monorepo-wide Python checks means Python projects drift independently. Using
Bazel/Pants as a unified build system replaces native Python tooling and creates
high migration cost.

## Practice

Use **nox** as the primary orchestration layer for Python test/lint pipelines
across projects.

### noxfile.py

- Discovers Python projects by scanning for `pyproject.toml`
- For each project, installs `-e .[dev]`
- Provides standard sessions:
  - `tests`: run pytest for all projects with `tests/`
  - `lint`: run ruff + mypy for `app/` and `tests/`

### Nx Integration

- Nx is the unified orchestrator for Node/TypeScript, Docker, Rust, and other
  polyglot tasks at the monorepo root (see
  [typescript-monorepo-best-practices/pnpm-nx-monorepo.md](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md)).
- Nx may invoke Python service commands via `package.json` scripts or
  `project.json` targets that shell out to `nox -s tests` / `nox -s lint`.
- Nx does **not** replace Python's build system — nox remains the Python-side
  orchestrator.
- Possible future: an `nx run-many -t test` target that delegates to
  `nox -s tests` for Python projects, so a single `nx affected -t test` command
  covers both Node and Python.

### Why nox Over Bazel/Pants

- **Augments** native Python tooling instead of replacing it
- Lower mental model and migration cost
- Easier to extract projects into standalone repos
- Preserves pytest, uv, pip, FastAPI ecosystem

## Related Concepts

- [pyproject.toml Manifest](pyproject-toml-manifest.md) — nox installs from dev extras
- [pytest Testing Baseline](pytest-testing-baseline.md) — nox runs pytest
