# Automobile Constraints — Domain Index

Domain-specific constraints for automobiles. Referenced by
`references/constraint-attributes.md`. Load when the user is buying, leasing, or
financing any vehicle.

Vehicles are high-value depreciating assets with recurring ownership costs
(insurance, fuel, maintenance, registration) that can exceed the purchase price
over the ownership period. A wrong decision compounds over years.

## How to Use This Index

1. Read the generic constraints below (apply to all vehicles)
2. Identify the vehicle type and load the matching sub-domain file
3. Surface all identified constraints in the Needs Discovery Brief

## Sub-Domain Files

| Sub-domain | When to load | Reference |
|------------|-------------|-----------|
| **EV / PHEV** | User is buying a battery-electric or plug-in hybrid vehicle | `ev-phev.md` |
| **Hybrid** | User is buying a traditional (non-plug-in) hybrid vehicle | `hybrid.md` |
| **Exotic / Sports** | User is buying a high-end sports car, supercar, or exotic | `exotic.md` |
| **Truck** | User is buying a pickup truck (for payload, towing, or work use) | `truck.md` |
| **RV / Motorhome** | User is buying a motorhome, camper van, or towable RV | `rv.md` |

Sedans, vans, and standard passenger cars use only the generic constraints
below — no separate sub-domain file is needed.

## Generic Constraints (All Vehicle Types)

### Title & History

- **Title check**: Verify title status via [NICB
  VINCheck](https://vincheck.nicb.org/) — clean, salvage, or rebuilt. A
  salvage/rebuilt title means the vehicle was declared a total loss. Financing
  and insurance are harder to obtain; resale value drops 20–40%.
- **VIN history report**: Pull a vehicle history report (Carfax, AutoCheck) by
  VIN. Check for: accident history, odometer rollback, number of owners,
  service records, flood damage, lemon history, structural damage. A clean
  report does not guarantee no problems — it means no reported problems.
- **Recall check**: Search the VIN on the [NHTSA recall
  database](https://www.nhtsa.gov/recalls). Open recalls should be fixed by the
  dealer for free, but unrepaired recalls indicate a prior owner who deferred
  maintenance. Check for Takata airbag recalls specifically — these are
  dangerous and long-running.

### Inspection & Insurance

- **Pre-purchase inspection (PPI)**: Always get a PPI from an independent
  mechanic before buying a used vehicle. Cost: $100–$300. This is the single
  best investment in the buying process. It catches hidden problems the seller
  won't disclose and the history report won't show.
- **Insurance cost verification**: Get an insurance quote **before** committing
  to a purchase. Insurance costs vary wildly by vehicle model, driver profile,
  and location. A "cheap" car can have expensive insurance. Check comprehensive,
  collision, and liability costs separately.

### Financing

- **APR comparison**: Get pre-approved from a credit union and/or bank before
  visiting the dealer. Compare the offered APR against the dealer's financing.
  Dealers can mark up the interest rate (reserve) — a 2% markup on a $30k loan
  over 60 months costs ~$1,600 extra.
- **Credit union vs bank vs dealer**:

  | Source | Typical APR advantage | Notes |
  |--------|----------------------|-------|
  | Credit union | Often lowest | Member-owned, member-focused rates |
  | Bank | Competitive | Existing relationship may help |
  | Dealer | Can be lowest (captive) or highest | Manufacturer incentives (0% APR) can win, but watch for rate markup |

- **Loan term**: Longer terms (72–84 months) lower monthly payments but
  increase total interest and risk being "underwater" (owing more than the car
  is worth) due to depreciation.

### Depreciation

- **Depreciation curve**: New cars lose ~20% of value driving off the lot, and
  ~40% by year 3. By year 5, most cars retain 40–50% of original value.
  Depreciation is the largest ownership cost for most vehicles.
- **Buying 3–5 years old** avoids the steepest depreciation while still
  capturing most of the vehicle's useful life.

### Registration & Fees

- **Registration/fees by state**: Varies significantly. Some states charge a
  flat fee; others base it on vehicle value, weight, or age. California, for
  example, charges a percentage of vehicle value (declining with age). Check
  the DMV website for the target state. Factor in sales tax (can be 0–10%+
  depending on state), title transfer fees, and documentation fees (dealer
  doc fees range $75–$800+ by state).

### Emissions Inspection

- **Emission inspection requirements by state**: Some states require periodic
  emissions testing (e.g., California, New York, Illinois in certain
  counties); others have no requirement. Check the state's DMV/environmental
  agency. A vehicle that fails emissions may require expensive repairs to
  register. Diesel vehicles and older vehicles face stricter scrutiny in some
  states.

### Auction-Specific Vehicle Constraints

When buying a vehicle at auction (Copart, IAAI, GSA Auctions, GovDeals,
GovPlanet, tow yard, police seized, etc.), additional constraints apply
beyond the standard checks above. See the deal-intelligence skill's
`references/auction-constraints.md` for the full details. Key flags to
surface in the Needs Discovery Brief when the user is considering auction
vehicles:

- **Smog / CARB compliance**: If the user is in California or another
  strict-emissions state, flag whether the vehicle is CARB-certified
  (50-state emissions label). 49-state or EPA-only vehicles cannot be
  registered in California. Budget $200–$1,500+ for smog-related repairs
  on auction vehicles that may not pass.
- **Export-only restriction**: Some auction vehicles (especially at Copart
  and IAAI) are sold export-only — the buyer must export the vehicle
  outside the US and cannot title or register it domestically. Ask the
  user whether they are buying for export or domestic use.
- **Salvage / rebuilt / junk title**: Auction vehicles frequently have
  branded titles. Ask the user whether they are willing to repair and
  rebuild a salvage vehicle. If not, exclude salvage/rebuilt title
  vehicles from recommendations.
- **Damage level opt-in**: Auction vehicles are sold with varying levels
  of disclosed damage (run & drive, startable, non-runable, front/rear/
  side damage, flood, hail, theft recovery, vandalism, biohazard). Ask
  the user which damage levels they are willing to accept. Flood damage
  should be strongly discouraged unless the user is an experienced
  mechanic or buying for parts.
- **Dealer license requirement**: Some auction sales (especially at
  Copart and IAAI) require a dealer license. Ask the user if they have
  one. If not, they can use a dealer agent/broker ($300–$800 per
  vehicle) or stick to public-access sales.
- **Locale / travel**: Auction vehicles typically require local pickup.
  Ask the user whether they are willing to travel to the pickup location
  or arrange third-party transport. Factor transport cost into the total
  acquisition cost.

## Recommendation

For any vehicle purchase, always recommend: a VIN history report, a recall
check, an independent PPI, and an insurance quote before committing. Surface
all identified constraints in the Needs Discovery Brief with severity levels:

- ⚠️ caution — research further before proceeding
- ❌ deal-breaker — recommend against the purchase
- ☢️ requires expert assessment — professional inspection needed

<!-- vim: set ft=markdown -->
