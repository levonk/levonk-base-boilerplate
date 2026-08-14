---
workflow: "Be Critical"
slug: "be-critical"
description: "Stress-test a claim or hypothesis by gathering evidence for and against it, then identifying the necessary conditions for it to be true."
use: "When you need to evaluate whether a claim, proposal, belief, or hypothesis holds up under evidence-based scrutiny — not one-sided attack, but symmetric analysis."
role: "Evidence Auditor"
triggers: ["manual"]
concurrency:
  group: "be-critical"
  cancel_in_progress: false
retries:
  max: 0
  backoff_secs: 0
safety:
  dry_run: false
  confirm_dangerous_ops: false
artifacts: ["critical-analysis.md"]
permissions: ["read"]
tools:
  - name: "analysis"
    description: "Symmetric evidence gathering and necessary-conditions analysis"
    inputs:
      - name: "claim"
        type: "string"
        required: true
        description: "The claim, hypothesis, or proposal to evaluate"
      - name: "context"
        type: "string"
        required: false
        description: "Background, constraints, or stakes"
    outputs:
      - name: "analysis"
        type: "string"
        description: "Evidence-for, evidence-against, necessary conditions, and verdict"
version: 1.0.0
owner: "user"
status: "ready"
visibility: "internal"
compliance: []
runtime:
  duration:
    min: "3m"
    max: "15m"
    avg: "7m"
  terminate: "manual"
date:
  created: "2026-07-12"
  knowledge-basis: "2026-07-12"
  last-used: "2026-07-12"
---

# Be Critical

## Goal

Evaluate a claim by treating it as a hypothesis and applying three symmetric
questions:

1. **Evidence that supports the claim** — what data, observations, or reasoning
   backs it up?
2. **Evidence that challenges the claim** — what data, observations, or reasoning
   contradicts or undermines it?
3. **What needs to be true for this to be real?** — what necessary conditions
   must hold, and do they?

This is not one-sided attack (devil's advocate) or one-sided defense (cherry
picking). It is symmetric evidence gathering followed by a necessary-conditions
check — the structure of scientific hypothesis evaluation and Bayesian belief
updating.

Success criteria: A balanced verdict that states the claim's strength based on
evidence weight and the viability of its necessary conditions, with an explicit
confidence level.

### Role

- **Evidence Auditor**: Gather evidence for and against with equal rigor, then
  test the claim's foundations.
- Do not start with a conclusion and look for supporting evidence. Start with
  the claim, gather both sides, then judge.
- Distinguish between evidence (data, observation, citation) and argument
  (logic, inference, reasoning). Label each.

## I/O

### Context

- The claim, hypothesis, or proposal under evaluation.
- The domain, stakes, and decision that depends on the claim.
- Available sources (files, docs, data, prior research).

#### Required Context

- **Claim**: The specific assertion being evaluated.

#### Suggested Context

- Stakes: what decision depends on this claim being true or false?
- Sources: where can evidence be found?
- Prior beliefs: what is currently assumed to be true?

### Inputs

```yaml
schema:
  inputs:
    - name: claim
      type: string
      required: true
      description: "The claim, hypothesis, or proposal to evaluate"
      example: "Migrating to microservices will improve our deployment frequency"
    - name: context
      type: string
      required: false
      description: "Background, stakes, constraints, available sources"
      example: "Team of 8, monolith deployed weekly, considering split into 12 services"
    - name: focus_areas
      type: array<string>
      required: false
      description: "Specific dimensions to emphasize (e.g., cost, performance, risk)"
      example: ["deployment-frequency", "team-scaling", "operational-complexity"]
```

### Outputs

```yaml
schema:
  outputs:
    - name: evidence_for
      type: array<string>
      required: true
      description: "Evidence supporting the claim, each with source and weight"
    - name: evidence_against
      type: array<string>
      required: true
      description: "Evidence challenging the claim, each with source and weight"
    - name: necessary_conditions
      type: array<string>
      required: true
      description: "What must be true for the claim to hold"
    - name: conditions_met
      type: array<object>
      required: true
      description: "Each necessary condition with a met/unmet/unknown status"
    - name: verdict
      type: string
      required: true
      description: "Balanced assessment with confidence level"
    - name: confidence
      type: integer
      required: true
      description: "Confidence in the verdict (1-10)"
```

