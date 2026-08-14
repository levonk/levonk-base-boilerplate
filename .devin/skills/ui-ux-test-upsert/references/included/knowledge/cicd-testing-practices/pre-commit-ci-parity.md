---
type: Practice
title: Pre-Commit CI Parity
description: Same checks run locally and in CI via shared Dockerized quality script. FAST_MODE for local, FULL_MODE for CI. Eliminates "works on my machine" and ensures consistent enforcement.
tags: [pre-commit, ci-cd, parity, quality, docker, consistency]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20251218002-shared-quality-scripts
    resource: "internal-docs/adr/adr-20251218002-shared-quality-scripts.md"
    title: "levonk-base-boilerplate"
---


# Pre-Commit CI Parity

## Failure Mode

Different checks run locally vs CI. "Works on my machine" syndrome. Drift
between hook and CI tool versions. Developers bypass slow checks by skipping
hooks, then CI fails unexpectedly.

## Practice

**Same checks run locally and in CI** via the shared Dockerized quality script.

### How It Works

1. **Pre-commit hook**: Calls `scripts/run-quality-checks.sh` with `FAST_MODE=1`
   for quick feedback
2. **GitHub Actions**: Calls same script with `FULL_MODE=1` for complete
   validation
3. **Same Docker images**: Same pinned tool versions in both contexts
4. **Same scanner configs**: Same rules, same thresholds

### Developer Experience

- `FAST_MODE=1`: Lint only, runs in seconds
- `MARKDOWN_ONLY=1`: For docs-only changes
- `SKIP_RUNTIME_SCAN=1`: Skip heavy runtime scans
- `FULL_MODE=1`: Everything (CI default)

### Benefits

- **Consistent enforcement**: Same checks, same results
- **Faster onboarding**: One interface to learn
- **Easier upgrades**: Patch tooling centrally in one file
- **No surprises**: If it passes locally, it passes in CI

## Related Concepts

- [Shared Quality Scripts](shared-quality-scripts.md) — The script that enables
  parity
- [Vitest Unified Runner](vitest-unified-runner.md) — Tests run through this
  parity pipeline
