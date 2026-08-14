---
okf_version: "0.2"
---

# Data Engineering Best Practices

A compounding knowledge base documenting hard-won lessons from building data
platforms, pipelines, and orchestration systems. Each concept captures a
specific practice grounded in real infrastructure — Airflow deployments on
Kubernetes, layered container images, warehouse modeling, streaming semantics,
ORM/data-access patterns observed in production codebases, and practices
distilled from the DataTalksClub Data Engineering Zoomcamp curriculum.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [ETL vs ELT](etl-vs-elt.md) - ETL transforms before load; ELT loads then transforms in-warehouse with dbt — choose by warehouse compute cost and transformation maturity
* [Airflow DAG Patterns](airflow-dag-patterns.md) - Idempotent tasks, clear task boundaries, XCom for small data only, deterministic retries
* [Airflow Layered Images](airflow-layered-images.md) - Split Airflow runtime into base-common → base-python → core → platform → py layers for cache reuse and task-image separation
* [Airflow on Kubernetes](airflow-on-kubernetes.md) - KubernetesExecutor, Helm chart deployment, Postgres metadata DB, non-root read-only security hardening
* [Spark Best Practices](spark-best-practices.md) - Partitioning, broadcast joins, caching strategy, memory tuning, and shuffle reduction
* [dbt Transformation Patterns](dbt-transformation-patterns.md) - Models, tests, snapshots, materializations, and incremental models for in-warehouse transformations
* [Data Warehouse Design](data-warehouse-design.md) - Star schema vs snowflake, slowly changing dimensions (SCD1/SCD2), fact and dimension table modeling
* [BigQuery Partitioning and Clustering](bigquery-partitioning-clustering.md) - Partition by date/ingestion time to prune scanned bytes, cluster by filter columns to reduce slot consumption
* [BigQuery ML](bigquery-ml.md) - Train, evaluate, and deploy ML models in-warehouse with `CREATE MODEL` SQL — avoid data movement for standard model types
* [Streaming Data Patterns](streaming-data-patterns.md) - Kafka/Kinesis patterns, exactly-once semantics, watermarking, windowing, Kafka Connect, and ksqlDB
* [Schema Registry and Avro](schema-registry-avro.md) - Manage streaming schemas with a Schema Registry and Avro — enforce backward/forward compatibility and avoid silent deserialization failures
* [Data Quality Testing](data-quality-testing.md) - Great Expectations and Soda for schema validation, freshness checks, and pipeline gate assertions
* [Orchestration Comparison](orchestration-comparison.md) - Airflow vs Argo Workflows vs Tekton vs Kueue vs Kestra — pick by what your tasks look like and where they run
* [Terraform for Data Infrastructure](terraform-data-infrastructure.md) - Provision cloud data platform resources (BigQuery datasets, GCS buckets, IAM) with Terraform — never by clicking through a console
* [dlt Declarative Ingestion](dlt-ingestion-patterns.md) - Declarative ingestion from APIs, files, and databases with auto-schema evolution and incremental loading via dlt
* [DuckDB for Local Analytics](duckdb-local-analytics.md) - In-process OLAP for local dbt development, ad-hoc analytics, and CI testing without a cloud warehouse
* [Integrated Data Platforms](integrated-data-platforms.md) - All-in-one platforms (Bruin) vs best-of-breed stacks — choose by team size, complexity, and lock-in tolerance
* [CQRS and Caching](cqrs-and-caching.md) - CQRS with delayed reads for cache-first data retrieval, separating write models from read models
* [Drizzle ORM Patterns](drizzle-orm-patterns.md) - Drizzle ORM configuration, schema definition, and migrations for PostgreSQL with TypeScript
* [SQLite-Family Edge Databases and Partitioned Analytics](sqlite-edge-and-partitioned-analytics.md) - Turso (Rust rewrite of SQLite) and libSQL for edge/local-first workloads; one SQLite file per partition (tenant, agent, region) for filesystem-level isolation with ATTACH scatter-gather analytics
