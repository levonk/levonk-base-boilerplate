---
type: Practice
title: dbt Transformation Patterns — Models, Tests, Snapshots, and Materializations
description: Use dbt to transform data in the warehouse with clear model layers, materialization strategies, generic and custom tests, snapshots for SCD2, and incremental models for large tables.
tags: [data-engineering, dbt, data-warehouse, transformations, tests, snapshots, incremental]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: dbt-docs-materializations
    resource: "https://docs.getdbt.com/docs/build/materializations"
    title: "dbt docs: Materializations"
  - id: dbt-docs-tests
    resource: "https://docs.getdbt.com/docs/build/tests"
    title: "dbt docs: Tests"
  - id: dbt-docs-snapshots
    resource: "https://docs.getdbt.com/docs/build/snapshots"
    title: "dbt docs: Snapshots"
---

# dbt Transformation Patterns

## Failure Mode

SQL transformation logic is scattered in BI tools and ad-hoc queries, leading to
inconsistent metrics, untested changes, and full-table refreshes that fail on
large datasets.

## Symptoms

- The same metric is defined differently in two dashboards.
- A schema change in the source breaks downstream reports without warning.
- `SELECT *` models run for hours because they cannot be incremental.
- Historical dimension changes are lost because there is no SCD2 logic.

## Practice

### Model Layers

Organize models into layers:

- `staging` — cleaned source data, 1:1 with source tables.
- `intermediate` — business logic, joins, aggregations.
- `mart` — final tables for analytics and BI consumption.

### Materializations

| Materialization | When to Use |
|-----------------|---------------|
| `view` | Lightweight transformations, always-fresh data, small source tables |
| `table` | Heavy transformations queried often, data fits in memory |
| `incremental` | Large tables, append-only or upsert semantics, partition pruning |
| `ephemeral` | Reusable CTEs not materialized directly |

### Incremental Models

- Use `is_incremental()` to branch logic.
- Provide an `incremental_strategy` (`merge`, `delete+insert`, `append`).
- Use a `unique_key` to enable upserts.
- Filter source data by `max(_loaded_at)` or partition to reduce scanned rows.

### Tests

- Generic tests: `not_null`, `unique`, `accepted_values`, `relationships`.
- Custom tests for business rules (e.g. revenue > 0).
- Source freshness tests on `loaded_at` columns.
- Run `dbt build` (compile + run + test) in CI.

### Snapshots

- Use dbt snapshots for slowly changing dimensions (SCD2).
- Define `unique_key` and `updated_at`/`dbt_updated_at`.
- Query snapshots with `dbt_valid_to is null` for current records.
