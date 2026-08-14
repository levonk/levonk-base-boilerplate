# Total Cost of Ownership — Attribute Reference

Constraint attribute: applies when the item has ongoing costs beyond the
purchase price. Referenced by `references/constraint-attributes.md`.

## The Purchase Price Is Often the Smallest Cost

Before recommending, estimate the **total cost of ownership** (TCO) over the
expected ownership period. A cheap purchase with high ongoing costs can be
more expensive than a premium purchase with low ongoing costs.

## Subscription Requirements

Device requires ongoing subscription to function fully:

| Product | Subscription | Annual cost | Notes |
|---------|-------------|-------------|-------|
| Keurig | K-cups | $200–$600 | vs $60–$120 for ground coffee |
| Inkjet printer | Ink cartridges | $100–$400 | "Razor and blades" model |
| Peloton | Membership | $480 | Required for full functionality |
| Smart lock | Cloud subscription | $30–$60 | For remote access features |
| CPAP | Proprietary parts | $200–$400 | Mask, filters, humidifier chambers |
| EV charging network | Subscription | $100–$200 | Some networks require membership |

Calculate subscription cost over the expected ownership period and add it to
the purchase price.

## Cheap to Buy, Expensive to Own

| Category | Purchase | Annual cost | Why |
|----------|---------|-------------|-----|
| Inkjet printer | $50 | $200–$400/yr | Ink is the profit center |
| European luxury car (BMW, Mercedes, Audi) | $10k–$50k used | $2k–$5k/yr | Parts, labor, premium fuel, insurance |
| Boat | $5k–$50k | $3k–$15k/yr | Storage, slip fees, maintenance, insurance, winterization |
| Pool | $20k–$50k install | $1.5k–$5k/yr | Chemicals, electricity, cleaning, repairs |
| Hot tub | $3k–$10k | $500–$1.5k/yr | Chemicals, electricity, water, cover replacement |
| Lawn (large) | Property cost | $1k–$5k/yr | Mowing, fertilizing, irrigation, equipment |
| Horse | $1k–$10k | $3k–$10k/yr | Boarding, feed, vet, farrier |
| RV / camper | $10k–$100k | $2k–$8k/yr | Storage, maintenance, depreciation, insurance |

## Maintenance Burden

Some purchases require significant time investment:

| Item | Weekly maintenance | Annual cost if outsourced |
|------|-------------------|--------------------------|
| Pool | 1–2 hours | $1,200–$2,500 |
| Hot tub | 30 min | $500–$1,000 |
| Boat | 1 hour (in season) | $1,500–$4,000 |
| Large lawn | 2–4 hours | $1,000–$3,000 |
| Rental property | 2–5 hours | $1,200–$3,000 (property manager) |

A $2,000 hot tub that requires 2 hours/week of maintenance is a bad buy for
someone who won't maintain it. Compare the maintenance burden to the user's
willingness to maintain.

## Disposal Cost

Items that are expensive to get rid of at end of life:

| Item | Disposal cost | Why |
|------|---------------|-----|
| Mattress | $50–$150 | Bulky; few recyclers accept |
| Old appliances | $50–$200 | Haul-away required; refrigerant recovery |
| Tires | $5–$20 each | Disposal fee at tire shops |
| CRT monitor / old TV | $20–$50 | Hazardous materials |
| Boat | $500–$5,000 | Hull disposal, engine, trailer |
| Hot tub | $300–$800 | Demolition, haul-away, electrical disconnect |
| EV battery | $0–$2,000 | Some manufacturers recycle free; others charge |

Factor disposal into the lifetime cost, especially for items with short
lifespans.

## Depreciation Cliff

Some items lose value fast at a known point:

| Item | When value crashes | Why |
|------|-------------------|-----|
| New car | Driven off the lot | 20% instant depreciation |
| Outgoing tech model | Successor launches | 20–40% drop |
| iPhone | New model launches (September) | 10–20% drop |
| GPU | New generation launches | 20–40% drop |
| Seasonal items | End of season | 30–60% drop |

Check the product lifecycle (see
`deal-intelligence/references/market-timing.md` — Product Lifecycle Timing)
before recommending. Buying right before the cliff means overpaying.

## TCO Calculation

```
TCO = Purchase price + (Annual ongoing cost × Expected ownership years)
      + Disposal cost - Residual value at end of ownership
```

Present TCO alongside the purchase price so the user sees the real cost:

```text
| Option | Purchase | Annual cost | Years | Disposal | Residual | TCO |
|--------|---------|-------------|-------|----------|----------|-----|
| Cheap printer | $50 | $300 | 3 | $20 | $0 | $970 |
| Laser printer | $200 | $80 | 5 | $20 | $50 | $570 |
```

<!-- vim: set ft=markdown -->
