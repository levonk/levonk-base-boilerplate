---
type: Practice
title: Maven Best Practices — Dependency Management and Reproducible Builds
description: Use BOMs, lock dependency versions, run mvn dependency:tree, split surefire/failsafe tests, and cache .m2/repository in CI and dev containers.
tags: [java, maven, build, dependencies, reproducible-build, testing, caching]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
  - id: mavengradle-project-configuration
    resource: ../../skills/software-dev/project-adopter/scripts/configure-java.sh
    title: Maven/Gradle project configuration
---

# Maven Best Practices

## Failure Mode

Maven builds become non-reproducible or slow because dependency versions drift
between environments, transitive dependencies conflict silently, tests are mixed
between unit and integration, and the local `.m2/repository` is rebuilt from
scratch on every CI run.

## Symptoms

- `mvn package` works locally but fails in CI because a transitive dependency
  changed.
- Two developers get different dependency trees for the same `pom.xml`.
- Integration tests that need a database run during `mvn test` (surefire),
  slowing the feedback loop and failing in environments without the service.
- CI pipelines re-download all artifacts on every run because `.m2` is not cached.

## Practice

### Pin Versions

- Use `<dependencyManagement>` with explicit versions, ideally via a BOM
  (`import` scope).
- Never rely on transitive dependency version resolution for direct
  dependencies.
- Run `mvn dependency:tree` and `mvn dependency:analyze` regularly to find unused
  or undeclared dependencies.

### Reproducible Builds

- Set `<project.build.outputTimestamp>` for reproducible artifact timestamps
  (Maven 3.2.1+).
- Use `maven-dependency-plugin:3.1.2+` with `reproducible` resolution where
  possible.
- Pin plugin versions in `<pluginManagement>` — do not let Maven pick defaults.

### Test Split

- **Unit tests** → `maven-surefire-plugin` (`src/test/java`).
- **Integration tests** → `maven-failsafe-plugin` (`src/integrationTest/java` or
  `*IT.java` suffix).
- Use profiles (`-Pintegration-tests`) to activate long-running tests only in
  CI.

### Caching

- Mount or cache `.m2/repository` in CI and dev containers. The infrahub
  `java-sidecar` and `gradle-sidecar` use named volumes (`java-m2-cache`,
  `gradle-cache`) for this purpose.

## When Maven Over Gradle

- Teams already familiar with Maven.
- Projects with stable plugin ecosystems and BOM-heavy dependency trees.
- When convention-over-configuration is preferable to DSL flexibility.
