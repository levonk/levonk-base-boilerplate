---
type: Synthesis
title: Nix Build Practices Overview
description: Synthesis of Nix build practices — flake structure, devbox as Nix abstraction, package verification via search.nixos.org, reproducible builds with lock files, inherent platform scope detection, partial platform coverage with hybrid fallback flakes, and nixpkgs upstream contribution via pkgs/by-name.
tags: [nix, flakes, devbox, reproducible, builds, overview, synthesis, platform-scope, partial-coverage, nixpkgs-contribution]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"
sources:
  - id: adr-20251219001-nix-direnv-dev-environment
    resource: internal-docs/adr/adr-20251219001-nix-direnv-dev-environment.md
    title: levonk-base-boilerplate
  - id: adr-20251226001-devbox-direnv-dev-environment
    resource: internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md
    title: levonk-base-boilerplate
  - id: nixify-skill-v2.15.0
    resource: ../../skills/software-dev/nixify/SKILL.md.tmpl
    title: nixify skill v2.15.0 — platform scope and hybrid fallback
  - id: nubjs-nub-169
    resource: https://github.com/nubjs/nub/issues/169
    title: nubjs/nub#169 — prebuilt chosen over from-source (vendored runtime tree)
  - id: nixpkgs-quick-start
    resource: "https://nixos.org/manual/nixpkgs/stable/#chap-quick-start"
    title: "nixpkgs Reference Manual — Quick Start to Adding a Package"
  - id: nixify-skill-v2.19.0
    resource: ../../skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify skill v2.19.0 — nixpkgs superset check and upstream contribution"
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


# Nix Build Practices Overview

This bundle documents practices for Nix-based build and development environments.
Each concept was extracted from ADRs, the nixify skill, and project conventions
— the decisions that ensure reproducible builds, correct package references,
practical abstraction over raw Nix, and correct platform targeting.

## The Nix Build Stack

The bundle has two layers: a **build pipeline** (4 phases that every Nix
project passes through) and a **platform strategy** layer (2 concepts that
govern which platforms the flake targets and how to handle gaps in prebuilt
release coverage). The platform strategy is orthogonal to the pipeline — it
is consulted at the structure phase to scope `allSystems` and at the
verification phase to compute coverage.

```
Build pipeline:
  flake-structure → devbox-abstraction → package-verification → reproducible-builds

Platform strategy (orthogonal, consulted at structure + verification):
  inherent-platform-scope → partial-platform-coverage
```

| Layer | Phase | Practice | Prevents |
|-------|-------|----------|----------|
| Pipeline | Structure | [Nix Flake Structure](nix-flake-structure.md) | Missing inputs, unclear outputs, non-reproducible shells |
| Pipeline | Abstraction | [Devbox as Nix Abstraction](devbox-as-nix-abstraction.md) | Complex Nix syntax, steep learning curve |
| Pipeline | Verification | [Package Verification](package-verification.md) | Non-existent packages, renamed attributes, version mismatches |
| Pipeline | Reproducibility | [Reproducible Builds](reproducible-builds.md) | Different builds across machines, unpinned dependencies |
| Strategy | Scope | [Inherent Platform Scope](inherent-platform-scope.md) | Broken builds on unsupported platforms, unnecessary cross-compilation |
| Strategy | Coverage | [Partial Platform Coverage](partial-platform-coverage.md) | "Package not available" on platforms the project could build from source |
| Pipeline | Distribution | [nixpkgs Contribution](nixpkgs-contribution.md) | Project invisible to Nix users who search nixpkgs first |

### How the Layers Interact

1. **Inherent platform scope** runs first — it determines `target_platforms`,
   the set of systems the flake will target. A macOS-only app narrows to
   darwin; a cross-platform CLI keeps all 4 systems.
2. **Partial platform coverage** is computed relative to `target_platforms` —
   not the hardcoded 4-system set. A darwin-only project that ships both
   darwin binaries has full coverage of its scope, even though it ships no
   Linux binaries.
3. The flake's `allSystems`, `assets`, and `meta.platforms` are scoped to
   `target_platforms`. When coverage is partial and source build is feasible,
   the hybrid fallback variant makes `#default` fall back to source on the
   missing platforms.

## Scope

This bundle covers **Nix-based build and development** — flake structure, devbox
abstraction, package verification, reproducible builds, inherent platform
scope, and partial platform coverage. It does **not** cover:

- Devbox/direnv/just workflow — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- CI/CD pipeline configuration — see
  [cicd-testing-practices](../cicd-testing-practices/overview.md).
- Container build patterns — see
  [container-best-practices](../container-best-practices/overview.md).
- Upstream contribution practices (forking, PR etiquette) — see
  [upstream-contribution-practices](../upstream-contribution-practices/overview.md).

## Sources

- `internal-docs/adr/adr-20251219001-nix-direnv-dev-environment.md` — boilerplate (66 lines)
- `internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md` — boilerplate (65 lines)
- `src/current/skills/software-dev/nixify/SKILL.md.tmpl` — nixify skill v2.14.0 (hybrid fallback) and v2.15.0 (platform scope)
- `https://github.com/nubjs/nub/issues/169` — prebuilt chosen over from-source (vendored runtime tree)
- Project conventions: package verification via search.nixos.org

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Workflow practices using devbox/direnv/just
- [cicd-testing-practices](../cicd-testing-practices/overview.md) — CI uses Nix
  for reproducible builds
- [container-best-practices](../container-best-practices/overview.md) —
  Container builds on Nix base images
- [upstream-contribution-practices](../upstream-contribution-practices/overview.md)
  — The nixify skill consumes this bundle when forking upstream repos
