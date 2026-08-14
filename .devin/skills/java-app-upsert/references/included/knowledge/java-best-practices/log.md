# Directory Update Log

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Update**: Completed missing concept pages that were referenced in [index.md](index.md) and [overview.md](overview.md) but not yet written to disk.
  - [maven-best-practices.md](maven-best-practices.md) — Maven dependency management, reproducible builds, surefire/failsafe split
  - [gradle-best-practices.md](gradle-best-practices.md) — Gradle wrapper, version catalogs, configuration cache, build cache
  - [java-testing.md](java-testing.md) — JUnit 5, Mockito, Testcontainers, surefire/failsafe
  - [java-security.md](java-security.md) — Dependency scanning, SAST, JEP 411 Security Manager deprecation
  - [java-build-optimization.md](java-build-optimization.md) — Incremental compilation, parallel execution, build cache
  - [java-alpine-compatibility.md](java-alpine-compatibility.md) — musl libc, JNI, glibc workarounds
  - [java-sidecar-pattern.md](java-sidecar-pattern.md) — Development sidecars with shared Maven/Gradle cache volumes
  - [bigdecimal-pitfalls.md](bigdecimal-pitfalls.md) — BigDecimal equals() vs compareTo()

## 2026-07-17

* **Initialization**: Created the `java-best-practices` knowledge bundle as an OKF v0.1 knowledge bundle, filling the gap where no dedicated Java knowledge bundle existed in skills-src.
* **Creation**: Initialized 11 concept pages sourced from real findings across infrahub, job-aide, 2ndbrain, and skills-src repositories.
  - [overview.md](overview.md) — synthesis of the full Java practice set
  - [jvm-tuning.md](jvm-tuning.md) — container-aware JVM flags, G1/ZGC selection, MaxRAMPercentage
  - [java-in-containers.md](java-in-containers.md) — JRE vs JDK, multi-stage builds, Alpine openjdk17 vs Debian
  - [maven-best-practices.md](maven-best-practices.md) — dependency management, reproducible builds, .m2 caching
  - [gradle-best-practices.md](gradle-best-practices.md) — wrapper, version catalog, configuration cache, gradle-cache volume
  - [java-testing.md](java-testing.md) — JUnit 5, Mockito, Testcontainers, surefire/failsafe split
  - [java-security.md](java-security.md) — OWASP DependencyCheck, SpotBugs, JEP 411 Security Manager deprecation
  - [java-build-optimization.md](java-build-optimization.md) — incremental compilation, build cache, parallel execution, daemon
  - [java-alpine-compatibility.md](java-alpine-compatibility.md) — musl libc JNI issues, gnu-libiconv workaround, Alpine vs Debian
  - [java-sidecar-pattern.md](java-sidecar-pattern.md) — development sidecar architecture from infrahub
  - [bigdecimal-pitfalls.md](bigdecimal-pitfalls.md) — compareTo() vs equals() for BigDecimal comparison
* **Creation**: Established [index.md](index.md) directory listing and [log.md](log.md) update log.
* **Note**: The infrahub Java sidecar (`Dockerfile.java-sidecar`) uses Alpine `openjdk17` while the Gradle sidecar (`Dockerfile.gradle-sidecar`) uses a multi-stage build with `openjdk17-jre` in the runtime stage — a real example of the JRE-vs-JDK and Alpine-vs-Debian trade-offs documented in this bundle.
* **Note**: The 2ndbrain article on BigDecimal comparison pitfalls (2024-06-19) provided the source for the [bigdecimal-pitfalls.md](bigdecimal-pitfalls.md) concept — a real captured finding from the user's knowledge base.
