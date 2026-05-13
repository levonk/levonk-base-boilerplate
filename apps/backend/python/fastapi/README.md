# FastAPI Backend Boilerplate

This template scaffolds a production-leaning FastAPI backend service using `pyproject.toml` as the single source of dependency truth.

## Features

- FastAPI application with `/health` endpoint
- `pyproject.toml` (uv-/PEP 621-compatible) for dependencies and tooling
- Multi-stage Dockerfile (Alpine-based) with non-root user (PUID/PGID/TZ aware)
- `docker-compose.yml` for local development
- `Makefile` with `build` and `up` targets for Docker, plus basic Python dev tasks
- `pytest` test suite with a health-check test

## Getting Started

```bash
# (Recommended) create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate

# Install in editable mode with dev extras
pip install -e ".[dev]"

# Run tests
pytest

# Run the app locally
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Docker

```bash
# Build and run via Makefile
make build
make up
```

The container image respects `PUID`, `PGID`, and `TZ` environment variables for user and timezone configuration.
