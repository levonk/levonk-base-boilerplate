# Modular and Parallel CI

Keep CI files DRY. Reusable workflows, composite actions, and job matrices
eliminate copy-pasted definitions and enable parallel execution.

## Patterns Overview

| Pattern | Use case | Complexity |
|---------|----------|------------|
| Reusable workflow | Share an entire workflow across repos | Medium |
| Composite action | Share a step sequence within a repo | Low |
| Job matrix | Run the same job across variants | Low |
| Dynamic matrix | Generate matrix from changed files | Medium |
| Workflow per concern | Separate workflows for build/test/deploy | Low |

## Reusable Workflows

Call a workflow from another via `workflow_call`. Pass inputs and secrets
explicitly. The caller stays thin; the callee holds the logic.

```yaml
# .github/workflows/test.yml (reusable)
name: Test
on:
  workflow_call:
    inputs:
      python-version: { required: true, type: string }
    secrets:
      codecov-token: { required: false }
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "${{ inputs.python-version }}" }
      - run: pip install -e . pytest pytest-cov
      - run: pytest --cov=src --cov-report=xml
      - uses: codecov/codecov-action@v4
        with: { token: "${{ secrets.codecov-token }}" }
```

```yaml
# .github/workflows/ci.yml (caller)
name: CI
on: [pull_request]
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      python-version: "3.12"
    secrets:
      codecov-token: ${{ secrets.CODECOV_TOKEN }}
```

## Composite Actions

Bundle a step sequence into a single action. Best for setup steps repeated
across workflows.

```yaml
# .github/actions/setup-env/action.yml
name: Setup Environment
inputs:
  cache-key: { required: false, default: default }
runs:
  using: composite
  steps:
    - uses: actions/checkout@v4
    - uses: jetify-com/devbox-install-action@v0
      with: { enable-cache: true, devbox-path: devbox.json }
    - run: just install-deps
      shell: bash
```

```yaml
# Usage in a workflow
steps:
  - uses: ./.github/actions/setup-env
  - run: just build
```

## Job Matrices

Run a job across multiple variants (OS, language version, shard). Always set
`fail-fast: false` so one failure doesn't cancel the others. Use `exclude` to
skip specific combinations.

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, macos-latest]
    python-version: ["3.11", "3.12"]
    exclude:
      - os: macos-latest
        python-version: "3.11"   # skip known-broken combo
```## Dynamic Matrices

Generate the matrix from changed files. Only run jobs for packages that
changed. Requires a job that outputs a JSON matrix.

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v4
      - id: set-matrix
        run: |
          CHANGED=$(git diff --name-only origin/main...HEAD | grep -oE '^packages/[^/]+/' | sort -u)
          MATRIX=$(echo "$CHANGED" | jq -R -s -c '{package: split("\n") | map(select(length > 0))}')
          echo "matrix=$MATRIX" >> "$GITHUB_OUTPUT"
  build:
    needs: detect
    strategy:
      fail-fast: false
      matrix:
        include: ${{ fromJson(needs.detect.outputs.matrix) }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd packages/${{ matrix.package }} && make build
```

## DRY CI File Organization

| File | Concern |
|------|---------|
| `ci.yml` | Orchestrator — calls reusable workflows |
| `build.yml` | Reusable build workflow |
| `test.yml` | Reusable test workflow |
| `deploy.yml` | Reusable deploy workflow |
| `actions/setup-env/` | Composite action for environment setup |
| `actions/security-scan/` | Composite action for security scans |

The rule of three: if a step sequence appears in three workflows, extract it
into a composite action or reusable workflow.

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| `workflow_call` | Share workflows across repos | Built into GitHub Actions |
| Composite actions | Share step sequences | Single responsibility principle |
| `fromJSON()` | Dynamic matrices | Parse job outputs as matrix |
| dorny/paths-filter | Feed dynamic matrices | Pairs well with dynamic matrix |
