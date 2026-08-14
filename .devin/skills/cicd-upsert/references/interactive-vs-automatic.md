# Interactive vs Automatic Changes

When updating existing CI/CD, classify every change as automatic or
interactive. Optimizations and quality improvements within the existing
process are automatic. Build process changes that require the project to adapt
are interactive.

## Key Principle

> Optimizations and quality improvements within the existing process are
> automatic. Build process changes that require the project to adapt are
> interactive.

## Decision Framework

| Change type | Automatic | Interactive | Rationale |
|-------------|-----------|-------------|-----------|
| Add non-blocking check | Yes | | No risk to existing flow |
| Add blocking gate | | Yes | Can block merges unexpectedly |
| Optimize caching | Yes | | Performance only, no behavior change |
| Add quality metrics | Yes | | Informational, non-blocking |
| Fix typos | Yes | | No functional impact |
| Update tool version (patch) | Yes | | Backward compatible |
| Update tool version (major) | | Yes | May break build |
| Add provenance/SBOM | Yes | | Additive, doesn't change build |
| Change required status checks | | Yes | Affects merge requirements |
| Alter deployment strategy | | Yes | Changes production flow |
| Modify branch protection | | Yes | Affects all contributors |
| Restructure workflows | | Yes | Changes build process |
| Change build commands | | Yes | Project must adapt |
| Add security scan (non-blocking) | Yes | | Report only |
| Add security scan (blocking) | | Yes | Can fail builds |

## Governance Patterns

| Pattern | Use case | Implementation |
|---------|----------|----------------|
| PR labels for automated changes | Distinguish bot PRs from human PRs | `automated-ci`, `ci-improvement` labels |
| Auto-merge for safe changes | Merge automatic changes without review | Enable auto-merge on labeled PRs |
| Draft PRs for disruptive changes | Signal that review is required | Open as draft, request explicit review |
| Separate commits per change | Reviewability and revertability | One logical change per commit |

## Decision Flowchart

```
Proposed CI/CD change
        │
        ▼
Does it change the build process?
        │
   ┌────┴────┐
   YES       NO
   │         │
   ▼         ▼
INTERACTIVE  Does it add a blocking gate?
              │
         ┌───┴───┐
         YES     NO
         │       │
         ▼       ▼
      INTERACTIVE  Does it change merge/deploy requirements?
                       │
                  ┌────┴────┐
                  YES       NO
                  │         │
                  ▼         ▼
               INTERACTIVE  AUTOMATIC
                              (apply directly,
                               separate commit)
```

## Concrete Classification Examples

**Automatic (apply, create PR, separate commit):**
- Add Trivy container scan as non-blocking advisory step
- Add `actions/cache` for Go module downloads
- Fix typo in workflow name
- Bump `actions/checkout` from v3 to v4
- Add SBOM generation with Syft (additive, no gate)
- Add coverage reporting upload to Codecov

**Interactive (propose, explain, wait for confirmation):**
- Change deployment from rolling to canary
- Add `golangci-lint` as a required status check
- Restructure monolith workflow into per-concern workflows
- Bump Go from 1.21 to 1.22 (may require code changes)
- Add merge queue to branch protection
- Change build from `make` to `just`

## Workflow for Applying Changes

1. **Classify** each proposed change using the decision framework
2. **Apply automatic changes** directly — separate commit per change
3. **Propose interactive changes** — present prioritized list with
   before/after, benefit, and risk
4. **Wait for confirmation** on interactive changes — author accepts all,
   a subset, or rejects
5. **Apply approved interactive changes** — separate commit per change
6. **Validate** — run pipeline locally, verify nothing broke

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| PR labels | Distinguish change types | `automated-ci`, `interactive` |
| GitHub auto-merge | Merge safe changes automatically | Enable on labeled PRs |
| `act` | Validate changes locally before pushing | Run via devbox |
