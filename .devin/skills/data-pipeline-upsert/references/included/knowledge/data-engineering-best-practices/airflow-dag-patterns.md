---
type: Practice
title: Airflow DAG Patterns — Idempotency, Task Boundaries, and XCom Discipline
description: Author Airflow DAGs with idempotent tasks, clear task boundaries, small XCom only, and deterministic retries to ensure safe reruns and backfills.
tags: [data-engineering, airflow, dag, idempotency, xcom, orchestration]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: airflow-documentation-xcoms
    resource: "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/xcoms.html"
    title: "Airflow documentation — XComs"
  - id: airflow-documentation-dynamic-task-mapping
    resource: "https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html"
    title: "Airflow documentation — Dynamic Task Mapping"
  - id: airflow-documentation-task-retry-and-timeout
    resource: "https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dags.html"
    title: "Airflow documentation — Task Retry and Timeout"
  - id: executor-choice-affects-task-isolation
    resource: "/airflow-on-kubernetes.md"
    title: "executor choice affects task isolation"
  - id: task-base-images-for-kubernetespodoperator
    resource: "/airflow-layered-images.md"
    title: "task base images for KubernetesPodOperator"
---

# Airflow DAG Patterns — Idempotency, Task Boundaries, and XCom Discipline

## Idempotency

Every task must produce the same output when run with the same inputs,
regardless of how many times it runs. This is the single most important DAG
authoring rule because Airflow reruns tasks on failure, retry, backfill, and
clear. Non-idempotent tasks cause duplicate data, double-charged API calls, and
corrupted state.

Practices:

- Write outputs to partitioned paths keyed by `{{ ds }}` or `{{ data_interval_start }}`,
  not to mutable overwrite paths.
- Use `INSERT ... ON CONFLICT` (upsert) or `MERGE` instead of bare `INSERT`.
- Check whether work is already done before doing it (e.g., file exists,
  partition exists).
- Avoid `datetime.now()` — use Airflow's execution context macros so reruns
  operate on the logical run date, not the wall clock.

## Task Boundaries

Each task should do one meaningful unit of work. Too fine-grained and the DAG
becomes a thousand-task graph that overwhelms the scheduler; too coarse-grained
and a failure forces re-running a massive task from the beginning.

Rules of thumb:

- A task should be rerunnable independently without redoing unrelated work.
- If a task takes longer than 30 minutes, consider splitting it.
- If two tasks always run together and never independently, merge them.
- If a task fetches data and transforms it, split fetch from transform so
  failures in transform don't re-fetch.

## XCom Discipline

XCom (cross-communication) passes small data between tasks. The failure mode is
treating XCom as a data transport for actual datasets.

- XCom is stored in the metadata DB (Postgres/MySQL). Large XCom values bloat
  the DB and slow the scheduler.
- Keep XCom to metadata: file paths, row counts, timestamps, small config
  dicts. Not DataFrames, not JSON payloads of records.
- For large data, write to object storage (S3/GCS) in the producing task and
  pass the path via XCom.
- In Airflow 2.x+, custom XCom backends (S3, GCS) can store larger payloads,
  but the default remains DB-backed — know your backend.

## Retries and Timeouts

- Set `retries` on every task (default 2-3) with `retry_delay` and
  `retry_exponential_backoff=True`.
- Set `execution_timeout` on every task so a hung task doesn't block the pool.
- Use `sla` for business-critical deadlines, not as a timeout.
- Catch expected exceptions and raise `AirflowSkipException` for intentional
  skips rather than failing the task.

## Dynamic Task Mapping

Airflow 2.3+ supports dynamic task mapping (`expand` / `expand_kwargs`) which
fan-outs tasks at runtime based on upstream output. This replaces fragile
dynamic-DAG-generation patterns. Use it for partitioned processing where the
number of partitions is known only at runtime.
