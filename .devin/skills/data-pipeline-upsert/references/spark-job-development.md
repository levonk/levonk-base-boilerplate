# Spark Job Development

> Detailed guidance for authoring Apache Spark jobs — partitioning, caching,
> broadcast joins, memory tuning, DataFrame API vs SQL, and UDFs.

## Spark Job Structure

### Minimal PySpark Job

```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

def main():
    spark = (
        SparkSession.builder
        .appName("daily-aggregation")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .config("spark.sql.shuffle.partitions", "200")
        .getOrCreate()
    )

    # Read source data (partition-aware)
    df = (
        spark.read
        .option("header", "true")
        .schema(input_schema)
        .parquet("s3://bucket/events/")
        .filter(F.col("date") == run_date)
    )

    # Transform
    result = (
        df.groupBy("user_id", "date")
        .agg(F.count("*").alias("event_count"))
    )

    # Write (idempotent — overwrite partition)
    (
        result.write
        .mode("overwrite")
        .partitionBy("date")
        .parquet("s3://bucket/aggregations/")
    )

    spark.stop()

if __name__ == "__main__":
    main()
```

### Submitting a Spark Job

```bash
# Local
spark-submit --master local[4] --name daily-agg jobs/daily_aggregation.py

# On Kubernetes (Spark on K8s operator)
spark-submit \
  --master k8s://https://kubernetes.default.svc \
  --deploy-mode cluster \
  --conf spark.kubernetes.container.image=ghcr.io/org/spark:3.5 \
  --conf spark.kubernetes.namespace=spark \
  --conf spark.executor.instances=4 \
  --conf spark.executor.memory=4g \
  --conf spark.driver.memory=2g \
  jobs/daily_aggregation.py
```

## Partitioning

Partitioning is the single most impactful optimization for Spark jobs.

### Read Partitioning

Read only the partitions you need — partition pruning:

```python
# Good — partition pruning (reads only the date partition)
df = spark.read.parquet("s3://bucket/events/").filter(F.col("date") == "2026-07-17")

# Bad — reads everything, then filters
df = spark.read.parquet("s3://bucket/events/").filter(F.col("date") == "2026-07-17")
# (Actually the same code, but if the data is NOT partitioned by date,
# Spark reads all files. Ensure the source is partitioned.)
```

### Write Partitioning

Partition output by date or a natural key for efficient downstream reads:

```python
df.write.mode("overwrite").partitionBy("date").parquet("s3://bucket/output/")
```

### Shuffle Partitioning

`spark.sql.shuffle.partitions` controls the number of partitions after a
shuffle (groupBy, join). Default is 200 — tune based on data size:

- Small data (<1 GB): 50-100
- Medium data (1-100 GB): 200 (default)
- Large data (>100 GB): 400-1000

With AQE (Adaptive Query Execution) enabled, Spark can coalesce partitions
automatically:

```python
.config("spark.sql.adaptive.enabled", "true")
.config("spark.sql.adaptive.coalescePartitions.enabled", "true")
```

### Repartition vs Coalesce

- **`repartition(n)`** — full shuffle, creates exactly `n` partitions. Use
  before a wide transformation (groupBy, join) to increase parallelism.
- **`coalesce(n)`** — no shuffle, merges existing partitions. Use to reduce
  partitions before writing (e.g., coalesce to 1 for a single output file,
  but only if the data is small — large data in one partition causes OOM).

```python
# Increase parallelism before a join
df = df.repartition(400, "join_key")

# Reduce files before writing small output
df.coalesce(1).write.mode("overwrite").parquet("s3://bucket/small/")
```

## Caching

Caching stores a DataFrame in memory across actions. Use sparingly — cache
is expensive (memory) and can cause OOM if overused.

### When to Cache

- The DataFrame is used **more than once** in the same job.
- The computation to produce it is expensive (wide transformations, complex
  joins).
- The DataFrame fits in memory (check with `df.cache()` then monitor the
  storage tab in the Spark UI).

### When NOT to Cache

- The DataFrame is used only once — caching adds overhead with no benefit.
- The DataFrame is too large for memory — use checkpointing to disk instead.
- Small DataFrames — the overhead of caching exceeds the recomputation cost.

```python
# Cache a reused DataFrame
df.cache()
df.count()  # Materialize the cache (cache is lazy)

# Use it
result1 = df.filter(...).agg(...)
result2 = df.join(other, ...)

# Unpersist when done
df.unpersist()
```

### Checkpointing

For very large lineages (hundreds of transformations), checkpoint to disk
to truncate the lineage and avoid stack overflow / recomputation on retry:

```python
spark.sparkContext.setCheckpointDir("s3://bucket/checkpoints/")
df = df.checkpoint(eager=True)
```

## Broadcast Joins

When one side of a join is small (<10 MB by default), broadcast it to all
executors to avoid a shuffle:

```python
# Explicit broadcast
from pyspark.sql import functions as F
result = large_df.join(F.broadcast(small_df), "key")

# Automatic broadcast (if spark.sql.autoBroadcastJoinThreshold is set high enough)
result = large_df.join(small_df, "key")
```

