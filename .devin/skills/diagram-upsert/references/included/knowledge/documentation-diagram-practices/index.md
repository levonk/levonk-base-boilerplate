---
okf_version: "0.2"
---

# Documentation Diagram Practices

A compounding knowledge base documenting practices for embedding diagrams in
technical documentation — tool selection, syntax conventions that survive
markdown pre-processing, and the failure modes that break renders. Each concept
captures a specific diagram concern and the practice that addresses it, sourced
from real ADRs and documentation fixes.

## Concepts

* [Overview](overview.md) - Synthesis of the full diagram practice set and how the pieces fit together
* [Diagram Tool Selection](diagram-tool-selection.md) - Pick the right tool (Mermaid, PlantUML, Excalidraw) by output type, version control needs, and rendering environment
* [Mermaid Practices](mermaidjs.md) - Quoting labels, `<br/>` line breaks, decision node syntax, and avoiding markdown pre-processor stripping
* [PlantUML Practices](plantuml.md) - Text-based diagrams for sequence/class/state, server vs local rendering, `@startuml`/`@enduml` hygiene
* [Excalidraw Practices](excalidraw.md) - Hand-drawn whiteboard diagrams, `.excalidraw` JSON storage, and when sketching beats precision
* [Color Contrast Practices](color-contrast.md) - Never host light text on pastel fills; pair dark text with light fills or light text with dark fills; target WCAG AA 4.5:1
* [Rust Doc Comment Patterns](rust-doc-comment-patterns.md) - `///` vs `//!` conventions, Examples/Errors/Panics sections, intra-doc links, doc test patterns
* [Cargo Doc Generation](cargo-doc-generation.md) - cargo doc commands, public API documentation, hosted docs, cross-crate links, CI doc checks
