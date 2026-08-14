# Skill Discovery & Research Phase

## Table of Contents

1. [Overview](#overview)
2. [Running the Discovery Script](#running-the-discovery-script)
3. [Analyzing Found Skills](#analyzing-found-skills)
4. [Gap Assessment](#gap-assessment)
5. [Decision: Create vs Reuse](#decision-create-vs-reuse)
6. [Incorporating Findings into a New Skill](#incorporating-findings-into-a-new-skill)

## Overview

Before creating a new skill, research what already exists. This prevents
duplicating effort and ensures new skills incorporate the best ideas from
existing work. The research phase searches three sources:

| Source | What it covers | How |
|---|---|---|
| **Local** | Skills in skills-src, project `.agents/skills/`, `~/.agents/skills/` | Filesystem scan of SKILL.md frontmatter |
| **skills.sh** | Public skills registry (Vercel Labs ecosystem) | API search |
| **GitHub** | Repositories with SKILL.md files | `gh api search/code` + repo metadata |

The goal is not just to find skills, but to **assess whether they cover the
user's need** and **identify what's missing** — so the new skill (if created)
is better than what exists, not a duplicate.

## Running the Discovery Script

```bash
# Search all sources (local, skills.sh, GitHub)
uv run --script scripts/discover_skills.py "skill comparison and evaluation"

# Search only local skills
uv run --script scripts/discover_skills.py "code review" --sources local

# Search skills.sh and GitHub only (skip local)
uv run --script scripts/discover_skills.py "pdf rotation" --sources skills.sh,github

# Verbose output (prints progress to stderr)
uv run --script scripts/discover_skills.py "git workflow" --verbose

# Dry run (show what would be searched without API calls)
uv run --script scripts/discover_skills.py "testing" --dry-run
```

The script outputs JSON with arrays of found skills per source. Each skill
includes name, description, URL/path, and source-specific metadata (installs
for skills.sh, stars for GitHub, match_score for local).

## Analyzing Found Skills

For each found skill, assess:

1. **Relevance**: Does it address the same need the user described? Read the
   description carefully — many skills have similar names but different
   purposes.
2. **Scope**: Does it cover the full scope the user wants, or only part of it?
3. **Quality**: Is it well-structured (frontmatter, references, scripts)? Does
   it have evals? Is it actively maintained?
4. **Fit**: Does it match the user's constraints (language, platform, license,
   distribution model)?

### Skill-Specific Meta-Features

When comparing found skills, use these skill-specific meta-features (adapted
from the `feature-matrix` rule):

| Meta-feature | What to assess | Icon guidance |
|---|---|---|
| Triggers | How well-defined are the trigger conditions? | 🏆 explicit + negative guards / ✅ explicit / ➖ implicit / ⚠️ vague / ❌ none |
| Dependencies | Are dependencies documented and minimal? | 🏆 zero deps / ✅ documented / ➖ some undocumented / ⚠️ heavy deps / ❌ unknown |
| Scripts | Does it bundle executable scripts for deterministic phases? | 🏆 well-structured / ✅ present / ➖ minimal / ⚠️ broken / ❌ none |
| References | Does it use progressive disclosure with reference files? | 🏆 comprehensive / ✅ adequate / ➖ inline-heavy / ⚠️ disorganized / ❌ monolithic |
| Evals | Does it have evals for testing? | 🏆 comprehensive / ✅ present / ➖ minimal / ⚠️ outdated / ❌ none |
| Maintenance | Is it actively maintained? | 🏆 active (< 1 month) / ✅ recent (< 6 months) / ➖ moderate / ⚠️ stale / ❌ abandoned |
| Distribution | Is it distributed via a registry? | 🏆 skills.sh + GitHub / ✅ GitHub / ➖ local only / ⚠️ private / ❌ unknown |

### Coverage Assessment

Use the shared comparison methodology to map coverage:

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


Apply the 3-tier category discovery to determine if found skills are in the
same category as the user's request. Map coverage using the 5-level icon scale
to identify what each skill covers and what's missing.

## Gap Assessment

After analyzing found skills, determine whether there's a gap:

| Situation | Gap? | Action |
|---|---|---|
| No skills found | Yes — clear gap | Proceed to create |
| Skills found but none cover the user's need | Yes — coverage gap | Proceed to create, incorporating best ideas |
| Skills found, partially cover the need | Yes — scope gap | Proceed to create, noting what existing skills miss |
| Skills found, fully cover the need | No gap | Offer to install the best match (see below) |
| Multiple skills found, each covers part | Partial gap | Consider creating a skill that combines the best parts |

### What Counts as "Fully Covered"

A need is fully covered when an existing skill:
1. Addresses the user's specific use case (not just a related one)
2. Has acceptable quality (structured, maintained, has evals)
3. Matches the user's constraints (language, platform, distribution)
4. Is installable and usable by the user

If any of these fail, there's at least a partial gap.

## Decision: Create vs Reuse

### If there IS a gap

Present the findings to the user:
- What skills exist and what they cover
- What's missing (the gap)
- How the new skill would be better

Then offer to create the skill. The user's ideas/constraints + best practices
the LLM knows + the best ideas from existing skills all feed into the new
skill's design.

### If there is NO gap

Present the best existing skill(s) with:
- Name, description, and link (so the user can investigate themselves)
- Why it fits the user's need
- Any caveats (quality, maintenance, scope limitations)

Then ask the user:
1. **Install the existing skill?** — Provide the install command (e.g.,
   `pnpm dlx skills add owner/repo` for skills.sh skills, or `git clone` for
   GitHub repos).
2. **Still create a new skill?** — The user may have reasons to create their
   own (customization, learning, different constraints). Respect their choice
   and proceed with creation.

### If the user wants to investigate

Always provide links so the user can investigate existing skills themselves
before deciding. Do not make the decision for them — present the evidence and
let them choose.

## Incorporating Findings into a New Skill

When proceeding to create a new skill after finding existing ones:

1. **Note the best ideas**: What did existing skills do well? (workflow
   structure, reference organization, script patterns, eval design)
2. **Note the gaps**: What did existing skills miss? This is the value
   proposition of the new skill.
3. **Note the user's ideas/constraints**: What does the user want that
   existing skills don't address?
4. **Apply best practices**: Use the LLM's knowledge of skill design best
   practices (from `anatomy.md`, `progressive-disclosure.md`, etc.)
5. **Synthesize**: Combine all three inputs (existing ideas + gap filling +
   best practices) into the new skill's design.

The new skill should be **better than any single existing skill** — not just
different. If it's merely a reimplementation, reconsider whether creation is
warranted.
