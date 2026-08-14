---
type: Practice
title: BigQuery ML — In-Warehouse Machine Learning with SQL
description: Train, evaluate, and deploy ML models inside BigQuery with `CREATE MODEL` SQL statements to avoid data movement, leverage warehouse compute, and operationalize predictions without a separate ML platform.
tags: [data-engineering, bigquery, machine-learning, bigquery-ml, in-warehouse-ml, sql, predictions]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-bigquery-ml
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/03-data-warehouse"
    title: "Data Engineering Zoomcamp — Module 3: Machine Learning in BigQuery"
  - id: bigquery-ml-docs
    resource: "https://cloud.google.com/bigquery-ml/docs"
    title: "BigQuery ML documentation"
---

# BigQuery ML

## Failure Mode

ML models are trained by exporting warehouse data to a separate Python
environment, training in scikit-learn/TensorFlow, then importing predictions
back. Data movement is expensive, the training pipeline is brittle, and
predictions are batch-only because the model lives outside the warehouse.

## Symptoms

- Training a model on 100 GB of warehouse data requires exporting it to CSV,
  waiting hours, and paying egress fees.
- The model is trained on a stale snapshot because the export ran last week.
- Predictions require a separate scoring service — analysts cannot query
  `SELECT predicted_label FROM model` in SQL.

## Practice

### Train Models with SQL

- Use `CREATE MODEL` to train models directly on warehouse tables — no data
  export.
- Supported model types: linear/logistic regression, DNN, boosted trees,
  ARIMA (time series), k-means, matrix factorization.
- Feature preprocessing (scaling, one-hot encoding) is handled automatically
  by `TRANSFORM` clauses.

### Evaluate and Inspect

- Use `ML.EVALUATE` to compute metrics (precision, recall, RMSE) on a held-out
  set.
- Use `ML.TRAINING_INFO` to inspect loss curves and detect overfitting.
- Use `ML.FEATURE_INFO` to see feature importance and statistics.

### Predict in SQL

- Use `ML.PREDICT` to score new data with a single SQL query — predictions
  stay in the warehouse alongside the source data.
- Analysts can join predictions to dimension tables without a separate scoring
  service.
- Batch and near-real-time scoring share the same model — no separate
  deployment.

### Hyperparameter Tuning

- Use `HPARAM_TUNING` in `CREATE MODEL` with `num_trials` and objective
  metrics.
- BigQuery ML runs trials in parallel on warehouse compute — no GPU cluster
  required for standard models.

### Export and Deploy

- For low-latency online serving, export the model with `ML.EXPORT` and deploy
  to Vertex AI or a Docker container.
- Keep the in-warehouse model for batch scoring; export only when
  sub-100ms latency is required.

### When to Use BigQuery ML vs External ML

| Factor | BigQuery ML | External (Python/Spark) |
|--------|------------|------------------------|
| Data location | Already in BigQuery | Needs export or external compute |
| Model complexity | Standard (regression, trees, DNN) | Custom architectures, deep learning |
| Prediction latency | Batch / SQL queries | Online / real-time serving |
| Team skills | SQL analysts | ML engineers |
| Data movement | None | Required |

## Related Concepts

- [BigQuery Partitioning and Clustering](/bigquery-partitioning-clustering.md)
  — keep training queries cheap by partition-pruning the training table.
- [Data Warehouse Design](/data-warehouse-design.md) — the warehouse tables
  that BigQuery ML trains on.
