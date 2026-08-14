# Context Enrichment — Workspace Scan Pre-Step

The user's raw question is often just the tip of the iceberg. Their workspace
likely contains files that would dramatically improve the council's output.
Before framing the question, scan for and read relevant context files.

## What to Scan For

| File / directory | What it contains | Why it helps |
|---|---|---|
| `CLAUDE.md` / `claude.md` / `AGENTS.md` | Business context, preferences, constraints | Grounds advisors in the user's actual situation |
| `memory/` folder | Audience profiles, voice docs, business details, past decisions | Provides history and audience specificity |
| Files the user explicitly referenced | The actual artifact under consideration | The council needs to see the thing, not a description of it |
| Recent council transcripts in this folder | Past council verdicts on related questions | Avoids re-counciling the same ground; shows how thinking evolved |
| `README.md` | Project/product context | Grounds the Outsider advisor (and others) in what the project actually is |
| Any context files relevant to the specific question | e.g., revenue data for pricing questions, past launch results for go-to-market questions | Specific data beats generic advice |

## How to Scan

Use `Glob` and quick `Read` calls. Don't spend more than 30 seconds on this.
You're looking for the 2-3 files that would give advisors the context they
need to give specific, grounded advice instead of generic takes.

**Scan pattern:**

1. `Glob` for `CLAUDE.md`, `claude.md`, `AGENTS.md` in the project root and
   workspace.
2. `Glob` for `memory/**` if a memory folder exists.
3. `Glob` for any files the user explicitly referenced by name.
4. `Glob` for `council-transcript-*.md` in the current directory (recent
   council runs).
5. `Read` the 2-3 most relevant files found. Skip the rest.

## Framing the Question

Take the user's raw question AND the enriched context and reframe it as a
clear, neutral prompt that all advisors will receive. The framed question
should include:

1. **The core decision or question** — stated neutrally, not leading.
2. **Key context from the user's message** — what they said, distilled.
3. **Key context from workspace files** — business stage, audience,
   constraints, past results, relevant numbers. Only include what's relevant;
   don't dump the whole CLAUDE.md.
4. **What's at stake** — why this decision matters. The advisors think
   differently when the stakes are real and named.

## Framing Rules

- **Don't add your own opinion.** The frame is neutral; the advisors have
  opinions.
- **Don't steer.** "Should I do X?" should not become "Why X is the right
  choice" — that biases every advisor.
- **Do include enough context for grounded answers.** "Help me decide about
  pricing" with no context produces generic advice. "Help me decide whether
  to price at $97 vs $297 for an audience of 800 non-technical solopreneurs
  who've bought $47 products before but never $200+" produces specific advice.
- **If the question is too vague, ask one clarifying question.** Just one.
  Then proceed. Don't turn the framing into an interrogation.

## Save the Framed Question

Save the framed question for the transcript. The original raw question and
the framed question both go into `council-transcript-[timestamp].md` so the
user can see how their question was interpreted.
