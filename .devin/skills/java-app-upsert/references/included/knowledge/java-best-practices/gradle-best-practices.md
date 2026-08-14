---
type: Practice
title: Gradle Best Practices — Wrapper, Version Catalogs, and Configuration Cache
description: Use the Gradle wrapper, version catalogs for dependency centralization, configuration cache for faster builds, and a dedicated gradle-cache volume in containers.
tags: [java, gradle, build, version-catalog, configuration-cache, caching, gradle-wrapper]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-gradle-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/gradle-sidecar/Dockerfile.gradle-sidecar
    title: infrahub gradle-sidecar Dockerfile
  - id: mavengradle-project-configuration
    resource: ../../skills/software-dev/project-adopter/scripts/configure-java.sh
    title: Maven/Gradle project configuration
---

# Gradle Best Practices

## Failure Mode

Gradle builds slow down because developers use different Gradle versions,
dependencies are scattered across build files, and configuration is re-evaluated
on every invocation. Container builds re-download the Gradle distribution.

## Symptoms

- `gradle --version` differs across CI runners and laptops.
- Dependencies appear with hardcoded versions in multiple `build.gradle.kts` files.
- `gradle build` spends 30+ seconds in configuration on a no-op build.
- The Gradle distribution is downloaded inside every fresh container.

## Practice

### Use the Wrapper

- Commit `gradlew`, `gradlew.bat`, and `gradle/wrapper/` to version control.
- Update the wrapper with `./gradlew wrapper --gradle-version=X.Y`.
- CI and containers should always invoke `./gradlew`, never a system `gradle`.

### Version Catalogs

- Centralize versions in `gradle/libs.versions.toml`.
- Reference libraries as `libs.junit.jupiter` and plugins as `alias(libs.plugins.spring.boot)`.
- This prevents version drift and makes Renovate/Dependabot updates trivial.

### Configuration Cache

- Enable `org.gradle.configuration-cache=true` in `gradle.properties`.
- Avoid build logic that reads external state at configuration time (network,
  environment variables without `providers`).
- Mark tasks that cannot be cached with `notCompatibleWithConfigurationCache`.

### Build Cache

- Enable `org.gradle.caching=true`.
- In CI, use a remote build cache (Gradle Enterprise, S3, GCS, or GitHub
  Actions cache).
- In dev containers, mount `gradle-cache` volume to `~/.gradle` to persist the
  wrapper, dependencies, and build cache across container restarts.

### Multi-Project Builds

- Use `include("project-name")` in `settings.gradle.kts`.
- Prefer `implementation(project(":core"))` over direct filesystem references.
- Keep plugin configuration in convention plugins under `buildSrc` or
  `gradle/plugins`.
