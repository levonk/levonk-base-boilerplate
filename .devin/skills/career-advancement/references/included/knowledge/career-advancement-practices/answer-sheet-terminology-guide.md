---
type: Practice
title: Answer Sheet and Terminology Guide
description: Why executive resumes with industry-specific language need a companion document that explains jargon, internal terms, and acronyms for reviewers. The answer sheet ensures any reviewer — human or AI — can understand context without misinterpretation. Living documentation that is updated whenever new terms are introduced.
tags: [resume-writing, terminology, jargon, answer-sheet, companion-document, reviewer-context]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"
sources:
  - id: levonk-answer-sheet
    resource: "internal observation"
    title: "Resume system — answer sheet companion document for terminology and context"
---

# Answer Sheet and Terminology Guide

## The Problem

An executive resume with 15+ years of experience in a specific industry will
contain terms, acronyms, and internal references that are meaningful to
insiders and opaque to outsiders. A non-technical recruiter screening the
resume may misread a term. An AI agent generating a variant may
misinterpret an acronym. A hiring manager from a different industry may
discount experience they don't understand.

The resume itself cannot explain every term — that would bloat it beyond
readability (see [Conciseness and Length](conciseness-and-length.md)). The
solution is a **companion document**: the answer sheet.

## What the Answer Sheet Is

The answer sheet is a **markdown document** that explains potentially
confusing lines, terms, and references in the resume. It ensures that any
reviewer — human or AI — can quickly understand context without
misinterpretation.

It is **not a resume artifact** — it is reference material for reviewers and
agents. It is not sent to recruiters or uploaded to ATS.

## What to Include

### Industry Jargon

Terms that may not be universally understood:

> **Spotify Model** — An engineering organization model popularized by
> Spotify, using squads (small cross-functional teams), tribes (collections of
> squads), chapters (functional specialists across squads), and guilds
> (communities of practice). Not an official Spotify framework, but a widely
> adopted approach to scaling agile engineering organizations.

### Company-Internal Terms

Terms specific to a former employer that an outsider won't know:

> **Cast Choice Award** — A cross-conglomerate Disney recognition award for
> innovative technology. The Marketing ROI project that received this award
> contributed to $1B in revenue.

> **PAR** — Program Authorization Request — Disney's internal process for
> requesting funding/approval for new technology initiatives.

### Acronyms on First Use

Acronyms that may not be universally recognized:

> **RMDS** = Research Methods and Data Science
> **CSPO** = Certified Scrum Product Owner

### Historical Context

Items that may seem anachronistic without explanation:

> **TWDC** — The Walt Disney Company. Used as an abbreviation in internal
> documents and some resume bullets to refer to the conglomerate broadly.

### Expired or Former Affiliations

Clearly noted as expired or former:

> **CSPO certified (expired)** — Certified Scrum Product Owner certification
> has lapsed. Listed to demonstrate past qualification, not current
> certification.

## Format

```markdown
# Answer Sheet — Resume Terminology & Context Guide

## Term: Spotify Model
**Appears in:** Working resume, Executive resume
**Explanation:** An engineering organization model popularized by Spotify...

## Term: PAR
**Appears in:** Working resume (Analytics Evangelism section)
**Explanation:** Program Authorization Request — Disney's internal process...

## Term: Cast Choice Award
**Appears in:** Working resume, Executive resume
**Explanation:** A cross-conglomerate Disney recognition award...
```

## Rules

- **Living documentation** — update whenever new terms are introduced
- **Concise explanations** — 2–4 sentences per term
- **No age-signaling context** — do not include "this was done in 2012
  when..." (see [Age Bias Coded Language](age-bias-coded-language.md))
- **No legacy technology explanations** in modern document answer sheets
  (legacy tech belongs only in the archive — see [Resume Architecture and
  Lineage](resume-architecture-and-lineage.md))
- **Not a resume artifact** — it is reference material, not distributed to
  recruiters or ATS

## Who Uses It

| User | How they use it |
|------|----------------|
| **Non-technical recruiter** | Looks up terms they don't recognize during the S3 scan (see [Application Funnel Stages](application-funnel-stages.md)) |
| **Hiring manager from another industry** | Understands industry-specific context during the S4 read |
| **AI agent generating a variant** | Interprets terms correctly when tailoring or compressing |
| **The candidate** | Reference during interviews — ensures consistent explanations |
| **Referral / warm intro contact** | Context for someone advocating for you internally |

## Relationship to Other Concepts

- **[Resume Architecture and Lineage](resume-architecture-and-lineage.md)** —
  The answer sheet is a companion to the resume system, not a tier in the
  lineage.
- **[Award and Recognition Framing](award-and-recognition-framing.md)** —
  Internal awards need both on-resume framing AND answer sheet detail.
- **[Age Bias Coded Language](age-bias-coded-language.md)** — The answer sheet
  must not introduce age signals that the resume carefully excluded.
- **[Application Funnel Stages](application-funnel-stages.md)** — The answer
  sheet helps reviewers at S3 (recruiter scan) and S4 (hiring manager read).
- **[Content Exclusion and Disclosure Prevention](content-exclusion-and-
  disclosure-prevention.md)** — The answer sheet must not reveal protected-
  class information or personal details.
