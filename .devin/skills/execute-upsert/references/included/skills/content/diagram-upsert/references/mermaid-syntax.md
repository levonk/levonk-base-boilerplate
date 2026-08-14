---
type: Reference Pointer
title: Mermaid Syntax Practices
description: Pointer to the canonical Mermaid syntax conventions in the documentation-diagram-practices knowledge bundle.
tags: [diagrams, mermaid, syntax, reference-pointer]
timestamp: 2026-07-19T00:00:00Z
---

# Mermaid Syntax Practices (Reference Pointer)

The canonical Mermaid syntax conventions live in the knowledge bundle. **Read
the bundle page before authoring a Mermaid diagram** — this file is a pointer,
not a restatement.

## Canonical Source

[`knowledge/documentation-diagram-practices/mermaidjs.md`](../included/knowledge/documentation-diagram-practices/mermaidjs.md)

## Summary (for quick orientation only)

The most common footgun (from ADR-20260520001) is **unquoted decision node
labels containing `<br/>` or parentheses**. Markdown pre-processors strip
`<br/>` to a literal newline, then `(` on the next line is parsed as a
parenthesis-start token, causing `Expecting 'SQE', got 'PS'` errors.

**Fix**: quote every decision node label that contains `<br/>` or special
characters using Mermaid's `{"..."}` syntax:

```mermaid
flowchart TD
    Q1{"What kind of<br/>question?"} --> A1[Answer 1]
    Q1 --> A2[Answer 2]
```

The full quoting rules, `<br/>` handling, ✅/❌ examples, and renderer-specific
quirks are in the bundle page — read it.

## Why this is a pointer

The bundle is the single source of truth. Restating the rules here would
cause drift. When the bundle updates, this pointer stays valid.
