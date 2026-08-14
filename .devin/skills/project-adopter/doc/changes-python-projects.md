# Python Project Changes

This document outlines all changes made by the project-adopter skill specifically for Python projects.

## Detection Patterns

Projects are detected as Python when they contain:
- `pyproject.toml`
- `poetry.lock`
- `requirements.txt`
- `setup.py`
- `Pipfile`

## Files Created

### Core Files
- **devbox.json** - Environment with Python packages
- **justfile** - Python-specific targets and commands
- **README.md** - Python development setup guide
- **AGENTS.md** - Python AI agent configuration
- **.envrc** - Python environment configuration

## devbox.json Changes

### Adopt Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "python3", "poetry", "black", "ruff", "mypy", "pytest"
  ]
}
```

### Standardize Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "python3", "poetry", "black", "ruff", "mypy", "pytest",
    "pytest-cov", "pytest-xdist", "hatch", "build", "twine",
    "bandit", "safety", "pip-audit"
  ]
}
```

## justfile Changes

### Language-Specific *_impl Targets
```just
# Python-specific implementations
dev_impl:
    poetry run python main.py

build_impl:
    poetry build

test_impl:
    poetry run pytest

lint_impl:
    poetry run ruff check .

typecheck_impl:
    poetry run mypy src/

clean_impl:
    rm -rf dist/ build/ *.egg-info/ __pycache__/ .pytest_cache/

bootstrap_impl:
    poetry install
    echo "Python development environment ready!"
```

### Additional Targets
```just
# Development loop
loop: || (bootstrap build test dev)

# CI pipeline
ci: || (bootstrap lint typecheck test build)

# Package management
install:
    poetry install

update:
    poetry update

# Security
audit:
    poetry run safety check
    poetry run pip-audit
```

## pyproject.toml Surgical Changes

### Development Dependencies Added (Adopt Mode)
```toml
[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
pytest-cov = "^4.0"
black = "^23.0"
ruff = "^0.1"
mypy = "^1.0"
```

### Development Dependencies Added (Standardize Mode)
```toml
[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
pytest-cov = "^4.0"
pytest-xdist = "^3.0"
black = "^23.0"
ruff = "^0.1"
mypy = "^1.0"
bandit = "^1.7"
safety = "^2.3"
hatch = "^1.9"
build = "^0.10"
twine = "^4.0"
```

## Configuration Files

### pytest.ini (Created if missing)
```ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --verbose --tb=short
```

### ruff.toml (Created if missing)
```toml
line-length = 88
target-version = "py311"
select = ["E", "F", "W", "I", "N", "UP"]
```

### mypy.ini (Created if missing)
```ini
[mypy]
python_version = 3.11
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Essential packages only** - python3, poetry, black, ruff, mypy, pytest
- **Basic configuration** - Minimal pytest, ruff, mypy configs
- **Standard commands** - install, build, test, lint, typecheck
- **Preserves existing** - Won't override existing pyproject.toml sections

### Standardize Mode (Comprehensive)
- **Full ecosystem** - Adds pytest-cov, pytest-xdist, bandit, safety, etc.
- **Complete configuration** - Comprehensive linting and security rules
- **Advanced commands** - Security audit, package publishing, coverage
- **Standardizes** - Enforces our preferred Python configurations

## Related Documentation

- [All Projects Changes](changes-all-projects.md)
- [Node.js Project Changes](changes-nodejs-typescript-projects.md)
- [Rust Project Changes](changes-rust-projects.md)
- [Go Project Changes](changes-go-projects.md)
- [Java Project Changes](changes-java-projects.md)

<!-- vim: set ft=markdown: -->
