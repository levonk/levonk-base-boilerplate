---
type: Practice
title: dlt Declarative Ingestion — Auto-Schema Evolution and Incremental Loading
description: Use dlt (data load tool) for declarative ingestion from APIs, files, and databases with automatic schema inference, incremental loading, and schema evolution — replacing hand-coded extraction scripts with a self-maintaining pipeline.
tags: [data-engineering, ingestion, dlt, schema-evolution, incremental-loading, elt, api-extraction]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-dlt-workshop
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2026/workshops/dlt.md"
    title: "Data Engineering Zoomcamp — Workshop 1: Data Ingestion with dlt"
  - id: dlt-documentation
    resource: "https://dlthub.com/docs"
    title: "dlt (data load tool) documentation"
---

# dlt Declarative Ingestion

## Failure Mode

Data ingestion is implemented as bespoke Python scripts per source — each with
its own schema assumptions, error handling, and incremental-load logic. When a
source API adds a column or changes a field type, the script breaks silently or
drops the new field.

## Symptoms

- A new column appears in the source API response and is silently dropped
  because the ingestion script has a hardcoded schema.
- Incremental loading is reimplemented per source with off-by-one bugs (missing
  the last record on each run, or duplicating it).
- Adding a new data source takes days of boilerplate: auth, pagination, retry,
  schema mapping, write logic.
- Schema drift between source and warehouse goes undetected until a downstream
  dashboard breaks.

## Practice

### Declarative Extraction

- Use dlt to declare sources (APIs, files, databases) as Python objects with
  `dlt.resource` decorators — the framework handles pagination, retry, and
  auth.
- Let dlt infer the schema from the first batch of records instead of
  hand-defining every column.
- Write to any destination (BigQuery, Snowflake, Postgres, DuckDB) with a
  single `pipeline.run()` call — the destination adapter handles DDL.

### Incremental Loading

- Use `dlt.sources.incremental` with a cursor column (e.g. `updated_at`) to
  load only new or changed records.
- dlt tracks the last cursor value across runs — no manual bookmarking.
- For append-only sources, use `incremental` with `end_value` to bound the
  load window.

### Schema Evolution

- dlt detects new columns and type changes on subsequent loads and evolves the
  destination schema automatically (`ALTER TABLE ADD COLUMN`).
- Configure `schema_evolution` to control whether new columns are added
  silently or require explicit approval.
- Use the dlt dashboard to review schema changes before they propagate
  downstream.

### Normalization

- dlt normalizes nested JSON (arrays, objects) into separate tables with
  parent-child foreign keys — no manual unnesting.
- Column names are sanitized to destination-compatible identifiers
  (snake_case for SQL warehouses).

### Production Deployment

- Run dlt pipelines on a schedule via an orchestrator
  ([Airflow](/airflow-dag-patterns.md), Kestra, or cron).
- Use the dlt MCP server with AI agents to accelerate pipeline development and
  validate schema changes conversationally.
- Monitor pipeline runs through the dlt dashboard for load counts, schema
  changes, and data quality metrics.

## Related Concepts

- [ETL vs ELT](/etl-vs-elt.md) — dlt is an ELT ingestion tool (load raw,
  transform later).
- [Data Quality Testing](/data-quality-testing.md) — validate dlt-loaded data
  before it flows downstream.
- [dbt Transformation Patterns](/dbt-transformation-patterns.md) — transform
  the raw data dlt loads into the warehouse.
