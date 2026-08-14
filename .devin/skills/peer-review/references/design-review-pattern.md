# Design Review Pattern — Blind Multi-Reviewer on Proposals

Apply the peer-review protocol to design proposals, architecture options, or
RFCs when you want multiple reviewers to evaluate competing approaches without
anchoring on author seniority or team affiliation.

## When to Use

- Comparing 2–5 architecture proposals for the same problem.
- Evaluating RFCs where the author's reputation might unduly influence
  reviewers (e.g., a principal engineer's proposal vs a junior's).
- Cross-team design reviews where each team tends to favor their own approach.

## Steps

1. **Collect proposals.** Each proposal must address the same problem
   statement and constraints. If proposals assume different constraints,
   normalize them first or note the divergence in the bundle.

2. **Anonymize.** Strip author names, team references, and any "as I proposed
   in last week's meeting..." phrasing. Run `scripts/anonymize.py` with each
   proposal as a separate response.

3. **Spawn N reviewers.** One per proposal (N proposals → N reviewers), or
   one per architectural concern (scalability, cost, operability, migration
   risk) if you want concern-focused rather than proposal-focused reviews.
   Each reviewer answers the three questions from `review-protocol.md`.

4. **De-anonymize for the synthesizer.** The synthesizer (architect, tech
   lead, or decision owner) gets the mapping and all reviews, then produces
   the design decision: which approach, with what modifications, and what the
   identified risks are.

## Reviewer Prompt Template (Design)

```
You are reviewing N design proposals blind. You do not know who authored
each.

The problem:
---
[problem statement + constraints]
---

**Proposal A:**
[proposal]

**Proposal B:**
[proposal]

[... through Proposal N]

Answer these three questions. Reference proposals by letter.

1. Which proposal is strongest? Why?
2. Which proposal has the biggest blind spot? What is it missing?
3. What did ALL proposals miss that should be considered before deciding?

Keep your review under 200 words. Be direct.
```

## Notes

- **Normalize constraints first.** If Proposal A assumes a $50k/mo budget and
  Proposal B assumes $5k/mo, the comparison is meaningless. Either reject
  out-of-scope proposals before anonymization, or annotate each with its
  assumed constraints so reviewers can factor that in.
- **One concern per reviewer vs one reviewer per proposal.** The
  proposal-per-reviewer pattern surfaces which proposal each reviewer would
  pick. The concern-per-reviewer pattern surfaces which proposal best handles
  each concern. Choose based on what you're trying to learn.
