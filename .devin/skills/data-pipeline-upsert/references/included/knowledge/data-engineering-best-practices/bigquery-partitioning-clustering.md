---
type: Practice
title: BigQuery Partitioning and Clustering — Cost and Query Performance
description: Partition BigQuery tables by ingestion time or date column to prune scanned bytes, and cluster by frequently-filtered columns to reduce slot consumption — together they control cost and latency on large tables.
tags: [data-engineering, bigquery, data-warehouse, partitioning, clustering, cost-optimization, query-performance]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-data-warehouse
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/03-data-warehouse"
    title: "Data Engineering Zoomcamp — Module 3: Data Warehousing (BigQuery partitioning and clustering)"
  - id: bigquery-partitioned-tables-docs
    resource: "https://cloud.google.com/bigquery/docs/partitioned-tables"
    title: "BigQuery documentation — Partitioned tables"
  - id: bigquery-clustered-tables-docs
    resource: "https://cloud.google.com/bigquery/docs/clustered-tables"
    title: "BigQuery documentation — Clustered tables"
---

# BigQuery Partitioning and Clustering

## Failure Mode

Large BigQuery tables are queried without partition or cluster pruning, so
every query scans the entire table. Costs scale linearly with table size, and
query latency grows until dashboards become unusable.

## Symptoms

- A simple `SELECT ... WHERE date = '2024-01-15'` scans 500 GB and costs $2.50
  per run on a table that has 5 years of data.
- The same dashboard query takes 30 seconds in January and 3 minutes in
  December because the table grew tenfold.
- BigQuery slot consumption spikes during peak hours because no queries are
  pruned.

## Practice

### Partitioning

- Partition by a `DATE` or `DATETIME` column, or by ingestion time
  (`_PARTITIONTIME` pseudo-column).
- Use daily partitions as the default — hourly partitions for high-volume
  streaming sources, monthly partitions for low-volume batch sources.
- Always filter queries by the partition column (`WHERE date >= ...`) so
  BigQuery prunes partitions and charges only for scanned bytes.
- Partition limits: a table can have at most 4000 partitions — plan the
  partition granularity accordingly.

### Clustering

- Cluster by the columns most frequently used in `WHERE`, `GROUP BY`, and
  `JOIN` filters (e.g. `customer_id`, `region`).
- Clustering orders data within each partition so BigQuery can skip blocks
  that do not match the filter.
- Up to 4 clustering columns; order them by filter selectivity (most selective
  first).
- Clustering is automatic and continuous — no maintenance, but it works best
  when data is loaded in sorted order (e.g. via `dlt` or batch loads sorted by
  the cluster key).

### Partitioning vs Clustering

| Aspect | Partitioning | Clustering |
|--------|-------------|------------|
| Pruning unit | Entire partition (day/hour/month) | Blocks within a partition |
| Cost impact | Reduces bytes billed | Reduces slot consumption |
| Column limit | 1 partition column | Up to 4 cluster columns |
| Maintenance | Partition expiry can auto-delete old data | Automatic, no maintenance |
| Use together | Yes — partition by date, cluster by filter columns | Yes |

### Cost Control

- Set partition expiry to auto-delete old partitions (e.g. 90 days for raw
  staging tables).
- Use `WHERE _PARTITIONTIME >= ...` in every production query to enforce
  partition pruning.
- Monitor bytes processed vs bytes billed in `INFORMATION_SCHEMA.JOBS` to
  detect queries that are not pruning.

### When Not to Partition

- Tables under 1 GB — the overhead of partition metadata exceeds the pruning
  benefit.
- Tables queried without any date or time filter — partitioning adds cost
  without benefit.

## Related Concepts

- [Data Warehouse Design](/data-warehouse-design.md) — physical table design
  that partitioning and clustering optimize.
- [dbt Transformation Patterns](/dbt-transformation-patterns.md) — use
  incremental models with partition filters to avoid full scans.
