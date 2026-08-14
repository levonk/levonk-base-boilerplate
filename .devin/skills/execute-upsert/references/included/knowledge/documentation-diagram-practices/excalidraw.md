---
type: Practice
title: Excalidraw Practices
description: Excalidraw conventions for documentation — store .excalidraw JSON in git for diffability, use the hand-drawn aesthetic to signal tentative designs, and switch to Mermaid/PlantUML when precision is required.
tags: [documentation, diagrams, excalidraw, whiteboard, hand-drawn, json-storage]
date:
  created: "2026-07-19"
  knowledge-basis: "2026-07-18"
  last-used: "2026-07-18"
---

# Excalidraw Practices

## Practice

Excalidraw is the tool of choice for **hand-drawn whiteboard diagrams** —
architecture sketches, brainstorming sessions, low-fidelity mockups. The
sketch aesthetic communicates "this is tentative" in a way polished diagrams
cannot.

### 1. Store `.excalidraw` JSON in git, not PNG exports

Excalidraw saves as JSON (`.excalidraw` extension). Commit the JSON file to
git — it's diffable (though noisy) and preserves editability. PNG/SVG exports
are binary blobs that lose edit history:

```bash
# ✅ Correct — commit the JSON source
git add architecture-whiteboard.excalidraw

# ❌ Wrong — binary blob, no edit history
git add architecture-whiteboard.png
```

For rendering in markdown, export to SVG (text-based, diffable) and commit
both the `.excalidraw` source and the `.svg` export:

````markdown
![Architecture](./architecture-whiteboard.svg)
<details><summary>Source (Excalidraw)</summary>

`architecture-whiteboard.excalidraw` — open in https://excalidraw.com or the
Obsidian Excalidraw plugin.
</details>
````

### 2. Use the hand-drawn aesthetic deliberately

The sketch aesthetic is a feature, not a limitation. Use it when:

- The design is **tentative** and you don't want readers to treat it as final.
- You're capturing a **whiteboard session** and want to preserve the
  brainstorming feel.
- You're communicating **"this is one option, not the option"**.

Switch to Mermaid or PlantUML when the diagram should read as authoritative.

### 3. Use the Obsidian Excalidraw plugin for embedded diagrams

The Obsidian Excalidraw plugin embeds `.excalidraw` files directly in notes
with live editing. This is the lowest-friction workflow for Obsidian-based
documentation:

1. Create `diagram.excalidraw` in the note's directory.
2. Embed with `![[diagram.excalidraw]]`.
3. Edit in-place; the plugin auto-saves the JSON.

### 4. Switch to Mermaid/PlantUML when precision is required

Excalidraw is the wrong tool for:

- **Decision trees** — use Mermaid (renders inline, see
  [Mermaid Practices](mermaidjs.md)).
- **Sequence/class/state UML** — use PlantUML (precise UML, see
  [PlantUML Practices](plantuml.md)).
- **Diagrams that must be regenerated from source on CI** — Excalidraw JSON is
  hand-authored, not generated from a DSL.

### 5. Export to SVG for non-Excalidraw environments

GitHub and most static site generators don't render `.excalidraw` files. Export
to SVG for those environments:

```bash
# Via the CLI (pnpm dlx — never npx in this monorepo)
pnpm dlx @excalidraw/utils export --input diagram.excalidraw --output diagram.svg

# Or via the web app: File → Export → SVG
```

## Why

Excalidraw fills a gap that Mermaid and PlantUML can't: **communicating
tentativeness**. A polished Mermaid flowchart reads as "this is the design";
a hand-drawn Excalidraw sketch reads as "this is one idea we're considering."
Using the right tool for that signal prevents readers from over-indexing on
tentative designs.

Storing the JSON source (not just PNG exports) preserves editability — you can
re-open and modify the diagram later without redrawing from scratch.

## When this practice applies

- Whiteboard sessions captured into documentation.
- Architecture sketches that are deliberately tentative.
- Brainstorming diagrams where the hand-drawn aesthetic communicates
  "work in progress."
- Obsidian-based documentation with the Excalidraw plugin installed.

## When this practice does NOT apply

- **Finalized architecture diagrams** — use Mermaid or PlantUML.
- **Diagrams that must render on GitHub without external files** — use Mermaid
  (inline fenced code block).
- **Precise UML** — use PlantUML.
- **CI-generated diagrams** — use a text-based DSL (Mermaid/PlantUML) that can
  be regenerated from source.

## See Also

- [Diagram Tool Selection](diagram-tool-selection.md) — when to pick Excalidraw
  over Mermaid or PlantUML.
- [Mermaid Practices](mermaidjs.md) — the inline-rendering alternative for
  decision trees and flowcharts.
- [PlantUML Practices](plantuml.md) — the precise-UML alternative for
  finalized designs.
- [dev-environment-practices](../dev-environment-practices/overview.md) —
  Excalidraw desktop app and Obsidian plugin installation.

## Sources

- Excalidraw official site — https://excalidraw.com/
- Obsidian Excalidraw plugin — https://github.com/zsviczian/obsidian-excalidraw-plugin
- Excalidraw CLI export — `@excalidraw/utils` npm package.
