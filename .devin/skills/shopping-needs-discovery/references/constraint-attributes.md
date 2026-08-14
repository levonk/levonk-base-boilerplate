# Constraint Attributes Index — Reference

Index of all constraint attributes and domain-specific checks. Referenced by
`SKILL.md` section "5. Constraint Identification". **Load only the attribute
and domain files that apply to the current purchase type** — do not load all
files. This index is the only file always read; everything else is
on-demand.

## How to Use This Index

1. Read the attribute table below
2. For each attribute, check the "When to load" column — if the condition
   matches the current purchase, load that reference file
3. Read the domain table below
4. If the purchase matches a domain, load that domain file
5. Surface all identified constraints in the Needs Discovery Brief
   `Constraints & Warnings` section

## Universal Attributes

These apply to most product purchases. Load when the condition matches.

| Attribute | When to load | Reference |
|-----------|-------------|-----------|
| **Obsolescence** | Item has software, firmware, cloud service, or ecosystem dependency (electronics, smart home, software, connected devices) | `attributes/obsolescence.md` |
| **Repairability** | Item has components that could fail and need repair/replacement (anything mechanical or electronic with a lifespan > 1 year) | `attributes/repairability.md` |
| **Total cost of ownership** | Item has ongoing costs: subscriptions, fuel, maintenance, insurance, parts, disposal (vehicles, appliances, printers, pools, boats, smart devices) | `attributes/total-cost-of-ownership.md` |
| **Used-specific risks** | User is considering a used or refurbished purchase (not buying new) | `attributes/used-risks.md` |
| **Situational fit** | Item could mismatch the user's environment: climate, infrastructure, space, or financing is involved | `attributes/situational-fit.md` |

## Conditional Attributes

These apply to specific scenarios. Load only when triggered.

