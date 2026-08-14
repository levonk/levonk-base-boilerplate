# Agent-Specific Search

When researching before creating or improving an agent:

1. **Local**: Scan `internal-docs/agents/` for existing agent files. Check
   frontmatter `agent`, `role`, and `capabilities` fields.
2. **skills.sh / GitHub**: Search for "agent" + expertise domain keywords.
   Agent patterns may be published as skills or prompts.
3. **Cross-check with prompts/templates**: An existing prompt or template may
   already encode the expertise the agent would provide. If so, consider
   wrapping the prompt/template in an agent rather than duplicating the
   expertise.

## Search Strategy

- **Keyword combinations**: Use the expertise domain plus "agent" (e.g.,
  "tax strategist agent", "software architect agent", "spiritual advisor
  agent").
- **Capability search**: Search for specific capabilities the agent should
  have (e.g., "code review agent", "requirements analysis agent").
- **Role search**: Search for the primary role (e.g., "critic agent",
  "researcher agent", "designer agent").

## Avoiding Duplication

Before creating a new agent, verify that:

- No existing agent in `internal-docs/agents/` already covers the same
  expertise domain and capabilities.
- No existing prompt or template already provides the expertise the agent
  would channel. If one exists, the agent can wrap and orchestrate it rather
  than redefining the expertise.
- No existing skill already performs the autonomous workflow the agent would
  execute. If one exists, the agent can invoke the skill rather than
  duplicating the workflow.

<!-- vim: set ft=markdown -->
