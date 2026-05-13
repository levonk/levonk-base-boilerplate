# Airflow Project Boilerplate (Copier)

Scaffolds a minimal Apache Airflow project structure with a starter DAG.

Usage:

```bash
copier copy ./boilerplate/apps/infrastructure/airflow-project ./out/airflow-project
```

Inputs:

- `project_name`: output folder and display name
- `dag_id`: DAG id to create under `dags/`
- `ollama_base_url`: default base URL for LLM calls (optional)
- `ollama_model`: model name (optional)

Notes:

- Designed for KubernetesExecutor by default. Adjust as needed.
- This repository uses `env.template` (no leading dot) in localnet; copy and adapt to `.env` where you deploy Airflow.

## Dependency model: Airflow env vs task image

There are two Python environments involved:

- Airflow environment (scheduler/webserver/workers): must include operator/provider packages used at DAG parse time. Example: `apache-airflow-providers-cncf-kubernetes` for `KubernetesPodOperator`.
- Task container image (referenced by `KubernetesPodOperator.image`): must include runtime libs required by the containerized task.

This template provides `files/airflow/requirements.txt.jinja` for the Airflow environment extras (providers, small utilities). Build your Airflow image with these installed so DAGs import/parse and operators exist.

Your task image dependencies belong in the `airflow-node` boilerplate (`files/requirements.txt.jinja`) that you build and reference in the DAG `image` field.
