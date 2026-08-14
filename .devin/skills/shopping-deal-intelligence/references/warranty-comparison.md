# Warranty Comparison — Reference

Detailed guidance for comparing warranty terms across suppliers, brands, and
conditions before making a purchase recommendation. Referenced by `SKILL.md`
section "5. Warranty Comparison".

## Why Warranty Comparison Matters

Two suppliers offering the "same" item at different prices often have
different warranty terms. The cheaper option isn't always cheaper once you
factor in warranty coverage — a part that fails in month 7 with a 6-month
warranty costs you twice; the same failure with a 1-year warranty is a free
replacement. Warranty comparison is especially critical when:

- The same OEM part is sold under different brand labels with different
  warranty durations (see `references/part-number-research.md`)
- Comparing new vs refurbished vs used-pull conditions
- The item is expensive enough that a second purchase would hurt
- The part is failure-prone (batteries, screens, hinges, power boards, pumps,
  compressors, heating elements)
- A failure could damage other components (a failing battery can damage the
  motherboard; a failing pump can flood the house)

## Warranty Types

| Type | Source | Typical duration | Transferability |
|------|--------|-----------------|-----------------|
| **Manufacturer warranty** | The OEM that made the part | 90 days – 5 years | Usually non-transferable (tied to original buyer) |
| **Brand/seller warranty** | The seller or brand reselling the OEM part | 14 days – 2 years | Varies — check terms |
| **Extended warranty** | Third-party (SquareTrade, Allstate) or retailer | 1–4 years beyond manufacturer | Sometimes transferable for a fee |
| **Implied warranty** | State law (US: Magnuson-Moss) | Varies by state | Applies to the original buyer |
| **Credit card extended warranty** | Card benefits (see `references/purchase-optimization.md`) | +1–2 years beyond manufacturer | Tied to the cardholder |
| **No warranty / as-is** | Used pulls, private sellers, auctions | None | None |

## Warranty Terms to Compare

For each candidate supplier/brand, collect and compare these dimensions:

| Dimension | What to check | Why it matters |
|-----------|---------------|----------------|
| **Duration** | How long does coverage last? | Longer = more protection, but only if the part is likely to fail in that window |
| **Coverage scope** | What failures are covered? (defects only? accidental? wear?) | "Defects only" excludes the most common real-world failures |
| **Claim process** | Do you ship it back? Pre-paid label? RMA required? Phone call? | A painful claim process effectively reduces the warranty value |
| **Shipping costs** | Who pays return shipping? | A "free warranty" with $20 return shipping isn't free |
| **Replacement vs repair** | Do they send a new part or repair the old one? | Replacement is faster and better for the buyer |
| **Transferability** | Does the warranty transfer to a new owner? | Matters for resale value and gifts |
| **Restocking fee** | Is there a fee for returns even within the warranty period? | Eats into the savings |
| **Advance replacement** | Do they ship the replacement before you return the defective part? | Eliminates downtime |
| **Prorated vs full** | Is it a full replacement or prorated (decreasing value over time)? | Prorated warranties lose value fast |
| **Exclusions** | What's explicitly not covered? (water damage, user error, DIY installation damage) | Narrow exclusions can void the warranty on common failure modes |

## Warranty Comparison Table Format

```text
## Warranty Comparison

| Supplier | Brand | Price | Warranty Duration | Coverage | Return Shipping | Claim Process | Effective Cost with Risk |
|----------|-------|-------|-------------------|----------|-----------------|---------------|--------------------------|
| AliExpress OEM Store | Innolux | $48 | 30-day | Defects only | Buyer pays ($15) | Ship back, wait | $63 if fails in 30d, $96 if fails after |
| eBay (partsplus) | Innolux (used) | $32 | 14-day | DOA only | Buyer pays ($10) | Message seller | $42 if DOA, $64 if fails after 14d |
| eBay (oempanels) | AUO (new) | $55 | 60-day | Defects + backlight | Pre-paid label | RMA online | $55 (return shipping covered) |
| Lenovo Parts | Lenovo (official) | $145 | 1-year | Full manufacturer defects | Pre-paid | Phone/online RMA | $145 (best coverage, highest price) |
```

## Risk-Adjusted Cost Calculation

When warranty terms differ, compute a **risk-adjusted cost** to compare
apples-to-apples:

```
Risk-adjusted cost = Price + (Failure_probability × Out-of-warranty_replacement_cost)
```

Where:
- **Failure probability**: Estimated from reliability data, forum reports,
  and part type (batteries: ~15%/year after year 2; screens: ~5%/year; hinges:
  ~8%/year; SSDs: ~1.5%/year)
- **Out-of-warranty replacement cost**: The price of buying the part again
  if it fails after the warranty expires

**Example**: A $48 panel with 30-day warranty vs a $55 panel with 60-day
warranty vs a $145 panel with 1-year warranty. If the annual failure
probability is 5%:
- $48 panel: Risk-adjusted = $48 + (0.05 × $48) = $50.40 (but only 30 days
  covered, so most of the risk period is uninsured)
- $55 panel: Risk-adjusted = $55 + (0.05 × $55) = $57.75 (60 days covered)
- $145 panel: Risk-adjusted = $145 + (0.05 × $0) = $145 (full year covered,
  near-zero risk)

The $55 panel is the sweet spot: low price, enough warranty for the early
failure window, and the risk-adjusted cost is still far below the official
part.

## When Warranty Should Override Price

| Scenario | Prioritize warranty over price |
|----------|-------------------------------|
| Safety-critical part (brake pad, helmet, smoke detector) | Always — failure is catastrophic |
| Part whose failure damages other components (battery, pump, PSU) | Always — cascading failure cost exceeds the price difference |
| High base failure rate part (batteries, hinges, screens) | Strong preference for longer warranty |
| Part is difficult/expensive to reinstall (engine component, built-in appliance) | Strong preference — labor cost of re-doing the repair doubles the cost |
| Part is cheap and easy to replace (< $20, 5-minute swap) | Warranty matters less — just buy the cheapest |
| User is buying for resale or as a gift | Prefer transferable warranty |

## Warranty Stacking with Credit Card Benefits

Credit card extended warranty (see `references/purchase-optimization.md` —
Extended Warranty Stacking) can add 1–2 years to the manufacturer warranty at
no cost. When comparing suppliers, factor in whether the purchase qualifies
for card extended warranty:

- Most cards require the original manufacturer warranty to be ≤ 5 years
- The card extends the **manufacturer** warranty, not the seller warranty
- Used/refurbished parts may not qualify if the "manufacturer warranty" is
  actually a seller warranty
- Paying with a card that offers extended warranty can make a shorter
  manufacturer warranty equivalent to a longer one — effectively leveling the
  playing field between a 90-day OEM warranty and a 1-year branded warranty

<!-- vim: set ft=markdown -->
