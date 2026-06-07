---
modeline: "vim: set ft=markdown:"
title: "ADR: Architecture Decision Records Process"
adr-id: "20251129002"
slug: "20251129002-architecture-decision-records-process"
url: "/internal-docs/adr/adr-20251129002-architecture-decision-records-process.md"
synopsis: "Standardizes how, when, and where Architecture Decision Records (ADRs) are created and maintained in this repository."
author: "https://github.com/levonk"
date-created: "2025-11-29"
date-updated: "2025-11-29"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "process", "governance"]
supersedes: []
superseded-by: []
related-to: ["adr-20251129001-copier-based-boilerplate-standard"]
scope:
  impact-scope: ["all applications", "all packages", "internal-docs"]
  excluded-scope: []
---

# Decision Record: Architecture Decision Records Process

- belongs in `internal-docs/adr/adr-20251129002-architecture-decision-records-process.md`

---

## Context

The monorepo depends on a growing set of architectural and cross-cutting decisions:

- Monorepo tools (pnpm, Turborepo).
- Package and application organization.
- Runtime safety policies, testing standards, and boilerplate templates.

These decisions are currently documented as individual ADRs in `internal-docs/adr/`, but the **process** for creating and maintaining ADRs has not itself been defined as an ADR. Without a clear process:

- It is ambiguous when an ADR is required versus optional.
- Different authors may use inconsistent structures or metadata.
- Future contributors may not know where to look for prior decisions.

We need a lightweight but explicit standard for ADR usage in this repository.

## Constraints

- The process must be simple enough that contributors will actually follow it.
- It must fit the existing repository layout (`internal-docs/adr/`).
- It must be compatible with editor and tooling expectations (frontmatter, file naming).
- It should be consistent with the ADR guidance already captured in the `/adr` workflow.

## Decision

This repository will use **Architecture Decision Records (ADRs)** as the canonical mechanism for documenting architecturally significant decisions.

- All ADRs MUST live in: `internal-docs/adr/`.
- All ADRs MUST include standardized YAML frontmatter.
- ADRs MUST be created for any **architecturally significant decision**, including but not limited to:
  - System and monorepo structure.
  - Core technology and framework choices.
  - Cross-cutting concerns (security, testing, CI/CD, documentation).
  - Long-lived patterns and processes that affect multiple applications or packages.

## Rationale

Formalizing the ADR process provides:

- **Traceability**: Each decision is recorded once, with a stable identifier, and can be referenced from code, PRs, design docs, and specs.
- **Consistency**: A single expected format makes ADRs easy to skim and maintain.
- **Onboarding**: New contributors can review ADRs to understand why the system looks the way it does, instead of reverse-engineering intent from code.
- **Change Management**: Superseding ADRs documents reversals and refinements without erasing history.

This ADR aligns the repository with established industry practice for documenting architecture decisions while grounding it in this repo's specific layout and conventions.

## Technical Approach

### 1. Location and Naming

- **Directory**: All ADRs live under `internal-docs/adr/`.
- **File naming**:
  - New ADRs SHOULD use a date-based identifier in the filename, for example:
    - `20251129002-architecture-decision-records-process.md`
  - For historical reasons, some ADRs use short numeric IDs (e.g. `001-package-organization.md`) or `adr-<id>-<slug>.md`. These remain valid but new ADRs should prefer the date-based style.

### 2. Frontmatter Schema

Each ADR MUST start with a YAML frontmatter block including at least:

- `title`: `"ADR: <Proper Cased Title>"`
- `adr-id`: A stable identifier (short integer or `YYYYMMDDNNN` string).
- `slug`: Lowercased, hyphenated short slug.
- `url`: Repository-relative path to the ADR.
- `synopsis`: One-sentence summary of the decision.
- `author`: GitHub URL or similar identifier.
- `date-created`, `date-updated`: ISO dates.
- `version`: Semantic version for the ADR text.
- `status`: One of `proposed`, `accepted`, `rejected`, `superseded`.
- `tags`: Must include `"doc/architecture/adr"` and `"adr"`; additional tags are encouraged.
- `supersedes`, `superseded-by`, `related-to`: Lists of related ADR slugs or IDs when applicable.

