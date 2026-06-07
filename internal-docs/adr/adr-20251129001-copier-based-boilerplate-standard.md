---
modeline: "vim: set ft=markdown:"
title: "ADR: Copier-Based Boilerplate Standard"
adr-id: "20251129001"
slug: "20251129001-copier-based-boilerplate-standard"
url: "/internal-docs/adr/adr-20251129001-copier-based-boilerplate-standard.md"
synopsis: "Establishes copier as the standard tool for project scaffolding and lifecycle management."
author: "https://github.com/levonk"
date-created: "2025-11-29"
date-updated: "2025-11-29"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "tooling", "standard"]
supersedes: []
superseded-by: []
related-to: []
scope:
  impact-scope: ["all projects"]
  excluded-scope: []
---

# Decision Record: Copier-Based Boilerplate Standard

- belongs in `internal-docs/adr/adr-20251129001-copier-based-boilerplate-standard.md`

---

## Context

As the monorepo grows, maintaining consistency across many packages and applications becomes increasingly difficult. We need a way to:
1.  Rapidly scaffold new projects with a standardized structure.
2.  Ensure all projects adhere to current configuration standards (ESLint, TypeScript, Vitest, etc.).
3.  Update existing projects when standards change (e.g., moving from one CI/CD pattern to another).

Traditional "cookiecutter" or static template generators only solve the first problem. Once a project is generated, it drifts from the template, making it hard to retrofit improvements.

## Decision

We will use **[copier](https://github.com/copier-org/copier)** as the standard tool for all project scaffolding and lifecycle management within the repository.

All project templates must be maintained in the `boilerplate/` directory.

## Rationale

`copier` was chosen over alternatives like `cookiecutter`, `yeoman`, or simple git cloning because:

1.  **Update Capability**: `copier` creates a `.copier-answers.yml` file in the generated project. This allows it to re-apply the template to an existing project, intelligent merging changes. This is critical for keeping dozens of packages in sync with the latest infrastructure standards.
2.  **Simplicity**: Templates are just directory trees with Jinja2 placeholders. There is no complex logic or compiled code required to create a template.
3.  **Local & Remote Support**: It works well with local paths, making it easy to test templates within the monorepo before "releasing" them.

## Technical Approach

### Template Location
All templates reside in `boilerplate/`. Common templates include:
- `boilerplate/apps/flutter`
- `boilerplate/packages/category`

### Usage
To create a new project:
```bash
copier copy boilerplate/packages/category packages/active/features/node/my-feature/typescript
```

To update an existing project:
```bash
copier update
```

### Template Standards
- **`copier.yml`**: Every template must have a `copier.yml` defining questions and default values.
- **`.copier-answers.yml`**: This file must be committed to the generated project to enable future updates.
- **Minimal Logic**: Keep Jinja2 logic simple. Complex logic should be handled by scripts invoked after generation if absolutely necessary, but declarative templating is preferred.

## Consequences

### Positive
- **Consistency**: All new projects start with the correct configuration.
- **Maintainability**: We can push structural fixes to all projects by updating the template and running `copier update`.
- **Speed**: Developers don't need to copy-paste from other projects, reducing "cargo cult" configuration errors.

### Negative
- **Learning Curve**: Developers need to learn `copier` commands.
- **Merge Conflicts**: Updating a heavily modified project might result in git merge conflicts that need manual resolution.

## Alternatives Considered

- **Cookiecutter**: Rejected because it lacks robust update/diff capabilities.
- **Yeoman**: Rejected because it is too complex and requires maintaining generators as NPM packages.
- **Manual Copying**: Rejected as it leads to immediate configuration drift.
