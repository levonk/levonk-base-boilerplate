---
type: Practice
title: Spark Best Practices — Partitioning, Caching, and Memory Tuning
description: Partition data by query pattern, cache only reused DataFrames, broadcast small dimension tables, reduce shuffle, and tune executor/driver memory with off-heap awareness.
tags: [data-engineering, spark, performance, partitioning, caching, shuffle, memory]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: spark-tuning-guide
    resource: "https://spark.apache.org/docs/latest/tuning.html"
    title: "Spark Tuning Guide"
  - id: spark-performance-faq
    resource: "https://spark.apache.org/docs/latest/sql-performance-tuning.html"
    title: "Spark Performance FAQ"
---

# Spark Best Practices

## Failure Mode

Spark jobs are slow or fail with OOM because data is not partitioned correctly,
intermediate DataFrames are cached unnecessarily, small tables trigger large
shuffles, and memory settings ignore off-heap and container limits.

## Symptoms

- `java.lang.OutOfMemoryError: Java heap space` on executors.
- Stages take forever due to skewed partitions (one partition much larger).
- Caching a 50 GB DataFrame when only a 1 MB result is needed.
- Joining a 100-row lookup table causes a full shuffle of the fact table.

## Practice

### Partitioning

- Partition by the column most used in `WHERE` clauses and joins.
- For time-series data, use `date` or `hour` partitions.
- Repartition by a high-cardinality key before a group/join if the natural
  distribution is skewed.
- Use `salting` for highly skewed keys to distribute work.

### Caching

- Cache only DataFrames that are reused multiple times.
- Use `persist(StorageLevel.MEMORY_AND_DISK_SER)` for large datasets that don't
  fit in memory.
- Unpersist as soon as possible to free memory.

### Broadcast Joins

- Broadcast dimension tables < 10 MB (tune `spark.sql.autoBroadcastJoinThreshold`).
- Avoid broadcasting large tables; it can OOM the driver.

### Shuffle Reduction

- Use `bucketBy` and `sortBy` for pre-shuffled data.
- Prefer `reduceByKey` over `groupByKey` in RDDs.
- Filter early to reduce the dataset before shuffling.

### Memory Tuning

- Leave ~20% of executor memory for off-heap and OS overhead.
- Set `spark.executor.memory` together with `spark.executor.memoryOverhead` and
  `spark.executor.memoryFraction`.
- In containers, set `spark.kubernetes.memoryOverheadFactor` appropriately.
