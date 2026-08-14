# Consumables — Domain Reference

Domain-specific constraints for food, raw materials, supplies, and other
consumables. Referenced by `references/constraint-attributes.md`. Load when
the user is buying consumable goods (not durable goods).

Consumables have different constraints than durable products. Obsolescence,
repairability, and warranty don't apply. Instead, shelf life, storage,
bulk economics, and quality/freshness are the primary concerns.

## Shelf Life & Freshness

| Category | Typical shelf life | Storage requirements | Freshness indicators |
|----------|-------------------|---------------------|---------------------|
| Fresh produce | 3–14 days | Refrigeration, humidity control | Color, firmness, smell, mold |
| Fresh meat/fish | 1–3 days | Refrigeration (32–38°F) | Color, smell, slime |
| Frozen foods | 3–12 months | Freezer (0°F) | Freezer burn, ice crystals |
| Dry goods (flour, rice, pasta) | 6–24 months | Cool, dry, airtight | Weevils, rancidity, mold |
| Canned goods | 2–5 years | Cool, dry | Dents, bulging, rust |
| Spices | 1–3 years (ground), 3–4 years (whole) | Cool, dark, airtight | Aroma loss, color fade |
| Oils | 6–24 months | Cool, dark | Rancidity (smell test) |
| Coffee beans | 2–4 weeks (fresh roast), 2 years (frozen) | Airtight, cool | Aroma, oil on surface |
| Building materials (cement, paint) | 6–12 months (opened) | Dry, above freezing | Clumping, separation |
| Batteries | 5–10 years (storage) | Cool, dry | Voltage check |
| Filaments / resins | 1–2 years | Dry, sealed | Moisture absorption, brittleness |

**For bulk purchases**: calculate the per-unit cost savings against the
realistic consumption rate. If the user uses 1 lb of flour per month and
buys a 50 lb bag, 40+ lbs will go bad before it's used. The bulk "savings"
are wasted.

## Bulk Economics

Bulk buying saves money only if:

1. **The consumption rate exceeds the spoilage rate** — you use it faster
   than it goes bad
2. **Storage is available and adequate** — you have cool/dry/dark space
3. **The per-unit savings is significant** — bulk discounts under 10% may
   not justify the storage cost and capital tie-up
4. **The quality doesn't degrade in bulk** — some products lose quality
   when stored in large quantities (coffee beans go stale, spices lose
   potency, paint separates)

### Bulk Purchase Decision Table

```text
| Package size | Unit cost | Monthly usage | Time to consume | Spoilage risk | Storage needed | Net savings |
|-------------|----------|---------------|-----------------|---------------|----------------|-------------|
| 1 lb | $X/lb | 2 lb/month | 0.5 months | None | Minimal | Baseline |
| 10 lb | $Y/lb | 2 lb/month | 5 months | Low | Shelf space | $Z |
| 50 lb | $W/lb | 2 lb/month | 25 months | High (will spoil) | Large container | -$V (waste) |
```

## Quality & Sourcing

For food and raw materials, quality varies significantly by source:

- **Grading systems**: USDA grades (beef: Prime/Choice/Select), honey
  grades, maple syrup grades, olive oil grades (extra virgin vs virgin vs
  refined). Know the grading system for the category.
- **Origin matters**: Coffee (single-origin vs blend), olive oil
  (Mediterranean vs California), wood (hardwood vs softwood, FSC certified),
  metals (alloy grade, temper).
- **Adulteration risk**: Olive oil (often diluted with cheaper oils), honey
  (diluted with corn syrup), spices (adulterated with fillers), vanilla
  (synthetic vs natural). Buy from reputable sources for high-adulteration
  categories.
- **Organic / certification**: Verify certifications are from a recognized
  body (USDA Organic, Fair Trade, FSC, MSC). "Natural" and "artisan" are
  unregulated marketing terms with no legal meaning.

## Storage Requirements

Before recommending a bulk or specialty purchase, verify the user has
appropriate storage:

| Storage type | What it needs | Cost to set up |
|--------------|-------------|----------------|
| Dry pantry | Cool, dark, dry shelves | Minimal |
| Refrigeration | 32–38°F | Existing fridge |
| Freezer | 0°F | Chest freezer ($150–$500) |
| Airtight containers | Sealed bins, mylar bags + O2 absorbers | $20–$100 |
| Climate-controlled | 50–70°F, 30–50% humidity | Dehumidifier/AC |
| Bulk fuel storage | Approved containers, ventilation, legal limits | Varies by fuel type |

## When Consumables Don't Need Constraint Research

For inexpensive, single-use, commodity consumables (e.g., "buy AA
batteries", "buy paper towels"), skip the full constraint analysis. Just
check:

- Is the brand reputable?
- Is the price reasonable?
- Is the quantity appropriate for usage?

Don't overthink a $10 purchase of paper plates.

<!-- vim: set ft=markdown -->
