---
type: Practice
title: Airflow on Kubernetes — KubernetesExecutor, Helm, and Security Hardening
description: Deploy Airflow with the official Helm chart, KubernetesExecutor, Postgres metadata DB, non-root containers, dropped capabilities, read-only root FS, and tmpfs for temporary files.
tags: [data-engineering, airflow, kubernetes, helm, security, deployment]
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
  - id: airflow-kubernetesexecutor-docs
    resource: "https://airflow.apache.org/docs/apache-airflow/stable/administration-and-deployment/executors/kubernetes-executor.html"
    title: "Airflow KubernetesExecutor docs"
---

# Airflow on Kubernetes

## Failure Mode

Airflow runs on a single VM with LocalExecutor, becomes a single point of
failure, cannot scale with workload, and has privileged containers that violate
cluster security policies.

## Symptoms

- Long-running tasks block the scheduler because they share a worker process pool.
- Pods run as root and are rejected by PodSecurityPolicy/OPA Gatekeeper.
- Metadata DB connection limits are exhausted under load.
- Logs are lost when a worker pod is evicted.

## Practice

### Use KubernetesExecutor

- Each task runs in its own pod, scaling horizontally with the cluster.
- Define `pod_override` per task or use a base pod template for resource limits,
  node selectors, and tolerations.
- Use `KubernetesPodOperator` for tasks that need custom images (e.g. the
  `airflow-py` task image).

### Helm Deployment

- Use the official Apache Airflow Helm chart.
- Store `values.yaml` in Git and version it.
- Override base images to use your layered images (`airflow-core`,
  `airflow-platform`) instead of upstream defaults.

### Metadata DB

- Use a managed Postgres or a dedicated HA Postgres cluster.
- Set `result_backend` to Redis or an S3/RPC backend for Celery if not using
  KubernetesExecutor.
- Backup the metadata DB before upgrades.

### Security Hardening

- Run containers as non-root with a read-only root filesystem.
- Drop all capabilities (`cap-drop: ALL`) and set `no-new-privileges`.
- Mount `/tmp` and `/opt/airflow/logs` as emptyDir `tmpfs` for writable scratch
  space.
- Use Kubernetes Secrets or an external secret backend (Vault) for Airflow
  Connections and Variables.
