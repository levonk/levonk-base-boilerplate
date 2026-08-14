---
description: Create a deep, professional research report with citations
use: When you need a detailed, reference-filled research document on a topic
inputs:
  - name: TOPIC
    description: The topic to research
    required: true
  - name: RESEARCH_QUESTION
    description: The specific question to answer (leave blank to have the system propose and confirm one)
    default: ""
  - name: AUDIENCE
    description: Who this report is for (drives tone, assumptions, and recommendations)
    default: "technical leadership"
  - name: SCOPE
    description: Optional scope boundaries (what to include/exclude)
    default: ""
  - name: TIMEFRAME
    description: Time coverage for sources (e.g., "2018-present", "last 24 months", "seminal works + last 5 years")
    default: "seminal works + last 5 years"
  - name: GEOGRAPHY
    description: Geography/jurisdiction focus if relevant (e.g., "US", "EU", "global")
    default: "global"
  - name: DEPTH
    description: How deep to go (brief|standard|deep)
    default: "deep"
  - name: MIN_SOURCES
    description: Minimum number of distinct sources to cite
    default: 15
  - name: MUST_INCLUDE
    description: Comma-separated list of required subtopics, frameworks, companies, standards, or case studies
    default: ""
  - name: MUST_EXCLUDE
    description: Comma-separated list of areas to explicitly exclude
    default: ""
  - name: OUTPUT_FORMAT
    description: Output format for the final report (markdown|doc-outline)
    default: "markdown"
  - name: CITATION_STYLE
    description: Citation style to use (markdown-footnotes|apa|chicago)
    default: "markdown-footnotes"
---

# Deep Research Workflow

## Role
Act as a **senior research analyst**.

Primary goal: produce a **high-signal, professional research document** on **[TOPIC]** that is:
- Thorough and decision-useful
- Explicit about scope and assumptions
- Dense with evidence
- Rigorously cited

## Hard rules (citation integrity)

- **Do not fabricate sources or citations.**
- **Do not cite anything you have not actually read.**
- Every non-trivial claim must have:
  - A citation, or
  - A clear label like "Unverified" / "No strong sources found".
- Prefer **primary** and **authoritative** sources:
  - Standards bodies (e.g., NIST, ISO, IETF)
  - Academic papers (peer-reviewed when possible)
  - Vendor primary documentation
  - Government and major institutional publications
  - Major industry benchmarks and datasets

## Phase 0: Scope confirmation

If `RESEARCH_QUESTION` is empty or ambiguous:
- Propose **3 candidate research questions**.
- Ask up to **5** clarifying questions focused on:
  - Intended decisions to support
  - Constraints and exclusions
  - Time sensitivity
  - Required depth and deliverable format
- Choose the best default if no further input is provided, and clearly state why.

Translate inputs into a single explicit scope statement:
- Topic:
  - [TOPIC]
- Research question:
  - [RESEARCH_QUESTION]
- Audience:
  - [AUDIENCE]
- Timeframe:
  - [TIMEFRAME]
- Geography:
  - [GEOGRAPHY]
- Scope boundaries:
  - Include: [SCOPE]
  - Must include: [MUST_INCLUDE]
  - Must exclude: [MUST_EXCLUDE]

## Phase 1: Research plan (show your approach)

Create a research plan containing:
- A structured outline (major headings and subheadings)
- A search-query matrix:
  - Queries per subtopic
  - Preferred source types per query (standards, academic, vendor, etc.)
- A "source strategy":
  - What counts as primary evidence
  - What is considered weak evidence (blogs, marketing pages, undated posts)
  - How you will handle paywalled sources

## Phase 2: Source collection and evidence extraction

Collect and read sources.

For each source, capture:
- Full citation metadata (author, title, publisher, date)
- URL
- Access date
- 3-7 bullet-point takeaways
- Any critical quotes, numbers, or definitions (with exact citation)

Also build an "Evidence Table" (Markdown table) with:
- Claim
- Supporting source(s)
- Evidence type (primary/secondary)
- Confidence (high/medium/low)

## Phase 3: Synthesis and analysis

Synthesize the evidence into a coherent report.

Required analytical elements:
- Clear definitions (avoid ambiguous terms)
- Competing viewpoints and trade-offs
- What is known vs. unknown
- Practical implications
- Risks and failure modes
- Security, privacy, and compliance considerations when relevant

## Output requirements

### Report structure (default)

Produce a single report with these sections:

- Title
- Executive Summary
- Scope and Research Question
- Methodology (how sources were found, how claims were evaluated)
- Key Findings (bulleted, each with citations)
- Background / Definitions
- Deep Dive (thematic sections)
- Comparative Analysis (options, approaches, vendors, architectures, etc.)
- Risks, Limitations, and Open Questions
- Recommendations and Next Steps
- Appendix
  - Evidence Table
  - Annotated Bibliography

### Citation format

Use [CITATION_STYLE].
If `markdown-footnotes`:
- Put citations in footnotes, and reference them inline like `[^src-01]`.
- Footnote text must include title, publisher, date (if available), and URL.
- Include access date for web sources.

### Minimum sourcing

- Cite at least [MIN_SOURCES] distinct sources.
- If this minimum cannot be met, explicitly say why and recommend what to do next.

## Final quality gates (must pass)

Before finalizing:
- Confirm every major claim has citations.
- Remove fluff; keep language concrete and testable.
- Ensure recommendations follow from evidence (no leaps).
- Add a "What would change my mind" note for the most important conclusion.
- Check internal consistency:
  - Executive summary matches findings
  - Findings match citations
  - Bibliography entries are all referenced at least once
