# Incremental Builds

Path-aware CI that only runs jobs affected by the changes in a pull request or
push. Reduces CI minutes and shortens feedback loops without sacrificing safety.

## When to Use / Not to Use

**Use:** Monorepos, multi-component repos, CI runs exceeding a few minutes,
per-minute CI billing.
**Don't:** Single-package repos where every change affects the whole build, or
CI runs under 2 minutes (filtering overhead isn't worth it).

## Approaches

| Approach | Tool | CI-agnostic | Complexity |
|----------|------|-------------|------------|
| Path filters | dorny/paths-filter@v4 | GitHub Actions | Low |
| Raw git-diff | `git diff --name-only` | Yes | Low |
| Dependency graph | Nx / Turborepo | Yes (CLI) | High |
| Workflow-level `paths:` | Native GitHub Actions | GitHub Actions | Low |

## The Required-Checks Deadlock

**Problem:** Workflow-level `paths:` triggers create a branch-protection
deadlock. If a required status check only runs when certain paths change, a PR
touching *other* paths won't trigger that check. Branch protection then blocks
the merge because the check never reported a status.

**Solution:** Use job-level filtering. The workflow always runs on every PR (no
`paths:` on the trigger), but individual jobs skip themselves based on changed
files. The job still reports a status (skipped), satisfying branch protection.

## Concrete Example: dorny/paths-filter

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
      docs: ${{ steps.filter.outputs.docs }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v4
        id: filter
        with:
          filters: |
            backend:
              - 'backend/**'
              - 'go.mod'
              - 'go.sum'
            frontend:
              - 'frontend/**'
              - 'package-lock.json'
            docs:
              - 'docs/**'
              - '*.md'

  backend-tests:
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: backend/go.mod
      - run: cd backend && go test ./...

  frontend-tests:
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd frontend && npm ci && npm test

  docs-build:
    needs: detect-changes
    if: needs.detect-changes.outputs.docs == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd docs && mkdocs build
```

## CI-Agnostic git-diff

```bash
CHANGED=$(git diff --name-only origin/${BASE_BRANCH}...HEAD)
if echo "$CHANGED" | grep -qE '^backend/'; then
  cd backend && go test ./...
fi
if echo "$CHANGED" | grep -qE '^frontend/'; then
  cd frontend && npm ci && npm test
fi
```

## Dependency-Aware Filtering

When a shared library changes, rebuild its dependents. Track dependencies
explicitly in the filter:

```yaml
filters: |
  shared-lib:
    - 'libs/shared/**'
  backend:
    - 'backend/**'
    - 'libs/shared/**'   # backend depends on shared-lib
  frontend:
    - 'frontend/**'
    - 'libs/shared/**'   # frontend depends on shared-lib
```

For complex graphs, use a tool that computes the graph automatically.

## Manual Trigger Fallback

Manual triggers (`workflow_dispatch`) have no diff baseline — change detection
can't determine what changed because there's no push or PR to diff against.
Without handling, the filter outputs nothing and all jobs skip, leaving the
run empty.

Fix: on `workflow_dispatch`, force all profile/component flags to true so
everything builds:

```yaml
- name: Detect changed profiles
  id: changes
  run: |
    if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
      echo "current=true" >> "$GITHUB_OUTPUT"
      echo "private=true" >> "$GITHUB_OUTPUT"
      exit 0
    fi
    # ... normal git diff logic ...
```

Also note: the first commit on a new branch has no `HEAD~1` — `git diff
HEAD~1` fails. Handle with an `|| echo ""` fallback so the diff is empty
rather than erroring out:

```bash
CHANGED=$(git diff --name-only HEAD~1 2>/dev/null || echo "")
```

## Monorepo Strategies

| Tool | Command | How it works |
|------|---------|--------------|
| Nx | `nx affected -t build` | Analyzes project graph, runs affected tasks |
| Turborepo | `turbo run build --filter=...[origin/main]` | Content-hash based, caches outputs |
| Lerna | `lerna run build --since origin/main` | Package-level diffing (legacy) |

```yaml
# Nx (needs full history for graph diffing)
nx-affected:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with: { fetch-depth: 0 }
    - run: pnpm exec nx affected -t lint test build --base=origin/main

# Turborepo
turbo-affected:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - run: pnpm dlx turbo run lint test build --filter=...[origin/main]
```

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| dorny/paths-filter | GitHub Actions path filtering | Most popular, well-maintained |
| Nx | JS/TS monorepos with project graph | Also supports Go, Rust via plugins |
| Turborepo | JS/TS monorepos, caching focus | Remote caching via Vercel |
| git-diff | CI-agnostic, simple setups | Roll your own logic |
