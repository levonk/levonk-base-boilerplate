---
type: Synthesis
title: Container Best Practices Overview
description: Synthesis of container best practices extracted from real failure modes — base image selection, layer caching, build context, multi-stage builds, process supervision, supply-chain pinning, linting, compose dependency ordering, runtime hardening, registry cache strategy, build-time secret hygiene, Node.js production hardening, Dockerfile package cleanup, and deterministic image versioning from Git state.
tags: [docker, containers, dockerfile, docker-compose, buildkit, security, nodejs, versioning, best-practices, overview, synthesis]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: existing-project-standard
    resource: "../../workflows/software-dev/devops/containers/docker-standards.md"
    title: "existing project standard"
  - id: image-build-automation
    resource: "../../skills/software-dev/container-image-build/SKILL.md"
    title: "image build automation"
  - id: compose-ansible-deployment
    resource: "../../skills/software-dev/container-service-deploy/SKILL.md"
    title: "compose/Ansible deployment"
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


# Container Best Practices Overview

This bundle documents practices for authoring and running containers that are
small, fast to build, reproducible, secure, and operationally sound. Each
concept was extracted from a specific failure mode — a Dockerfile that was
slow, bloated, broken, or unreproducible; a compose stack that raced on
startup; a container that leaked privileges or secrets — and the practice
that prevents it.

## The Container Lifecycle

```
base-image → layer-order → context-hygiene → multi-stage → process-model → pin-digest → lint
                                                                                          ↓
                            secrets → registry-cache → compose-ordering → runtime-hardening → versioning
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Base image | [Base Image Selection](base-image-selection.md) | musl libc breakage, 15× build-time penalty, missing native deps |
| Layering | [Layer Cache Order](layer-cache-order.md) | Cold rebuild on every code edit; dependency install re-runs needlessly |
| Context | [Build Context Hygiene](build-context-hygiene.md) | Shipping node_modules/.git/logs to daemon; mile-long COPY commands |
| Build | [Multi-Stage Builds](multi-stage-builds.md) | 272 MB images for a static binary; toolchain in runtime image |
| Process | [Single-Container Multi-Process](single-container-multi-process.md) | Over-engineering two containers for a small app that needs Nginx+backend |
| Supply chain | [Pin Image Digests](pin-image-digests.md) | Reproducible builds breaking when tags move; internal image mistakes |
| Quality | [Dockerfile Linting](dockerfile-linting.md) | Manual review missing the patterns above; CI not enforcing them |
| Secrets | [BuildKit Secret Mounts](buildkit-secrets.md) | Credentials baked into layers, leaked via `docker history`, exposed in CI logs |
| Cache | [Registry Cache Strategy](registry-cache-strategy.md) | CI cold-rebuilding every layer; registry bandwidth costs; Docker Hub rate limits |
| Compose | [Compose Service Dependency Ordering](compose-service-dependency-ordering.md) | App containers crashing on startup because DB isn't accepting connections yet |
| Runtime | [Container Runtime Hardening](container-runtime-hardening.md) | Container escape, privilege escalation, resource exhaustion attacks, docker.sock exposure, unscanned images |
| Node.js | [Node.js in Containers](nodejs-in-containers.md) | Dev deps in prod, root-owned processes, zombie processes from missing init, SIGTERM not reaching Node.js |
| Dockerfile | [Dockerfile Best Practices](dockerfile-best-practices.md) | Bloated layers, package cache retention, missing healthchecks, root-by-default images |
| Build strategy | [Container Runtime Essentials](container-runtime-essentials.md) | Rebuilding from source when a pre-built image exists; single-arch :latest for mixed fleets; QEMU segfaults on Rust/C++ builds; missing --push for multi-platform |
| Monorepo | [Nx Monorepo Docker Patterns](nx-monorepo-docker-patterns.md) | Per-app Dockerfiles reinstalling the full workspace; CI rebuilding every app image on every commit; Nx cache and Docker cache operating in isolation |
| Versioning | [Deterministic Image Versioning](image-versioning.md) | Non-deterministic image tags (CI build numbers, timestamps, `latest`); no traceability from running image to source commit; multi-arch builds emitting different version strings per platform; Git smudge/clean filters silently failing in CI and shallow clones |

## Scope

This bundle covers **container authoring, build, runtime, and language-specific
hardening** — Dockerfiles, build context, multi-stage patterns, the runtime
process model, build-time secret hygiene, registry cache strategy, compose
dependency ordering, runtime hardening (including docker.sock and TCP daemon
prohibitions, image scanning), Node.js production container hardening,
Dockerfile package cleanup patterns, and the build-strategy decision tree
(pre-built vs Dockerfile vs Nix, multi-arch mandates, QEMU avoidance, sidecar
usage, entrypoint/healthcheck file naming), and deterministic image versioning
(Git-derived version strings, OCI labels, post-deployment override). It does
**not** cover:

- Container orchestration (Kubernetes, Nomad) — separate bundle.
- Container runtime daemon configuration (Docker daemon, containerd, podman
  config files) — future concept pages can be ingested here.
- Container registry administration (push policies, garbage collection,
  signing) — future concept pages can be ingested here.
- Project-specific security ADRs — see job-aide ADR-20251218001 and the
  `secure-docker` workflow; this bundle's [Container Runtime Hardening](container-runtime-hardening.md)
  provides the generalizable knowledge behind those standards.
- Nx monorepo package-manager-in-containers policy — the
  [pnpm-nx-monorepo](../typescript-monorepo-best-practices/pnpm-nx-monorepo.md)
  concept in the TypeScript bundle defines the `npx`/`bunx`/`pnpm exec` rule
  and its container exception. [Nx Monorepo Docker Patterns](nx-monorepo-docker-patterns.md)
  in this bundle applies that rule to Docker builds and documents the
  pnpm-sidecar shared store pattern.

## Relationship to Existing Project Standards

The job-aide `docker-standards.md` workflow prescribes project-specific
container standards (file structure, base image preferences for infra
services, OrbStack/podman tooling). This bundle provides the **generalizable
knowledge** behind those standards — the "why" that explains when the
project standard applies and when it doesn't.

The most important interaction: `docker-standards.md` says "prefer alpine if
possible" for infrastructure services. [Base Image Selection](base-image-selection.md)
explains why this is correct for infra (you control the toolchain) but wrong
for application Dockerfiles (musl breaks upstream glibc wheels). The two are
not contradictory — they are context-dependent.

## Sources

The initial 7 concepts were extracted from the DevOps Toolbox video
"Give me 15 minutes and I'll Fix Your Dockerfiles Forever" (2026-07-17), which
distilled five corrections plus two bonus practices from years of container
building experience.

The 2ndbrain note capturing the full video transcript with timecoded
backlinks lives at:
`2ndbrain/Default/Literature/Internet/Video/Give me 15 minutes and I'll Fix Your Dockerfiles Forever.md`

