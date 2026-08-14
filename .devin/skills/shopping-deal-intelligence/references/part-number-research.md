# Part-Number Research — Reference

Detailed guidance for sourcing replacement parts by their specific manufacturer
part number rather than by product model name. Referenced by `SKILL.md` section
"1.5. Part-Number Sourcing (When Applicable)".

## The Convenience Tax Problem

Searching `laptop model XYZ screen replacement` or `Dyson V11 battery
replacement` surfaces a specific category of listings: pre-packaged repair
kits and model-specific "compatible" parts that carry a **convenience markup**
of 30–150% over the raw OEM component. Sellers know the buyer doesn't know the
part number, so they bundle the part with instructions, tools, and a
model-name guarantee — and charge for the bundling.

Searching the actual part number (e.g., `LP140QH1-SPB1` instead of `X1 Carbon
Gen 9 screen`) surfaces the raw OEM panel from component suppliers, parts
resellers, and international marketplaces at a fraction of the cost. The same
physical component, no convenience markup.

**Rule**: When the Needs Discovery Brief includes a `Replacement Part` section
with a manufacturer part number, always search by the part number first. Only
fall back to model-name searches if part-number searches yield no results.

## Part-Number Sourcing Workflow

### 1. Search by Part Number

Run the part number across all sourcing channels, not just the ones that
survive a model-name search:

| Channel | What to search | Why |
|---------|---------------|-----|
| Google Shopping | `"PART_NUMBER"` (quoted) | Cross-retailer comparison for the exact component |
| eBay | `"PART_NUMBER"` in title, filter by condition | Used pulls, surplus, and new old stock (NOS) |
| [AliExpress](https://www.aliexpress.com/) / [Alibaba](https://www.alibaba.com/) | `"PART_NUMBER"` | Often the OEM factory or their direct distributor — lowest price |
| Amazon | `"PART_NUMBER"` | Sometimes listed by component resellers without the model-name markup |
| Manufacturer parts store | Part number lookup | Official part, highest price, guaranteed compatibility |
| Parts resellers ([PartSelect](https://www.partselect.com/), [eReplacementParts](https://www.ereplacementparts.com/), [Sears PartsDirect](https://www.searspartsdirect.com/)) | Part number lookup | Verified compatibility, mid-range price |
| [RockAuto](https://www.rockauto.com/) (automotive) | Part number or cross-reference | Aftermarket + OEM side by side |
| Specialist forums / Reddit | `"PART_NUMBER" site:reddit.com` or forum search | Community-verified suppliers, group buys, known-good sellers |
| International: [Taobao](https://www.taobao.com/) (via agent), [Banggood](https://www.banggood.com/) | `"PART_NUMBER"` | OEM factory direct for Chinese-manufactured components |

### 2. Cross-Brand Equivalent Identification

The same OEM part is frequently sold under multiple brand labels at different
prices. A panel manufactured by Innolux might be sold as `LP140QH1-SPB1`
(Innolux brand) and also rebranded under a laptop manufacturer's own part
number (e.g., `01YN414` for Lenovo). The physical component is identical; the
price difference is the brand tax.

**How to find cross-brand equivalents:**

1. Look up the part in the manufacturer's service manual — it often lists
   approved substitute part numbers (e.g., "Use 01YN414 or LP140QH1-SPB1 or
   B140HAN05.7")
2. Search the part number on parts cross-reference databases:
   - [Partsouq](https://www.partsouq.com/) (automotive OEM cross-reference)
   - [RockAuto](https://www.rockauto.com/) (automotive aftermarket cross-ref)
   - Forum posts — search `"PART_NUMBER" equivalent OR substitute OR cross-reference`
3. Check the OEM manufacturer's own product page — they often list all the
   brand part numbers that map to their component
4. Search eBay/Amazon for the part number and note listings that say
   "replaces PART_NUMBER" or "compatible with PART_NUMBER" — these reveal
   the equivalent numbers

**Cross-brand comparison table format:**

```text
| Part Number | Brand | Supplier | Condition | Price | Warranty | Notes |
|-------------|-------|----------|-----------|-------|----------|-------|
| LP140QH1-SPB1 | Innolux (OEM) | AliExpress | New | $48 | 30-day | Factory direct |
| 01YN414 | Lenovo (rebrand) | Lenovo Parts | New | $145 | 1-year | Official, 3x price |
| B140HAN05.7 | AUO (equivalent) | eBay | New | $55 | 60-day | Approved substitute |
| LP140QH1-SPB1 | Innolux (OEM) | eBay | Used pull | $32 | 14-day | From decomissioned unit |
```

### 3. Condition Assessment for Parts

| Condition | Typical savings | Risk | When to choose |
|-----------|----------------|------|----------------|
| New OEM (factory direct) | Baseline | Lowest | High-value or safety-critical parts |
| New OEM (branded reseller) | 0–10% off | Low | When you need the warranty / return policy |
| New aftermarket | 20–50% off | Medium — check reviews | Non-critical parts, budget-constrained |
| Used pull / NOS | 40–70% off | Medium — test on arrival | Obsolete parts, budget repairs, non-critical |
| Refurbished | 15–40% off | Low–medium | When refurbisher offers warranty |

### 4. Supplier Reputation Check for Parts

Parts sourcing has higher fraud risk than retail. For each supplier:

- **eBay sellers**: Check feedback score (99%+ for parts), sold count of this
  specific part, how long they've been selling
- **AliExpress/Alibaba**: Check store rating, years on platform, order count,
  buyer photos/reviews
- **Parts resellers**: Check BBB, return policy, whether they test parts
  before shipping
- **Forum-recommended sellers**: Verify the recommendation is recent (within
  12 months) — suppliers go bad

### 5. Price Comparison Output

```text
## Part-Number Sourcing Report

### Part Details
- Manufacturer part number: [PART_NUMBER]
- Component: [description, e.g., 14" IPS display panel, 1920x1200]
- Cross-brand equivalents found: [list]
- Device compatibility: [model(s) this part fits]

### Supplier Comparison (sorted by effective cost)
| Rank | Supplier | Part Number Listed | Brand | Condition | Price | Shipping | Warranty | Effective Cost | Notes |
|------|----------|-------------------|-------|-----------|-------|----------|----------|---------------|-------|
| 1 | AliExpress (OEM Store) | LP140QH1-SPB1 | Innolux | New | $48 | $6 | 30-day | $54 | Factory direct, 2-week ship |
| 2 | eBay (seller: partsplus) | LP140QH1-SPB1 | Innolux | Used pull | $32 | $5 | 14-day | $37 | From working unit, tested |
| 3 | eBay (seller: oempanels) | B140HAN05.7 | AUO | New | $55 | Free | 60-day | $55 | Approved substitute, faster ship |
| 4 | Lenovo Parts | 01YN414 | Lenovo | New | $145 | $10 | 1-year | $155 | Official rebrand, 3x cost |

### Recommendation
→ Buy from [Supplier] at $X effective cost
→ Savings vs model-name search: $Y (Z%)
→ Warranty: [terms] — see warranty comparison for trade-off analysis
```

## When Part-Number Sourcing Doesn't Apply

- The Needs Discovery Brief has no `Replacement Part` section (user is buying
  a whole product, not repairing)
- The part number could not be identified (needs-discovery failed to find it)
- The part is discontinued / no longer available (NLA) — fall back to
  model-name search or recommend full product replacement
- The effort tier is Quick and the part cost difference is under $10 — the
  research time isn't worth the savings

<!-- vim: set ft=markdown -->
