# AI Ollama Samples (Copier Template)

This template scaffolds a minimal Airflow DAG that calls Ollama via HTTP, plus quickstart docs.

Usage:

```bash
copier copy ./boilerplate/apps/infrastructure/ai-ollama-samples ./out/ai-ollama-samples
```

Inputs:
- `project_name`: folder name
- `ollama_base_url`: default `http://ollama:11434`

This repo uses `env.template` (no leading dot) to define ports and paths; copy it to `.env` in the runtime project, not here.
