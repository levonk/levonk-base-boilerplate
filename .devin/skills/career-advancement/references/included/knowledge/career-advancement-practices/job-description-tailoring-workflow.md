---
type: Practice
title: Job Description Tailoring Workflow
description: The 5-step process for tailoring a resume to a specific job description — ingest JD, gap analysis, mutate resume, verify ATS compatibility, and output the application package. Distinct from application strategy (which is about which jobs to target).
tags: [resume-writing, tailoring, job-description, ats, keyword-matching, workflow]
date:
  created: "2026-08-02"
  knowledge-basis: "2026-08-02"
  last-used: "2026-08-02"
sources:
  - id: levonk-tailoring-workflow
    resource: "internal observation"
    title: "Resume tailoring workflow — 5-step JD-to-application process"
---

# Job Description Tailoring Workflow

## When to Use This

This workflow is for **tailoring a resume to a specific job description**. It
is distinct from [Application Strategy](application-strategy.md), which is
about *which* jobs to target. This is about *how* to adapt your resume once
you've chosen a target.

A single "best resume" does not exist. Different contexts require different
optimizations (see [Application Funnel Stages](application-funnel-stages.md)):

| Context | Primary Optimization |
|---------|---------------------|
| ATS-first application | Maximum keyword coverage; standard headers; zero parse risk |
| Recruiter-driven search | Scan-friendly headline; recognizable brands; metric bullets |
| Warm introduction / referral | Narrative depth; problem-solution-impact stories |
| Executive search (retained) | Transformation thesis; board/advisor cred; exclusivity signals |
| LinkedIn / public profile | SEO-optimized headline; keyword-dense summary |

**Always ask which context a resume is being prepared for before generating.**

## The 5-Step Workflow

### Step 1: Ingest the Job Description

Extract the structured requirements from the JD:

- **Required skills** — technologies, methodologies, domain expertise
- **Years of experience** — and the implied seniority level
- **Education and certifications** — degrees, specific certs
- **Preferred/nice-to-have qualifications** — differentiate from required
- **Company stage and culture signals** — startup vs enterprise, tech stack,
  growth phase

### Step 2: Gap Analysis

Compare the JD requirements against your working resume (see [Resume
Architecture and Lineage](resume-architecture-and-lineage.md)):

- **Missing keywords** — Terms in the JD that don't appear in your resume
- **Unquantified achievements** — Bullets that lack metrics (see [Metrics and
  Quantification](metrics-and-quantification.md))
- **Weak recency alignment** — Your most recent roles don't match the JD's
  implied scope
- **Score each requirement category** — Current match percentage per category

### Step 3: Mutate the Resume

Adapt the working resume into a tailored variant:

1. **Rewrite the summary** to mirror the JD's first 3–5 requirements
2. **Reorder bullets** to prioritize JD-aligned achievements
3. **Inject missing keywords** into the Skills section AND Experience bullets
   (see [Keyword Engineering](keyword-engineering.md))
4. **Adjust metrics** to match the JD's implied scale (e.g., "led teams" →
   "led 35-person engineering org")
5. **Apply [Strategic Abstraction](strategic-abstraction.md)** — match bullet
   altitude to the seniority of the target role
6. **Apply [Technology-Outcome Framing](technology-outcome-framing.md)** —
   frame technologies named in the JD as solutions to business problems

### Step 4: Verify ATS Compatibility

Confirm no parse traps were introduced (see [ATS Reality vs
Myths](ats-reality-vs-myths.md)):

- **Standard section headers** maintained (Summary, Experience, Education,
  Skills) — no creative headers like "My Journey"
- **No text in headers, footers, text boxes, tables, or columns** — these are
  invisible to parsers
- **No images, icons, QR codes, or charts**
- **Single-column layout** throughout
- **Keyword density natural** — 1–2% per section, not stuffed
- **Both acronyms and full terms** on first use: `Amazon Web Services (AWS)`
- **Dates in Month YYYY – Month YYYY format** consistently
- **No unexplained employment gaps** — use `Independent Consulting` or
  `Strategic Sabbatical` if needed

### Step 5: Output the Application Package

Produce the deliverables:

1. **Tailored .docx** (primary submission) — highest ATS parser compatibility
2. **Tailored clean PDF** (backup / human share) — generated from the .docx,
   not scanned
3. **Cover letter** aligned to the same keywords (see [Application
   Strategy](application-strategy.md) — The Cover Letter Question)

**Forbidden for ATS submission**: `.pages`, image PDFs, `.txt`, `.html`,
cloud links, styled/designer PDFs with background images or color blocks.

## The Single-Use Rule

A tailored variant created by this workflow is a **single-use resume**. Per
the lineage rule (see [Resume Architecture and Lineage](resume-architecture-
and-lineage.md)), single-use changes do NOT propagate back to the archive
unless they introduce a reusable fact. If the tailoring is purely reordering
and emphasis for one job, it stays in the single-use copy only.

## Anti-Patterns That Kill Funnel Progression

| Anti-Pattern | Stage Killed | Why |
|--------------|-------------|-----|
| PDF with background images/color blocks | ATS parse | Parser extracts gibberish |
| Creative section headers ("My Journey") | ATS parse | Parser misses the section entirely |
| Tables for skills/experience layout | ATS parse | Content read out of order or dropped |
| Contact info in header/footer only | ATS parse | Parser may not extract it |
| Missing dates or "Present" instead of month | ATS scoring | ATS flags as incomplete |
| Generic summary ("Results-driven leader...") | Recruiter scan | Cannot differentiate in 6 seconds |
| Passive language ("Responsible for...") | Hiring manager read | No ownership perceived (see [Ownership Verbs](ownership-verbs.md)) |
| Jargon without context ("Led OKRs") | Hiring manager read | No scale or impact understood |

## Relationship to Other Concepts

- **[Resume Architecture and Lineage](resume-architecture-and-lineage.md)** —
  The system this workflow operates within. Tailored variants are derived from
  the working resume.
- **[Application Strategy](application-strategy.md)** — The upstream decision:
  which jobs to target. This workflow executes the tailoring once a target is
  chosen.
- **[Keyword Engineering](keyword-engineering.md)** — Step 3 depends on
  keyword matching principles.
- **[ATS Reality vs Myths](ats-reality-vs-myths.md)** — Step 4 verification
  rules.
- **[Application Funnel Stages](application-funnel-stages.md)** — The stages
  this workflow optimizes for.
- **[Strategic Abstraction](strategic-abstraction.md)** — Match bullet
  altitude to the target role's seniority during mutation.
