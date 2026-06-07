---
modeline: "vim: set ft=markdown:"
title: "ADR: Use GitHub Actions for CI/CD"
adr-id: 20251106014
slug: 20251106014-cicd-strategy
url: /internal-docs/adr/adr-20251106014-cicd-strategy.md
synopsis: Adopt GitHub Actions as the primary platform for all CI/CD workflows, and use 'act' to enable local execution and testing of these workflows.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "ci", "cd", "devops", "github-actions", "act"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106001-pnpm-and-turborepo", "adr-20251106012-containerization-strategy"]
---


## Context

We need a powerful, flexible, and tightly integrated Continuous Integration and Continuous Deployment (CI/CD) system to automate our testing, building, and deployment processes. The system must live alongside our source code and be easy for the entire team to understand and contribute to.

## Constraints

- The CI/CD system must integrate directly with our GitHub repository.
- It must support complex workflows, including matrix builds, conditional steps, and environment protection rules.
- It must provide a way for developers to test CI/CD changes locally to shorten the feedback loop.

## Decision

1. **CI/CD Platform**: We will use **GitHub Actions** for all CI/CD pipelines.
2. **Local Runner**: We will use **`act`** to enable developers to run GitHub Actions workflows locally from their machines.

## Rationale

- **Deep Integration**: GitHub Actions is built into GitHub, providing seamless integration with our source code, pull requests, and releases. This eliminates the need for a separate, third-party CI/CD service and simplifies our toolchain.
- **Powerful and Flexible**: The workflow syntax is declarative (YAML) but powerful, supporting everything from simple linting jobs to complex, multi-stage deployment pipelines. The vast marketplace of pre-built actions allows us to compose complex workflows without reinventing the wheel.
- **`act` for Local Development**: The `act` tool is a game-changer for CI/CD development. It allows developers to run and debug GitHub Actions workflows in a local Docker container, providing a rapid feedback loop without having to push changes and wait for a run on GitHub's servers. This dramatically improves developer productivity and reduces broken builds on the main branch.
- **Community and Ecosystem**: GitHub Actions is the industry standard for projects hosted on GitHub, with a massive community and a rich ecosystem of shared actions and best practices.

## Consequences

- **Positive**:
  - A single, unified platform for all automation, managed as code within our repository.
  - Faster development and debugging of CI/CD workflows thanks to `act`.
  - Tighter integration between our code, tests, and deployments.

- **Negative**:
  - We are dependent on the GitHub Actions platform. A major outage at GitHub could halt our development and deployment pipeline.
  - The cost of GitHub-hosted runners can add up for large teams or frequent builds, although this can be mitigated with self-hosted runners if necessary.

## Alternatives Considered

- **Jenkins**: A powerful and highly extensible CI/CD server. However, it is notoriously complex to set up and maintain, and its configuration-as-code (Jenkinsfiles) is often considered more cumbersome than GitHub Actions' YAML.
- **CircleCI / Travis CI**: Excellent third-party CI/CD services. However, they introduce another tool and interface to our workflow. Given that GitHub Actions is now on par with (or exceeds) their feature sets for most use cases, the native integration of Actions is a compelling advantage.
- **GitLab CI/CD**: A very powerful and well-regarded CI/CD system, but it is tightly coupled to the GitLab platform. As our code is hosted on GitHub, it is not a direct fit.

## Rollout / Migration

1. A `.github/workflows` directory will be maintained at the root of the repository.
2. Initial workflows will be created for:
    - Linting and formatting checks on every push.
    - Running unit and integration tests on every pull request.
    - Building container images.
3. Deployment workflows will be created to integrate with our Pulumi IaC setup, triggered on merges to the main branch.
4. Developers will be instructed on how to install and use `act` for local workflow testing.

## References

- [GitHub Actions](https://github.com/features/actions)
- [act](https://github.com/nektos/act)

<!-- vim: set ft=markdown: -->
