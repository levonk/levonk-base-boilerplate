---
type: Reference Pointer
title: Diagram Tool Selection
description: Pointer to the canonical diagram tool selection guidance in the documentation-diagram-practices knowledge bundle.
tags: [diagrams, tool-selection, reference-pointer]
timestamp: 2026-07-19T00:00:00Z
---

# Diagram Tool Selection (Reference Pointer)

The canonical guidance for selecting between Mermaid, PlantUML, and Excalidraw
lives in the knowledge bundle. **Read the bundle page before authoring** —
this file is a pointer, not a restatement.

## Canonical Source

[`knowledge/documentation-diagram-practices/diagram-tool-selection.md`](../included/knowledge/documentation-diagram-practices/diagram-tool-selection.md)

## Summary (for quick orientation only)

Pick the tool by **output type** and **rendering environment**:

| Tool | Best for | Renders in | VCS diffable |
|------|----------|-----------|--------------|
| Mermaid | Flowcharts, decision trees, sequence diagrams in markdown | GitHub, Obsidian, VS Code, static sites | ✅ |
| PlantUML | Precise UML (class, state, component, deployment) | Server, local jar, Obsidian plugin | ✅ |
| Excalidraw | Hand-drawn whiteboard sketches, low-fidelity mockups | Excalidraw app, Obsidian plugin | ⚠️ JSON |

The full decision tree (5 questions), mixing-tools-in-one-document guidance,
and "when this practice does NOT apply" are in the bundle page — read it.

## Why this is a pointer

The bundle is the single source of truth. Restating the rules here would
cause drift. When the bundle updates, this pointer stays valid.
