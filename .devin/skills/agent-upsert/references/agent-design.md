# Agent Design Focus

## Core Design Questions

1. **What expertise does this agent embody?** Define the domain (tax strategy,
   software architecture, spiritual guidance, etc.) and the depth of
   expertise required.
2. **What is the agent's primary role?** (e.g., Critic, Requirements Analyst,
   Code Generator, Researcher, Designer, Architect, QA, Analyst, Data
   Scientist)
3. **What capabilities does the agent need?** List the specific actions the
   agent can perform.
4. **What tools does the agent require?** Declare each tool with its inputs,
   outputs, and constraints.
5. **What model level is appropriate?** (default, background, reasoning, long,
   websearch) — match the model to the complexity of the agent's tasks.
6. **What are the agent's boundaries?** What will the agent not do? What
   triggers termination?

## Personality Design

- **Name**: A memorable name that reflects the agent's role
- **Role**: The primary stance (Critic, Researcher, Architect, etc.)
- **Color**: A UI color hex code for visual identification
- **Icon**: An emoji or icon representing the agent
- **Personality archetype**: (wise-elder, curious-explorer, empathetic-guide,
  etc.)
- **Voice**: Configure voice stability, similarity boost, and rate (wpm) to
  match the agent's persona

## Capability Boundaries

Define clear boundaries to prevent scope creep:

- **In scope**: What the agent will do autonomously
- **Out of scope**: What the agent will flag for human review
- **Termination conditions**: When the agent should abort (timeout, ambiguity
  above threshold, missing inputs)

<!-- vim: set ft=markdown -->
