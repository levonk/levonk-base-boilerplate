---
modeline: "vim: set ft=markdown:"
title: "ADR: Containerization Strategy with Docker, Compose, and Kubernetes"
adr-id: 20251106012
slug: 20251106012-containerization-strategy
url: /internal-docs/adr/adr-20251106012-containerization-strategy.md
synopsis: Adopt Docker for containerization, Docker Compose for local development orchestration, and Kubernetes with Helm for production deployments to ensure consistency and scalability.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "containers", "docker", "docker-compose", "kubernetes", "helm", "devops"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106003-pulumi-for-iac"]
---


## Context

To ensure our application is portable, scalable, and has a consistent environment from local development to production, we must use containerization. We need a clear strategy for how we build container images, orchestrate them for local development, and deploy them to production environments.

## Constraints

- All application services must run in containers.
- The local development environment must be easy to set up and closely mirror production.
- The production deployment strategy must be scalable, resilient, and manageable through code.

## Decision

We will adopt a three-tiered containerization strategy:

1. **Containerization**: **Docker** (or a compatible alternative like Podman) will be used to build OCI-compliant container images for all services.
2. **Local Orchestration**: **Docker Compose** will be used to define and run our multi-container application stack for local development and testing.
3. **Production Orchestration**: **Kubernetes (K8s)** will be our container orchestrator for production environments. We will use **Helm** charts to package and manage our Kubernetes applications.

## Rationale

- **Docker**: It is the de facto industry standard for containerization, providing a robust and well-documented platform for building and running application images.
- **Docker Compose**: It is the simplest and most effective tool for defining and managing a multi-service stack on a local machine. It allows developers to spin up the entire application environment with a single command (`docker-compose up`), which is ideal for developer productivity.
- **Kubernetes and Helm**: Kubernetes is the undisputed leader for production container orchestration, offering unparalleled scalability, self-healing, and service discovery capabilities. Helm simplifies the complexity of managing Kubernetes applications by packaging all necessary resources (deployments, services, configs, etc.) into a single, versionable chart.
- **Clear Separation**: This strategy provides a clear and standard progression from local development to production. Docker Compose is perfect for the inner loop of development, while Kubernetes and Helm provide the robustness required for production workloads.

## Consequences

- **Positive**:
  - Consistent and reproducible environments across all stages (dev, test, prod).
  - Simplified onboarding for new developers.
  - A scalable and resilient production architecture.
  - Infrastructure and application configurations are version-controlled and managed as code.

- **Negative**:
  - Kubernetes has a steep learning curve and adds significant operational complexity. This will be managed via our IaC tool, Pulumi, which has strong Kubernetes support.
  - Maintaining Dockerfiles, Compose files, and Helm charts requires dedicated effort.

## Alternatives Considered

- **Docker Swarm**: A simpler alternative to Kubernetes for container orchestration. However, it has a much smaller market share and community, and it lacks the advanced features and ecosystem of Kubernetes.
- **Nomad**: Another strong orchestrator from HashiCorp. It is known for its simplicity and flexibility in handling non-containerized workloads. Kubernetes was chosen for its larger community and status as the industry standard.
- **Using Docker Compose in Production**: While possible for very simple applications, Docker Compose lacks the features needed for a robust production environment, such as automated scaling, self-healing, and advanced networking.

## Rollout / Migration

1. `Dockerfile`s will be created for every service in the application.
2. A root `docker-compose.yml` file will define the entire application stack for local development.
3. Our Pulumi setup will be used to provision a Kubernetes cluster in our beta environment.
4. Helm charts will be created for our applications to define the Kubernetes resources, and Pulumi will be used to deploy these charts.

## References

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)

<!-- vim: set ft=markdown: -->
