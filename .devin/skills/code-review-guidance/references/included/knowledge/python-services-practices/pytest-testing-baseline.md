---
type: Practice
title: pytest Testing Baseline
description: pytest as default test runner with pytest-asyncio and httpx/TestClient. Browser/E2E tests use Stagehand + Playwright from Node harness, not Python.
tags: [python, pytest, testing, asyncio, httpx, stagehand, playwright, e2e]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: levonk-base-boilerplate
    resource: internal-docs/adr/adr-20251129003-python-services-and-packages-standard.md
    title: levonk-base-boilerplate
---

# pytest Testing Baseline

## Failure Mode

Using Python Playwright bindings duplicates the E2E stack already decided for
web (Stagehand, Playwright JS, Vitest). Splitting browser automation across
Python and Node divides ecosystem knowledge.

## Practice

### Python Unit/Integration Tests

- Use **pytest** as the default test runner
- Tests live under `tests/` with naming convention `test_*.py` or `*_test.py`
- Use `pytest-asyncio` for async test support
- Use `httpx`/`TestClient` for FastAPI endpoint testing

### Browser/E2E Tests for Python Backends

- Use **Stagehand** and **Playwright** from a **Node-based test harness**
- Not from Python — keeps browser automation in the TypeScript/Node ecosystem
- Target Python backends via HTTP (e.g., `http://localhost:<PORT>/...`)
- Rely on the service being up (via `docker compose`, `make up`, or CI)

### Why Node-Based E2E

Stagehand/Playwright are first-class in the Node ecosystem. Keeping browser
automation there avoids duplicating the E2E stack and splitting ecosystem
knowledge. Python focuses on API-level and unit-level correctness.

## Related Concepts

- [FastAPI Service Layout](fastapi-service-layout.md) — Tests live in tests/
- [nox Orchestration](nox-orchestration.md) — nox runs pytest across projects
