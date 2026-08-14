---
type: Practice
title: Integrated Data Platforms — All-in-One vs Best-of-Breed
description: Choose between an integrated data platform (Bruin, which unifies ingestion, transformation, orchestration, quality, and lineage in one tool) and a best-of-breed stack (separate Airflow + dbt + Great Expectations) based on team size, complexity, and vendor-lock-in tolerance.
tags: [data-engineering, data-platform, bruin, architecture, comparison, ingestion, orchestration, lineage]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-data-platforms
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/05-data-platforms"
    title: "Data Engineering Zoomcamp — Module 5: Data Platforms (Bruin)"
  - id: bruin-documentation
    resource: "https://getbruin.com/docs"
    title: "Bruin data platform documentation"
---

# Integrated Data Platforms

## Failure Mode

A data team assembles a best-of-breed stack (Airflow + dbt + Great Expectations
+ separate ingestion tool + lineage tool) and spends more time gluing tools
together than building data products. Each integration is a failure surface,
and the operational burden falls on a small team.

## Symptoms

- A pipeline failure requires checking three tools (orchestrator logs, dbt
  logs, quality tool logs) to find the root cause.
- Lineage is maintained manually because the orchestrator, transformation tool,
  and quality tool each have their own metadata silos.
- Onboarding a new data engineer requires learning five separate tools with
  different configuration formats.
- A schema change requires updating the ingestion tool, the dbt model, the
  quality check, and the lineage registry — four places, often missed.

## Practice

### The Integrated Platform Pattern

An integrated data platform (e.g. Bruin) unifies the data lifecycle under a
single project and tool:

- **Ingestion** — YAML ingestor assets and Python scripts pull from APIs,
  files, and databases.
- **Transformation** — SQL and Python assets transform data in the warehouse.
- **Orchestration** — pipeline YAML defines schedules and dependencies; no
  separate orchestrator process.
- **Quality** — built-in checks and validation run as part of the pipeline.
- **Lineage** — automatically derived from asset dependencies; no separate
  lineage tool.

### Asset-Based Architecture

- An **asset** is a single file (SQL, Python, or YAML) that creates or updates
  a table or view.
- Assets declare their dependencies; the platform computes the DAG and lineage
  automatically.
- A **pipeline** groups assets by schedule — each pipeline has one schedule
  and its own configuration.
- **Environments** (dev, staging, prod) are project-level; the same assets run
  against different warehouse connections.

### Best-of-Breed vs Integrated

| Factor | Best-of-Breed (Airflow + dbt + GE) | Integrated (Bruin) |
|--------|-------------------------------------|---------------------|
| Tool count | 3–5 separate tools | 1 platform |
| Integration effort | High (glue code, metadata sync) | None (unified) |
| Lineage | Manual or third-party tool | Automatic from asset deps |
| Flexibility | High (swap any component) | Constrained to platform scope |
| Vendor lock-in | Low (open standards) | Medium (platform-specific YAML) |
| Team size fit | Larger teams with specialists | Small teams, generalists |
| Onboarding | Learn multiple tools | One tool, one config format |
| AI integration | Per-tool, fragmented | Unified MCP for conversational pipeline building |

### When to Choose Integrated

- Small data team (1–5 engineers) where operational overhead of multiple tools
  exceeds the flexibility benefit.
- Greenfield projects where no existing tool investment exists.
- Teams that value lineage and quality as first-class, built-in capabilities
  rather than add-ons.

### When to Choose Best-of-Breed

- Large team with specialists in orchestration, transformation, and quality.
- Existing investment in Airflow/dbt that would be costly to migrate.
- Need to swap individual components (e.g. replace Great Expectations with
  Soda without touching the orchestrator).
- Regulatory requirements that demand tool-level isolation and auditing.

### Hybrid Pattern

- Use an integrated platform for new greenfield pipelines.
- Keep best-of-breed for legacy pipelines that are stable and do not warrant
  migration.
- Bridge the two with a shared warehouse — both write to the same BigQuery /
  Snowflake, so data is unified even if tooling is not.

## Related Concepts

- [dbt Transformation Patterns](/dbt-transformation-patterns.md) — the
  transformation layer that integrated platforms absorb.
- [Orchestration Comparison](/orchestration-comparison.md) — the orchestrator
  layer that integrated platforms replace.
- [Data Quality Testing](/data-quality-testing.md) — the quality layer that
  integrated platforms build in.
- [dlt Declarative Ingestion](/dlt-ingestion-patterns.md) — the ingestion
  layer that integrated platforms provide natively.
