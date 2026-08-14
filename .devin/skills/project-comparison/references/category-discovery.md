# Category Discovery (Project-Specific)

## Table of Contents

1. [Overview](#overview)
2. [Project-Specific Search Tactics](#project-specific-search-tactics)
3. [Project-Specific Membership Signals](#project-specific-membership-signals)

## Overview

The generic 3-tier category discovery process (known names → category search →
adjacent categories), membership verification, and mismatch handling are defined
in the shared `comparison-methodology` include. This file adds project-specific
search tactics and membership signals.

---
description: Shared comparison methodology — category discovery, coverage mapping, and matrix output. Included by skills that compare multiple items (projects, skills, tools) to determine category membership, map coverage, and produce a feature matrix.
---

# Comparison Methodology

Shared methodology for comparing multiple items to determine category membership,
map what parts of a category each item addresses, and produce a feature matrix.
Included by `project-comparison` (software projects) and `ai-upsert`
research phase (AI skills). Domain-specific metadata gathering, search tactics,
and meta-features stay in each skill's own reference files.

## Category Discovery (3-Tier)

Determine whether all items belong to the same category, and discover candidate
items when the user provides only a category name.

1. **Known names** — start from items the user names or that are well-known in
   the category. Read each item's description; extract category signals
   (self-description, tags, topics, "alternatives" sections).
2. **Category search** — search for additional items explicitly tagged or
   described as belonging to the category. Filter by relevance, activity, and
   significance.
3. **Adjacent categories** — look at neighboring categories that may overlap.
   Include adjacent-category items only if they meaningfully compete in the
   target category.

### Membership Verification

| Signal | Strong evidence | Weak evidence |
|---|---|---|
| Self-description | Explicitly names the category | Mentions a related keyword |
| Tags/topics | Tags include the category | Tags are related but not the category |
| Community perception | Listed in curated category lists, comparison articles | Mentioned in a tangential discussion |
| Functionality | Core functionality addresses the category's primary use case | Has a feature that overlaps with the category |

**Rule**: An item is a member if it has at least 2 strong signals, or 1 strong +
2 weak signals. Items with only weak signals are "borderline" and should be
flagged to the user.

### Handling Mismatches

When items don't all belong to the same category:

1. **Report the mismatch clearly**: Name the category each item belongs to and
   explain why they differ.
2. **Offer options**:
   - **Narrow**: Exclude non-matching items and compare only same-category ones.
   - **Broaden**: Expand the category definition to encompass all items (if
     reasonable).
   - **Cross-category comparison**: Proceed but label it as cross-category,
     noting the different categories in the matrix.
3. **Respect the user's choice**: If the user wants to compare across categories
   despite the mismatch, do so — but make the category difference visible.

## Coverage Mapping

Determine which parts of a category each item addresses. A category is defined
by a set of **dimensions** (capabilities, features, use cases). Each item covers
some dimensions fully, some partially, and lacks others.

### Defining Category Dimensions

1. **Start from the category's purpose**: What problem does this category solve?
2. **Identify core capabilities**: What capabilities are essential to deliver
   that purpose?
3. **Identify extended capabilities**: What capabilities differentiate items
   within the category?
4. **Identify integration capabilities**: How do items integrate with the
   broader ecosystem?
5. **Check existing comparisons**: Look at existing comparison articles,
   curated lists, and item documentation for dimensions others have used.

Aim for 8-15 dimensions. Too few misses meaningful distinctions; too many makes
the matrix unwieldy.

Organize dimensions into groups: **Core** (essential), **Extended**
(differentiating), **Integration** (ecosystem connections), **Operations**
(deployment/maintenance), **DX** (developer/user experience).

### 5-Level Coverage Scale

For each item × dimension, assign a coverage rating using the full 5-level
icon scale (matching the `feature-matrix` rule):

---
description: Shared 5-level coverage scale icons for feature/comparison matrices — 🏆 best-in-class, ✅ full, ➖ partial, ⚠️ problematic, ❌ missing. Use in project-comparison, coverage-mapping, and any feature matrix output.
---

# 5-Level Coverage Scale Icons

Use this icon scale when rating how well an item (project, tool, product)
covers a dimension (feature, capability, use case) in a comparison matrix.
The full 5-level scale makes distinctions visible at a glance.

| Icon | Meaning | Criteria |
|---|---|---|
| 🏆 | **Best-in-class** | Standout, industry-leading implementation — the item's marquee feature |
| ✅ | **Full support** | First-class, well-supported feature |
| ➖ | **Partial support** | Supported but limited, requires plugins, or has caveats |
| ⚠️ | **Problematic** | Exists but broken, deprecated, actively harmful, or has serious known issues |
| ❌ | **Not supported** | Not addressed, or requires significant custom work |

## Usage Rules

- **Reserve 🏆 for true standouts.** Not every ✅ is a 🏆 — 🏆 is for the
  item's marquee feature or an industry-leading implementation.
- **Distinguish ⚠️ from ➖ and ❌.** Use ⚠️ when a feature exists but is broken
  or deprecated — distinct from ➖ (works but limited) and ❌ (doesn't exist).
- **Use the full scale.** Don't collapse to just ✅/❌ — the middle levels
  (🏆, ➖, ⚠️) carry the most decision-relevant signal.
- **Apply consistently across items.** The same dimension uses the same
  criteria for every item in the matrix.

## Legend Format

When presenting a matrix, include a one-line legend:

```markdown
**Icons**: 🏆 best · ✅ good · ➖ neutral · ⚠️ bad · ❌ worst
```

## Coverage Summary Labels

After mapping all items, summarize using these labels:

- **Table-stakes** (all ✅) — baseline, move to bottom of matrix
- **Best-in-class** (🏆) — competitive advantage, highlight in recommendation
- **Problematic** (⚠️) — broken or deprecated, flag in recommendation
- **Differentiating** — items vary, keep prominent
- **Gaps** (none ✅) — unmet needs, note in recommendation
- **Unique advantages** — only one item has ✅, highlight in recommendation


The scale above is the canonical reference — use it consistently across all
comparison matrices.

### Identifying Gaps and Overlaps

After mapping all items:

1. **Table-stakes dimensions**: All items have ✅. Baseline — move to bottom of
   matrix.
2. **Differentiating dimensions**: Items vary. Most interesting — keep prominent.
3. **Gap dimensions**: No item has ✅. Unmet needs — note in recommendation.
4. **Unique dimensions**: Only one item has ✅. Competitive advantage —
   highlight in recommendation.

## Matrix Output Format

The feature matrix follows the `feature-matrix` rule for icons and table
layout. Additional structural guidance:

### Table Structure

- **Items across the top** (column headers), with inline links
- **Features down the side** (row headers), grouped into sections
- **Icons in cells** for quick visual comparison
- **Identical-value rows at the bottom** (features where all items have the
  same rating)

### Meta-Features Section

The top of the table contains standard meta-features that apply to all
comparisons. Each skill defines its own meta-features appropriate to its domain
(see the skill's own reference files for the specific meta-features to include).

### Recommendation Framework

Structure recommendations **by use case, not by item**. Each bullet is a
use-case context, and names the item that fits best with a one-line reason.

**Order recommendations progressively** — either least→most demanding or
most→least demanding — and pick a direction and stick with it. This gives the
reader a natural escalation path: "start here, move up when you outgrow it."

#### Choosing Recommendation Axes

Pick 3-6 axes that represent the real decision dimensions a user faces. Common
axis families:

| Axis family | Example axes | When to use |
|---|---|---|
| **Expertise / complexity** | Beginner, intermediate, expert | Tools with steep learning curves |
| **Scale** | No scale needs, medium, high scale, enterprise | Tools where architecture affects throughput |
| **Performance** | Latency-sensitive, throughput-focused, balanced | Tools where perf characteristics differ meaningfully |
| **Rigor / compliance** | Quick-and-dirty, production-grade, regulated/audit | Tools where operational maturity matters |
| **Deployment context** | Homelab, small team, enterprise, cloud-native | Self-hosted tools, platforms, infrastructure |
| **Team composition** | Solo developer, small team, large org | Collaboration-heavy tools |
| **Ecosystem preference** | React ecosystem, Python-native, language-agnostic | Tools tied to a language or framework ecosystem |

Don't use all families — pick the 3-6 most relevant to the category being
compared.

#### Recommendation Template

```markdown
## Recommendation

*(Ordered from least to most demanding)*

- **For [use case A]**: Item X — [reason: why it fits]
- **For [use case B]**: Item Y — [reason: why it fits]
- **For [use case C]**: Item Z — [reason: why it fits]
- **Avoid**: Item W — [reason: abandoned, critical issues, or outclassed]
- **Watch**: Item V — [reason: new but promising, not production-ready yet]
```

Include **Avoid** only if an item genuinely should be avoided. Include **Watch**
only if there's an item worth tracking that isn't ready for recommendation yet.


## Project-Specific Search Tactics

When searching for candidate projects (Tier 2 — Category Search), use these
project-specific tactics:

1. **GitHub topic search**: Use `gh api search/repositories?q=topic:[topic]`
   to find projects tagged with relevant topics.
2. **GitHub search by description**: Search for repositories whose description
   matches category keywords.
3. **Awesome lists**: Search for `awesome-[category]` repositories on GitHub,
   which curate projects in a category.
4. **Web search**: Search for "[category] comparison", "[category]
   alternatives", "best [category] [year]" to find comparison articles and
   blog posts that name projects.

Filter candidates by:
- **Stars threshold**: Use a minimum star count to filter out inactive/personal
  projects (e.g., 100+ stars, adjustable by category size).
- **Activity**: Exclude archived repos and repos with no commits in the last
  2+ years (unless historically significant).
- **Relevance**: Read the description to confirm the project actually belongs
  to the category, not just mentions a keyword.

## Project-Specific Membership Signals

For project category membership, the strong/weak evidence signals are:

| Signal | Strong evidence | Weak evidence |
|---|---|---|
| Self-description | README/project description explicitly names the category | Mentions a related keyword |
| Topics/tags | GitHub topics include the category | Topics are related but not the category |
| Community perception | Listed in awesome-[category] lists, comparison articles | Mentioned in a tangential discussion |
| Functionality | Core functionality addresses the category's primary use case | Has a feature that overlaps with the category |

**Rule**: A project is a member if it has at least 2 strong signals, or 1
strong + 2 weak signals. Projects with only weak signals are "borderline" and
should be flagged to the user.
