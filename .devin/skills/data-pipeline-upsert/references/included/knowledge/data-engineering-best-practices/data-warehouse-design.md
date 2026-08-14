---
type: Practice
title: Data Warehouse Design — Star Schema, SCD, and Fact Table Grain
description: Design warehouses around star schemas with explicit fact table grain, slowly changing dimensions (SCD1/SCD2), and surrogate keys for stable joins.
tags: [data-engineering, data-warehouse, star-schema, snowflake-schema, scd, fact-tables, dimension-tables]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: kimball-group-dimensional-modeling
    resource: "https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/"
    title: "Kimball Group — Dimensional Modeling"
---

# Data Warehouse Design

## Failure Mode

Data warehouses become unmaintainable because tables are normalized like OLTP
databases, fact table grain is unclear, and dimension history is lost whenever a
source value changes.

## Symptoms

- Reports show inconsistent revenue because one analyst joins on `customer_id`
  and another on `customer_email`.
- A dimension value changes and all historical reports silently update.
- Fact tables have duplicated rows because the grain was not defined.
- Joins across many normalized tables are slow and brittle.

## Practice

### Star Schema by Default

- One fact table surrounded by dimension tables.
- Fact tables contain foreign keys and measures.
- Dimension tables contain descriptive attributes.
- Prefer star over snowflake for query simplicity and join performance.

### Fact Table Grain

Define the grain explicitly:

- "One row per product sold per transaction line per day."
- Do not mix grains in the same fact table.
- Include a degenerate dimension (transaction ID, line number) to enforce grain.

### Slowly Changing Dimensions

| Type | Behavior | When to Use |
|------|----------|-------------|
| SCD0 | Never changes | Static attributes (e.g. country code) |
| SCD1 | Overwrite | Corrections where history is not needed |
| SCD2 | Track history with start/end dates | When you need point-in-time reporting |
| SCD3 | Track previous value only | Limited history, one prior value |

Use dbt snapshots for SCD2 implementation.

### Surrogate Keys

- Use integer or hash surrogate keys for dimensions, not natural keys.
- Natural keys (e.g. `customer_email`) can change and are not stable.
- Surrogate keys isolate the warehouse from source system changes.
