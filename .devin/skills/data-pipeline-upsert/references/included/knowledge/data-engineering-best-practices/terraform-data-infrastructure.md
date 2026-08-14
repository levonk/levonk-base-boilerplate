---
type: Practice
title: Terraform for Data Infrastructure — IaC for Cloud Data Platforms
description: Provision cloud data platform resources (GCP projects, BigQuery datasets, GCS buckets, IAM roles, VPCs) with Terraform so infrastructure is versioned, reproducible, and reviewable — never created by clicking through a cloud console.
tags: [data-engineering, terraform, infrastructure-as-code, gcp, bigquery, cloud, provisioning]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-docker-terraform
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform"
    title: "Data Engineering Zoomcamp — Module 1: Containerization and Infrastructure as Code"
  - id: terraform-gcp-provider-docs
    resource: "https://registry.terraform.io/providers/hashicorp/google/latest/docs"
    title: "Terraform Google Cloud Platform Provider documentation"
---

# Terraform for Data Infrastructure

## Failure Mode

Cloud data platform resources (BigQuery datasets, GCS buckets, IAM bindings,
VPC networks) are created manually through the cloud console. Environments
drift, disaster recovery is impossible without a paper trail, and new team
members cannot reproduce the platform without tribal knowledge.

## Symptoms

- A BigQuery dataset disappears and nobody knows who created it or what
  permissions it had.
- Staging and production have different IAM bindings because someone clicked
  through the console differently.
- Onboarding a new data engineer takes days of "which buckets do I need access
  to?" instead of a single `terraform apply`.
- A cloud billing spike is traced to a manually-created resource that was
  never documented.

## Practice

### Provision Everything with Terraform

- Define GCP projects, BigQuery datasets, GCS buckets, service accounts, IAM
  bindings, and VPC networks as Terraform resources.
- Never create data platform resources through the cloud console — if it is
  not in `.tf` files, it does not exist in a reproducible form.
- Use provider modules (e.g. `terraform-google-modules`) for standardized
  resource patterns instead of hand-rolling every resource.

### Variables and Environment Separation

- Use a `variables.tf` file for environment-specific values (project ID,
  region, dataset names).
- Separate environments with `tfvars` files: `dev.tfvars`, `staging.tfvars`,
  `prod.tfvars`.
- Never hardcode project IDs or credentials in `.tf` files — pass them as
  variables or read from environment variables.

### State Management

- Store Terraform state remotely (GCS bucket for GCP, S3 for AWS) with state
  locking enabled.
- Never commit `terraform.tfstate` to git — it may contain sensitive values.
- Use `terraform import` to bring manually-created resources under Terraform
  management without destroying and recreating them.

### Resource Lifecycle

- Use `terraform plan` before every `apply` — review the diff in code review.
- Use `terraform destroy` for ephemeral resources (development sandboxes) to
  control cloud spend.
- Tag resources with `environment`, `owner`, and `cost_center` labels for
  billing attribution.

### Data Platform Resources to Provision

| Resource | Terraform Type | Purpose |
|----------|---------------|---------|
| GCP project | `google_project` | Isolation boundary for data workloads |
| BigQuery dataset | `google_bigquery_dataset` | Warehouse schema container |
| GCS bucket | `google_storage_bucket` | Data lake / staging area |
| Service account | `google_service_account` | Pipeline identity (not user accounts) |
| IAM binding | `google_project_iam_member` | Least-privilege access for pipeline SA |
| VPC network | `google_compute_network` | Network isolation for private data access |

## Related Concepts

- [Data Warehouse Design](/data-warehouse-design.md) — the warehouse that
  Terraform provisions.
- [ETL vs ELT](/etl-vs-elt.md) — the load target that Terraform creates.
