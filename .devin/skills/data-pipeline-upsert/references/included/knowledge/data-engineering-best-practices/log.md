# Directory Update Log

## 2026-08-09

* **Ingest**: Added a 20th concept page sourced from Turso / libSQL
  documentation and engineering writeups.
  - [sqlite-edge-and-partitioned-analytics.md](sqlite-edge-and-partitioned-analytics.md)
    — Turso (the Rust rewrite of SQLite — async-first, MVCC, CDC-based sync)
    and libSQL (the open-contribution SQLite fork — embedded replicas,
    page-level sync) for edge and local-first workloads; plus the partitioned
    SQLite file pattern (one `.db` file per tenant/agent/region/session) for
    filesystem-level analytics isolation with `ATTACH` + `UNION ALL`
    scatter-gather across partitions. Sources: Turso docs, the
    `tursodatabase/turso` and `tursodatabase/libsql` GitHub repos, Turso's
    sync-benchmark and "we will rewrite SQLite" blog posts, and practitioner
    writeups on SQLite-per-tenant isolation and sharding strategies.
* **Update**: Updated [index.md](index.md) with the new concept entry.
* **Update**: Updated [overview.md](overview.md) description, tags, sources
  frontmatter, lifecycle diagram, phase table, and scope to reflect the
  expanded 20-concept bundle.

## 2026-08-09

