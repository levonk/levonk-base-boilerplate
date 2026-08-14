---
type: Practice
title: Airflow Layered Images — Cache Reuse and Task-Image Separation
description: Split Airflow into layered images (base-common → base-python → airflow-core → airflow-platform → airflow-py) so scheduler/webserver code does not leak into task pods and layers cache independently.
tags: [data-engineering, airflow, containers, layered-images, caching, kubernetes]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: infrahub-airflow-service-readme
    resource: "https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/airflow/README.md"
    title: "infrahub Airflow service README"
  - id: job-aide-airflow-layered-images-spec
    resource: "https://github.com/lrepo52/job-aide/blob/main/specs/005-airflow-layered-images-spec/spec.md"
    title: "job-aide Airflow layered images spec"
---

# Airflow Layered Images

## Failure Mode

A single Airflow image is used for both the scheduler/webserver and task pods,
making task pods bloated, slowing startup, and forcing rebuilds of task images
whenever the scheduler changes.

## Symptoms

- Task pods are 1 GB+ because they include scheduler dependencies.
- Every Airflow upgrade forces rebuilding custom task images.
- Task-level Python dependencies conflict with Airflow core dependencies.
- Build cache is invalidated by changes in unrelated layers.

## Practice

### Layer Hierarchy

The infrahub/job-aide pattern uses five layers:

```
airflow-base-common
    ↓
base-python-{debian,alpine}
    ↓
airflow-core
    ↓
airflow-platform
    ↓
airflow-py
```

| Layer | Purpose | Contents |
|-------|---------|----------|
| `airflow-base-common` | Minimal shared OS layer | `tzdata`, `tini`, base packages |
| `base-python-{debian,alpine}` | Python runtime | Python 3.14 (Debian) or 3.13 (Alpine), pip |
| `airflow-core` | Airflow runtime | Airflow 3.1.2 with constraints |
| `airflow-platform` | Providers and platform config | `cncf.kubernetes`, `postgres`, `http`, `slack` providers |
| `airflow-py` | Task base image | Libraries for `KubernetesPodOperator` tasks; no Airflow scheduler code |

### Benefits

- `airflow-py` is small because it does not include scheduler/webserver code.
- Task pods start faster and are easier to cache on nodes.
- Changes to task libraries do not invalidate the `airflow-core` layer.
- Airflow upgrades rebuild only the upper layers.

### Provider Installation

Install providers in `airflow-platform` using official constraints to avoid
Python dependency conflicts:

```text
apache-airflow==3.1.2
apache-airflow-providers-cncf-kubernetes==...
apache-airflow-providers-postgres==...
```
