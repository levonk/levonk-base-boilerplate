# AXI Principles for CLI Scripts and Tools

The [Agent eXperience Interface (AXI)](https://github.com/kunchenguid/axi)
defines ergonomic standards for CLI tools that autonomous agents interact with
through shell execution. This reference lists each principle with its tier
applicability: **Embedded** (single-file scripts bundled in skills/projects)
and **Full** (standalone CLI tools scaffolded from boilerplate).

## Table of Contents

1. [Output Discipline](#1-output-discipline)
2. [Structured Errors](#2-structured-errors)
3. [Definitive Empty States](#3-definitive-empty-states)
4. [No Interactive Prompts](#4-no-interactive-prompts)
5. [Idempotent Mutations](#5-idempotent-mutations)
6. [Exit Codes](#6-exit-codes)
7. [Content Truncation](#7-content-truncation)
8. [Pre-computed Aggregates](#8-pre-computed-aggregates)
9. [Minimal Default Schemas](#9-minimal-default-schemas)
10. [Content-First No-Args](#10-content-first-no-args)
11. [Contextual Disclosure](#11-contextual-disclosure)
12. [Fail Loud on Unrecognized Input](#12-fail-loud-on-unrecognized-input)
13. [TOON Output Format](#13-toon-output-format)
14. [Session Hook Infrastructure](#14-session-hook-infrastructure)
15. [Fields Flag](#15-fields-flag)

## Tier Applicability Summary

| Principle | Embedded | Full |
|-----------|----------|------|
| Output discipline | Yes | Yes |
| Structured errors | Yes | Yes |
| Definitive empty states | Yes | Yes |
| No interactive prompts | Yes | Yes |
| Idempotent mutations | Yes | Yes |
| Exit codes (0/1/2) | Yes | Yes |
| Content truncation | If large output | Yes |
| Pre-computed aggregates | If list output | Yes |
| Minimal default schemas | If list output | Yes |
| TOON output format | If data-heavy | Yes |
| `--fields` flag | If list output | Yes |
| Content-first no-args | If has live state | Yes |
| Contextual disclosure (help[]) | Optional | Yes |
| Fail loud on unrecognized input | Yes | Yes |
| Session hook infrastructure | If standalone¹ | Yes |
| Shell completion | No | Yes |

¹ Skill-bundled scripts typically skip session hooks — the skill is the
discovery mechanism. Standalone embedded scripts (installed once, used
repeatedly) should support them.

## 1. Output Discipline

**Tier: Both**

- **stdout**: all structured output the agent consumes — data, errors, suggestions
- **stderr**: debug logging, progress indicators, diagnostics (agents don't read this)
- Never mix progress messages into stdout. An agent that reads "Fetching data..."
  will try to interpret it as data.

## 2. Structured Errors

**Tier: Both**

Errors go to **stdout** in a parseable format with an actionable suggestion.
Never let raw dependency output (API errors, stack traces) leak through.

```
error: --title is required
help: Run with --title "..." to specify the title
```

- Validate required flags before calling any dependency
- Translate errors — extract actionable meaning, discard noise
- Never leak dependency names — suggestions reference your CLI's commands

## 3. Definitive Empty States

**Tier: Both**

When the answer is "nothing", say so explicitly. Ambiguous empty output causes
agents to re-run with different flags to verify.

```
$ items list --status closed
items: 0 closed items found
```

State the zero with context. Make it clear the command succeeded — the absence
of results is the answer. Exit code 0.

## 4. No Interactive Prompts

**Tier: Both**

Every operation must be completable with flags alone. If a required value is
missing, fail immediately with a clear error — don't prompt for it. Suppress
prompts from wrapped tools.

```
# Bad — agent hangs waiting for input
$ tool delete 42
Are you sure? (y/n):

# Good — agent gets an error and can retry with --force
$ tool delete 42
error: deletion requires --force
help: Run with --force to skip confirmation
```

## 5. Idempotent Mutations

**Tier: Both**

Don't error when the desired state already exists. If the agent closes
something already closed, acknowledge and move on with exit code 0.

```
$ tool close 42
item: #42 already closed (no-op)    # exit 0
```

Reserve non-zero exit codes for situations where the agent's intent genuinely
cannot be satisfied.

## 6. Exit Codes

**Tier: Both**

| Code | Meaning |
|------|---------|
| 0 | Success (including no-ops) |
| 1 | Generic error |
| 2 | Usage error (missing/invalid args) |
| 130 | SIGINT |

## 7. Content Truncation

**Tier: Embedded (if large output) / Full (always)**

Detail views often contain large text fields. Omitting them forces agents to
hunt; including them wastes tokens. Truncate by default and tell the agent how
to get the full version.

```
item:
  id: 42
  title: Fix auth bug
  body: First 500 chars of the body...
    ... (truncated, 8432 chars total)
help[1]: Run `tool view 42 --full` to see complete body
```

- Never omit large fields entirely — include a truncated preview
- Show the total size so the agent knows how much it's missing
- Suggest the escape hatch (`--full`) only when content is actually truncated
- Choose a truncation limit that covers most use cases (500-1500 chars)

## 8. Pre-computed Aggregates

**Tier: Embedded (if list output) / Full (always)**

The most expensive token cost is often a follow-up call. If your backend has
data that agents commonly need as a next step, compute it and include it.

**Aggregate counts**: include the total count in list output, not just the
page size.

```
count: 30 of 847 total
items[30]{id,title,status}:
  1,Fix auth bug,open
  ...
```

**Derived status fields**: when the next step almost always involves checking
related state, include a lightweight summary inline.

```
item:
  id: 42
  title: Deploy pipeline fix
  status: open
  checks: 3/3 passed
  comments: 7
```

Only include derived fields your backend can provide cheaply — a summary
("3/3 passed"), not the full data.

## 9. Minimal Default Schemas

**Tier: Embedded (if list output) / Full (always)**

Every field in stdout costs tokens — multiplied by row count in collections.
Default to the smallest schema that lets the agent decide what to do next:
typically an identifier, a title, and a status.

- Default list schemas: 3-4 fields, not 10
- Default limits: high enough to cover common cases in one call
- Long-form content (bodies, descriptions) belongs in detail views, not lists
- Offer a `--fields` flag (Full tier) to let agents request additional fields

## 10. Content-First No-Args

**Tier: Embedded (if has live state) / Full (always)**

Running a CLI with no arguments should show the most relevant live content, not
a usage manual. When an agent sees actual state, it can act immediately. When
it sees help text, it has to make a second call.

```
$ tool
items[3]{id,title,status}:
  1,Fix bug,open
  2,Add feature,open
  3,Update docs,closed
help[2]:
  Run `tool view <id>` for details
  Run `tool create --title "..."` to add a task
```

If there is no live state to show (e.g., a utility script with no persistent
data), showing help is acceptable.

## 11. Contextual Disclosure

**Tier: Embedded (optional) / Full (always)**

Include a few next steps that follow logically from the current output. The
agent discovers CLI surface area organically by using it.

- **Relevant**: after open item → suggest closing; after empty list → suggest
  creating; after list → suggest viewing
- **Actionable**: every suggestion is a complete command carrying forward
  disambiguating flags
- **Concise**: 2-4 suggestions maximum, ranked by relevance
- **Structured**: use `help[]` array in output for machine parsing

```
help[2]:
  Run `tool view 42` for details
  Run `tool close 42` to close this item
```

## 12. Fail Loud on Unrecognized Input

**Tier: Both**

Reject unknown flags and arguments — never silently ignore them. A dropped
flag is worse than an error: the agent gets plausible-looking output it
believes is scoped or filtered, then proceeds confidently on wrong data.

```
$ tool list --stat closed
error: unknown flag --stat for `list`
help: valid flags for `list`: --state, --assignee, --limit (--help always allowed)
```

- Validate before any dependency call, with exit code 2
- `--help` always passes — it's the one universal flag
- Renamed or removed flags get a targeted hint (`--status was renamed; use
  --state instead`)
- Make the error self-correcting in one turn — list valid flags inline

## 13. TOON Output Format

**Tier: Embedded (if data-heavy) / Full (always)**

Use [TOON (Token-Oriented Object Notation)](https://toonformat.dev/) as the
output format on stdout in agent mode. TOON provides ~40% token savings over
equivalent JSON while remaining readable by agents. Convert to TOON at the
output boundary — keep internal logic in JSON.

```
items[2]{id,title,status,assignee}:
  "1",Fix auth bug,open,alice
  "2",Add pagination,closed,bob
```

**When embedded scripts need TOON**: any embedded script that returns
substantial data — list outputs, API responses, transcripts, search results.
A YouTube transcript fetcher returning thousands of tokens benefits from
TOON's ~40% savings just as much as a full tool. The threshold is data
volume, not file count. If the script returns >500 tokens of structured
data, offer TOON.

**When embedded scripts can skip TOON**: scripts that return a single status
line, a boolean, or a small fixed-size result (e.g., "ok", "0 items found",
a single file path). Plain text or minimal JSON is sufficient.

## 14. Session Hook Infrastructure

**Tier: Embedded (if standalone) / Full (always)**

Register the tool into the agent's session lifecycle so every conversation
starts with relevant state already visible.

- Provide an explicit setup command (`--install-agent-hooks`) that installs
  session hooks after user intent is clear
- At session start, the integration runs the tool and provides a compact
  dashboard as context
- Support Claude Code (`~/.claude/settings.json`), Codex (`~/.codex/hooks.json`),
  and OpenCode (`~/.config/opencode/plugins/`)
- Token-budget-aware: ruthlessly minimize session-start context
- Directory-scoped: show only state relevant to the current working directory
- Idempotent: repeated installs with the same path are silent no-ops

**Skill-bundled scripts typically skip session hooks**: the skill itself is
the discovery mechanism (triggers on description match), so a session hook
would add per-session token cost for context the agent may not need that
session. The skill calls the script on demand; that's the right time for
the script to run.

**Standalone embedded scripts should support session hooks**: if the script
is installed once and used repeatedly (not bundled in a skill), session hooks
are how the agent discovers it. Without a hook, the agent doesn't know the
script exists until the user mentions it. A standalone transcript fetcher
that runs at session start to show "3 new transcripts since last session" is
exactly the AXI ambient context pattern.

## 15. Fields Flag

**Tier: Embedded (if list output) / Full (always)**

Offer a `--fields` flag to let agents request additional fields explicitly.

```
$ tool list --fields id,title,status,assignee,priority
```

- Validate field names against available fields
- Apply to both TOON and JSON output formats
- Default schema is 3-4 fields; `--fields` expands it

**When embedded scripts need `--fields`**: any embedded script that returns
list output with selectable fields. A transcript fetcher returning
`{id,title,duration,segments,tags,description}` should default to
`{id,title,duration}` and let the agent request more with
`--fields id,title,duration,segments`. The threshold is whether the output
has more fields than the agent typically needs in one call.
