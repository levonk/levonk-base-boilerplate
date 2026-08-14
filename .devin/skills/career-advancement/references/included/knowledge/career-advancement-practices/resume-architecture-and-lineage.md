---
type: Practice
title: Resume Architecture and Lineage
description: Why professionals with long careers need a multi-tier resume system — a full archive as the root source of truth, a working resume derived from it, and tailored variants for specific roles. The lineage rule (edit root first, propagate downstream) and the single-use exception.
tags: [resume-writing, architecture, lineage, source-of-truth, multi-variant, system-design]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"
sources:
  - id: levonk-resume-system
    resource: "internal observation"
    title: "Resume system architecture — multi-tier archive/derived/tailored model with root-first lineage rule"
---

# Resume Architecture and Lineage

## The Problem

A professional with 15+ years of experience faces a structural problem: the
resume that contains every role, technology, and achievement is too long, too
detailed, and too old for modern roles. But the resume that is trimmed for a
specific target has lost the detail needed to generate the next variant. If
you edit the trimmed version, the source of truth drifts. If you edit the full
version, the trimmed versions go stale.

The solution is a **multi-tier resume system** with a lineage rule.

## The Three Tiers

| Tier | Purpose | Length | Distributed? |
|------|---------|--------|--------------|
| **Archive (root)** | Complete career record — every role, every technology, full detail | Unlimited | No — internal database |
| **Working resume** | Derived from the archive; modern-relevant content only; used to generate all downstream variants | 3–4 pages | No — internal working document |
| **Tailored variants** | Derived from the working resume; compressed and optimized for a specific role or audience | 1–3 pages | Yes — sent to recruiters/ATS |

Each tier is derived from the one above it, with increasing compression,
modernization, and role-specific optimization.

### The Archive (Root)

The archive is the **complete record of your career**. It is the source of
truth for all future documents.

- Includes every role from the start of your career onward
- Full detail, no filtering
- Contains legacy technologies, early-career work, and historical context
- Not recruiter-ready, not length-constrained
- Used only as a **database** for downstream generation

Treat the archive as immutable historical data. When facts change (a new
metric is confirmed, a role is clarified), update the archive first.

### The Working Resume

The working resume is the **internal working document** derived from the
archive. It is not distributed externally — only its derived variants are
shared.

- Full detail for recent roles (last 10–15 years)
- Older roles condensed into a short credibility section (see [Credibility
  Section for Senior Careers](credibility-section-for-senior-careers.md))
- No legacy technologies, no age signals, no early-career implementation detail
- Structured for AI extraction and rendering
- The primary input for generating all downstream variants

### Tailored Variants

Tailored variants are the **distributed documents** — what actually gets sent
to recruiters, uploaded to ATS, or shared on LinkedIn.

- Compressed from the working resume to fit the target (2–3 pages for
  executive roles, 1 page for sales/one-pagers)
- Optimized for a specific role, company, or audience (see [Job Description
  Tailoring Workflow](job-description-tailoring-workflow.md))
- May reorder, emphasize, or de-emphasize content — but never invent content
  that doesn't exist in the working resume

## The Lineage Rule (Root-First Editing)

**All content changes must start at the root (archive) and propagate
downstream.** No agent or person may edit a derived document without first
updating its source.

```
Archive (root)
  └→ Working resume (derived, not distributed)
       ├→ Executive resume (derived, distributed)
       ├→ One-pager / sales asset (derived, distributed)
       └→ LinkedIn profile (derived, distributed)
```

### Why Root-First

If you edit a derived document directly, the source of truth drifts. The next
time you generate a variant from the working resume, the change is lost. Over
time, the documents diverge and you can no longer trust any of them.

### The Single-Use Exception

A **single-use resume** — a one-off resume tailored for a specific job
application (not tracked as a canonical document) — may be edited directly
without propagating back to the root. **The archive must NOT be updated** for
single-use changes unless the change introduces a **reusable fact** (a new
metric, role, or skill that applies beyond the one application).

If the change is purely tailoring for one job (reordering bullets, emphasizing
certain themes, mirroring JD keywords), it stays in the single-use copy only.

### How to Propagate

1. **Edit the archive first.** Add or modify the content, tag it with the
   appropriate extraction marker if your system uses them.
2. **Update the working resume.** Extract the modern-relevant subset of the
   archive change.
3. **Flag downstream documents.** Determine which tailored variants need the
   change and update them.
4. **Regenerate outputs.** Re-render PDFs, update LinkedIn, etc.

## Extraction Markers

A sophisticated archive uses inline markers to indicate which content
propagates to the working resume and how:

| Marker | Meaning |
|--------|---------|
| `EXTRACT` | Extract to working resume (full detail) |
| `EXTRACT:CREDIBILITY` | Extract as a condensed credibility bullet only |
| `EXTRACT:MODERN-SKILLS` | Extract only the modern subset of a skills list |
| `ARCHIVE-ONLY` | Legacy/historical; do not appear in any modern document |
| `ARCHIVE-ONLY:AGE-SIGNAL` | Age-signaling content; excluded from modern docs |
| `ARCHIVE-ONLY:LEGACY-TECH` | Legacy technology; excluded from modern docs |

Markers make extraction unambiguous — an agent or person generating a variant
knows exactly what to include and what to leave behind.

## Format Choices

### YAML-Primary Model

For resumes rendered by a tool like RenderCV, the working resume and tailored
variants should be **YAML-only** (canonical, render-ready). The archive is the
narrative/human-readable source (Markdown). There is no Markdown↔YAML sync
step — editing a resume means editing its YAML directly.

### Markdown for Profiles

LinkedIn profiles and other non-CV documents stay Markdown — they are profile
specs, not rendered by a CV tool.

## Why This Matters

Without a lineage system, a long-career professional faces one of two failures:

1. **Stale variants** — The tailored resumes drift from the source of truth
   because changes were made directly to them. The next regeneration loses
   those changes.
2. **Lost detail** — The archive is neglected because the working resume is
   edited directly. Over time, the archive becomes incomplete and can no
   longer serve as the database for new variants.

The lineage rule prevents both: the archive stays complete, the working resume
stays current, and the variants stay derivable.

## Relationship to Other Concepts

- **[Credibility Section for Senior Careers](credibility-section-for-senior-
  careers.md)** — How the working resume condenses older roles from the
  archive without losing credibility.
- **[Job Description Tailoring Workflow](job-description-tailoring-
  workflow.md)** — How to generate a tailored variant from the working resume
  for a specific job application.
- **[Application Funnel Stages](application-funnel-stages.md)** — Different
  variants are optimized for different funnel stages.
- **[Age Bias Coded Language](age-bias-coded-language.md)** — The archive
  preserves age-signaling content; the working resume and variants exclude it.
- **[Chronological Accuracy and Name Changes](chronological-accuracy-and-name-
  changes.md)** — The archive uses time-appropriate names; modern documents
  use current names.
