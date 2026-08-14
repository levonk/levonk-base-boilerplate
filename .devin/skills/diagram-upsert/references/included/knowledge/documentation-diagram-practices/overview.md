---
type: Synthesis
title: Documentation Diagram Practices Overview
description: Synthesis of documentation diagram practices — tool selection across Mermaid, PlantUML, and Excalidraw, plus the syntax conventions that keep diagrams rendering across markdown pre-processors.
tags: [documentation, diagrams, mermaid, plantuml, excalidraw, overview, synthesis]
date:
  created: "2026-07-19"
  knowledge-basis: "2026-07-18"
  last-used: "2026-07-18"
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


# Documentation Diagram Practices Overview

This bundle documents practices for embedding diagrams in technical
documentation. Each concept captures a specific diagram concern — tool
selection, syntax that survives markdown pre-processing, rendering pipelines —
and the practice that addresses it.

## The Diagram Tool Landscape

```
tool-selection → mermaid (inline, render-portability) → plantuml (precise, server-rendered)
                                ↓
              excalidraw (hand-drawn, whiteboard, .excalidraw JSON)
```

| Concern | Practice | Prevents |
|---------|----------|----------|
| Selection | [Diagram Tool Selection](diagram-tool-selection.md) | Picking a tool that doesn't render in your target environment, version-control friction, unreachable rendering servers |
| Mermaid | [Mermaid Practices](mermaidjs.md) | Parse errors from unquoted labels, `<br/>` stripped by pre-processors, broken decision nodes |
| PlantUML | [PlantUML Practices](plantuml.md) | Missing `@startuml`/`@enduml`, server-only rendering, layout sprawl, unreadable sequence diagrams |
| Excalidraw | [Excalidraw Practices](excalidraw.md) | Binary blob in git, lost sketch history, hand-drawn diagrams where precision is required |
| Contrast | [Color Contrast Practices](color-contrast.md) | Light text on pastel fills, sub-WCAG contrast ratios, labels that vanish on dim screens and in print |
| Rust Docs | [Rust Doc Comment Patterns](rust-doc-comment-patterns.md) | Missing Examples/Errors/Panics sections, broken intra-doc links, stale doc tests |
| Cargo Doc | [Cargo Doc Generation](cargo-doc-generation.md) | No CI doc checks, missing hosted docs, broken cross-crate links, undocumented feature flags |

## Scope

This bundle covers **diagram authoring and embedding practices** for technical
documentation — the tool selection, syntax conventions, and rendering
considerations that keep diagrams working across markdown renderers (GitHub,
Obsidian, VS Code, static site generators). It does **not** cover:

- General technical writing — see a dedicated writing bundle.
- Diagram design aesthetics (palette selection, visual hierarchy, brand color
  choices) — out of scope. **Color contrast for readability is in scope** as an
  accessibility concern; see
  [Color Contrast Practices](color-contrast.md).
- Rendering tool installation — see
  [dev-environment-practices](../dev-environment-practices/overview.md).
- Build system integration for diagram pipelines — see
  [build-system-essentials](../build-system-essentials/overview.md).

## Compounding

New lessons from future diagram work — new tool integrations, renderer-specific
quirks, accessibility practices — should be filed as new concept pages. Append
to `log.md` when adding.

## Related Knowledge Bundles

- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Environment setup for diagram rendering tools (PlantUML jar, Mermaid CLI,
  Excalidraw desktop).
- [build-system-essentials](../build-system-essentials/overview.md) —
  Diagram-to-image pipelines in build systems.
- [software-architecture-essentials](../software-architecture-essentials/overview.md)
  — ADRs that embed decision-tree diagrams (Mermaid flowcharts) rely on the
  Mermaid practices in this bundle to render correctly.

## Sources

- ADR-20260520001 v3.0.0 — `ADR-20260520001 v3.0.0 (job-aide internal-docs)`
  (two Mermaid flowcharts that broke from unquoted decision node labels; fix
  documented in [mermaidjs.md](mermaidjs.md)).
