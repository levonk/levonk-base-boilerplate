# Testing Strategies

Run the right tests at the right time. The test pyramid guides the mix;
parallelization and sharding keep CI fast; flaky test management keeps it
trustworthy.

## The Test Pyramid

| Level | Proportion | Speed | Run when |
|-------|-----------|-------|----------|
| Unit | ~70% | Seconds | Every PR, every push |
| Integration | ~20% | Tens of seconds | Every PR |
| E2E | ~10% | Minutes | Pre-merge on main, nightly |

Aim for fast feedback: unit tests catch most regressions in seconds.
Integration tests verify component boundaries. E2E tests verify user journeys
but are slow and brittle — run sparingly.

## Parallel Test Execution

Shard tests across matrix jobs to cut wall-clock time. Each shard runs a
subset of tests in parallel.

```yaml
jobs:
  test:
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3, 4]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version-file: .python-version
      - run: pip install -e . pytest-split
      - name: Run test shard
        run: pytest --shard-id=${{ matrix.shard }} --num-shards=4 --verbose
```

## Test Splitting Tools

| Tool | Language | How it splits | Notes |
|------|----------|---------------|-------|
| pytest-split | Python | `--shard-id` / `--num-shards` | Duration-based balancing |
| jest-circus | JS/TS | `--shard` flag | Built into Jest |
| knapsack-pro | Ruby, JS | Time-based splitting | Supports many runners |
| go test -parallel | Go | `t.Parallel()` | Within a single runner |
| JUnit + partitioner | JVM | Custom sharding | Needs a partitioner script |

## Flaky Test Management

Flaky tests erode trust in CI. Manage them explicitly.

| Technique | How | When |
|-----------|-----|------|
| Retry on failure | `nick-fields/retry@v3` action | Transient infra failures |
| Quarantine | Move to `@flaky` marker, skip in CI | Known flaky, fix later |
| `fail-fast: false` | Matrix continues if one shard fails | Never cancel all shards |
| Retry limit | Max 2 retries, then fail | Prevent infinite retries |
| Flaky detection | Run tests N times, flag variance | Periodic audit job |

```yaml
- uses: nick-fields/retry@v3
  with:
    max_attempts: 2
    timeout_minutes: 10
    command: pytest tests/integration/
```

## Coverage Reporting and Gates

Generate coverage reports and upload to a coverage service. Enforce a minimum
threshold to prevent regression.

```yaml
- run: pytest --cov=src --cov-report=xml --cov-fail-under=80
- uses: codecov/codecov-action@v4
  with:
    files: ./coverage.xml
    fail_ci_if_error: false
```

| Service | Free tier | Gate support |
|---------|-----------|--------------|
| Codecov | Yes (public repos) | `fail_under` in config |
| Coveralls | Yes (public repos) | Coverage drop threshold |
| SonarQube | Self-hosted | Quality gate rules |

## Test Organization

| Level | When to run | Parallelization | Target duration |
|-------|------------|-----------------|-----------------|
| Unit | Every PR + push | Sharded across runners | < 2 min total |
| Integration | Every PR | Sharded if slow | < 5 min total |
| E2E | Pre-merge on main, nightly | Parallel by feature | < 15 min total |
| Smoke | After deploy | Sequential | < 30 sec |

## Capturing Test Artifacts on Failure

Upload logs, screenshots, and reports when tests fail. Essential for debugging
flaky tests and E2E failures.

```yaml
- uses: actions/upload-artifact@v4
  if: failure()
  with:
    name: test-results-${{ matrix.shard }}
    path: |
      test-results/
      screenshots/
      **/*.log
    retention-days: 7
```

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| pytest-split | Python test sharding | Duration-based, balanced |
| jest --shard | JS/TS test sharding | Built into Jest |
| codecov-action | Coverage upload | Free for public repos |
| nick-fields/retry | Retry flaky steps | Configurable attempts |
| actions/upload-artifact | Capture failure artifacts | Auto-expiring retention |
