---
type: Synthesis
title: Data Engineering Best Practices Overview
description: Synthesis of data engineering practices spanning infrastructure-as-code, ingestion, ETL/ELT, Airflow orchestration, layered container images, Spark, dbt, warehouse design, BigQuery optimization and ML, streaming with schema management, data quality, orchestration tooling, integrated platforms, CQRS, ORM patterns, and SQLite-family edge databases with partitioned analytics.
tags: [data-engineering, airflow, spark, dbt, data-warehouse, bigquery, streaming, data-quality, orchestration, terraform, dlt, duckdb, cqrs, drizzle, sqlite, turso, libsql, edge-database, partitioning, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: infrahub-airflow-service-readme
    resource: "https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/airflow/README.md"
    title: "infrahub Airflow service README"
  - id: job-aide-airflow-layered-images-spec
    resource: "https://github.com/lrepo52/job-aide/blob/main/specs/005-airflow-layered-images-spec/spec.md"
    title: "job-aide Airflow layered images spec"
  - id: 2ndbrain-airflow-vs-argo-workflows-vs-tekton-pipelines
    resource: "https://github.com/levonk/2ndbrain"
    title: "2ndbrain: Airflow vs Argo Workflows vs Tekton Pipelines"
  - id: 2ndbrain-kueue-vs-airflow
    resource: "https://github.com/levonk/2ndbrain"
    title: "2ndbrain: Kueue vs Airflow"
  - id: job-aide-adr-20251106011-postgresql-as-primary-database
    resource: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251106011-postgresql-for-database.md"
    title: "job-aide ADR-20251106011: PostgreSQL as Primary Database"
  - id: job-aide-drizzle-orm-config
    resource: "https://github.com/lrepo52/job-aide/blob/main/apps/active/politics/left-parody/web/typescript/drizzle.config.ts"
    title: "job-aide Drizzle ORM config"
  - id: datatalksclub-data-engineering-zoomcamp
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp"
    title: "DataTalksClub Data Engineering Zoomcamp — free 9-week course on data engineering fundamentals"
  - id: turso-database-github
    resource: "https://github.com/tursodatabase/turso"
    title: "Turso Database — SQLite-compatible database rewritten from scratch in Rust"
  - id: turso-libsql-docs
    resource: "https://docs.turso.tech/libsql"
    title: "Turso libSQL documentation — fork vs rewrite"
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Data Engineering Best Practices Overview

This bundle documents practices for building and operating data platforms —
from pipeline authoring and orchestration to warehouse modeling, streaming
semantics, data quality, and application-level data access. Each concept was
extracted from real infrastructure: an Airflow-on-Kubernetes deployment with
layered container images, a spec-driven image build pipeline, comparison
matrices of orchestration tools, and TypeScript application data-access
patterns using Drizzle ORM and CQRS-style read models.

## The Data Engineering Lifecycle

```
provision → ingest → transform → orchestrate → store → quality → serve
    ↑          ↑         ↑            ↑          ↑        ↑        ↑
 terraform  dlt /     etl-vs-elt   airflow-*   warehouse  data-   cqrs /
            etl-vs-   dbt          spark       design     quality  drizzle
            elt                    duckdb      bigquery-*           sqlite-edge-
                                   integrated  schema-              and-partitioned
                                   platforms   registry             -analytics
                     ↑
              orchestration-comparison
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Provision | [Terraform for Data Infrastructure](terraform-data-infrastructure.md) | Unreproducible cloud resources, environment drift, no disaster recovery |
| Ingest | [dlt Declarative Ingestion](dlt-ingestion-patterns.md) | Hand-coded extraction scripts, silent schema drift, broken incremental loads |
| Ingest/Transform | [ETL vs ELT](etl-vs-elt.md) | Transforming in the wrong place; warehouse compute waste; brittle pre-load transforms |
| Orchestration | [Airflow DAG Patterns](airflow-dag-patterns.md) | Non-idempotent reruns, XCom bloat, tangled task boundaries |
| Orchestration | [Airflow Layered Images](airflow-layered-images.md) | Rebuilding Airflow from scratch on every change; task images bloated with scheduler code |
| Orchestration | [Airflow on Kubernetes](airflow-on-kubernetes.md) | Privileged containers, shared metadata DB corruption, executor misconfiguration |
| Processing | [Spark Best Practices](spark-best-practices.md) | Shuffle storms, OOM kills, broadcast-join blowups, wasted caching |
| Transform | [dbt Transformation Patterns](dbt-transformation-patterns.md) | Untested models, full-refresh explosions, lost history without snapshots |
| Transform | [DuckDB for Local Analytics](duckdb-local-analytics.md) | Slow/costly cloud-dependent development, no offline or CI testing |
| Storage | [Data Warehouse Design](data-warehouse-design.md) | Snowflake-schema join complexity, lost dimension history, fact table grain confusion |
| Storage | [BigQuery Partitioning and Clustering](bigquery-partitioning-clustering.md) | Full-table scans, runaway query costs, unbounded latency on growing tables |
| Storage | [BigQuery ML](bigquery-ml.md) | Expensive data export for ML, stale training snapshots, separate scoring infrastructure |
| Streaming | [Streaming Data Patterns](streaming-data-patterns.md) | At-least-once duplicates, late events dropping, windowing misalignment |
| Streaming | [Schema Registry and Avro](schema-registry-avro.md) | Silent deserialization failures, no schema versioning, 10x payload bloat from JSON |
| Quality | [Data Quality Testing](data-quality-testing.md) | Silent schema drift, stale data flowing downstream, unmonitored freshness |
| Tooling | [Orchestration Comparison](orchestration-comparison.md) | Picking Airflow for CI/CD, Tekton for ETL, ignoring Kueue quotas, or missing Kestra for YAML-native pipelines |
| Tooling | [Integrated Data Platforms](integrated-data-platforms.md) | Glue-code burden from best-of-breed stacks, fragmented lineage, slow onboarding |
| Serving | [CQRS and Caching](cqrs-and-caching.md) | Read/write model coupling, cache staleness, thundering herd on cache miss |
| Serving | [Drizzle ORM Patterns](drizzle-orm-patterns.md) | Unmanaged migrations, raw SQL drift, missing schema type safety |
| Serving | [SQLite-Family Edge Databases and Partitioned Analytics](sqlite-edge-and-partitioned-analytics.md) | Network-bound edge reads, offline failure, cross-tenant leaks from missed WHERE filters, cross-partition write-lock contention |

## Scope

This bundle covers **infrastructure provisioning, data ingestion, pipeline
authoring, orchestration, transformation, warehouse modeling and optimization,
in-warehouse ML, streaming with schema management, data quality, orchestration
tooling, integrated data platforms, application data access, and SQLite-family
edge databases with partitioned analytics**. It does
**not** cover:

- General Kubernetes operations — see the container-best-practices bundle.
- Container image build mechanics — see [airflow-layered-images](airflow-layered-images.md)
  for the Airflow-specific layered strategy and the container bundle for
  general Dockerfile practices.
- Frontend data fetching and UI state management — this bundle's
  [cqrs-and-caching](cqrs-and-caching.md) covers the backend read/write split
  only.
- General Terraform practices (modules, workspaces, provider patterns) — this
  bundle covers Terraform only as it applies to data platform resources; for
  general IaC practices see the cloud-provider-essentials bundle.

## Relationship to Real Infrastructure

The Airflow concepts are grounded in the infrahub Airflow service at
`shared/active/03-container/services/airflow/` and the job-aide spec
`specs/005-airflow-layered-images-spec/`. The layered image strategy
(airflow-base-common → base-python → airflow-core → airflow-platform →
airflow-py) is a real, deployed pattern using Airflow 3.1.2, Python 3.14
(Debian) / 3.13 (Alpine fallback), KubernetesExecutor, and Postgres metadata
DB.

The orchestration comparison synthesizes 2ndbrain feature-matrix notes that
compare Airflow, Argo Workflows, Tekton Pipelines, and Kueue across licensing,
Kubernetes nativeness, scheduling, and workload fit. Kestra was added from the
DataTalksClub Zoomcamp Module 2, which teaches workflow orchestration with
Kestra's YAML-native, event-driven flow model.

The Drizzle and CQRS concepts reference the job-aide `left-parody` application's
Drizzle ORM configuration and the architecture gaps analysis that identifies
CQRS/read models as a planned capability.

The Terraform, dlt ingestion, BigQuery partitioning/clustering, BigQuery ML,
DuckDB, integrated data platforms, and Schema Registry/Avro concepts were
distilled from the DataTalksClub Data Engineering Zoomcamp — a free 9-week
course that builds an end-to-end data pipeline covering containerization and
IaC (Module 1), Kestra orchestration (Module 2), BigQuery warehousing
(Module 3), dbt analytics engineering with DuckDB (Module 4), Bruin integrated
data platforms (Module 5), Spark batch processing (Module 6), and Kafka
streaming with Schema Registry and ksqlDB (Module 7).

## Sources

The initial 12 concepts were extracted from three real sources on 2026-07-17:

1. **infrahub** — Airflow service README and layered image directory structure.
2. **job-aide** — `005-airflow-layered-images-spec` (spec, plan, research,
   quickstart), Drizzle ORM config, PostgreSQL ADR, and architecture gaps
   analysis.
3. **2ndbrain** — Orchestration comparison notes (Airflow vs Argo vs Tekton,
   Kueue vs Airflow, open-source workflow tools comparison).

On 2026-08-09, 7 additional concepts were ingested from a fourth source:

4. **DataTalksClub Data Engineering Zoomcamp** — Terraform for data
   infrastructure (Module 1), dlt declarative ingestion (Workshop 1), BigQuery
   partitioning/clustering and BigQuery ML (Module 3), DuckDB for local
   analytics (Module 4), integrated data platforms with Bruin (Module 5), and
   Schema Registry/Avro schema evolution (Module 7). The Kestra orchestrator
   was also added to the existing orchestration comparison (Module 2), and
   Kafka Connect/ksqlDB were added to the existing streaming patterns page
   (Module 7).

On 2026-08-09, a 20th concept was ingested from a fifth source:

5. **Turso / libSQL documentation and engineering writeups** — the Turso
   Database Rust rewrite of SQLite (async-first, MVCC, CDC-based sync) and the
   libSQL open-contribution fork (embedded replicas, page-level sync), plus the
   partitioned SQLite file pattern for per-partition analytics isolation
   (tenant, agent, region, session) with `ATTACH` scatter-gather. Sources
   include the Turso docs, the `tursodatabase/turso` and `tursodatabase/libsql`
   GitHub repos, Turso's sync-benchmark and rewrite blog posts, and
   practitioner writeups on SQLite-per-tenant isolation and sharding.

See each concept's `sources` frontmatter for the specific URLs and paths.

## Compounding

New lessons from future data engineering work — production incidents, new
tooling evaluations, warehouse migrations, streaming redesigns — should be
filed as new concept pages. The trigger for adding a concept is: a pipeline
failure, a data quality incident, a tooling comparison that resolved a
decision, or a debugging session that revealed a practice the bundle doesn't
yet cover. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `data-lineage.md` — OpenLineage integration, Marquez, lineage-driven
  impact analysis
- `data-contracts.md` — Schema contracts between producing and consuming
  teams, contract testing
- `feature-store-patterns.md` — Online/offline feature parity, Feast, Tecton
- `lakehouse-architecture.md` — Iceberg/Delta/Hudi table formats, time travel,
  ACID on object storage
- `reverse-etl.md` — Hightouch, Census, pushing warehouse data back to
  operational systems
- `spark-structured-streaming.md` — Spark Structured Streaming vs Flink/Kafka
  Streams, micro-batch vs continuous, checkpointing
- `data-observability.md` — Monte Carlo, Databand, anomaly detection on data
  volume, schema, freshness, and distribution

## Related Knowledge Bundles

- [container-best-practices](../container-best-practices/overview.md) —
  container authoring, layered images, and runtime hardening used by Airflow
  and Spark deployments.
- [java-best-practices](../java-best-practices/overview.md) — Spark and other
  JVM data processing tools build on Java packaging and JVM tuning practices.
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — TypeScript data access layers (Drizzle ORM, CQRS) and monorepo conventions
  used by data products.
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — pipeline
  security, credential handling, and container hardening for data platforms.
