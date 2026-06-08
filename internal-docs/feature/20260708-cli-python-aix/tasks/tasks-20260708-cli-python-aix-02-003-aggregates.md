---
story_id: "02-003"
story_title: "Pre-computed Aggregates"
story_name: "aggregates"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260708-cli-python-aix/story-02-003-aggregates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["output.py", "aggregates.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "aggregates", "output"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement pre-computed aggregates including total counts in list output and derived status fields. Compute counts efficiently at query time and include lightweight summaries inline. Apply to detail and list views where relevant.

## Sub-Tasks

- [ ] Implement aggregate count computation for list queries — `output/aggregates.py`
- [ ] Add total count to list output format — `output/aggregates.py`
- [ ] Format counts as "count: 30 of 847 total" — `output/aggregates.py`
- [ ] Implement derived status field computation — `output/aggregates.py`
- [ ] Add lightweight summary inline (e.g., checks: 3/3 passed) — `output/aggregates.py`
- [ ] Only include derived fields backend can provide cheaply — `output/aggregates.py`
- [ ] Apply aggregates to detail views — `output/aggregates.py`
- [ ] Apply aggregates to list views where relevant — `output/aggregates.py`
- [ ] Optimize count queries for efficiency — `output/aggregates.py`
- [ ] Test aggregate counts for all list commands — `tests/test_aggregates.py`
- [ ] Test derived status fields — `tests/test_aggregates.py`
- [ ] Test aggregate computation performance — `tests/test_aggregates.py`

## Relevant Files

- `apps/cli/python/core/files/output/aggregates.py.jinja` — Aggregate computation
- `apps/cli/python/core/files/output/schema.py.jinja` — Schema with aggregate fields
- `apps/cli/python/core/files/tests/test_aggregates.py.jinja` — Aggregate tests

## Acceptance Criteria

- [ ] List output includes total count
- [ ] Count format is "count: 30 of 847 total"
- [ ] Derived status fields are included inline
- [ ] Derived fields are lightweight summaries only
- [ ] Only cheap-to-compute derived fields are included
- [ ] Aggregates apply to detail views
- [ ] Aggregates apply to list views where relevant
- [ ] Count queries are efficient
- [ ] All tests pass

## Test Plan

- Unit: Test aggregate count computation
- Unit: Test derived status field computation
- Unit: Test aggregate efficiency
- Integration: Test actual CLI output with aggregates
- Performance: Benchmark aggregate computation
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log aggregate computation events
- Log aggregate computation performance
- Track aggregate usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Aggregate computation too slow — Mitigation: Optimize queries, cache if needed
- Risk: Derived fields too expensive — Mitigation: Only include cheap fields, measure performance
- Risk: Aggregate format inconsistent — Mitigation: Standardize format, test thoroughly

## Dependencies & Sequencing

- Depends on: 02-001 (Minimal Schemas)
- Unblocks: 02-004 (Empty States)

## Definition of Done

- Aggregate counts implemented
- Derived status fields implemented
- Aggregates apply to relevant views
- Computation is efficient
- Comprehensive test coverage
- Documentation updated

## Commit Conventions

- `feat(output): add pre-computed aggregate counts`
- `feat(output): add derived status fields`
- `test(output): add tests for aggregates`
