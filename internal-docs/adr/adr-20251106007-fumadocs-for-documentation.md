---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Fumadocs for Documentation Sites"
adr-id: 20251106007
slug: 20251106007-fumadocs-for-documentation
url: /internal-docs/adr/adr-20251106007-fumadocs-for-documentation.md
synopsis: Adopt Fumadocs as the framework for building all documentation sites, including developer docs, blogs, and FAQs, to leverage its modern features and integration with Next.js.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "documentation", "fumadocs", "nextjs", "mdx"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

The project requires high-quality, maintainable, and performant documentation for multiple audiences, including developers (API references, guides) and end-users (blog posts, FAQs). We need a unified solution that can handle both technical and content-focused documentation efficiently.

## Constraints

- The solution must be based on modern web technologies and integrate with our Next.js frontend stack.
- It must support MDX (Markdown with JSX) for rich, interactive content.
- It must provide features expected of a modern documentation site, such as search, navigation, and good typography.
- It should be able to handle different types of content, from structured technical docs to chronological blog posts.

## Decision

We will use **Fumadocs** as the standard framework for building all documentation and content-driven websites. This includes:

1. **Developer Documentation**: For API references, architectural guides, and tutorials.
2. **Content Sites**: For blogs and FAQs, using Fumadocs' Content Collections or page frontmatter to manage structured content.

## Rationale

- **Modern and Next.js-Native**: Fumadocs is built on top of Next.js and leverages its powerful features like the App Router, Server Components, and advanced caching, ensuring our documentation sites are fast and modern.
- **MDX Support**: Its first-class support for MDX allows us to create rich, interactive documentation that goes beyond static text.
- **Excellent Developer Experience**: Fumadocs offers a streamlined setup, powerful search capabilities out of the box, and a highly customizable UI, making it easy to create beautiful and functional documentation.
- **Versatility**: While optimized for technical documentation, its flexible structure and support for content collections make it equally suitable for managing other content types like blog posts or knowledge bases, providing a single tool for multiple needs.

## Consequences

- **Positive**:
  - A single, consistent framework for all documentation and content sites simplifies maintenance and development.
  - Documentation sites will be fast, SEO-friendly, and feature-rich.
  - Developers can use their existing React and Next.js skills to build and customize the documentation.

- **Negative**:
  - As a newer framework compared to giants like Docusaurus, the community and plugin ecosystem may be smaller.

## Alternatives Considered

- **Docusaurus**: A very popular and mature documentation framework from Facebook. It is feature-rich and has a large community. However, Fumadocs offers a more modern architecture by being built on the Next.js App Router.
- **Nextra**: Another excellent documentation framework built on Next.js. Fumadocs and Nextra are very similar; Fumadocs was chosen for its slightly more opinionated and streamlined approach to UI and search.
- **VitePress**: A documentation generator powered by Vite. It is extremely fast but is built on Vue.js, which would introduce another frontend framework into our otherwise React-based ecosystem.

## Rollout / Migration

1. A new Next.js application will be scaffolded within the `apps/` directory specifically for our primary documentation site.
2. Fumadocs will be installed and configured in this application.
3. The initial structure for developer documentation and a blog will be created.
4. ADRs and other architectural documents will be gradually migrated into the new documentation site to serve as the single source of truth.

## References

- [Fumadocs](https://fumadocs.ui.shadcn.com/)

<!-- vim: set ft=markdown: -->
