# Services — Domain Reference

Domain-specific constraints for service provider hiring. Referenced by
`references/constraint-attributes.md`. Load when the user is hiring a
service provider (contractor, professional, tradesperson, consultant).

## Vendor Tier Differentiation

The same service can often be performed by different vendor types at
different price points. The user may be **over-specifying** (paying for a
higher tier than needed) or **under-specifying** (hiring a lower tier that
can't legally or competently perform the work). Identify the correct tier
before researching specific providers.

### Common Vendor Tier Mismatches

| Service need | Lower tier (cheaper) | Higher tier (expensive) | When to use lower | When to need higher |
|--------------|---------------------|------------------------|-------------------|---------------------|
| Bookkeeping / accounting | Bookkeeper ($30–$60/hr) | CPA ($100–$300/hr) | Monthly books, payroll, simple tax filing | Tax strategy, multi-state, business entity, audit representation, certified financial statements |
| Electrical work | Handyman ($40–$80/hr) | Licensed electrician ($75–$150/hr) | Replacing a switch, installing a ceiling fan | New circuits, panel upgrade, service entrance, anything requiring a permit |
| Plumbing | Handyman ($40–$80/hr) | Licensed plumber ($75–$150/hr) | Replacing a faucet, unclogging a drain | New plumbing, repiping, sewer line, gas line, anything requiring a permit |
| Legal documents | Paralegal / online service ($50–$200) | Attorney ($200–$500/hr) | Simple will, LLC formation, uncontested divorce | Estate planning, litigation, complex contracts, criminal defense |
| Home design | Draftsperson ($30–$60/hr) | Architect ($100–$250/hr) | Simple plans, permit drawings | Complex designs, structural engineering, historic renovation |
| Medical care | NP / PA ($copay) | MD specialist ($copay + referral) | Routine checkups, minor illness | Complex diagnosis, surgery, specialist treatment |
| Car repair | DIY / shade tree mechanic | ASE-certified mechanic | Oil change, brake pads, simple swaps | Engine rebuild, transmission, diagnostics, warranty work |
| Landscaping | Day laborer ($15–$25/hr) | Licensed landscaper ($40–$80/hr) | Mowing, trimming, basic cleanup | Hardscaping, irrigation systems, grading, retaining walls |
| Tax filing | Tax software ($0–$100) | CPA ($300–$1,000+) | W2 income, standard deduction | Business, investments, rental property, multi-state |

### How to Determine the Right Tier

1. **Identify what the user actually needs done** — not the title they
   asked for. "I need a CPA" might mean "I need someone to do my monthly
   books" (bookkeeper) or "I need tax planning for my S-corp" (CPA).
2. **Check legal requirements** — some work requires a licensed
   professional by law (electrical, plumbing, structural). Using an
   unlicensed worker can void insurance, fail inspection, and create
   liability.
3. **Check permit requirements** — if the work needs a permit, the
   permit may require a licensed contractor to pull it.
4. **Check insurance/bonding requirements** — licensed professionals
   carry insurance; handymen often don't. For work that could cause
   damage (plumbing, electrical, roofing), insist on insurance.
5. **Present the tier comparison** so the user can choose based on their
   needs and budget.

### Vendor Tier Comparison Output

```markdown
### Service Tier Analysis
- Service needed: [description]
- Legal requirement: [Licensed professional required / No license required]
- Permit required: [Yes/No — who pulls it]

| Tier | Vendor type | Typical cost | Can do this work? | When to choose |
|------|-----------|-------------|-------------------|----------------|
| 1 | [lower tier] | $X | ✅ / ❌ | [condition] |
| 2 | [higher tier] | $Y | ✅ | [condition] |

- Recommendation: [Tier X — reason]
```

## Licensing

Does the jurisdiction require a license for this work? Common licensed
trades:

| Trade | Typically licensed? | Verify via |
|-------|-------------------|------------|
| Plumbing | Yes (most states) | State licensing board |
| Electrical | Yes (most states) | State licensing board |
| HVAC | Yes (most states) | State licensing board |
| Roofing | Yes (many states) | State licensing board / registrar |
| General contractor | Yes (most states, above $500 threshold) | State licensing board |
| Tree removal | Varies | City/county |
| Pest control | Yes (EPA + state) | State pesticide office |
| Land surveying | Yes | State board |
| Engineering | Yes | State PE board |
| Architecture | Yes | State architecture board |
| Law | Yes | State bar |
| Medicine | Yes | State medical board |
| Accounting (CPA) | Yes | State board of accountancy |

Verify license status online before hiring. An expired or suspended license
means the provider cannot legally perform the work.

## Insurance & Bonding

- **General liability**: Covers damage to your property. Request a
  certificate of insurance directly from the provider's insurer (not a
  photocopy from the provider).
- **Workers' comp**: Covers injuries to the provider's employees on your
  property. Required if the provider has employees.
- **Bonding**: Protects against the provider not completing the work or
  failing to pay subcontractors. Required for some trades (plumbing,
  electrical, roofing in some states).

## Permits

Does the work require a building permit? Who pulls it — homeowner or
contractor? Common permit-requiring work:

- Structural changes (removing walls, adding windows/doors)
- Electrical (new circuits, panel upgrades)
- Plumbing (new lines, water heater replacement)
- Roofing (full replacement)
- Fences over a certain height
- Sheds over a certain size
- Decks
- HVAC installation

**Unpermitted work** can cause problems when selling (buyer's inspector
flags it), trigger code enforcement fines, and void insurance coverage for
related damage.

## Complaint History

Check before hiring:

- **BBB**: Complaints and resolution history
- **State contractor licensing board**: Disciplinary actions, complaints
- **Yelp filtered reviews**: The filtered reviews often contain the most
  honest negative feedback
- **Court records**: Search the county court for lawsuits against the
  provider

## Seasonal Availability

| Trade | Peak season | Off-season | Notes |
|-------|------------|------------|-------|
| Roofing | After hail season, summer | Winter | Off-season bids 10–25% lower |
| HVAC | Summer (AC), winter (heat) | Spring, fall | Off-season installation cheaper |
| Landscaping | Spring, summer | Late fall, winter | Off-season design/planning cheaper |
| Plumbing | Holidays (kitchen), winter (pipe bursts) | — | Emergency surcharges apply during peaks |
| Painter | Summer | Winter | Interior painting available year-round |

## Red Flags

- Demands full payment upfront
- No written estimate
- No physical address (PO box only)
- Pressure to decide immediately
- Won't provide references
- License number not provided or doesn't match
- Asks for cash only, no receipt
- Wants to pull permit in homeowner's name (shifts liability to you)
- Vehicle is unmarked (no business name/logo)
- No separate business phone number

<!-- vim: set ft=markdown -->
