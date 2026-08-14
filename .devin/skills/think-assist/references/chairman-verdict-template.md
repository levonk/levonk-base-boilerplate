# Chairman Verdict Template

The fixed 5-part output structure the chairman produces after the blind
peer-review round. The structure is deliberately rigid — it forces the
synthesis to surface agreement, clash, and blind spots before reaching a
recommendation, rather than jumping straight to a verdict.

## The Five Sections

### 1. Where the Council Agrees

Points that multiple advisors converged on independently. These are
high-confidence signals — when advisors with different thinking styles arrive
at the same conclusion from different angles, that convergence is the most
trustworthy signal in the whole process.

- List each point of agreement.
- Name which advisors agreed (now that you're de-anonymized, you can see who
  said what).
- State why the convergence is meaningful — not just "they agreed" but "the
  Contrarian and the Expansionist, who usually disagree, both flagged the
  pricing as wrong."

### 2. Where the Council Clashes

Genuine disagreements. Do not smooth these over. Present both sides and
explain why reasonable advisors disagree. The clash is often more informative
than the agreement — it tells the user where the decision is genuinely
uncertain and where they'll have to make a judgment call.

- For each clash, state the two (or more) positions.
- Name which advisor holds each position.
- Explain *why* they disagree — what different assumption or value leads them
  apart?
- Do not resolve it here. The resolution comes in the recommendation.

### 3. Blind Spots the Council Caught

Things that only emerged through the peer-review round. These are points that
individual advisors missed but other advisors flagged during blind review.
This section is the unique value of the peer-review round — without
anonymization, these points would have been deferred away.

- List each blind spot.
- Name which advisor's response had the blind spot.
- Name which reviewer flagged it.
- State why it matters.

### 4. The Recommendation

A clear, actionable recommendation. Not "it depends." Not "consider both
sides." A real answer. The chairman can disagree with the majority if the
reasoning supports it — the chairman's job is to make the call, not to
tabulate votes.

- State the recommendation directly.
- Give the reasoning — reference the agreement, clash, and blind-spot
  sections that led here.
- If the chairman disagrees with the majority, say so explicitly and explain
  why.
- Address the clashes from section 2 — which side did the chairman come down
  on, and why?

### 5. The One Thing to Do First

A single concrete next step. Not a list of 10 things. One thing. This is the
anti-pattern-corrective against the LLM habit of returning 10-item action
lists. The user can figure out steps 2-10 once they've done step 1.

- State one action.
- Make it concrete enough to do Monday morning (the Executor's discipline).
- If the recommendation is "don't do this," the one thing to do first is the
  first step of the alternative.

## Chairman Prompt Template

```
You are the Chairman of a council. Your job is to synthesize the work of N
advisors and their blind peer reviews into a final verdict.

The question brought to the council:
---
[framed question]
---

ADVISOR RESPONSES (de-anonymized):

**[Advisor Name]:**
[response]

[... for each advisor]

PEER REVIEWS:
[all N reviews, with the A-N mapping revealed]

Produce the council verdict using this exact structure:

## Where the Council Agrees
[Points multiple advisors converged on independently. Name who agreed and
why the convergence is meaningful.]

## Where the Council Clashes
[Genuine disagreements. Present both sides. Name who holds each position.
Explain why they disagree. Do not resolve here.]

## Blind Spots the Council Caught
[Things that only emerged through peer review. Name whose response had the
blind spot and which reviewer flagged it.]

## The Recommendation
[A clear, direct recommendation. Not "it depends." A real answer with
reasoning. If you disagree with the majority, say so and explain why.]

## The One Thing to Do First
[A single concrete next step. Not a list. One thing. Concrete enough to do
Monday morning.]

Be direct. Don't hedge. The whole point of the council is to give the user
clarity they couldn't get from a single perspective.
```

## Why "One Thing to Do First" Matters

LLMs default to producing lists. A 10-item action list feels comprehensive
but is actually useless — the user does item 1, gets distracted, and items
2-10 are forgotten. Forcing a single next step forces the chairman to
prioritize, which is the actual job. The user can ask for step 2 after
completing step 1.
