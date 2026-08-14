---
type: Practice
title: Java Build Optimization — Incremental Compilation, Parallel Execution, and Build Cache
description: Enable incremental compilation, parallel execution, build cache, and the Gradle daemon to keep Java build times low; prefer module boundaries that compile independently.
tags: [java, build, gradle, maven, performance, caching, parallel, incremental]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: gradle-build-cache
    resource: https://docs.gradle.org/current/userguide/build_cache.html
    title: Gradle Build Cache
  - id: maven-parallel-builds
    resource: https://maven.apache.org/ref/3.9.6/maven-embedder/cli.html
    title: Maven parallel builds
---

# Java Build Optimization

## Failure Mode

Java builds become slow because the compiler reprocesses unchanged sources,
tests run sequentially, the build cache is disabled, and the project is one
monolithic module where every change triggers a full rebuild.

## Symptoms

- `mvn package` or `gradle build` takes several minutes on a one-line change.
- The Gradle daemon is disabled, so every build re-initializes the JVM.
- CI builds do not share compiled outputs between branches.
- A single `util` package change forces the entire monolith to recompile.

## Practice

### Maven

- Run `mvn -T 1C ...` to use one thread per CPU core.
- Use `maven.compiler.incremental` where supported by your toolchain.
- Cache `.m2/repository` between CI runs.
- Split large codebases into multi-module projects with clear API boundaries.

### Gradle

- Keep the daemon enabled (`org.gradle.daemon=true`).
- Enable parallel execution (`org.gradle.parallel=true`).
- Enable the build cache (`org.gradle.caching=true`) and configure a remote
  cache for CI.
- Use the configuration cache (`org.gradle.configuration-cache=true`) once
  plugins are compatible.
- Modularize with `api`/`implementation` separation to reduce recompilation.

### Modular Boundaries

- Split code into modules by bounded context (e.g., `core`, `api`, `adapters`).
- Use `implementation` for internal dependencies and `api` only for types that
  leak into public signatures.
- Avoid cyclic dependencies between modules — they break incremental
  compilation.
