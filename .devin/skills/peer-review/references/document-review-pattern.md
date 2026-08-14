# Document Review Pattern — Blind Multi-Reviewer on Drafts

Apply the peer-review protocol to policy drafts, spec documents, legal text,
or any written artifact where multiple reviewers' judgment matters and author
identity would distort the evaluation.

## When to Use

- Policy documents where legal/compliance/eng reviewers each bring a
  different lens and might defer to the author's seniority.
- Spec documents where the author's reputation could anchor reviewers on
  "this must be right because X wrote it."
- Competitive drafts (two writers produced different versions of the same
  section) and you want to pick the stronger one on merit.

## Steps

1. **Collect drafts.** Each draft must address the same scope. If drafts
   cover different scopes, narrow them to the common scope before review, or
   note the scope divergence in the bundle.

2. **Anonymize.** Strip author names, voice fingerprints ("as I argued in
   my earlier memo..."), and any metadata that identifies the author. Run
   `scripts/anonymize.py` with each draft as a separate response.

3. **Spawn N reviewers.** One per draft (N drafts → N reviewers), or one per
   review lens (legal risk, clarity, completeness, alignment with stated
   goals). Each reviewer answers the three questions from `review-protocol.md`,
   adapted for documents:

   - Which draft is strongest, and why?
   - Which draft has the biggest blind spot — what's missing or wrong?
   - What did ALL drafts miss that should be in the final version?

4. **De-anonymize for the synthesizer.** The synthesizer (editor, policy
   owner, or final author) gets the mapping and all reviews, then produces
   the final document — which may be one of the drafts, a merge of several,
   or a new draft that addresses the collective blind spots.

## Reviewer Prompt Template (Document)

```
You are reviewing N document drafts blind. You do not know who authored
each.

The document's purpose:
---
[purpose + intended audience]
---

**Draft A:**
[draft]

**Draft B:**
[draft]

[... through Draft N]

Answer these three questions. Reference drafts by letter.

1. Which draft is strongest? Why?
2. Which draft has the biggest blind spot? What is it missing or getting wrong?
3. What did ALL drafts miss that should be in the final version?

Keep your review under 200 words. Be direct.
```

## Notes

- **Voice fingerprinting.** Even without names, an experienced reviewer may
  recognize an author's voice. If this is a real concern, lightly edit drafts
  to normalize voice before anonymization — but be careful not to change
  meaning.
- **One draft, N lenses** is often more useful than N drafts, N reviewers for
  policy work — you usually have one draft and want legal/comms/eng to each
  evaluate it from their angle. In that case, anonymization still helps
  (strips author authority) but the comparison is across lenses, not drafts.
