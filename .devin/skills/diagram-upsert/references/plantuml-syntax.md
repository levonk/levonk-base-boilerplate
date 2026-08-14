---
type: Reference Pointer
title: PlantUML Syntax Practices
description: Pointer to the canonical PlantUML syntax conventions in the documentation-diagram-practices knowledge bundle.
tags: [diagrams, plantuml, syntax, reference-pointer]
timestamp: 2026-07-19T00:00:00Z
---

# PlantUML Syntax Practices (Reference Pointer)

The canonical PlantUML syntax conventions live in the knowledge bundle. **Read
the bundle page before authoring a PlantUML diagram** — this file is a pointer,
not a restatement.

## Canonical Source

[`knowledge/documentation-diagram-practices/plantuml.md`](../included/knowledge/documentation-diagram-practices/plantuml.md)

## Summary (for quick orientation only)

- Every PlantUML diagram must be wrapped in `@startuml` / `@enduml`.
- Prefer a local jar over the public plantuml.com server for offline /
  air-gapped environments and to avoid server downtime.
- Use `salt` for wireframes.
- Layout sprawl and unreadable sequence diagrams are addressed in the bundle.

The full syntax rules, local-jar setup, and layout guidance are in the bundle
page — read it.

## Why this is a pointer

The bundle is the single source of truth. Restating the rules here would
cause drift. When the bundle updates, this pointer stays valid.
