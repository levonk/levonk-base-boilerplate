# Questioning Examples & Decision Tables — Reference

Detailed questioning format, product-vs-service classification, problem-to-product mapping, and alternative discovery examples. Referenced by `SKILL.md` sections "2. Intelligent Questioning" through "3.5. Alternative Discovery".

## Intelligent Questioning Format

Present questions in numbered format with lettered answer choices. Pre-fill best-guess answers based on context so the user can confirm or override.

```text
1. What is the primary use case?
   a) Daily commuting (← suggested based on your mention of "getting to work")
   b) Weekend recreation
   c) Long-distance travel
   d) Commercial/business use

2. What is your budget range?
   a) Under $500
   b) $500–$1,500 (← suggested based on typical range for this category)
   c) $1,500–$3,000
   d) $3,000+
```

### Questioning Rules

- Number questions sequentially (1, 2, 3…)
- Letter answer choices (a, b, c, d…)
- Mark suggested answer with `(← suggested: <reason>)`
- Limit to 3–5 questions per round; follow up if needed
- Group related questions together under a heading
- If the user's response is ambiguous, re-ask with refined choices

## Product vs Service Classification

| Type | Indicators | Workflow Differences |
|------|-----------|---------------------|
| **Product** | User needs a thing (tool, appliance, device, material) | Standard product research, pricing, sourcing |
| **Service** | User needs someone to do something (repair, install, clean, consult, teach) | Provider vetting, quote comparison, licensing checks |
| **Both** | Product + installation/setup (e.g., new HVAC system, fence, appliance with install) | Product research + service provider coordination |

For **services**, add these questions to the intelligent questioning round:

- Scope of work (what exactly needs doing?)
- Urgency (emergency vs scheduled?)
- Previous providers (anyone they've used and liked/disliked?)
- License/insurance requirements (some jurisdictions require licensed electricians, plumbers, etc.)

## Problem-to-Product/Service Mapping — Decision Table

When the user describes a **problem** rather than a product or service, present solution categories as a decision table:

```text
| # | Category | Type | Fit | Typical Cost | Timeline Match | Notes |
|---|----------|------|-----|-------------|----------------|-------|
| 1 | Hire a plumber | Service | ⭐ | $150–$400 | ✅ | Licensed, insured, warrantied |
| 2 | DIY repair kit | Product | ☑️ | $25–$60 | ✅ | Requires skill; risk of water damage |
| 3 | Replace fixture yourself | Product | ⚠️ | $80–$200 | ⚠️ | Moderate difficulty; no warranty |
```

## Alternative Discovery — Comparison Table

When the user names a specific product, present alternatives as:

```text
| # | Product | vs Your Pick | Price | Rating | Key Difference |
|---|---------|-------------|-------|--------|----------------|
| ★ | Dyson V15 (your pick) | — | $750 | ⭐ | Best suction, heaviest |
| 2 | Samsung Bespoke Jet | Lighter, similar power | $550 | ☑️ | Better battery, less brand cachet |
| 3 | Tineco S7 Pro | Wet+dry, different approach | $500 | ☑️ | Mops too; less raw suction |
```

**Skip alternative discovery** if the user explicitly says "don't suggest alternatives" or the effort tier is Quick and the product is commodity (e.g., "buy AA batteries").

<!-- vim: set ft=markdown -->
