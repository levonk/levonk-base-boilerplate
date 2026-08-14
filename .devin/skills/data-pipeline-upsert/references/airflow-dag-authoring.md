# Airflow DAG Authoring

> Detailed guidance for authoring Apache Airflow DAGs with idempotency,
> retries, sensors, and the KubernetesExecutor pattern.

## DAG Structure

### Minimal DAG (TaskFlow API)

Prefer the TaskFlow API (`@dag`, `@task`) for new DAGs — it handles XCom
serialization automatically and reduces boilerplate.

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task

default_args = {
    "owner": "data-eng",
    "retries": 3,
    "retry_delay": timedelta(minutes=1),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=10),
    "execution_timeout": timedelta(hours=1),
}

@dag(
    dag_id="daily_ingestion",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    default_args=default_args,
    dagrun_timeout=timedelta(hours=2),
    tags=["ingestion", "daily"],
)
def daily_ingestion():
    @task
    def extract():
        # Pull data from source
        return {"records": [...]}

    @task
    def transform(data):
        return {"records": [transform_record(r) for r in data["records"]]}

    @task
    def load(data):
        # Idempotent load — MERGE or partition overwrite
        pass

    load(transform(extract()))

daily_ingestion()
```

### Operators vs TaskFlow API

| Aspect | Operators | TaskFlow API |
|--------|-----------|--------------|
| XCom | Manual (XCom push/pull) | Automatic (return values) |
| Boilerplate | More | Less |
| Custom logic | Subclass `BaseOperator` | `@task` decorator |
| Dynamic tasks | `expand()` | `@task` + `.expand()` |
| Legacy code | Often already operators | Wrap with `@task` if possible |

Use operators for well-known integrations (`KubernetesPodOperator`,
`S3ToRedshiftOperator`, `HttpOperator`). Use TaskFlow for custom Python
logic.

## Idempotency

Every task must be safe to re-run. Patterns:

### Database Writes

```sql
-- Idempotent upsert (PostgreSQL)
INSERT INTO target (id, value, updated_at)
VALUES (:id, :value, NOW())
ON CONFLICT (id)
DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

-- Idempotent upsert (Snowflake)
MERGE INTO target t
USING source s ON t.id = s.id
WHEN MATCHED THEN UPDATE SET t.value = s.value, t.updated_at = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (id, value, updated_at) VALUES (s.id, s.value, CURRENT_TIMESTAMP());
```

### Partition Overwrites

For partitioned data (S3, BigQuery, Iceberg), overwrite the target partition
instead of appending:

```python
# Spark: overwrite a single partition
df.write.mode("overwrite").partitionBy("date").parquet("s3://bucket/data/")

# BigQuery: overwrite a partition with writeDisposition
job_config = bigquery.QueryJobConfig(
    write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    query_parameters=[...],
)
```

### Anti-Patterns

- `INSERT INTO ... VALUES` without `ON CONFLICT` — duplicates on re-run
- `APPEND` mode writes without a dedup key
- API calls that create resources without idempotency keys
- File writes that don't check for existing files

## Task Boundaries

Design task granularity for retryability and observability:

- **Too coarse** — one giant task that does everything. A failure at the end
  wastes all prior work. Hard to diagnose.
- **Too fine** — one task per row. XCom overhead, scheduler pressure.
- **Right size** — one task per logical unit of work (extract one source,
  transform one dataset, load one table). If a task takes >30 minutes, split
  it.

### XCom

XCom (cross-communication) passes data between tasks. Limit XCom size —
Airflow stores XCom in the metadata database (or custom backend). For large
data, pass a reference (S3 path, table name) not the data itself.

```python
# Good — pass a reference
@task
def extract():
    path = write_to_s3(data)
    return {"s3_path": path}  # Small XCom

# Bad — pass the data
@task
def extract():
    return {"data": large_dataframe}  # Huge XCom, will fail
```

With the TaskFlow API, return values are automatically pushed to XCom. Keep
return values small.

## Sensors

Sensors wait for a condition (file exists, partition ready, API returns 200).

```python
from airflow.sensors.filesystem import FileSensor
from airflow.sensors.s3 import S3KeySensor

# Poke mode (default) — checks periodically, occupies a worker slot
FileSensor(task_id="wait_for_file", filepath="/data/input.csv", poke_interval=60)

