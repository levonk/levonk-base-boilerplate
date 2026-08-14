# Agent-Specific Guidelines

This section provides agent-specific guidance that complements the universal
creation framework included via `base-ai-guidance`.

## Agent vs Skill vs Workflow

- **Agent**: Embodies specific expertise and a personality. Works
  autonomously after initial questioning. Orchestrates workflows, prompts,
  and templates. Has a `personality` block (name, role, color, icon, voice)
  and `capabilities` that define what it can do.
- **Skill**: A packaged set of instructions, scripts, references, and assets
  that performs a specific task. No personality. Loaded by the model when
  triggered. See `ai-upsert`.
- **Workflow**: A multi-step procedure with clear phases (Initialize, Plan,
  Apply, Verify, Deliver). No personality. See `ai-workflow-upsert`.

Use an **agent** when the task requires a persistent persona with specific
expertise that orchestrates other artifacts. Use a **skill** or **workflow**
when the task is a self-contained procedure that doesn't need a persona.

## Agent Design Principles

- Create agents that embody specific expertise (e.g., tax strategist,
  software architect, spiritual advisor)
- Agents should work autonomously after initial questioning using
  workflows/prompts/templates
- Define clear boundaries and capabilities — what the agent will and will not
  do
- Declare tools with explicit contracts (inputs, outputs, constraints)
- Specify a model level appropriate to the agent's tasks (default, advanced,
  experimental)

## Autonomous Operation

After initial questioning, the agent should be able to operate without
further user input by:

1. Using declared tools to gather context
2. Applying workflows to structure the work
3. Invoking prompts/templates for domain-specific output
4. Verifying outputs against acceptance criteria
5. Reporting results with a summary and next steps

<!-- vim: set ft=markdown -->
