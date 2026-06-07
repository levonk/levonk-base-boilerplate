---
modeline: "vim: set ft=markdown:"
title: "ADR: Dev Environment via direnv + Devbox"
adr-id: 20251226001
slug: 20251226001-devbox-direnv-dev-environment
url: /internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md
synopsis: Upgrade from raw Nix flakes to Devbox (by Jetify) + direnv for managing reproducible development environments.
author: https://github.com/levonk
date-created: 2025-12-26
date-updated: 2025-12-26
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "developer-experience", "nix", "direnv", "tooling", "devbox"]
supersedes: ["20251219001-nix-direnv-dev-environment"]
superseded-by: ["adr-20260131001-standard-developer-ux-flow"]
related-to: []
---

## Context

While Nix flakes provide reproducibility (as established in [ADR 20251219001](./adr-20251219001-nix-direnv-dev-environment.md)), the learning curve for writing `flake.nix` files can be steep, and the developer experience for managing packages is often verbose.

We want to maintain the benefits of Nix (hermetic, reproducible environments) but improve the usability for developers who may not be Nix experts.

## Decision

This repository will switch standardization to:

- **Devbox** (by Jetify) to define the development environment (packages, scripts, plugins) via `devbox.json`.
- **direnv** to automatically activate the Devbox environment.

Devbox uses Nix under the hood, preserving the underlying value proposition of the previous decision, but offers a simpler JSON-based configuration and familiar CLI workflow (e.g., `devbox add`).

## Consequences

- **Positive**
  - **Simpler Configuration**: `devbox.json` is easier to read and modify than `flake.nix`.
  - **Lower Barrier to Entry**: Developers can use familiar commands like `devbox add <package>` without learning the Nix language.
  - **Performance**: Devbox's shell activation is optimized.
  - **Continuity**: Still uses Nix packages, so the breadth of available software remains the same.

- **Negative**
  - **New Dependency**: Requires `devbox` binary installation (in addition to `nix` and `direnv`).

## Rollout

- Initialize `devbox.json` in the repository root.
- Configure `.envrc` to use `eval "$(devbox generate direnv --print-envrc)"`.
- Update documentation and Makefiles to reflect `devbox` usage instead of raw `nix develop`.

### Baseline Makefile targets

Update the baseline Makefile targets to use Devbox:

- **bootstrap**: install Nix (if missing), install `devbox`, install `direnv`, and run `devbox install`.
- **clean**: `rm -rf .devbox` and clean up caches.
- **build**: run the project’s primary build using `devbox run build`.
- **run**: start the main application/service using `devbox run start`.
- **deploy**: invoke the project’s deployment flow (document environment assumptions).
- **lint**: run linters using `devbox run lint`.
- **doctor**: verify `devbox`, `nix`, and `direnv` installation.

<!-- vim: set ft=markdown: -->
