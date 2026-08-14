# Guardrails and Gates

Branch protection, merge queues, and status checks that enforce quality without
blocking developers in deadlocks.

## Branch Protection Rules

| Rule | Purpose | When to require |
|------|---------|-----------------|
| Require PR | No direct pushes to main | Always for protected branches |
| Require approvals | Human review before merge | 1+ for most teams, 2+ for critical paths |
| Status checks | CI must pass before merge | After CI is stable |
| Linear history | No merge commits, rebase only | Keeps history clean, easier reverts |
| Code owner reviews | Domain experts review their areas | Monorepos or shared repos |
| Stale PR auto-close | Prevents bitrot | 30-90 days |

## Required Status Checks

**Key rule:** The check name must exactly match the job name as it appears in the
GitHub Actions UI. If your job is named `test (matrix)`, that's the name to add
to required checks — not just `test`.

When using merge queues, checks must run on the *merged* state, not the PR head.
Add the `merge_group` trigger so checks fire when a PR is queued:

```yaml
on:
  pull_request:
  merge_group:
    types: [checks_requested]
```

This ensures the queue validates the squashed/merged result, not the PR branch,
preventing last-minute conflicts from sneaking through.

## Merge Queues

Merge queues batch PRs and test the merged state before finalizing — eliminating
the "PR passed CI but main is broken after merge" problem. Features: batch
multiple PRs (amortizes CI cost), test merged state (catches conflicts),
auto-requeue on failure, temporary `gh-readonly-queue/...` branch.

Enable in repo settings → General → Pull Requests → Merge queue, or via
rulesets. Configure merge method, build concurrency, and minimum group size.

## Blocking vs Quality Gates

| Gate type | Blocks merge? | Example |
|-----------|---------------|---------|
| Blocking | Yes — required status check | Unit tests, SAST CRITICAL |
| Quality | No — advisory, comments on PR | Coverage drop, lint warnings |
| Informational | No — logged only | Dependency age, bundle size |

Keep blocking gates minimal — each is a potential deadlock. Use quality gates
for things that matter but shouldn't stop an urgent fix.

## GitHub Rulesets

Rulesets are the successor to classic branch protection:

- **Multiple rule sets per branch** — layer rules instead of one config
- **Condition-based targeting** — apply by filename, ref name, or environment
- **Bypass lists** — let specific roles skip rules without disabling them
- **Enforcement status** — `active` or `evaluate` (logs without blocking)

### Ruleset example (via API / UI)

```json
{
  "name": "main-branch-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["refs/heads/main", "refs/heads/release/*"] }
  },
  "rules": [
    { "type": "deletion" },
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          { "context": "test" }, { "context": "lint" },
          { "context": "security / secret-scan" }
        ],
        "strict_required_status_checks_policy": true
      }
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "required_review_thread_resolution": true
      }
    },
    { "type": "merge_queue", "parameters": { "merge_method": "squash" } }
  ],
  "bypass_actors": [
    { "actor_type": "integration", "actor_id": 12345, "bypass_mode": "always" }
  ]
}
```

## Concrete Example: merge_group Trigger

```yaml
name: CI
on:
  pull_request:
  merge_group:
    types: [checks_requested]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: ./scripts/test.sh --shard ${{ matrix.shard }}
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./scripts/lint.sh
```

GitHub fires the workflow on PR open/update and when the PR enters the merge
queue. The queue waits for all checks on the `gh-readonly-queue/...` branch to
pass before finalizing the merge.

## Code Owner Reviews

Create a `CODEOWNERS` file to route reviews automatically:

```
*                           @devops-team
/backend/                   @backend-team
/frontend/                  @frontend-team
/.github/workflows/         @devops-team @security-team
/terraform/                 @devops-team @security-team
```

Pair with `require_code_owner_review: true` in rulesets so owned paths can't
merge without the owner's approval.

## Concurrency and Timeout Management

`concurrency: cancel-in-progress: true` cancels redundant runs on the same
branch — prevents wasted runner minutes when pushing multiple commits quickly.
`timeout-minutes` on each job prevents hung builds from consuming runner minutes
indefinitely. Always set both — a job without a timeout can run for 6 hours
(GitHub's default) before being killed.

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      ...
```

Use different concurrency groups for different branches to avoid canceling PR
runs when main is pushed (e.g., `group: ci-${{ github.ref }}` scopes per ref).

## Least-Privilege Permissions

GitHub Actions tokens default to broad permissions (contents: write, packages:
write, etc.). Scope `permissions:` at the workflow or job level to minimum
required. Common patterns:

- Build-only workflow: `permissions: { contents: read }`
- Publish-to-registry workflow: `permissions: { contents: read, packages: write }`
- Deploy workflow: `permissions: { contents: read, deployments: write }`

Never use `permissions: write-all` — it grants everything including admin access.

```yaml
name: Build
on: [pull_request]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: just build
```

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| GitHub Rulesets | Modern branch protection | Supersedes classic protection |
| Merge queues | Integration safety | Built into GitHub |
| CODEOWNERS | Review routing | Native GitHub feature |
| Mergify | Advanced merge automation | Beyond GitHub native queue |
