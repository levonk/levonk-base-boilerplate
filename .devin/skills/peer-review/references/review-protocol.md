# Peer-Review Protocol

The three-question framework, anonymization rules, reviewer prompt template,
and de-anonymization rules for the blind peer-review round.

## Table of Contents

1. [Anonymization Rules](#anonymization-rules)
2. [The Three Reviewer Questions](#the-three-reviewer-questions)
3. [Reviewer Prompt Template](#reviewer-prompt-template)
4. [De-Anonymization Rules](#de-anonymization-rules)
5. [Why Randomization Matters](#why-randomization-matters)

## Anonymization Rules

Before any reviewer sees a response, the following must hold:

1. **Strip author-identifying content.** If a response says "As the Contrarian,
   I think..." or otherwise names its own author, remove or rewrite that phrase
   before anonymization. Reviewers must not be able to infer the author from
   the text itself.
2. **Randomize the A–N mapping.** Run `scripts/anonymize.py` to assign each
   response a letter label (A, B, C, ...) in a shuffled order. The first
   response in the input array must not always become "Response A" — positional
   bias would creep back in.
3. **Keep the mapping secret from reviewers.** The mapping file
   (`peer-review-mapping-<timestamp>.json`) is for the synthesizer only.
   Reviewers see the anonymized bundle and nothing else.
4. **One bundle, all reviewers.** Every reviewer sees the same A–N bundle.
   Do not give different reviewers different subsets — the three questions
   require comparison across the full set.

## The Three Reviewer Questions

Each reviewer answers all three. The questions are fixed across reviewers so
the synthesizer can compare answers on the same axes.

1. **Which response is the strongest, and why?** Pick one. Reference it by
   letter (e.g., "Response C"). State the specific reason — not "it's
   well-argued" but "it correctly identifies the regulatory risk the others
   treat as secondary."

2. **Which response has the biggest blind spot, and what is it?** Pick one.
   Name the blind spot concretely. "Response B ignores the customer-support
   cost of the proposed pricing change" is useful. "Response B is incomplete"
   is not.

3. **What did ALL responses miss that the council should consider?** This is
   the most valuable question. It surfaces the collective blind spot — the
   thing no individual advisor caught on their own. If a reviewer can't find
   anything, they should say so explicitly rather than padding.

## Reviewer Prompt Template

```
You are reviewing the outputs of a peer-review round. N advisors
independently answered this question:

---
[question]
---

Here are their anonymized responses:

**Response A:**
[response]

**Response B:**
[response]

[... through Response N]

Answer these three questions. Be specific. Reference responses by letter.

1. Which response is the strongest? Why?
2. Which response has the biggest blind spot? What is it missing?
3. What did ALL responses miss that the council should consider?

Keep your review under 200 words. Be direct. No hedging.
```

## De-Anonymization Rules

After all reviews are collected:

1. **Reveal the mapping to the synthesizer only.** The chairman, facilitator,
   or whoever produces the final verdict gets `peer-review-mapping-<timestamp>.json`
   plus all reviews. They can now see which named author produced which lettered
   response.
2. **Do not retroactively edit reviews.** Reviews were written against the
   anonymized bundle. They reference "Response C", not "The Contrarian". Leave
   them as-is in the transcript; the synthesizer translates as needed.
3. **Save the full transcript.** The review transcript (question + anonymized
   bundle + all reviews + revealed mapping) is the provenance artifact. If the
   user re-runs the review later, the transcript shows how the thinking evolved.

## Why Randomization Matters

Three bias sources the shuffle eliminates:

- **Positional bias.** Reviewers unconsciously weight the first and last
  responses more heavily. If "Response A" is always the same advisor, that
  advisor gets the first-position boost on every review round.
- **Authority deference.** If reviewers know "Response C is the Senior
  Architect", they'll defer to C on technical points regardless of whether C's
  argument is actually stronger. Anonymization forces them to evaluate the
  argument.
- **Persona anchoring.** If reviewers know "Response A is the Contrarian",
  they'll interpret A's critique as "just the Contrarian doing their job" and
  discount it. Anonymization lets the critique stand on its own merits.

The seed parameter in `scripts/anonymize.py` makes the shuffle reproducible —
useful for re-running a review round with the same mapping while changing the
question or responses under review.
