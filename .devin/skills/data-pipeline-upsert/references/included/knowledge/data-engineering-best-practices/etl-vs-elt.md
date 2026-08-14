---
type: Practice
title: ETL vs ELT — Transform Before Load vs Load Then Transform
description: ETL transforms before load; ELT loads raw data then transforms in-warehouse with dbt — choose by warehouse compute cost, transformation maturity, and data volume.
tags: [data-engineering, etl, elt, dbt, data-warehouse, transformation]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: dbt-documentation-what-is-dbt
    resource: "https://docs.getdbt.com/docs/introduction"
    title: "dbt documentation — What is dbt?"
  - id: apache-spark-documentation
    resource: "https://spark.apache.org/docs/latest/"
    title: "Apache Spark documentation"
  - id: orchestrating-both-etl-and-elt-tasks
    resource: "/airflow-dag-patterns.md"
    title: "orchestrating both ETL and ELT tasks"
  - id: in-warehouse-transformation-practices
    resource: "/dbt-transformation-patterns.md"
    title: "in-warehouse transformation practices"
---

# ETL vs ELT — Transform Before Load vs Load Then Transform

## When to Use ETL

ETL (Extract → Transform → Load) transforms data in a separate processing
engine **before** writing to the warehouse. Use ETL when:

- The warehouse compute is expensive or limited, and pre-transforming saves
  cost.
- Transformations require external libraries or engines not available in the
  warehouse (e.g., complex Python ML preprocessing, Spark jobs).
- Data volumes are small enough that a separate transform step is cheaper than
  loading raw data.
- Regulatory or governance requirements demand that only cleaned, transformed
  data enters the warehouse.

ETL is the traditional pattern and pairs naturally with
[Spark](/spark-best-practices.md) for large-scale transforms.

## When to Use ELT

ELT (Extract → Load → Transform) loads raw data into the warehouse first, then
transforms it using warehouse SQL with a tool like
[dbt](/dbt-transformation-patterns.md). Use ELT when:

- The warehouse has cheap, elastic compute (Snowflake, BigQuery, Redshift,
  Postgres).
- Transformations are SQL-expressible and benefit from warehouse parallelism.
- You want version-controlled, tested transformations (dbt models with tests).
- Raw data retention is valuable for reprocessing when logic changes.

Modern ELT with dbt has become the default for most analytics workloads because
warehouse compute is cheaper than maintaining a separate transform pipeline,
and SQL transformations are easier to test and version than external code.

## The Decision

| Factor | ETL | ELT |
|--------|-----|-----|
| Warehouse compute cost | High (pre-transform to save) | Low (transform in-warehouse) |
| Transform complexity | Non-SQL (ML, Python, Spark) | SQL-expressible |
| Raw data retention | Not needed | Valuable for reprocessing |
| Tooling | Spark, custom code | dbt, SQL |
| Testing | Custom | dbt tests, schema validation |
| Orchestration | [Airflow](/airflow-dag-patterns.md) with SparkOperator | Airflow with dbt CLI |

## Hybrid Pattern

Many platforms run both: ELT for standard analytics transforms (dbt models in
the warehouse) and ETL for specialized processing (Spark jobs for ML feature
engineering or large-scale joins that exceed warehouse limits). Airflow
orchestrates both as separate task groups in the same DAG.