## Operation

Three phases, one per question. Do not skip or reorder — the symmetry is the
point.

### Phase 1: Evidence That Supports the Claim

1. **Restate the claim precisely.** Remove ambiguity. If the claim is vague,
   sharpen it before evaluating. Note any reframing.
2. **Gather affirmative evidence.** List every piece of evidence that supports
   the claim. For each:
   - State the evidence concretely (data point, observation, citation, case
     study, logical argument).
   - Tag it: **[Data]**, **[Observation]**, **[Citation]**, **[Argument]**,
     **[Analogy]**.
   - Rate its weight: **Strong** (directly supports, well-sourced),
     **Moderate** (supports but indirect or partially sourced), **Weak**
     (suggestive but circumstantial).
3. **Do not filter.** Include weak evidence — it will be weighed, not hidden.

### Phase 2: Evidence That Challenges the Claim

1. **Gather disconfirming evidence.** Apply the same rigor as Phase 1 — same
   tags, same weight scale. Look for:
   - Data that contradicts the claim.
   - Cases where the claim failed or did not hold.
   - Counterarguments from credible opposing perspectives.
   - Missing evidence: what evidence *should* exist if the claim is true, and
     is it absent?
2. **Steel-man the opposition.** Find the strongest version of the challenge,
   not the weakest. A claim that survives a strong challenge is stronger than
   one that only survives a weak one.
3. **Note absence of evidence.** If evidence that *should* exist for the claim
   is missing, that is evidence against — note it as **[Absence]**.

### Phase 3: What Needs to Be True for This to Be Real?

1. **Extract necessary conditions.** For the claim to hold, what must be true?
   These are the load-bearing assumptions — if any one is false, the claim
   collapses. Look for:
   - Explicit assumptions stated in the claim or context.
   - Implicit assumptions the claim depends on but does not state.
   - Causal links that must hold (A must cause B for the claim to work).
   - Boundary conditions (the claim only holds within certain ranges).
2. **Test each condition.** For each necessary condition, assign:
   - **Met**: Evidence confirms this condition holds.
   - **Unmet**: Evidence confirms this condition does not hold.
   - **Unknown**: No evidence either way — flag for investigation.
3. **Identify the weakest load-bearing condition.** The claim is only as strong
   as its most fragile necessary condition. Name it.

### Phase 4: Verdict

Synthesize the three phases into a verdict:

1. **Weigh the evidence.** Compare the evidence-for vs evidence-against. Which
   side has more strong-weight evidence? Is one side all weak?
2. **Check the load-bearing conditions.** How many necessary conditions are met
   vs unmet vs unknown? A single unmet load-bearing condition can sink an
   otherwise well-supported claim.
3. **State the verdict.** One of:
   - **Supported**: Evidence for outweighs evidence against, and all load-bearing
     conditions are met.
   - **Contested**: Evidence is mixed, or some conditions are unknown.
   - **Unsupported**: Evidence against outweighs evidence for, or a load-bearing
     condition is unmet.
   - **Falsified**: A necessary condition is definitively unmet, or strong
     evidence directly contradicts the claim.
4. **Assign confidence (1-10).** How confident are you in the verdict? Low
   confidence means more investigation is needed, not that the claim is weak.

### Tools

```yaml
manifest:
  steps:
    - name: restate_claim
      uses: analysis
      constraints:
        - "Remove ambiguity before evaluating"
    - name: evidence_for
      uses: analysis
      constraints:
        - "Tag and weight every piece of evidence"
        - "Include weak evidence — do not filter"
    - name: evidence_against
      uses: analysis
      constraints:
        - "Same rigor as evidence-for — symmetric"
        - "Steel-man the opposition"
        - "Note absence of expected evidence"
    - name: necessary_conditions
      uses: analysis
      constraints:
        - "Find implicit assumptions, not just explicit ones"
        - "Test each condition: met / unmet / unknown"
        - "Identify the weakest load-bearing condition"
    - name: verdict
      uses: analysis
      constraints:
        - "Weigh evidence, check conditions, state verdict with confidence"
```

