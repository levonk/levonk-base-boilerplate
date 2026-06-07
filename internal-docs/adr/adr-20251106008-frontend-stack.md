---
modeline: "vim: set ft=markdown:"
title: "ADR: Standardize on Next.js, Tailwind CSS, and Shadcn/UI for the Frontend"
adr-id: 20251106008
slug: 20251106008-frontend-stack
url: /internal-docs/adr/adr-20251106008-frontend-stack.md
synopsis: Adopt a standardized frontend stack consisting of Next.js, TypeScript, Tailwind CSS, Shadcn/UI, and Radix UI to build modern, performant, and maintainable user interfaces.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "frontend", "nextjs", "react", "typescript", "tailwind", "shadcn", "radix"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

We need to define a cohesive and modern technology stack for building all frontend applications. The stack must enable rapid development, produce high-performance user interfaces, ensure a great developer experience, and be maintainable in the long term within our TypeScript monorepo.

## Constraints

- The framework must be based on React.
- All code must be written in TypeScript, with no JavaScript allowed in the application source.
- The styling solution must be utility-first and highly customizable.
- We need a high-quality, accessible component library to accelerate UI development.

## Decision

Our standard frontend stack will consist of the following technologies:

1. **Framework**: **Next.js** (latest stable version, currently 14), utilizing the App Router.
2. **Language**: **TypeScript**.
3. **Styling**: **Tailwind CSS**.
4. **Component Library**: **Shadcn/UI**, which is built upon **Radix UI**.

We will also evaluate **Base Web** as a potential alternative to Radix UI for primitive components in the future.

## Rationale

- **Next.js**: It is the leading framework for production React applications. Its hybrid model of Server Components, Server-Side Rendering (SSR), and Static Site Generation (SSG) provides exceptional performance and flexibility. Its file-based routing and focus on modern React features make it highly productive.
- **TypeScript**: Non-negotiable for building robust, scalable applications. It ensures type safety and improves developer experience through better autocompletion and error checking.
- **Tailwind CSS**: A utility-first CSS framework that allows for rapid UI development without writing custom CSS. It is highly configurable and pairs perfectly with component-based frameworks.
- **Shadcn/UI & Radix UI**: This combination provides the best of both worlds. **Radix UI** offers a set of unstyled, accessible, and highly functional primitive components (e.g., dialogs, dropdowns). **Shadcn/UI** provides beautifully designed components built on top of Radix and Tailwind CSS. Crucially, Shadcn/UI is not a traditional component library; instead, you copy its source code directly into your project, giving you full control over the code.

## Consequences

- **Positive**:
  - A highly productive, modern, and cohesive stack for all frontend development.
  - Excellent performance and user experience due to Next.js's architecture.
  - A consistent and maintainable approach to styling and component building.
  - Full ownership and control over the component code thanks to Shadcn/UI's philosophy.

- **Negative**:
  - The learning curve for Next.js's App Router and Server Components can be steep for developers new to the concepts.

## Alternatives Considered

- **Remix**: Another excellent full-stack React framework. It has a different philosophy centered on web standards. Next.js was chosen for its larger ecosystem and more established position in the market.
- **Vite + React**: A simple and fast setup for client-side rendered applications. However, it lacks the integrated server-side capabilities and optimizations that Next.js provides out of the box.
- **Other Component Libraries (MUI, Chakra UI, Ant Design)**: These are excellent libraries, but they are more traditional "black box" dependencies. The Shadcn/UI approach of providing copy-pasteable source code offers greater flexibility and avoids dependency bloat.

## Rollout / Migration

1. All new frontend applications will be built using this stack.
2. A shared UI package (`@/ui/components`) will be created to house any custom or modified Shadcn/UI components.
3. A `tailwind.config.ts` file will be standardized and shared across projects where possible.

## To Investigate

- Evaluate **Base Web** as a potential alternative to Radix UI for the underlying component primitives to assess its accessibility, feature set, and developer experience.
- Monitor the evolution of **Next.js** and adopt new features (e.g., related to caching, static rendering, and UX) as they become stable.

## References

- [Next.js](https://nextjs.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Shadcn/UI](https://ui.shadcn.com/)
- [Radix UI](https://www.radix-ui.com/)
- [Base Web](https://baseweb.design/) (For future evaluation)

<!-- vim: set ft=markdown: -->
