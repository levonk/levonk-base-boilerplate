# Code Review Pattern — Blind Multi-Reviewer on a Diff

Apply the peer-review protocol to a code diff when you want multiple reviewers
to evaluate the same change without anchoring on each other's identities or
comments.

## When to Use

- High-stakes diffs (security, auth, payment, data migration) where a single
  reviewer's blind spot is expensive.
- Diffs authored by a senior contributor where junior reviewers might defer to
  authority instead of raising real concerns.
- Diffs touching multiple domains (e.g., a change spanning DB schema, API
  contract, and frontend) where you want domain-specific reviewers to evaluate
  the whole diff blind, then synthesize.

## Steps

1. **Prepare the diff bundle.** Produce a single artifact containing the diff,
   the relevant surrounding context (not just the changed lines), and the
   decision the diff is making (e.g., "switching from JWT to session cookies
   for auth"). This is the "question" the reviewers are evaluating.

2. **Anonymize.** If the diff or commit messages reveal the author, strip them.
   Run `scripts/anonymize.py` with the diff bundle as the single "response" —
   or, if you have multiple proposed approaches to the same problem, anonymize
   each approach as a separate response and let reviewers compare them blind.

3. **Spawn N reviewers.** One per domain or perspective you want covered
   (security, performance, maintainability, API design, etc.). Each reviewer
   sees the anonymized bundle and answers the three questions from
   `review-protocol.md`, adapted for code:

   - Which approach (or which aspect of the diff) is strongest, and why?
   - Which has the biggest blind spot — what's the failure mode?
   - What did ALL reviewers miss that should be considered before merge?

4. **De-anonymize for the synthesizer.** The synthesizer (tech lead, merge
   arbiter) gets the mapping and all reviews, then produces the merge decision:
   approve, request changes, or reject — with the specific concerns to address.

## Reviewer Prompt Template (Code)

```
You are reviewing a code change blind. You do not know who authored it.

The change:
---
[diff + context]
---

The decision this change is making:
[one-sentence summary, e.g., "Switching auth from JWT to session cookies"]

Answer these three questions. Reference specific lines or hunks.

1. Which aspect of this change is strongest? Why?
2. What is the biggest blind spot — the most likely failure mode?
3. What did you not see addressed that should be considered before merge?

Keep your review under 200 words. Be direct.
```

## Notes

- **One diff, N reviewers.** Unlike the council (N responses, N reviewers),
  code review is often one diff reviewed from N perspectives. The
  anonymization still helps — it strips author identity so reviewers focus on
  the code, not who wrote it.
- **If comparing multiple approaches**, anonymize each approach as a separate
  response and use the canonical council prompt from `review-protocol.md`.
- **Don't replace your normal CI/lint pipeline.** This is for judgment calls
  CI can't make — security tradeoffs, API design, architectural fit.