### Instructions

- **Symmetry is non-negotiable.** Evidence-for and evidence-against get the same
  rigor, the same tags, the same weight scale. Do not sandbag one side.
- **Evidence ≠ argument.** Tag each item. Data and observations carry different
  weight than logic and analogy — make the distinction visible.
- **Absence is evidence.** If evidence that should exist for the claim is
  missing, that counts against it.
- **Necessary conditions are load-bearing.** A claim with strong evidence but an
  unmet necessary condition is still false. Do not let evidence-for overshadow
  a broken foundation.
- **Name the weakest link.** The most fragile necessary condition is the thing
  most likely to sink the claim. Call it out explicitly.
- **Confidence is about the verdict, not the claim.** Low confidence means "I
  need more evidence to judge," not "the claim is weak."

### Templates

#### Input Template

```markdown
# Be Critical Request

**Claim**: [The assertion, hypothesis, or proposal to evaluate]

**Context**: [Background, stakes, what decision depends on this]

**Focus Areas** (optional): [e.g., cost, feasibility, risk, performance]
```

#### Output Template

```markdown
# Critical Analysis: [Claim]

## Claim (Restated)
[Precise version of the claim, with any reframing noted]

## Evidence That Supports the Claim
| # | Evidence | Type | Weight | Source |
|---|----------|------|--------|--------|
| 1 | [evidence] | [Data/Observation/Citation/Argument/Analogy] | [Strong/Moderate/Weak] | [source] |
| 2 | ... | ... | ... | ... |

## Evidence That Challenges the Claim
| # | Evidence | Type | Weight | Source |
|---|----------|------|--------|--------|
| 1 | [evidence] | [Data/Observation/Citation/Argument/Absence] | [Strong/Moderate/Weak] | [source] |
| 2 | ... | ... | ... | ... |

## What Needs to Be True for This to Be Real
| # | Necessary Condition | Status | Evidence |
|---|---------------------|--------|----------|
| 1 | [condition] | [Met/Unmet/Unknown] | [why] |
| 2 | ... | ... | ... |

**Weakest load-bearing condition**: [the most fragile one]

## Verdict

**Assessment**: [Supported / Contested / Unsupported / Falsified]

**Confidence**: [X]/10 — [brief justification]

**Reasoning**: [2-3 sentences weighing evidence against conditions]

**What would change my mind**: [what evidence would flip the verdict]
```

## Design By Contract

### Preconditions

- Claim is clearly stated and specific enough to evaluate.
- Sufficient context to gather meaningful evidence.

### Postconditions

- Evidence-for and evidence-against are gathered with equal rigor.
- At least 3 necessary conditions are identified.
- Each necessary condition has a met/unmet/unknown status.
- Verdict states confidence level and what would change it.

### Invariants

- Evidence-for and evidence-against use the same tags and weight scale.
- No side is sandbagged or filtered.
- Absence of expected evidence is noted.
- The weakest load-bearing condition is explicitly named.

### Assertions

```pseudo
assert(claim is precisely restated)
assert(evidence_for and evidence_against use same tag/weight scheme)
assert(necessary_conditions.length >= 3)
assert(each condition has met/unmet/unknown status)
assert(verdict includes confidence and "what would change my mind")
```

### Contracts

- **Symmetry Contract**: Evidence-for and evidence-against receive identical
  analytical rigor.
- **Necessary-Conditions Contract**: Every load-bearing assumption is identified
  and tested.
- **Verdict Contract**: The verdict accounts for both evidence weight and
  condition viability — not evidence alone.

## Relationship to Other Methods

| Method | Overlap | Difference |
|--------|---------|------------|
| Devil's Advocate | Challenges claims | One-sided (attack only); be-critical is symmetric |
| Inversion | Identifies failure modes | Asks "what guarantees failure?"; be-critical asks "what must be true?" |
| Confident | Evidence sourcing | Scores confidence of claims; be-critical evaluates a claim's truth |
| First Principles | Questions assumptions | Rebuilds from scratch; be-critical tests a specific claim |

<!-- vim: set ft=markdown -->