- **`spark.sql.autoBroadcastJoinThreshold`** — default 10 MB. Increase if
  your dimension tables are larger but still fit in broadcast.
- Broadcast eliminates the shuffle for that join — major speedup.
- Do NOT broadcast large tables — it will OOM the driver (broadcast collects
  the table to the driver first).

## Memory Tuning

### Key Memory Settings

| Config | Default | Purpose |
|--------|---------|---------|
| `spark.executor.memory` | 1g | Heap per executor |
| `spark.driver.memory` | 1g | Driver heap |
| `spark.executor.memoryOverhead` | 10% of executor.memory | Off-heap (Python, etc.) |
| `spark.memory.fraction` | 0.6 | Fraction of heap for execution + storage |
| `spark.memory.storageFraction` | 0.5 | Fraction of memory.fraction reserved for cached blocks |

### Common OOM Causes

1. **Single partition too large** — a groupBy or coalesce(1) creates one
   partition with all the data. Repartition to increase parallelism.
2. **Broadcast too large** — broadcasting a table larger than
   `autoBroadcastJoinThreshold` without increasing the threshold. The driver
   collects the full table and OOMs.
3. **Collect to driver** — `df.collect()` pulls all data to the driver. Use
   `df.toLocalIterator()` or write to storage instead.
4. **Python UDF memory** — Python workers have their own memory. If a UDF
   processes large rows, increase `executor.memoryOverhead`.

### Tuning Process

1. Start with `spark.executor.memory=4g`, `spark.executor.cores=2`.
2. Monitor the Spark UI — look for spill to disk, GC time, and task skew.
3. If spilling: increase `executor.memory` or increase partition count.
4. If GC time >10%: decrease `executor.memory` (too much heap = long GC) or
   increase executor count.
5. If task skew: repartition by a different key or use salting.

## DataFrame API vs SQL

### DataFrame API

```python
result = (
    df.filter(F.col("status") == "active")
    .groupBy("user_id")
    .agg(F.sum("amount").alias("total"))
    .orderBy(F.col("total").desc())
)
```

### Spark SQL

```python
df.createOrReplaceTempView("events")
result = spark.sql("""
    SELECT user_id, SUM(amount) AS total
    FROM events
    WHERE status = 'active'
    GROUP BY user_id
    ORDER BY total DESC
""")
```

### When to Use Which

- **DataFrame API** — type safety, IDE autocompletion, complex control flow,
  reusable transformations.
- **Spark SQL** — readability for SQL-heavy teams, porting existing SQL,
  ad-hoc analysis.
- Both compile to the same Catalyst optimizer plan — performance is
  equivalent.

Prefer the DataFrame API for production jobs (maintainability, refactoring).
Use Spark SQL for porting existing SQL pipelines or when the team is
SQL-centric.

## UDFs

### Avoid UDFs When Possible

UDFs (User-Defined Functions) bypass the Catalyst optimizer — Spark treats
them as black boxes. Prefer built-in functions:

```python
# Bad — UDF for a simple operation
@udf(returnType=StringType())
def upper_case(s):
    return s.upper() if s else None

# Good — built-in function (optimized)
df.withColumn("name_upper", F.upper(F.col("name")))
```

### When UDFs Are Necessary

For logic not expressible with built-in functions:

```python
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

@udf(returnType=StringType())
def categorize(amount):
    if amount > 1000:
        return "high"
    elif amount > 100:
        return "medium"
    else:
        return "low"

df.withColumn("tier", categorize(F.col("amount")))
```

### Pandas UDFs (Vectorized)

For better performance, use Pandas UDFs (Arrow-based, vectorized):

```python
from pyspark.sql.functions import pandas_udf

@pandas_udf("double")
def multiply_by_two(series: pd.Series) -> pd.Series:
    return series * 2

df.withColumn("doubled", multiply_by_two(F.col("value")))
```

Pandas UDFs are 10-100x faster than regular Python UDFs because they process
data in batches via Apache Arrow instead of row-by-row.

## Idempotency for Spark Jobs

- **Partition overwrite** — `mode("overwrite")` on a partitioned write
  replaces only that partition.
- **Iceberg / Delta Lake** — use `MERGE INTO` for idempotent upserts:
  ```python
  df.writeTo("catalog.db.table").merge("id").overwritePartitions()
  ```
- **Dynamic partition overwrite** — `spark.sql.sources.partitionOverwriteMode=dynamic`
  overwrites only partitions that have data in the current write.
- **Avoid append mode** unless you have a dedup strategy downstream.

## Best Practices Summary

- **Partition by date or natural key** — enables partition pruning and
  incremental processing
- **AQE enabled** — let Spark coalesce partitions adaptively
- **Broadcast small tables** — avoid shuffles for dimension tables
- **Cache sparingly** — only for reused, expensive DataFrames
- **Avoid UDFs** — use built-in functions; if needed, use Pandas UDFs
- **Tune shuffle partitions** — based on data size, not the default 200
- **Idempotent writes** — partition overwrite or MERGE, never blind append
- **Monitor the Spark UI** — spill, GC, and task skew are the top issues
