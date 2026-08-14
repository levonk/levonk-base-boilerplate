---
type: Synthesis
title: Java Best Practices Overview
description: Synthesis of Java/JVM best practices covering JVM tuning, container packaging, build tooling, testing, security, Alpine compatibility, sidecar architecture, and library pitfalls.
tags: [java, jvm, best-practices, overview, synthesis, containers, maven, gradle]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
  - id: infrahub-gradle-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/gradle-sidecar/Dockerfile.gradle-sidecar
    title: infrahub gradle-sidecar Dockerfile
  - id: java-project-configuration-automation
    resource: ../../skills/software-dev/project-adopter/scripts/configure-java.sh
    title: Java project configuration automation
  - id: mavengradle-build-system-detection
    resource: ../../skills/software-dev/project-detection/references/detection-capabilities.md
    title: Maven/Gradle build system detection
  - id: 2ndbrain-bigdecimal-article
    resource: https://igorstechnoclub.com/java-bigdecimal/
    title: 2ndbrain BigDecimal article
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Java Best Practices Overview

This bundle documents practices for building, running, and debugging Java/JVM
applications that are fast, reproducible, secure, and operationally sound. Each
concept was extracted from a specific finding — a container sidecar that needed
JRE-only runtime, a build tool that needed cache volumes, a library pitfall
that caused silent bugs — and the practice that addresses it.

## The Java Application Lifecycle

```
jvm-tuning → container-packaging → build-tool → testing → security
     ↑              ↑                  ↑          ↑         ↑
     └── alpine-compatibility ── sidecar-pattern ── library-pitfalls
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Runtime | [JVM Tuning](jvm-tuning.md) | OOM kills in containers, wrong GC for workload, ignored cgroup limits |
| Packaging | [Java in Containers](java-in-containers.md) | Shipping full JDK in runtime image, bloated images, missing JRE |
| Build (Maven) | [Maven Best Practices](maven-best-practices.md) | Non-reproducible builds, dependency conflicts, cold cache rebuilds |
| Build (Gradle) | [Gradle Best Practices](gradle-best-practices.md) | Unpinned Gradle versions, no configuration cache, missing wrapper |
| Testing | [Java Testing](java-testing.md) | Unit/integration test mixing, no containerized integration tests |
| Security | [Java Security](java-security.md) | Known CVEs in dependencies, injected vulnerabilities, deprecated security APIs |
| Build speed | [Java Build Optimization](java-build-optimization.md) | Slow incremental builds, no parallelism, daemon misconfiguration |
| Compatibility | [Java Alpine Compatibility](java-alpine-compatibility.md) | JNI crashes on musl, missing native libs, iconv failures |
| Architecture | [Java Sidecar Pattern](java-sidecar-pattern.md) | Redundant JDK downloads, no shared cache, slow dev container startup |
| Libraries | [BigDecimal Pitfalls](bigdecimal-pitfalls.md) | Silent inequality bugs from equals() comparing scale not value |

## Scope

This bundle covers **Java/JVM application building, packaging, and runtime** —
JVM tuning, container packaging, Maven and Gradle build tooling, testing
strategy, security scanning, build optimization, Alpine compatibility, the
sidecar development pattern, and library-level pitfalls. It does **not** cover:

- Java framework-specific patterns (Spring Boot, Quarkus, Micronaut) — separate
  bundles can be ingested here.
- Kotlin-specific practices — see the `configure-kotlin.sh` script in the
  project-adopter skill for Kotlin project setup.
- Java application server administration (Tomcat, Jetty, WildFly tuning) —
  future concept pages can be ingested here.
- JVM internals (classloading, bytecode manipulation, JIT profiling) — future
  concept pages can be ingested here.

## Relationship to Existing Project Assets

The skills-src repository contains several assets that interact with Java
projects but lacked a dedicated knowledge bundle — this bundle fills that gap:

- **project-adopter skill**: `scripts/configure-java.sh` handles Maven `pom.xml`
  and Gradle `build.gradle` configuration, Checkstyle, and testing setup. This
  bundle provides the **generalizable knowledge** behind what that script
  configures.
- **project-detection skill**: Detects Maven and Gradle build systems (see
  `references/detection-capabilities.md`). This bundle explains the practices
  that should follow detection.
- **infrahub sidecars**: The `java-sidecar` and `gradle-sidecar` containers
  (see [Java Sidecar Pattern](java-sidecar-pattern.md)) are real
  implementations of the container packaging and caching practices documented
  here.

## Sources

The concepts in this bundle were sourced from real findings across four
repositories:

1. **infrahub** — Java and Gradle sidecar Dockerfiles, health check scripts,
   and cache volume definitions in `docker-compose.*.yml`.
2. **job-aide** — `docker-compose.include.yml` referencing `gradle-cache` and
   `java-m2-cache` volumes; planned Java CLI boilerplate (ADR-20251210001).
3. **2ndbrain** — A single article on BigDecimal comparison pitfalls captured
   from Igor's Techno Club (2024-06-19).
4. **skills-src** — `configure-java.sh` and `configure-kotlin.sh` scripts in
   the project-adopter skill; Maven/Gradle detection in project-detection.

See each concept's `# Citations` section for the specific sources.

## Compounding

New lessons from future Java work — production incidents, library upgrades,
new JVM features, framework migrations — should be filed as new concept pages.
The trigger for adding a concept is: a build failure, a production incident, a
debugging session, or a library pitfall that revealed a practice the bundle
doesn't yet cover. Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `java-logging.md` — structured logging (SLF4J/Logback), log levels, JSON
  output for container environments
- `java-concurrency.md` — virtual threads (JEP 444), structured concurrency,
  executor service patterns
- `java-modules.md` — JPMS module system, `module-info.java`, automatic modules
- `spring-boot-best-practices.md` — auto-configuration, profiles, actuator
  health checks, layered jars
- `java-records-sealed.md` — records (JEP 395), sealed classes (JEP 409),
  pattern matching

## Related Knowledge Bundles

- [container-best-practices](../container-best-practices/overview.md) —
  multi-stage builds, base image selection, and runtime hardening for Java
  container packaging.
- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
  — data pipeline tooling that often runs on the JVM (Spark) or uses Java-based
  orchestration patterns.
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — dependency
  scanning, SAST, and secure coding practices that apply to Java applications.