| Attribute | When to load | Reference |
|-----------|-------------|-----------|
| **Defects & recalls** | Always check for any product — search recalls by model/serial. For used items, verify recalls were performed. Sources: [NHTSA](https://www.nhtsa.gov/recalls), [CPSC](https://www.cpsc.gov/Recalls), [FDA](https://www.fda.gov/safety/recalls) | Inline below — no separate file needed for basic recall checks |
| **Version pitfalls** | Item has known revision differences or model-year changes (search `<model> revision differences`, check serial number ranges) | Inline below |
| **Reliability data** | Item is expensive or safety-critical (search long-term reviews, MTTF data, forum failure reports) | Inline below |
| **Seller reputation** | Always check for marketplace/private sellers (BBB, Trustpilot, feedback score, account age) | Inline below |

### Inline Quick Checks (no separate file needed)

- **Recalls**: Search manufacturer + government recall databases by model and serial number. For used items, verify the recall was actually performed.
- **Version pitfalls**: "Never buy Model X revision 2; revision 3 fixed the motherboard issue." Check revision/serial before buying.
- **Reliability**: Check long-term review aggregation, forum failure reports, warranty claim rates. Does it fail gracefully or catastrophically?
- **Seller reputation**: BBB rating, Trustpilot score, return policy. For marketplace sellers: feedback % (99%+ for used), sold count, account age. For private sellers: verify identity, meet in public, never wire money.

## Domain-Specific Constraints

Load the domain file when the purchase matches that domain. Domain files
contain constraints that are unique to that product type and don't apply
elsewhere.

| Domain | When to load | Reference |
|--------|-------------|-----------|
| **Real estate** | User is buying, renting, or leasing property | `domains/real-estate/index.md` (generic) + one or more sub-domains below |
| **Real estate — residential** | User is buying a home to live in | `domains/real-estate/residential.md` |
| **Real estate — investment** | User is buying for appreciation/ROI (flip, hold, develop) | `domains/real-estate/investment.md` |
| **Real estate — rental** | User is buying property to rent out (landlord) | `domains/real-estate/rental.md` |
| **Real estate — commercial** | User is buying commercial property (retail, office, industrial) | `domains/real-estate/commercial.md` |
| **Real estate — leasee** | User is renting/leasing as a tenant | `domains/real-estate/leasee/index.md` (generic) + sub-domain below |
| **Real estate — leasee home** | User is renting a house, townhouse, or condo | `domains/real-estate/leasee/home.md` |
| **Real estate — leasee apartment** | User is renting an apartment in a multi-unit building | `domains/real-estate/leasee/apartment.md` |
| **Real estate — leasee commercial** | User is leasing commercial space | `domains/real-estate/leasee/commercial.md` |
| **Services** | User is hiring a service provider (contractor, professional, tradesperson, consultant) | `domains/services.md` |
| **Consumables** | User is buying food, raw materials, supplies, or other consumables (not durable goods) | `domains/consumables.md` |
| **Automobiles** | User is buying a vehicle | `domains/automobiles/index.md` (generic) + sub-domain below |
| **Automobiles — EV/PHEV** | Electric or plug-in hybrid vehicle | `domains/automobiles/ev-phev.md` |
| **Automobiles — hybrid** | Traditional (non-plug-in) hybrid | `domains/automobiles/hybrid.md` |
| **Automobiles — exotic** | Exotic/sports car | `domains/automobiles/exotic.md` |
| **Automobiles — truck** | Truck (payload/towing focus) | `domains/automobiles/truck.md` |
| **Automobiles — RV** | Motorhome or towable RV | `domains/automobiles/rv.md` |
| **Appliances** | User is buying a major appliance | `domains/appliances/index.md` (generic) + sub-domain below |
| **Appliances — HVAC** | Central AC, furnace, heat pump, mini-split | `domains/appliances/hvac.md` |
| **Appliances — water heater** | Tank, tankless, heat pump water heater | `domains/appliances/water-heater.md` |
| **Appliances — laundry** | Washer, dryer, combo unit | `domains/appliances/laundry.md` |
| **Appliances — kitchen** | Dishwasher, range, oven, pizza oven | `domains/appliances/kitchen.md` |
| **Appliances — refrigeration** | Fridge, freezer | `domains/appliances/refrigeration.md` |
| **Appliances — spa** | Sauna, hot tub/jacuzzi | `domains/appliances/spa.md` |
| **Appliances — commercial vs consumer** | Considering commercial appliance for home use | `domains/appliances/commercial-vs-consumer.md` |
| **Small appliances** | Blender, food processor, pressure cooker, fryer, mixer, meat grinder | `domains/small-appliances.md` |
| **Cameras** | DSLR, mirrorless, compact, action camera | `domains/cameras.md` |
| **Mobile phones** | Smartphone purchase | `domains/mobile-phones.md` |
| **Computers** | User is buying a whole laptop, desktop, or all-in-one (Mac, Windows PC, Chromebook) — not building a PC from parts | `domains/computers.md` |
| **Collectibles** | Watches, coins, cards, comics, art, wine, sneakers, vinyl, antiques | `domains/collectibles.md` |
| **Yard tools** | Mowers, trimmers, blowers, chainsaws, tillers, snow blowers | `domains/yard-tools.md` |
| **Computer parts** | User is building or upgrading a PC | `domains/computer-parts/index.md` (generic) + sub-domain below |
| **Computer parts — CPU/motherboard** | CPU, motherboard | `domains/computer-parts/cpu-motherboard.md` |
| **Computer parts — GPU** | Graphics card | `domains/computer-parts/gpu.md` |
| **Computer parts — RAM/storage** | RAM, SSD, NVMe, HDD | `domains/computer-parts/ram-storage.md` |
| **Computer parts — PSU/case/cooling** | Power supply, case, CPU cooler, fans | `domains/computer-parts/psu-case-cooling.md` |
| **Computer parts — monitor/peripherals** | Monitor, keyboard, mouse | `domains/computer-parts/monitor-peripherals.md` |
| **Tools** | User is buying workshop tools | `domains/tools/index.md` (generic) + sub-domain below |
| **Tools — woodworking** | Table saw, miter saw, router, planer, jointer, bandsaw | `domains/tools/woodworking.md` |
| **Tools — metalworking** | Lathe, mill, metal bandsaw, grinder, measuring tools | `domains/tools/metalworking.md` |
| **Tools — welding** | MIG, TIG, stick, flux-cored welder | `domains/tools/welding.md` |
| **Tools — gardening** | Hand tools, long-handle, pruning, soil prep | `domains/tools/gardening.md` |
| **Tools — pottery** | Wheel, kiln, clay, glazes, hand tools | `domains/tools/pottery.md` |

## Attribute Applicability Matrix

Quick reference for which attributes apply to common purchase types. This is
a starting point — always use judgment based on the specific product.

| Purchase type | Obsolescence | Repairability | TCO | Used risks | Situational fit | Domain file |
|--------------|-------------|---------------|-----|------------|-----------------|-------------|
| Laptop | ✅ | ✅ | ✅ | ✅ (if used) | ✅ | `computers.md` (whole computer) / `computer-parts/` (if building) |
| Phone | ✅ | ✅ | ✅ | ✅ (if used) | ✅ (carrier) | `mobile-phones.md` |
| Watch (mechanical) | ❌ | ✅ | ✅ (service) | ✅ (if used) | ❌ | `collectibles.md` (if luxury) |
| Watch (smart) | ✅ | ✅ | ✅ | ✅ (if used) | ❌ | — |
| Appliance (major) | ❌ | ✅ | ✅ | ✅ (if used) | ✅ (install) | `appliances/` |
| Appliance (small) | ❌ | ❌ | ❌ | ✅ (if used) | ✅ (counter) | `small-appliances.md` |
| Vehicle (gas) | ❌ | ✅ | ✅ | ✅ (if used) | ✅ | `automobiles/index.md` |
| Vehicle (EV/PHEV) | ✅ | ✅ | ✅ | ✅ (battery) | ✅ (charging) | `automobiles/ev-phev.md` |
| Vehicle (hybrid) | ❌ | ✅ | ✅ | ✅ (battery) | ✅ | `automobiles/hybrid.md` |
| Vehicle (exotic) | ❌ | ✅ | ✅ (high) | ✅ (if used) | ❌ | `automobiles/exotic.md` |
| Vehicle (truck) | ❌ | ✅ | ✅ | ✅ (if used) | ✅ (towing) | `automobiles/truck.md` |
| RV | ✅ (systems) | ✅ | ✅ (high) | ✅ (if used) | ✅ (storage) | `automobiles/rv.md` |
| Camera | ✅ (firmware) | ✅ | ✅ (lenses) | ✅ (if used) | ❌ | `cameras.md` |
| Collectibles | ❌ | ❌ | ✅ (insurance) | ✅ (fakes) | ✅ (storage) | `collectibles.md` |
| Yard tools | ❌ | ✅ | ✅ | ✅ (if used) | ✅ (yard size) | `yard-tools.md` |
| Computer parts | ✅ (drivers) | ✅ (desktop) | ✅ | ✅ (GPU/SSD) | ✅ (compat) | `computer-parts/` |
| Tools (power) | ❌ | ✅ | ✅ | ✅ (if used) | ✅ (220V?) | `tools/` |
| Tools (hand) | ❌ | ❌ | ❌ | ✅ (great value) | ❌ | `tools/` |
| Food / consumables | ❌ | ❌ | ❌ | ❌ | ✅ (storage) | `consumables.md` |
| Raw materials | ❌ | ❌ | ❌ | ❌ | ✅ (storage) | `consumables.md` |
| Real estate | ❌ | ✅ (repairs) | ✅ (taxes) | ✅ (if existing) | ✅ | `real-estate/` |
| Service (contractor) | ❌ | ❌ | ✅ (ongoing) | ❌ | ✅ | `services.md` |
| Service (professional) | ❌ | ❌ | ✅ (retainer) | ❌ | ❌ | `services.md` |
| Luxury goods | ❌ | ✅ | ✅ (insurance) | ✅ (counterfeit) | ❌ | `collectibles.md` |
| Software / SaaS | ✅ | ❌ | ✅ (subscription) | ❌ | ✅ (integration) | — |

## Output: Constraints in the Needs Discovery Brief

Surface all identified constraints in the `Constraints & Warnings` section.
For each constraint:

- The constraint (what the problem is)
- Severity: ⚠️ caution / ❌ deal-breaker / ☢️ requires expert assessment
- Source (where the information came from)
- Recommended action: research further / avoid / mitigate / accept the risk

For real estate, recommend a professional inspection, survey, title search,
and soil/water testing before any purchase commitment.

<!-- vim: set ft=markdown -->
