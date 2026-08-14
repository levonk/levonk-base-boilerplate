---
okf_version: "0.2"
---

# Java Best Practices

A compounding knowledge base documenting hard-won lessons from building,
running, and debugging Java/JVM applications. Each concept captures a specific
failure mode or pattern observed in real repositories — container sidecars,
build tooling, library pitfalls, and runtime tuning — and the practice that
prevents or addresses it.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [JVM Tuning](jvm-tuning.md) - Container-aware JVM flags, heap sizing with MaxRAMPercentage, GC selection (G1/ZGC)
* [Java in Containers](java-in-containers.md) - JRE vs JDK in containers, multi-stage builds for Java, Alpine openjdk17 vs Debian JDK
* [Maven Best Practices](maven-best-practices.md) - Dependency management, mvn dependency:tree, reproducible builds, .m2/repository caching
* [Gradle Best Practices](gradle-best-practices.md) - Gradle wrapper, version catalog, configuration cache, gradle-cache volume pattern
* [Java Testing](java-testing.md) - JUnit 5, Mockito, Testcontainers, surefire/failsafe split
* [Java Security](java-security.md) - Dependency scanning (OWASP DependencyCheck), SAST (SpotBugs), JEP 411 Security Manager deprecation
* [Java Build Optimization](java-build-optimization.md) - Incremental compilation, build cache, parallel execution, daemon configuration
* [Java Alpine Compatibility](java-alpine-compatibility.md) - musl libc issues with JNI native libraries, gnu-libiconv workaround, when to use Alpine vs Debian
* [Java Sidecar Pattern](java-sidecar-pattern.md) - Development sidecar architecture for Java/Gradle from the infrahub pattern
* [BigDecimal Pitfalls](bigdecimal-pitfalls.md) - BigDecimal.equals() compares scale; use compareTo() for numerical equality
