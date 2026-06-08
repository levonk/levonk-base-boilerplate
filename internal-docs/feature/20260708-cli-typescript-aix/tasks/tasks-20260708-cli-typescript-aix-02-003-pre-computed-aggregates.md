---
story_id: "02-003"
story_title: "Pre-computed Aggregates"
story_name: "pre-computed-aggregates"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260708-cli-typescript-aix/story-02-003-pre-computed-aggregates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["aggregates", "output"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "aggregates", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement pre-computed aggregates including total counts in list output and derived status fields (e.g., checks: 3/3 passed, comments: 7). Compute counts efficiently at query time and include lightweight summaries inline.

## Sub-Tasks

- [ ] Implement aggregate count computation — `src/aggregates/counter.mts`
- [ ] Implement derived status field computation — `src/aggregates/derived.mts`
- [ ] Add aggregate formatting for list output — `src/aggregates/formatter.mts`
- [ ] Integrate aggregates into list commands — `src/commands/list.mts`
- [ ] Add aggregate formatting for detail views — `src/commands/view.mts`
- [ ] Optimize count queries for efficiency — `src/aggregates/optimizer.mts`
- [ ] Add tests for aggregate counts — `tests/aggregates/counter.test.mts`
- [ ] Add tests for derived status fields — `tests/aggregates/derived.test.mts`
- [ ] Add integration tests for aggregate output — `tests/aggregates/integration.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/aggregates/counter.mts.jinja` — New file for count computation
- `apps/cli/typescript/core/files/src/aggregates/derived.mts.jinja` — New file for derived status fields
- `apps/cli/typescript/core/files/src/aggregates/formatter.mts.jinja` — New file for aggregate formatting
- `apps/cli/typescript/core/files/src/aggregates/optimizer.mts.jinja` — New file for query optimization
- `apps/cli/typescript/core/files/src/commands/list.mts.jinja` — List command (updated with aggregates)
- `apps/cli/typescript/core/files/src/commands/view.mts.jinja` — View command (updated with aggregates)
- `apps/cli/typescript/core/files/tests/aggregates/counter.test.mts.jinja` — New file for counter tests
- `apps/cli/typescript/core/files/tests/aggregates/derived.test.mts.jinja` — New file for derived tests
- `apps/cli/typescript/core/files/tests/aggregates/integration.test.mts.jinja` — New file for integration tests

## Acceptance Criteria

- [ ] List output includes total count: `count: 30 of 847 total`
- [ ] Counts are computed efficiently at query time
- [ ] Derived status fields are included inline where relevant
- [ ] Derived fields are lightweight summaries only (not full data)
- [ ] Example derived fields: `checks: 3/3 passed`, `comments: 7`
- [ ] Derived fields only included when backend can provide cheaply
- [ ] Aggregates apply to both list and detail views
- [ ] All tests pass

## Test Plan

- Unit: Test aggregate count computation
- Unit: Test derived status field computation
- Unit: Test query optimization
- Integration: Test list output with counts
- Integration: Test detail output with derived fields
- Performance: Verify count queries are efficient
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log aggregate computation time
- Log derived field computation
- Track query performance metrics

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Count queries may be slow for large datasets — Mitigation: Optimize queries, use caching if needed
- Risk: Derived fields may be expensive to compute — Mitigation: Only include cheaply computable fields
- Risk: Aggregates may add complexity — Mitigation: Keep logic simple, document well

## Dependencies & Sequencing

- Depends on: 02-001 (Minimal Schemas)
- Unblocks: 02-004 (Empty States)

## Definition of Done

- Aggregate counts implemented
- Derived status fields implemented
- Aggregates integrated into list and detail views
- Query optimization implemented
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(aggregates): implement aggregate count computation`
- `feat(aggregates): implement derived status fields`
- `feat(aggregates): add aggregate formatting`
- `feat(commands): integrate aggregates into list output`
- `feat(commands): integrate aggregates into detail views`
- `feat(aggregates): optimize count queries`
- `test(aggregates): add tests for aggregate system`
