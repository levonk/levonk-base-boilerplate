# Relationship to ai-prompt-create

## Division of Responsibility

- `template-upsert` focuses on **template contracts and scaffolds** — the
  reusable structures that define how content is generated.
- `ai-prompt-create` focuses on **prompt instances** — specific invocations
  that use templates to produce concrete output.

## Handoff Protocol

When `ai-prompt-create` discovers a reusable pattern that no existing template
captures:

1. `ai-prompt-create` identifies the pattern and documents it.
2. `ai-prompt-create` requests a new template via `template-upsert`.
3. `template-upsert` creates the template following the meta-template contract.
4. `ai-prompt-create` updates its references to use the new template.

## When to Use Each

- **Use `template-upsert`** when the user wants to create, update, or audit a
  reusable template structure.
- **Use `ai-prompt-create`** when the user wants to create a specific prompt
  instance that may use an existing template.

## Avoiding Duplication

- Prompts should prefer existing templates under `config/ai/templates/`.
- If a prompt encodes a reusable pattern, extract it into a template via
  `template-upsert` rather than duplicating the pattern across multiple prompts.
- Templates should be general enough to serve multiple prompt instances; if a
  template is only used by one prompt, consider whether it should be a template
  at all or just inline in the prompt.
