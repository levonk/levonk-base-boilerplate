# Agent Structure

When creating a new agent, use the standard agent frontmatter structure
defined in the agent template (see `references/agent-template.md.tmpl`).

## Required Frontmatter Fields

- `agent` — Agent identifier (name)
- `description` — One-sentence purpose of this agent
- `use` — When to use this agent; the trigger or scenario
- `personality`:
  - `name` — Name of the agent
  - `role` — Primary role (e.g., Critic, Requirements Analyst, Code
    Generator, Researcher, Designer, Architect, QA, Analyst, Data Scientist)
  - `color` — UI color hex code
  - `icon` — UI emoji/icon
  - `personality-archetype` — (wise-elder, curious-explorer, empathetic-guide,
    etc.)
  - `voice`:
    - `voice-id`
    - `voice-stability` — .28-.45 Dynamic Expressive, .45-.60 Calculated
      Precise, .60-.65 Controlled Consistent, .75-.85 Grounded Assured,
      .85-1.00 Unwavering Precise
    - `voice-similarity-boost` — high variability/consistent/adaptable/
      uniform/predictable/rigid/exacting/stable/reliable
    - `voice-rate-wpm` — 180-210 Calm/Deliberate, Thoughtful/Deliberate,
      Moderate, Sharp/Decisive, 240-280 Energetic/Rapid
- `aliases` — Alternative names for the agent
- `categories` — Categories this agent belongs to (e.g., business, code, docs,
  dev, ops)
- `capabilities` — What this agent can perform
- `model-level` — default | background | reasoning | long | websearch
- `model` — Specific model override (optional, e.g., gemini-2.5-flash,
  gemini-2.5-pro, opus, o1-preview)
- `tools` — Declared tools with contracts (name, description, inputs, outputs)
- `version` — Semantic version
- `owner` — Owner URL
- `agent-status` — draft | ready | deprecated
- `visibility` — public | internal
- `compliance` — Compliance frameworks (e.g., GDPR, HIPAA)
- `runtime`:
  - `duration`: min, max, avg
  - `terminate` — When to abort (condition or timeout)
- `tags` — Categorization tags

## Body Structure

The agent body follows the standard template:

1. **Goal** — The single most important outcome, with measurable success
   criteria
2. **Role** — Primary stance, responsibilities, and boundaries
3. **i/o** — Context, required/suggested context, inputs (with schema), and
   outputs/deliverables (with acceptance criteria)
4. **Primary Workflow** — Initialize, Plan, Act, Verify, Deliver
5. **Tools** — Tool manifest with constraints
6. **Instructions** — Non-negotiable execution rules
7. **Templates** — Input and output templates
8. **Guardrails** — Feature, process, and maintenance guardrails
9. **Design By Contract** — Preconditions, postconditions, invariants,
   assertions, and contracts
10. **Quality Evaluation** — Were objectives met?
11. **Handoffs** — Who receives outputs next
12. **References** — Supporting links

<!-- vim: set ft=markdown -->
