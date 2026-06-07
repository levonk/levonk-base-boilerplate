---
modeline: "vim: set ft=markdown:"
title: "ADR: Multi-Stage and Multi-Cloud Hosting Strategy"
adr-id: 20251106013
slug: 20251106013-hosting-strategy
url: /internal-docs/adr/adr-20251106013-hosting-strategy.md
synopsis: Adopt a multi-stage, multi-cloud hosting strategy using LocalStack for development, various IaaS/PaaS providers for beta, and a primary/secondary cloud approach for production to ensure resilience and flexibility.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "hosting", "cloud", "iaas", "paas", "gcp", "aws", "cloudflare"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106003-pulumi-for-iac", "adr-20251106012-containerization-strategy"]
---


## Context

We require a hosting strategy that supports the full application lifecycle, from local development to high-availability production. The strategy must enable rapid iteration, provide realistic testing environments, and ensure production resilience. It also needs to accommodate general-purpose compute, specialized GPU workloads, and a robust edge network.

## Constraints

- The strategy must provide a local development environment that closely mimics cloud services.
- It must support distinct beta/staging environments for pre-production testing.
- Production must be resilient, scalable, and not be dependent on a single cloud provider.
- It must provide cost-effective solutions for specialized GPU-based workloads.

## Decision

We will adopt a multi-stage, multi-provider hosting strategy, managed via our Infrastructure as Code (IaC) solution, Pulumi.

1. **Local Development**: **LocalStack** will be used to emulate AWS cloud services on developer machines, providing a high-fidelity environment for developing and testing cloud-native features without incurring cloud costs.
2. **Beta/Staging Environments**: We will use a mix of cost-effective IaaS and PaaS providers like **Render**, **Hetzner** (for KVM), and **DigitalOcean** to deploy preview branches and conduct integration testing.
3. **Production (General Compute)**: We will use a primary/secondary multi-cloud strategy. **Google Cloud Platform (GCP)** will be our primary provider, with **Amazon Web Services (AWS)** as our secondary for disaster recovery and specific service needs.
4. **Production (Edge Network)**: **Cloudflare** will be used for its global CDN, DDoS protection, and edge compute capabilities (e.g., Workers).
5. **Production (GPU Workloads)**: We will use specialized GPU cloud providers. **RunPod** will be our primary choice, with **TensorDock** as a secondary/alternative, to ensure cost-effective access to high-performance computing for AI/ML tasks.

## Rationale

- **Lifecycle Support**: This strategy provides a tailored environment for each stage of the development lifecycle, optimizing for developer experience, testing fidelity, and production robustness.
- **Resilience and Flexibility**: A multi-cloud production strategy (GCP + AWS) prevents vendor lock-in and provides a path for disaster recovery. Using specialized providers for GPU workloads (RunPod) and edge (Cloudflare) ensures we are using the best and most cost-effective tool for each job.
- **Cost Optimization**: Using LocalStack for development is free. Using budget-friendly providers for beta environments keeps testing costs low. Using specialized GPU providers is significantly cheaper than using general-purpose clouds for the same compute power.
- **IaC-Driven**: This entire strategy is underpinned by our decision to use Pulumi, which allows us to define and manage infrastructure across all these different providers in a consistent way.

## Consequences

- **Positive**:
  - A robust, resilient, and cost-effective hosting strategy for the entire application lifecycle.
  - Avoidance of single-provider vendor lock-in.
  - Developers can work locally with a high-fidelity cloud environment.

- **Negative**:
  - Managing infrastructure across multiple cloud providers is inherently more complex than using a single provider. This complexity is mitigated, but not eliminated, by using Pulumi.
  - Requires expertise across multiple cloud provider APIs and services.

## Alternatives Considered

- **Single Cloud Provider**: Using only one provider (e.g., AWS) for everything. This is simpler to manage but leads to vendor lock-in and may not be the most cost-effective solution for all workload types (especially GPU).
- **On-Premise Hosting**: This provides maximum control but comes with a massive operational overhead for hardware procurement, maintenance, and security, which is not viable for our team.

## Rollout / Migration

1. LocalStack will be integrated into our `docker-compose` setup for local development.
2. Pulumi will be used to define the infrastructure for a beta environment on Render or DigitalOcean.
3. Production infrastructure will be built out on GCP first, followed by the setup of disaster recovery resources on AWS.
4. Cloudflare will be configured as the DNS provider and CDN for our production domains.

## References

- [LocalStack](https://localstack.cloud/)
- [Render](https://render.com/)
- [RunPod](https://www.runpod.io/)
- [Pulumi](https://www.pulumi.com/)

<!-- vim: set ft=markdown: -->