* **Ingest**: Added 7 new concept pages sourced from the DataTalksClub Data
  Engineering Zoomcamp (https://github.com/DataTalksClub/data-engineering-zoomcamp),
  a free 9-week course covering the full data engineering lifecycle.
  - [terraform-data-infrastructure.md](terraform-data-infrastructure.md) —
    Terraform IaC for cloud data platform resources (GCP projects, BigQuery
    datasets, GCS buckets, IAM) — from Module 1 (Containerization & IaC)
  - [dlt-ingestion-patterns.md](dlt-ingestion-patterns.md) — declarative
    ingestion with dlt: auto-schema evolution, incremental loading,
    normalization — from Workshop 1 (Data Ingestion with dlt)
  - [bigquery-partitioning-clustering.md](bigquery-partitioning-clustering.md)
    — BigQuery partition pruning and clustering for cost/query performance —
    from Module 3 (Data Warehousing)
  - [bigquery-ml.md](bigquery-ml.md) — in-warehouse ML with `CREATE MODEL` SQL
    to avoid data movement — from Module 3 (Advanced: ML in BigQuery)
  - [duckdb-local-analytics.md](duckdb-local-analytics.md) — DuckDB in-process
    OLAP for local dbt development, CI testing, and ad-hoc analytics — from
    Module 4 (Analytics Engineering with dbt + DuckDB)
  - [integrated-data-platforms.md](integrated-data-platforms.md) — all-in-one
    data platforms (Bruin) vs best-of-breed stacks — from Module 5 (Data
    Platforms)
  - [schema-registry-avro.md](schema-registry-avro.md) — Schema Registry and
    Avro for streaming schema evolution with backward/forward compatibility —
    from Module 7 (Streaming: Kafka Schema Registry)
* **Update**: Added Kestra to [orchestration-comparison.md](orchestration-comparison.md)
  — YAML-native, event-driven orchestrator with 1000+ plugins and AI copilot
  (from Module 2: Workflow Orchestration with Kestra).
* **Update**: Added Schema Management and Kafka Connect/ksqlDB sections to
  [streaming-data-patterns.md](streaming-data-patterns.md), cross-linking the
  new schema-registry-avro concept (from Module 7: Streaming).
* **Update**: Updated [index.md](index.md) with all 7 new concept entries.
* **Update**: Updated [overview.md](overview.md) lifecycle diagram, phase
  table, scope, and sources sections to reflect the expanded 19-concept bundle.
* **Note**: The Zoomcamp curriculum also covers Docker/Postgres (Module 1),
  Spark batch processing (Module 6), and dbt transformation patterns (Module 4)
  — these topics were already covered by existing concept pages
  ([airflow-layered-images](airflow-layered-images.md),
  [spark-best-practices](spark-best-practices.md),
  [dbt-transformation-patterns](dbt-transformation-patterns.md)) so no new
  pages were created for them. The Zoomcamp served as corroboration for those
  existing practices.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Update**: Completed missing concept pages that were referenced in [index.md](index.md) and [overview.md](overview.md) but not yet written to disk.
  - [airflow-layered-images.md](airflow-layered-images.md) — Airflow layered image strategy
  - [airflow-on-kubernetes.md](airflow-on-kubernetes.md) — KubernetesExecutor, Helm, security hardening
  - [spark-best-practices.md](spark-best-practices.md) — Spark partitioning, caching, memory tuning
  - [dbt-transformation-patterns.md](dbt-transformation-patterns.md) — dbt models, tests, snapshots, incremental models
  - [data-warehouse-design.md](data-warehouse-design.md) — star schema, SCD, fact/dimension tables
  - [streaming-data-patterns.md](streaming-data-patterns.md) — Kafka/Kinesis, exactly-once, watermarking
  - [data-quality-testing.md](data-quality-testing.md) — schema validation, freshness, pipeline gates
  - [orchestration-comparison.md](orchestration-comparison.md) — Airflow vs Argo vs Tekton vs Kueue
  - [cqrs-and-caching.md](cqrs-and-caching.md) — CQRS with delayed reads
  - [drizzle-orm-patterns.md](drizzle-orm-patterns.md) — Drizzle ORM schema, migrations, PostgreSQL

## 2026-07-17

* **Initialization**: Created the `data-engineering-best-practices` knowledge bundle as an OKF v0.1 knowledge base, seeded from real findings across infrahub, job-aide, and 2ndbrain.
* **Creation**: Initialized [index.md](index.md) directory listing and [overview.md](overview.md) synthesis covering the full data engineering practice set.
* **Creation**: Added 12 concept pages sourced from real infrastructure, specs, and comparison notes.
  - [etl-vs-elt.md](etl-vs-elt.md) — ETL vs ELT patterns, modern ELT with dbt
  - [airflow-dag-patterns.md](airflow-dag-patterns.md) — DAG authoring, idempotency, XCom boundaries
  - [airflow-layered-images.md](airflow-layered-images.md) — layered image strategy (airflow-base-common → base-python → airflow-core → airflow-platform → airflow-py)
  - [airflow-on-kubernetes.md](airflow-on-kubernetes.md) — KubernetesExecutor, Helm, Postgres metadata DB, security hardening
  - [spark-best-practices.md](spark-best-practices.md) — partitioning, broadcast joins, caching, memory tuning
  - [dbt-transformation-patterns.md](dbt-transformation-patterns.md) — models, tests, snapshots, materializations, incremental models
  - [data-warehouse-design.md](data-warehouse-design.md) — star schema, SCD1/SCD2, fact/dimension tables
  - [streaming-data-patterns.md](streaming-data-patterns.md) — Kafka/Kinesis, exactly-once, watermarking, windowing
  - [data-quality-testing.md](data-quality-testing.md) — Great Expectations, Soda, schema validation, freshness checks
  - [orchestration-comparison.md](orchestration-comparison.md) — Airflow vs Argo vs Tekton vs Kueue
  - [cqrs-and-caching.md](cqrs-and-caching.md) — CQRS with delayed reads for cache-first retrieval
  - [drizzle-orm-patterns.md](drizzle-orm-patterns.md) — Drizzle ORM config, schema, migrations for PostgreSQL
* **Note**: Airflow layered image concepts derived from the infrahub Airflow service README (155 lines) and the job-aide `005-airflow-layered-images-spec` (spec, plan, quickstart, research). Orchestration comparison sourced from 2ndbrain feature-matrix notes. Drizzle and CQRS patterns sourced from job-aide `left-parody` app and ADR-20251106011.