# Deferrable mode (async) — releases the worker slot while waiting
# Requires deferrable=True on the sensor and a triggerer running
FileSensor(
    task_id="wait_for_file",
    filepath="/data/input.csv",
    poke_interval=60,
    deferrable=True,
    timeout=60 * 60,  # 1 hour
    mode="reschedule",  # or "poke" (default)
)
```

- **`mode="poke"`** — sensor holds a worker slot. Use for short waits (<5 min).
- **`mode="reschedule"`** — sensor releases the slot between pokes. Use for
  long waits.
- **`deferrable=True`** — sensor moves to the triggerer process. Most
  efficient for long waits. Requires Airflow 2.7+ and a triggerer.

Always set `timeout` on sensors to prevent infinite waits.

## Catchup

`catchup=True` (default) backfills all missed DAG runs since `start_date`.
For daily DAGs with years of history, this can create thousands of runs.

- **Set `catchup=False`** for most production DAGs — process only the latest
  interval.
- **Set `catchup=True`** only when you genuinely need historical backfill,
  and pair it with `max_active_runs=1` to avoid overwhelming the scheduler.

```python
@dag(
    dag_id="daily_ingestion",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,  # Don't backfill
    max_active_runs=1,  # One run at a time
)
```

## Retries

Every task should have retries for transient failures:

```python
default_args = {
    "retries": 3,
    "retry_delay": timedelta(minutes=1),
    "retry_exponential_backoff": True,  # 1 min, 2 min, 4 min...
    "max_retry_delay": timedelta(minutes=10),
    "retry_exponential_backoff_max": timedelta(minutes=30),
}
```

- **`retries=3`** — handles most transient failures (network blips, brief
  resource contention).
- **`retry_exponential_backoff=True`** — avoids thundering herd on shared
  resources.
- **`max_retry_delay`** — caps the backoff so a task doesn't wait hours
  between retries.

Do NOT retry tasks that are not idempotent — a retry will duplicate work.

## SLAs

SLAs (Service Level Agreements) alert when a task runs later than expected:

```python
from datetime import timedelta

@task(sla=timedelta(hours=1))
def critical_load():
    # If this task starts >1 hour after its scheduled time, an SLA miss
    # is recorded and alerts fire
    pass
```

- Set SLAs on time-sensitive tasks (e.g., data must be ready by 9 AM for
  downstream dashboards).
- SLA misses are recorded in the Airflow UI and can trigger callbacks.
- Use `sla_miss_callback` on the DAG to alert (PagerDuty, Slack).

## KubernetesExecutor Pattern

For Airflow 3.x with `KubernetesExecutor`, each task runs in its own pod.
This provides isolation and resource control.

### DAG Configuration

```python
from airflow.decorators import dag, task
from datetime import datetime, timedelta

@dag(
    dag_id="spark_on_k8s",
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
)
def spark_on_k8s():
    @task(
        executor_config={
            "KubernetesExecutor": {
                "image": "ghcr.io/org/spark-runner:3.5",
                "resources": {
                    "request_memory": "2Gi",
                    "request_cpu": "1000m",
                    "limit_memory": "4Gi",
                    "limit_cpu": "2000m",
                },
                "affinity": {
                    "nodeAffinity": {
                        "requiredDuringSchedulingIgnoredDuringExecution": {
                            "nodeSelectorTerms": [{
                                "matchExpressions": [{
                                    "key": "workload",
                                    "operator": "In",
                                    "values": ["spark"],
                                }]
                            }]
                        }
                    }
                },
            }
        }
    )
    def run_spark_job():
        # Spark submit inside the pod
        pass

    run_spark_job()
```

### Layered Images

Build the Airflow image in layers:

1. **Base layer** — Airflow + common providers (published to registry,
   rebuilt rarely).
2. **DAG layer** — your DAGs + custom operators (rebuilt on DAG changes).
3. **Task-specific layer** — heavy dependencies (Spark, custom libs) only
   in pods that need them, via `executor_config["KubernetesExecutor"]["image"]`.

This keeps the base image small and avoids rebuilding the entire stack for
every DAG change.

### Helm Deployment

Deploy Airflow via the official Helm chart with custom values:

```yaml
# values.yaml
executor: KubernetesExecutor
airflowVersion: "3.1.2"
images:
  airflow:
    repository: ghcr.io/org/airflow
    tag: "3.1.2"
config:
  kubernetes_executor:
    namespace: airflow
    pod_template_file: /opt/airflow/pod_templates/pod_template.yaml
```

## Airflow 3.x Notes

- Airflow 3.x changed the DAG serialization format and introduced the
  `DAG.bundle` concept for packaging DAGs with dependencies.
- The `schedule` parameter accepts cron presets (`@daily`), cron expressions,
  or timetables.
- `dataset`-based scheduling replaces some external trigger patterns — a DAG
  can trigger when a dataset it depends on is updated.
- The UI and API have been redesigned; some 2.x CLI commands changed.

## Best Practices Summary

- **Idempotency first** — every task safe to re-run
- **TaskFlow API** for new Python-heavy DAGs
- **`catchup=False`** for production DAGs
- **Retries with exponential backoff** on every task
- **Sensors with `timeout`** — never infinite waits
- **Small XCom** — pass references, not data
- **`KubernetesExecutor`** for isolation and resource control
- **Layered images** — base, DAG, task-specific
- **SLAs** on time-sensitive tasks
- **Tags** on every DAG for filtering and organization