The subsequent 4 concepts (compose dependency ordering, runtime hardening,
registry cache strategy, buildkit secrets) were researched from Docker
documentation, the CIS Docker Benchmark, NIST SP 800-190, and practitioner
blog posts — see each concept's `# Citations` section for the specific
sources.

The 2 language-specific concepts (Node.js in Containers, Dockerfile Best
Practices) were migrated from the devsecops-codeguard bundle, where they
were originally sourced from job-aide `.devin/rules/codeguard-0-devops-ci-cd-containers.md`
and `.devin/rules/dockerfile-best-practices.md`. The runtime hardening concept
was extended with docker.sock, TCP daemon, image scanning, and implementation
checklist content from the same codeguard rules.

## Compounding

New lessons from future container work — videos, articles, real production
failures, or new tooling — should be filed as new concept pages. The trigger
for adding a concept is: a build failure, a production incident, or a
debugging session that revealed a practice the bundle doesn't yet cover.
Append to `log.md` when adding.

Future concept candidates (not yet in the bundle):

- `container-networking-patterns.md` — bridge vs. host vs. macvlan; internal
  networks; DNS-based service discovery
- `container-logging-strategy.md` — JSON-file vs. journald vs. fluentd
  drivers; log rotation; structured logging from containers
- `container-resource-governance.md` — cgroups v2; CPU/memory/IO limits vs.
  reservations; OOM-kill behavior
- `image-vulnerability-scanning.md` — Trivy, Grype, Snyk; when to scan; how
  to handle CVEs in base images you can't upgrade
- `container-update-strategy.md` — Watchtower, Renovate, manual rebuilds;
  balancing freshness vs. stability

## Related Knowledge Bundles

- [devsecops-codeguard](../devsecops-codeguard/overview.md) — code-level security
  rules (credential detection, crypto governance, certificate validation, SSH
  hardening) that complement this bundle's runtime and build-time guidance.
  Container-specific concepts formerly in devsecops-codeguard have been
  consolidated here.
- [java-best-practices](../java-best-practices/overview.md) — Java/JVM
  container packaging, JRE vs JDK, and Alpine compatibility for Java
  applications.
- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
  — Airflow layered images and Kubernetes deployment patterns that build on
  the container practices here.
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
  — Node.js containerization and package conventions that intersect with
  Dockerfile best practices.
