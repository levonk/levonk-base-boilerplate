# Email Review Checklist

Use this checklist when reviewing or improving an existing email. Go through
each item, note issues, and propose fixes with before/after examples.

## Audit Checklist

### Subject Line

- [ ] Has a triage tag (Action / Decision / Update / Risk / Escalation /
  Confirmation / Refusal / Rejection / Resignation / Clarification) — or, for
  Cold Outreach, Introduction, and Networking, a descriptive subject that
  states what the email is about
- [ ] States the topic clearly
- [ ] Helps the reader prioritize without opening the email

**Anti-pattern:** Subject is "Quick question", "Following up", "Hi", or just
"Update" with no context.

### First Sentence

- [ ] States the ask, decision, risk, or update immediately
- [ ] No warm-up, no "I hope this finds you well", no story before the point
- [ ] Bad news is first if there is bad news

**Anti-pattern:** First paragraph is context, greeting, or background. The
actual ask is buried in paragraph three.

### Conciseness

- [ ] Every sentence earns its place
- [ ] No filler, repetition, or softening language
- [ ] Fits on one screen (if longer, punchline is first, then short sections)
- [ ] No generic AI-sounding phrases ("I wanted to reach out", "Please be
  informed", "Kindly", "Just circling back", "Let me know how I can help" as a
  default close)

**Anti-pattern:** Email is three paragraphs of context before a one-line ask.
Also: closing with "let me know how I can help" when you could have named the
next step — it offloads the work back to the reader.

### Specificity

- [ ] Uses names, numbers, dates, and facts
- [ ] No vague references ("some delays", "a few issues", "soon")
- [ ] Options or choices are concrete and comparable

**Anti-pattern:** "There were some delays" instead of "Vendor X missed the
March 12 deadline."

### Structure

- [ ] One email does one job (unrelated topics split into separate emails)
- [ ] Facts, judgment, and recommendation are separated
- [ ] Next step is obvious: who does what by when
- [ ] Next step targets what's actually indefinite (time, value, or scope —
  not a generic "let me know")
- [ ] For actions that need to happen, a go-forward plan is stated and the
  recipient is asked to object by a deadline, rather than asked for
  permission (reserve "may I?" for genuinely reversible or high-stakes
  decisions)
- [ ] Owner and deadline are stated

**Anti-pattern:** Email mixes three unrelated requests, no clear next step, no
deadline.

### Tone

- [ ] Direct but respectful
- [ ] No sarcasm, hints, or coded language
- [ ] Formality matches the audience (but never at the expense of clarity)
- [ ] Does not save face at the expense of truth

**Anti-pattern:** So polite and hedged that the actual ask is unclear.

### Forwarding

- [ ] Email makes sense if forwarded to someone with no context
- [ ] Names, dates, and decisions are all self-contained
- [ ] No references to "as we discussed" without stating what was discussed

**Anti-pattern:** "As we discussed, please proceed" — forwarded recipient has
no idea what was discussed or what to proceed with.

### Thread Hygiene

- [ ] Reply on same thread only if topic is the same
- [ ] New topic = new email with new subject line
- [ ] CC list is minimal (only people who need to act or know)

**Anti-pattern:** Reply-all on a 20-message thread to introduce an unrelated
topic.

## Prioritizing Issues

When proposing fixes, categorize by impact:

- **Critical** — missing subject tag, buried ask, no next step, no deadline
- **Important** — wordiness, lack of specificity, mixed topics, generic language
- **Nice to have** — tone adjustments, formatting, thread hygiene

Present the revised email with all critical and important fixes applied. Offer
nice-to-have changes as optional.

## Before/After Example

### Before (weak)

```
Subject: Quick question

Hi John, hope you are well. I wanted to reach out regarding the vendor
situation. As you know, we have been discussing timelines internally and
there have been a few complications on their side, so I thought I would
share some context before getting your thoughts. Please let me know what
you think.
```

Issues:
- **Critical**: No triage tag in subject, ask is buried (no clear request),
  no next step, no deadline
- **Important**: Generic language ("hope you are well", "wanted to reach out"),
  vague ("a few complications"), wordy

### After (good)

```
Subject: Decision needed: vendor delay on onboarding

Vendor X missed the March 12 deadline. If we keep the current scope,
onboarding moves to March 19.

My recommendation is to remove feature Y and keep the March 15 launch.

Please reply by 3 pm today so we can confirm with the client.
```

Changes:
- Subject: added triage tag + specific topic
- First sentence: states the problem with name, date, and impact
- Body: one line of context, one line of recommendation
- Close: specific action + deadline
- Removed: all filler, warm-up, and generic language
