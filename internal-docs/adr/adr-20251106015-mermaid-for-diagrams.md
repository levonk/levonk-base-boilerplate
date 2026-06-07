---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Mermaid for Diagrams"
adr-id: 20251106015
slug: 20251106015-mermaid-for-diagrams
url: /internal-docs/adr/adr-20251106015-mermaid-for-diagrams.md
synopsis: Adopt Mermaid as the standard tool for creating all diagrams within the project, using the .mmd file extension.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "documentation", "diagrams", "mermaid"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106007-fumadocs-for-documentation"]
---

## Architecture Decision Record: Use Mermaid for Diagrams

## Context

We need a consistent, version-controllable, and accessible way to create and maintain technical diagrams, such as flowcharts, sequence diagrams, and architectural block diagrams. These diagrams are essential for conveying complex ideas in our documentation, ADRs, and READMEs.

## Constraints

- The solution must be text-based to allow for version control via Git.
- It must render correctly on GitHub.
- It must be compatible with our chosen documentation framework, Fumadocs.
- The syntax should be relatively easy for the team to learn and use.

## Decision

1. We will use **Mermaid** for creating all diagrams.
2. Diagram source code will be stored in dedicated files with a **`.mmd`** extension.
3. These `.mmd` files will be located in a `diagrams` subdirectory, close to the markdown files that reference them (e.g., `internal-docs/diagrams/`).

## Rationale

- **Diagrams as Code**: Mermaid's text-based syntax means that diagrams are treated as code. They can be versioned, reviewed in pull requests, and easily updated.
- **Excellent Integration**: Mermaid is natively supported by GitHub for rendering in markdown files. It is also supported by Fumadocs, ensuring a consistent viewing experience across all our documentation platforms.
- **Standardization**: Adopting a single tool prevents the proliferation of various diagramming formats (e.g., binary files from draw.io, Lucidchart, or image screenshots), which are difficult to maintain and version control.
- **Ease of Use**: The Mermaid syntax is declarative and relatively simple to learn for the most common diagram types, lowering the barrier to entry for creating high-quality diagrams.

## Consequences

- **Positive**:
  - All diagrams will be version-controlled, maintainable, and have a consistent style.
  - The process for creating and updating diagrams is simplified and standardized.
  - Diagrams will render consistently across GitHub and our dedicated documentation sites.

- **Negative**:
  - Mermaid may not be suitable for highly complex or free-form diagrams, where a visual tool like Excalidraw might be better for initial sketching. However, final, committed diagrams should be in Mermaid.

## Alternatives Considered

- **PlantUML**: A very powerful and feature-rich alternative for diagrams as code. However, its syntax is more complex than Mermaid's, and it does not have the same level of native support on GitHub.
- **Excalidraw**: An excellent tool for collaborative, free-form sketching. It's ideal for brainstorming sessions but is not a "diagrams as code" tool, and its output is not as easily version-controlled or standardized as Mermaid's.
- **Pasting Images**: The worst option. Images are binary files that cannot be diffed, are difficult to update, and often render poorly on different screen sizes or in dark mode.

## Rollout / Migration

1. A central `internal-docs/diagrams/` directory will be created for high-level architectural diagrams.
2. The first diagram to be created using this standard will be the tech stack summary block diagram.
3. Team members will be directed to this ADR and encouraged to use Mermaid for any new diagrams in their documentation.

## References

- [Mermaid JS](https://mermaid.js.org/)

<!-- vim: set ft=markdown: -->
