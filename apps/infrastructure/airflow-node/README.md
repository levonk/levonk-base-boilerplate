# Airflow Node Boilerplate (Copier)

Build a lightweight container image for tasks executed via `KubernetesPodOperator` (or similar). This image is separate from the Airflow scheduler/webserver image.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/airflow-node ./out/airflow-node
```

Inputs:
- `project_name`: output folder and display name
- `base_image`: base to build from (prefer your org base image, fallback debian/alpine)
- `python_version`: Python version to install when needed
- `image_name`/`image_tag`: final image reference to publish and use in DAGs

## Dependency model: Airflow env vs task image

Two Python environments exist:
- Airflow environment (scheduler/webserver/workers): must include operator/provider packages used at DAG parse time (e.g., `apache-airflow-providers-cncf-kubernetes`).
- Task container image (this boilerplate): must include all runtime libraries used by the task code running inside the pod.

Put Airflow-side extras in the Airflow project’s `files/airflow/requirements.txt.jinja` and bake them into your Airflow image. Put task-time libraries into this node image’s `requirements.txt.jinja` and bake them into the node image.

## Resources, timeouts, retries

Configure per-task in your DAG operator:
- `container_resources` (CPU/memory `requests` & `limits`)
- `execution_timeout`, `startup_timeout_seconds`
- `retries`, `retry_delay`

Example (from the Airflow project boilerplate DAG): a `KubernetesPodOperator` setting CPU/mem requests/limits and timeouts. Each task runs in its own container using the image from this node boilerplate.

## Suggested files to add (can be templated)
- `files/Dockerfile.jinja` – FROM `base-debian:latest` (or `base-alpine`), install Python + pip, copy `requirements.txt`, `pip install -r requirements.txt`, drop privileges.
- `files/requirements.txt.jinja` – Task libraries (e.g., `requests`, `unstructured-client`).

If you want, I can scaffold these files now.
