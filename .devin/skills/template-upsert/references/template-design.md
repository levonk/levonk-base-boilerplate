# Template Design Focus

## Core Principles

- Create templates that structure content for specific purposes.
- Optimize for lowest reasonable reading/experience level.
- Define variables and rendering rules clearly.
- Capture **reusable structures** (not one-off prompts) as templates under
  `config/ai/templates/`.
- Use `config/ai/templates/meta/template-template.md` as the contract for new
  or significantly revised templates.

## Variable Design

- **Name variables clearly**: Use descriptive names (`document_title` not `t`).
- **Type appropriately**: Use `string`, `array`, `object`, `boolean`, `number`.
- **Default sensibly**: Provide defaults for optional variables; leave required
  variables without defaults.
- **Document each variable**: Every schema entry needs a `description` that
  explains what the variable controls and example values.

## Section Structure

- **Frontmatter**: Metadata, variable schema, rendering rules.
- **Body**: The template content with variable placeholders.
- **Partials/Includes**: Document any partials used and where they live.

## Rendering Rules

- Document the rendering engine (`go-template`, `markdown-only`, etc.).
- Specify conflict strategies (overwrite, skip, merge, backup-then-overwrite).
- Specify backup policies if the template overwrites existing files.
- Document any validation rules applied before rendering.

## Composability

- Keep templates focused and composable; use partials/includes when patterns
  overlap.
- Prefer evolving a small, powerful set of templates over creating many
  slightly different ones.
- When in doubt, document decisions in a nearby README rather than overloading
  template frontmatter.

## Audience Optimization

- Templates should be usable by both AI agents and human readers.
- Optimize for the lowest reasonable reading/experience level.
- Include usage examples in the template body or a companion README when the
  rendering rules are non-obvious.
