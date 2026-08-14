# Troubleshooting

Detailed guidance for subagents dispatched by the execute-upsert controller.
The SKILL.md covers the high-level expectations; this directory expands them
into a concrete playbook the subagent can follow when it hits an obstacle.

## Index

| Doc | When to read |
|-----|--------------|
| [principle.md](principle.md) | Always — the persist-before-reporting discipline that governs every troubleshooting step |
| [tool-substitution.md](tool-substitution.md) | Before reaching for any tool — the canonical table of disallowed tools and their sanctioned alternatives |
| [diagnosing-tool-not-found.md](diagnosing-tool-not-found.md) | When a tool is reported as "not found" — the 5-step diagnosis ladder before reporting a tool as genuinely missing |
| [report-templates.md](report-templates.md) | When reporting back to the orchestrator — block report (task could not complete) and workaround report (task succeeded after working around an obstacle) |
| [capturing-learnings.md](capturing-learnings.md) | When the orchestrator decides to persist a workaround to project memory — the memory-capture subagent's contract |
| [worked-examples.md](worked-examples.md) | When learning the pattern — four worked examples covering missing tools, disallowed tools, environment failures, and successful workarounds with memory capture |

## How to Use This Directory

1. **Start with `principle.md`** — it sets the discipline. Every other doc
   assumes the subagent has internalized it.
2. **Consult `tool-substitution.md` proactively** — don't wait for a tool to
   fail; use the sanctioned form from the start.
3. **When something fails**, walk `diagnosing-tool-not-found.md` before
   reporting the tool as missing.
4. **When reporting back**, use the template from `report-templates.md`
   that matches the outcome (block or workaround).
5. **The orchestrator** consults `capturing-learnings.md` when deciding
   whether to persist a workaround to project memory.
6. **`worked-examples.md`** is for learning the pattern; experienced
   subagents can skip it.

## Adding New Issues

When a new gotcha is discovered and captured to project memory (per
`capturing-learnings.md`), it is added to the **target project's** developer
docs (e.g., `.agents/knowledge/developer.md` under "Known Gotchas"), NOT to
this directory. This directory is the skill's canonical playbook; project
memory lives in the project being executed.
