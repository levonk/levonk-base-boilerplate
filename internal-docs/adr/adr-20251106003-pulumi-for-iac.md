---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Pulumi for Infrastructure as Code"
adr-id: 20251106003
slug: 20251106003-pulumi-for-iac
url: /internal-docs/adr/adr-20251106003-pulumi-for-iac.md
synopsis: Adopt Pulumi as the standard for Infrastructure as Code (IaC) to enable programmatic, type-safe, and multi-cloud infrastructure management using TypeScript.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "iac", "pulumi", "typescript", "cloud", "hosting"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106001-pnpm-and-turborepo"]
---

## Context

The project requires a multi-stage hosting strategy spanning local development (LocalStack), beta environments (Render, DigitalOcean), and production clouds (GCP, AWS, Cloudflare). We need a consistent, repeatable, and version-controlled way to define, deploy, and manage infrastructure across these diverse providers. Manually managing infrastructure is error-prone and does not scale.

## Constraints

- The IaC tool must support all our target cloud providers.
- It must integrate well with our primary language, TypeScript, to maintain a consistent developer experience.
- The tool must allow for creating reusable, modular infrastructure components.
- State management must be robust and reliable.

## Decision

We will use **Pulumi** as our Infrastructure as Code (IaC) tool, with **TypeScript** as the language for defining infrastructure.

## Rationale

- **Use Real Code**: Pulumi allows us to use a general-purpose programming language (TypeScript) to define infrastructure. This enables the use of loops, conditionals, functions, classes, and other programming constructs, providing far more power and flexibility than domain-specific languages (DSLs).
- **Unified Toolchain**: Our team is already proficient in TypeScript. Using Pulumi means we don't have to learn a separate DSL like HCL (Terraform). We can use the same linters, formatters, and IDEs for both application and infrastructure code.
- **Multi-Cloud Support**: Pulumi has excellent support for all our target providers, including AWS, GCP, Cloudflare, and Kubernetes, allowing us to manage our entire cloud ecosystem from a single tool.
- **Type Safety**: By using TypeScript, we get strong typing for our infrastructure, catching errors at compile-time rather than during a lengthy deployment process.

## Consequences

- **Positive**:
  - Infrastructure definitions will be more readable, maintainable, and testable.
  - Increased developer velocity as the team can leverage existing TypeScript skills.
  - Infrastructure and application code can be co-located and versioned together in our monorepo.
  - Easier to create complex, dynamic infrastructure setups.

- **Negative**:
  - There is a learning curve associated with the Pulumi SDK and its programming model (e.g., handling `Output<T>` types for asynchronous values).
  - State is managed by Pulumi's service by default, which creates a dependency on their platform (though self-hosted backends are an option).

## Alternatives Considered

- **Terraform / OpenTofu**: The industry standard for IaC. It uses a DSL called HCL, which is declarative and robust. However, HCL is less flexible than a full programming language and would require our team to learn and maintain a separate language and toolset.
- **Cloud-Native DSLs (CloudFormation, ARM, Bicep)**: These are specific to a single cloud provider (AWS or Azure) and do not meet our requirement for a multi-cloud solution.
- **CDK (Cloud Development Kit)**: Similar to Pulumi in that it uses general-purpose languages. However, CDK is primarily focused on AWS (with some support for other clouds), whereas Pulumi is designed from the ground up to be multi-cloud.

## Rollout / Migration

1. A new `infrastructure` package will be created within the monorepo to house all Pulumi code.
2. Initial implementation will focus on defining the infrastructure for a new, non-critical service (e.g., a staging environment on Render).
3. Reusable components (e.g., for a standard Kubernetes deployment or a serverless function) will be developed and published as internal packages.
4. Existing manually-configured infrastructure will be gradually imported into Pulumi's management.

## To Investigate

- Best practices for managing secrets and configuration for different environments (dev, beta, prod) within Pulumi.
- The feasibility and trade-offs of using a self-hosted state backend versus the default Pulumi Service.

## References

- [Pulumi](https://www.pulumi.com/)
- [Pulumi vs. Terraform](https://www.pulumi.com/docs/intro/vs/terraform/)

<!-- vim: set ft=markdown: -->
