# Review Checklist — Expanded

Detailed expansion of the code review checklist with examples and edge cases.
Use this reference when a category needs deeper scrutiny than the summary in
[SKILL.md](../SKILL.md.tmpl) provides.

## Infrastructure, Build & Deployment

### Build Configuration

- **CI pipeline changes** — any new steps, caches, or secrets added? Are they
  scoped to the minimum required permissions?
- **Dependency manifests** — `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`
  changes should be accompanied by a lockfile update. Verify the lockfile matches.
- **Build scripts** — custom build steps must be reproducible and deterministic.
  Flag any reliance on network access during the build.
- **Base images** — when container base images change, check for CVEs, size
  impact, and whether the new image is pinned to a digest, not just a tag.

### Deployment

- **Deployment manifests** — Kubernetes manifests, Helm values, Terraform, or
  CloudFormation changes must be reviewed for drift against the running
  environment.
- **Rollback safety** — can the deployment be rolled back without data loss? Are
  migrations forward-compatible (expand-then-contract)?
- **Environment variables** — new variables must be documented in the project's
  env manifest and provisioned in all target environments before deployment.

### Example

```yaml
# Anti-pattern: untagged base image
FROM node:20

# Better: pinned digest
FROM node:20.11.1@sha256:<digest>
```

## Schemas & Data

### Database Migrations

- **Reversibility** — every migration should have a tested down/rollback path.
- **Data preservation** — column renames and type changes must not destroy
  existing data. Use multi-step migrations (add new column → backfill → switch →
  drop old).
- **Locking** — large table alterations can lock production tables. Prefer
  online migrations or batched backfills.
- **Defaults** — new NOT NULL columns must have a default or be added nullable
  first.

### API & Type Contracts

- **Breaking changes** — removing a field, changing a type, or narrowing a
  range is breaking. Bump the API version or use additive-only changes.
- **Versioning** — if the API is versioned (URL path, header, or content type),
  ensure the new version is routed and documented.
- **Serialization** — verify JSON/protobuf serialization handles optional fields
  and unknown future fields gracefully.

### Example

```typescript
// Breaking: narrowing type from string to enum
interface User { status: string } // before
interface User { status: 'active' | 'inactive' } // after — breaks existing clients

// Safer: additive
interface User { status: string; statusEnum?: 'active' | 'inactive' }
```

## Integrations

### Service Contracts

- **Consumers** — list every consumer of the changed contract. Coordinate
  deployment order so consumers are updated before producers break.
- **Webhooks & events** — payload changes must be backward-compatible or
  versioned. Document the schema in the event catalog.
- **Idempotency** — webhook handlers must be idempotent; duplicate deliveries
  must not cause side effects.
- **Retries & timeouts** — verify retry policies, exponential backoff, jitter,
  and max-attempt limits are preserved or improved.

### Third-Party APIs

- **Version pinning** — pin to a specific API version; do not rely on
  latest/default.
- **Auth flows** — OAuth token refresh, API key rotation, and credential
  storage must follow the project's secret management standard.
- **Rate limits** — new integrations must respect documented rate limits and
  implement backoff.

## Security

### Auth & Permissions

- **Auth flow changes** — any change to login, session, token issuance, or
  permission checks warrants a dedicated security review. Run the project's
  security review process (e.g., `/security-review`).
- **Privilege escalation** — verify the change does not widen permissions for
  untrusted users.
- **Session handling** — token expiry, refresh rotation, and revocation must be
  preserved.

### Input Handling

- **Validation at trust boundaries** — validate and sanitize all external input
  (user input, API responses, file uploads) at the boundary, not deep in
  business logic.
- **Parameterized queries** — never concatenate SQL. Use parameterized queries
  or an ORM that does.
- **Output encoding** — encode data when rendering to HTML, JSON, or shell to
  prevent injection.

### Secrets

- **No secrets in code** — scan for hardcoded API keys, tokens, private keys,
  and connection strings. Use the project's secret scanner.
- **No secrets in logs** — ensure log statements, error messages, and stack
  traces do not leak credentials.
- **Secret rotation** — if new secrets are introduced, document the rotation
  procedure.

### Dependencies

- **Vulnerability scan** — run `npm audit`, `pip-audit`, `cargo audit`, or the
  project's SCA tool on new dependencies.
- **License compatibility** — verify the dependency license is compatible with
  the project (e.g., GPL in a permissively licensed project is a problem).
