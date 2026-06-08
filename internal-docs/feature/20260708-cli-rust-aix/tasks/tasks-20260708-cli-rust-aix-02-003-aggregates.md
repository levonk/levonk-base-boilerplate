---
story_id: "02-003"
story_title: "Pre-computed Aggregates"
story_name: "aggregates"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 2
parallel_id: 3
branch: "feature/current/20260708-cli-rust-aix/story-02-003-aggregates"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["data-layer", "output-formats"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "output", "axi"]
due: "2026-06-16"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement pre-computed aggregates (total counts, derived status fields) to reduce the need for follow-up API calls. Include total count in list output and lightweight derived status summaries in detail views. This optimizes agent interactions by providing commonly-needed data upfront.

## Sub-Tasks

- [ ] Design aggregate computation strategy for efficiency
- [ ] Implement total count computation for list queries
- [ ] Add count field to list output structures
- [ ] Format count as "count: 30 of 847 total"
- [ ] Identify commonly-needed derived status fields
- [ ] Implement derived status field computation (e.g., "3/3 passed", "7 comments")
- [ ] Add derived status fields to detail view structures
- [ ] Optimize aggregate queries for performance
- [ ] Integrate aggregate counts into TOON output
- [ ] Integrate aggregate counts into JSON output
- [ ] Integrate derived status fields into TOON output
- [ ] Integrate derived status fields into JSON output
- [ ] Ensure aggregates are only computed when backend can provide them cheaply
- [ ] Write unit tests for aggregate computation
- [ ] Write unit tests for derived status field computation
- [ ] Write integration tests for aggregate output formatting
- [ ] Write performance tests for aggregate queries
- [ ] Update CLI help text to document aggregate fields

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/aggregates/counter.rs` — Count computation logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/aggregates/tests.rs` — Tests for count computation (new file)
- `boilerplate/apps/cli/rust/core/src/internal/aggregates/derived.rs` — Derived status field logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/aggregates/derived_tests.rs` — Tests for derived fields (new file)
- `boilerplate/apps/cli/rust/core/src/internal/output/formatter.rs` — Integrate aggregates into output
- `boilerplate/apps/cli/rust/core/src/internal/output/tests.rs` — Tests for aggregate integration
- `boilerplate/apps/cli/rust/core/src/data/queries.rs` — Update queries to include aggregates
- `boilerplate/apps/cli/rust/core/src/data/tests.rs` — Tests for aggregate queries

## Acceptance Criteria

- [ ] Total count is computed efficiently for all list queries
- [ ] Count output format matches specification ("count: 30 of 847 total")
- [ ] Derived status fields are computed for relevant detail views
- [ ] Derived status fields provide lightweight summaries only
- [ ] Aggregates are integrated into TOON output correctly
- [ ] Aggregates are integrated into JSON output correctly
- [ ] Aggregate computation doesn't significantly impact query performance
- [ ] Aggregates are only computed when backend can provide them cheaply
- [ ] All aggregate functionality has test coverage
- [ ] Help text documents aggregate fields

## Test Plan

- Unit: `cargo test --lib internal::aggregates`
- Unit: `cargo test --lib data`
- Integration: Test aggregate output formatting
- Performance: Benchmark aggregate query performance
- Manual: Verify aggregate accuracy against actual data

## Observability

- Add logging for aggregate computation decisions at debug level
- Add metrics for aggregate computation performance
- Add metrics for aggregate field usage

## Compliance

- Ensure aggregate computation doesn't expose sensitive information
- Validate that derived status fields don't leak confidential data

## Risks & Mitigations

- Risk: Aggregate computation may impact query performance — Mitigation: Optimize queries, add caching where appropriate
- Risk: Derived status fields may be computationally expensive — Mitigation: Only compute cheap-to-calculate fields

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- No other dependencies (can be developed in parallel with 02-001, 02-002, 02-004)

## Notes

- Aggregate computation should be optimized for common query patterns
- Consider caching aggregate results for frequently accessed data
- Document which derived status fields are available for each command
