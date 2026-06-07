---
modeline: "vim: set ft=markdown:"
title: "ADR: Standardize Markdown Frontmatter"
adr-id: 20251106016
slug: 20251106016-standardized-frontmatter
url: /internal-docs/adr/adr-20251106016-standardized-frontmatter.md
synopsis: Adopt a standardized YAML frontmatter schema for all markdown files to ensure consistency, enable programmatic processing, and improve document management.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "documentation", "frontmatter", "markdown"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106007-fumadocs-for-documentation"]
---


## Context

Our project contains a growing number of markdown files, including ADRs, READMEs, and other documentation. To maintain consistency and enable tools (like our documentation site generator, Fumadocs) to process these files programmatically, we need a single, standardized schema for the YAML frontmatter at the top of each file.

## Constraints

- The schema must be flexible enough to accommodate different document types (ADRs, general docs, etc.).
- It must provide essential metadata for SEO, navigation, and content management.
- It must be easy to understand and apply for all team members.

## Decision

All markdown files (`.md`) in this repository must include a YAML frontmatter block with the following standardized schema.

### Core Schema (Required for all files)

```yaml
title: "A clear, human-readable title for the document"
# Synopsis provides a brief, one-sentence summary for previews and SEO.
synopsis: "A concise one-sentence summary of the document's content."
# Tags are used for categorization and search.
tags: ["tag1", "tag2", "doc-type"]
```

### ADR-Specific Schema (Required for ADRs)

ADRs must include the core schema plus the following fields:

```yaml
adr-id: 20251106016 # Unique identifier for the ADR (YYYYMMDDNNN)
status: "proposed" | "accepted" | "deprecated" | "superseded"
author: "https://github.com/username"
date-created: YYYY-MM-DD
date-updated: YYYY-MM-DD
version: 1.0.0
supersedes: ["adr-id-of-old-adr"]
superseded-by: ["adr-id-of-new-adr"]
related-to: ["adr-id-of-related-adr"]
```

### Optional Fields

These fields can be used in any markdown file as needed:

```yaml
# A vim modeline for consistent editor behavior.
modeline: "vim: set ft=markdown:"
# A unique, URL-friendly slug for the document.
slug: unique-document-slug
# The canonical URL for the document.
url: /path/to/document.md
# Aliases for redirects or alternative lookups.
aliases: ["old-title", "common-misspelling"]
```

## Rationale

- **Consistency**: A single schema ensures that all documents have a consistent set of metadata, making the repository easier to navigate and understand.
- **Automation**: Standardized frontmatter is machine-readable. This allows our documentation generator (Fumadocs), scripts, and other tools to automatically build navigation, generate indexes, and handle metadata without custom parsing logic for each file.
- **Discoverability**: Rich metadata like `synopsis` and `tags` improves the searchability of our documentation, both within the repository and on the generated documentation site.

## Consequences

- **Positive**:
  - Improved organization and consistency of all markdown-based documentation.
  - Enables powerful automation and tooling for our documentation sites.
  - All developers will follow the same clear standard when creating new documents.

- **Negative**:
  - There is a small overhead to adding and maintaining frontmatter for every new markdown file.
  - Existing documents will need to be updated to conform to this new standard.

## Rollout / Migration

1. This ADR will serve as the official standard for all new markdown files.
2. A follow-up task will be created to review all existing ADRs and other key markdown files to ensure they conform to this schema.
3. Linters or pre-commit hooks may be added in the future to enforce the presence and basic structure of the frontmatter.

## References

- [YAML 1.2 Spec](https://yaml.org/spec/1.2.2/)
- [Fumadocs - Frontmatter](https://fumadocs.ui.shadcn.com/docs/meta/frontmatter)

<!-- vim: set ft=markdown: -->