- **Minimal dependencies** — are there unnecessary dependencies added? If a
  heavy dependency is introduced, could a minimal inline version suffice?

## Performance

### Database

- **N+1 queries** — look for loops that issue one query per iteration. Use
  batch loading or joins.
- **Indexes** — do new query patterns need indexes? Are existing indexes still
  used or now redundant?
- **Query plans** — for complex queries, verify the query plan with
  `EXPLAIN` against a representative dataset.

### Caching

- **Cache opportunities** — are there repeated expensive computations or
  lookups that could be cached?
- **Invalidation** — cache invalidation must be correct; stale data can be
  worse than slow data. Identify the invalidation trigger for every cache entry.
- **TTL** — set a TTL even when invalidation is event-driven, as a safety net.

### Hot Path

- **Loops** — avoid O(n²) or worse inside request handlers over unbounded `n`.
- **Allocation** — reduce unnecessary allocations in hot loops; reuse buffers
  where safe.
- **Async** — move blocking work (I/O, heavy CPU) off the request path.

## Accessibility

### Keyboard & Focus

- **Keyboard navigation** — every interactive element must be reachable and
  operable via keyboard alone.
- **Focus management** — when dialogs, menus, or route changes occur, focus
  must move to a logical element and be trapped within modals.
- **Visible focus** — focus indicators must be visible and meet contrast
  requirements.

### ARIA & Semantics

- **ARIA roles** — use semantic HTML first; add ARIA only when semantics are
  missing. Misused ARIA is worse than no ARIA.
- **Labels** — form controls must have associated labels; icon-only buttons
  need `aria-label`.
- **Live regions** — dynamic content updates must use `aria-live` so screen
  readers announce them.

### Visual

- **Color contrast** — text and interactive elements must meet WCAG 2.1 AA
  contrast ratios (4.5:1 for normal text, 3:1 for large text).
- **Responsive design** — verify layouts at common breakpoints; do not assume
  a single viewport.
- **Motion** — respect `prefers-reduced-motion`; do not rely on color alone to
  convey meaning.

### States

- **Loading** — show loading indicators for async operations longer than ~200ms.
- **Empty** — design empty states that guide the user to the next action.
- **Error** — error states must be recoverable and explain what happened in
  plain language.
- **Offline** — if the app supports offline, verify graceful degradation when
  connectivity is lost.

## Cross-Cutting Concerns

### Maintainability

- **Naming** — names should reveal intent. Flag single-letter variables outside
  tight loops and abbreviations that are not domain-standard.
- **Comments** — comments should explain *why*, not *what*. Flag code that
  needs a comment to be understandable — consider a rename instead.
- **Complexity** — high cyclomatic complexity or deeply nested conditionals
  are candidates for extraction.

### Compatibility & Portability

- **OS assumptions** — hardcoded paths (`/tmp`, `C:\`), shell calls, or
  platform-specific APIs limit portability.
- **Architecture** — avoid assumptions about pointer size, endianness, or
  alignment unless the code is platform-specific by design.

### Licensing, Subscriptions & Compliance

- **Licensing** — new dependencies must be license-compatible. Flag GPL,
  AGPL, or copyleft licenses in permissive projects.
- **Subscriptions** — does the change introduce a paid-tier dependency or
  service? Flag for product/budget review.
- **Compliance** — GDPR (data subject rights), HIPAA (PHI handling), PCI
  (cardholder data), and regional data residency rules may apply. Flag any
  change that touches personal or regulated data.
- **Profit** — does the change affect billing, entitlements, or usage metering?
  Verify accuracy.

### Internationalization

- **Strings** — user-facing strings must go through the I18N layer, not be
  hardcoded.
- **Routes** — new routes must be internationalized if the app supports
  locale-prefixed routing.
- **Pluralization & formatting** — use the I18N library's pluralization and
  date/number formatting, not manual concatenation.

### Feature Flags

- **New flags** — if the change is risky or incomplete, gate it behind a flag.
- **Flag lifecycle** — flags should have an owner and a removal date. Flag
  flags that are added without a cleanup plan.

### Observability

- **Logging** — backend changes must log meaningful events (not just
  errors). Verify log levels and structured fields.
- **Metrics** — new endpoints, jobs, or queues should emit metrics (latency,
  throughput, error rate).
- **Tracing** — distributed tracing spans should cover new service boundaries.
- **Alerts** — if the change affects an SLO, verify the alerting thresholds
  still make sense.
