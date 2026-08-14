# CI/CD Audit Checklist

Full audit for existing CI/CD pipelines. Use when reviewing an existing
pipeline for gaps, inefficiencies, and security issues.

## Audit Workflow

1. **Read fully** — all workflow files, composite actions, Dockerfiles, deploy
   configs. Run `scripts/analyze_pipeline.py --path <repo>`.
2. **Audit** — check each category below against the pipeline.
3. **Classify** — mark each finding Automatic or Interactive (see
   `references/interactive-vs-automatic.md`).
4. **Propose** — present findings prioritized by Critical/Important/Nice-to-have.
5. **Confirm** — get user approval on interactive changes.
6. **Apply** — one logical change per commit, automatic changes first.
7. **Validate** — run pipeline locally, verify nothing broke.

## Checklist

| Category | Check | Priority | Auto/Interactive |
|----------|-------|----------|------------------|
| **Incremental Builds** | Does CI use path filters to skip unchanged components? | Important | Automatic |
| | Are job-level filters used (not workflow-level `paths:`)? | Important | Automatic |
| | Are shared library dependencies tracked in filters? | Nice-to-have | Automatic |
| **Pre-built Images** | Is a pre-built CI image used for heavy toolchains? | Important | Interactive |
| | Does the image rebuild only when env definition changes? | Important | Automatic |
| | Is the image scanned before publishing? | Critical | Automatic |
| **Security Scans** | Is secret scanning (Gitleaks) run on every PR? | Critical | Automatic |
| | Is SAST (CodeQL/Semgrep) configured? | Important | Automatic |
| | Is dependency scanning enabled? | Important | Automatic |
| | Is container scanning (Trivy/Grype) run on images? | Critical | Automatic |
| | Do scans gate on critical/high, report on medium/low? | Important | Interactive |
| | Are scan results uploaded as SARIF to GitHub Security? | Nice-to-have | Automatic |
| **Guardrails** | Are required status checks configured? | Critical | Interactive |
| | Is branch protection enabled on main? | Critical | Interactive |
| | Is a merge queue configured for high-traffic repos? | Nice-to-have | Interactive |
| | Are force-pushes to main disabled? | Critical | Interactive |
| **Versioning** | Are git tags created on releases? | Important | Interactive |
| | Is semantic versioning automated (semantic-release)? | Nice-to-have | Interactive |
| | Are changelogs generated automatically? | Nice-to-have | Automatic |
| | Is commitlint enforcing conventional commits? | Nice-to-have | Interactive |
| **Provenance** | Are container images signed with cosign? | Important | Automatic |
| | Are SBOMs generated (Syft) and attached? | Important | Automatic |
| | Are OCI labels (revision, source, version) embedded? | Important | Automatic |
| | Is signature verification run before deployment? | Critical | Interactive |
| | Is SLSA provenance generated? | Nice-to-have | Automatic |
| **Tooling Alignment** | Is devbox.json the single source of truth? | Important | Interactive |
| | Does CI read tool versions from version files? | Important | Automatic |
| | Does Dockerfile use same versions as devbox.json? | Important | Automatic |
| | Are lock files committed (devbox.lock, go.sum)? | Important | Automatic |
| | Are CI tools (act, trivy, gitleaks) in devbox.json? | Nice-to-have | Automatic |
| **Testing** | Are unit tests run on every PR? | Critical | Automatic |
| | Are tests parallelized/sharded? | Important | Automatic |
| | Is `fail-fast: false` set on test matrices? | Important | Automatic |
| | Is coverage reported and gated (fail-under)? | Important | Automatic |
| | Are flaky tests managed (retry, quarantine)? | Nice-to-have | Automatic |
| | Are test artifacts captured on failure? | Nice-to-have | Automatic |
| | Is the test pyramid balanced (~70/20/10)? | Nice-to-have | Interactive |
| **DRY CI Files** | Are reusable workflows used for shared logic? | Important | Interactive |
| | Are composite actions used for repeated step sequences? | Important | Interactive |
| | Is there one workflow per concern (build/test/deploy)? | Nice-to-have | Interactive |
| | Is the rule of three applied (extract after 3 uses)? | Nice-to-have | Interactive |
| **Deployment Validation** | Are smoke tests run after deploy? | Critical | Automatic |
| | Are health checks (liveness/readiness) configured? | Important | Automatic |
| | Is a rollback path defined before deploying? | Critical | Interactive |
| | Is progressive delivery (canary/blue-green) used? | Nice-to-have | Interactive |
| | Are error rate and latency monitored during rollout? | Important | Automatic |
| **Concurrency** | Is `concurrency: cancel-in-progress` set? | Important | Automatic |
| | Is `timeout-minutes` set on every job? | Important | Automatic |
| **Permissions** | Are `permissions:` scoped to minimum required? | Critical | Automatic |
| | Is `packages: write` only on workflows that publish? | Critical | Automatic |
| **Container** | Is `shell: bash -l {0}` used when running inside a container? | Important | Automatic |
| | Does `.dockerignore` exclude secret directories? | Critical | Automatic |
| | Is the CI image built before the main workflow uses it? | Important | Interactive |
| **Local testing** | Can the pipeline be tested locally with act? | Nice-to-have | Automatic |
| **Monitoring** | Are CI run times tracked for regression detection? | Nice-to-have | Automatic |
| | Are flaky jobs identified and quarantined? | Important | Automatic |
| **Cache** | Do cache keys include environment definition hash? | Important | Automatic |
| **Secrets** | Are multi-line secrets handled for local act testing? | Nice-to-have | Automatic |

## CI Pipeline Monitoring

- Track CI run times over time to detect slow degradation (new dependencies,
  growing test suite)
- Monitor for flaky jobs — jobs that pass on retry but fail intermittently
- Watch runner minutes consumption, especially on paid plans
- Set up alerts for jobs that exceed expected duration (e.g., build > 10min
  when it used to be 3min)
- Tools: GitHub Actions insights tab, InfluxDB + Grafana for custom dashboards

## Scoring Guide

| Priority | Action | When to fix |
|----------|--------|-------------|
| Critical | Fix immediately | Blocks this PR or next release |
| Important | Fix soon | Within the current sprint |
| Nice-to-have | Fix when convenient | Backlog, address opportunistically |

**Triage rule:** Fix all Critical findings before proposing Important or
Nice-to-have improvements. Never leave a Critical finding unaddressed in an
audit.

## Finding Classification

Each finding should include:
- **Category** and **Check** from the table above
- **Current state** — what the pipeline does now
- **Desired state** — what it should do
- **Priority** — Critical / Important / Nice-to-have
- **Auto/Interactive** — whether to apply directly or propose
- **Effort** — Small (< 1hr) / Medium (< 1day) / Large (> 1day)

Present findings as a prioritized table. Apply automatic changes first
(separate commits), then propose interactive changes for confirmation.