Additional fields (e.g., `scope`, `date-review`, `date-triggers`) are encouraged when helpful and may be extended as needed.

### 3. Body Structure

The body of each ADR SHOULD follow this logical structure (adapted from the `/adr` workflow):

- `## Context` – Problem statement, constraints, and relevant background.
- `## Constraints` – Hard requirements from infra, compliance, or integration.
- `## Decision` – The decision in one or two sentences.
- `## Rationale` – Why this option was chosen; trade-offs and implications.
- `## Technical Approach` – Implementation details, patterns, or processes.
- `## Consequences` – Positive, negative, and neutral impacts.
- `## Alternatives Considered` – Options evaluated and reasons for rejection.
- `## Rollout / Migration` – How to adopt the decision incrementally.
- `## Validation` – How to know if it was the right call.
- `## References` – Links to related ADRs, specs, issues, and external resources.

ADR authors may combine or omit sections when appropriate, but the `Context`, `Decision`, `Rationale`, and `Consequences` sections are required.

### 4. When to Create an ADR

Create a new ADR when:

- Introducing a new framework, runtime, or core dependency (e.g., Next.js, Pulumi, PostgreSQL).
- Changing the monorepo structure or project organization.
- Establishing or changing cross-cutting policies (e.g., testing strategy, CI/CD stack, security model).
- Defining patterns and standards that multiple apps or packages must follow (e.g., boilerplate strategy, documentation frontmatter).

Minor, localized refactors or bug fixes generally do **not** require an ADR unless they introduce a new pattern expected to spread across the codebase.

### 5. Workflow Integration

- ADRs are authored and reviewed like any other code change (branch + PR).
- PR descriptions SHOULD link to the relevant ADR(s) when implementing or adjusting a documented decision.
- Architectural discussions SHOULD reference ADR IDs to keep conversations grounded in existing decisions.
- When a decision is replaced, the old ADR MUST be marked `status: "superseded"` and linked to its replacement via `superseded-by` / `supersedes`.

## Consequences

### Positive

- **Shared Understanding**: Decisions and their rationales are centralized and discoverable.
- **Reduced Rework**: Contributors can avoid re-litigating previously made decisions.
- **Better Reviews**: Reviewers can validate changes against accepted ADRs.
- **Historical Record**: The evolution of architecture is preserved over time.

### Negative

- **Upfront Effort**: Writing ADRs adds work when making significant changes.
- **Maintenance**: ADRs must be updated or superseded when decisions change.

### Neutral

- ADRs do not replace detailed design docs or specs; they complement them by capturing the core decision and its rationale.

## Alternatives Considered

- **Ad-hoc Documentation in README Files**
  - *Pros*: Very low overhead; easy to start.
  - *Cons*: Hard to search; decisions get buried in long-form docs; no consistent status or lifecycle.

- **External ADR Tooling Only (adr-tools)**
  - *Pros*: Provides CLI helpers for creating and linking ADRs.
  - *Cons*: Adds tooling dependencies; less flexible across different editors and environments. The current approach focuses on content and process; additional tooling can be layered on later if needed.

## Rollout / Migration

1. Keep all existing ADRs in `internal-docs/adr/` as the historical record.
2. For new architecturally significant decisions, authors MUST create a new ADR following this process.
3. When existing decisions are refined or reversed, authors MUST either:
   - Update the existing ADR (if the decision is minor and not fundamentally changed), or
   - Create a new ADR and mark the old one as `superseded` with cross-links.
4. Update internal documentation (such as `internal-docs/ARCHITECTURE.md`) to reference this ADR so that contributors can easily discover the process.

## Validation

This ADR will be considered successful if:

- New technology or structural decisions consistently ship with new ADRs.
- Reviewers regularly reference ADR IDs in PR discussions.
- Contributors report that ADRs are a useful source of truth when learning the codebase.

## References

- Internal workflow: `.windsurf/workflows/adr.md` (Decision Records process)
- Existing ADRs in `internal-docs/adr/` (examples and precedents)
- Michael Nygard, "Documenting Architecture Decisions" (original ADR concept)
