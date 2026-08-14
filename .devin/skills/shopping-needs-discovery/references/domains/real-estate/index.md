# Real Estate Constraints — Domain Index

Domain-specific constraints for real estate. Referenced by
`references/constraint-attributes.md`. Load when the user is buying,
renting, or leasing property.

Real estate has the most expensive failure modes of any purchase category.
A wrong decision can cost six or seven figures and be difficult or
impossible to reverse.

## How to Use This Index

1. Read the generic constraints below (apply to all real estate)
2. Identify the transaction type and load the matching sub-domain file
3. Surface all identified constraints in the Needs Discovery Brief

## Sub-Domain Files

| Sub-domain | When to load | Reference |
|------------|-------------|-----------|
| **Residential** | User is buying a home to live in (primary or secondary residence) | `residential.md` |
| **Investment** | User is buying property for appreciation or ROI (flip, hold, develop) | `investment.md` |
| **Rental** | User is buying property to rent out (landlord perspective) | `rental.md` |
| **Commercial** | User is buying commercial property (retail, office, industrial, mixed-use) | `commercial.md` |
| **Leasee (tenant)** | User is renting/leasing as a tenant | `leasee/index.md` (generic) + sub-domain below |
| **Leasee — home rental** | User is renting a house, townhouse, or condo | `leasee/home.md` |
| **Leasee — apartment rental** | User is renting an apartment in a multi-unit building | `leasee/apartment.md` |
| **Leasee — commercial lease** | User is leasing commercial space (retail, office, industrial) | `leasee/commercial.md` |

Load multiple sub-domain files when the transaction spans types (e.g.,
buying a duplex to live in one unit and rent the other = residential +
rental).

## Generic Constraints (All Real Estate Types)

These apply to any real estate transaction — purchase, lease, or investment.

### Land & Terrain

- **Zoning**: Verify the parcel is zoned for the intended use (residential,
  commercial, agricultural, mixed). Check for conditional use permits,
  variances, or non-conforming use status. Can you subdivide? Can you run a
  home business? Can you build an ADU? Check the county/city zoning map and
  planning department.
- **Topography / incline**: Steep slopes make building expensive (foundation
  engineering, retaining walls, drainage). Slopes over 25% may be
  unbuildable. Check for landslide risk (especially after wildfires — burned
  hillsides are mudslide-prone for 2–5 years).
- **Soil conditions**: Expansive clay soils (Colorado, Texas, parts of
  California) cause foundation movement. Sinkhole risk (Florida, Texas,
  Missouri — check USGS karst maps). Permafrost (Alaska — specialized
  foundations). Contaminated soil (former industrial sites — see toxicity
  below). A geotechnical soil report is worth the cost before buying land to
  build on.
- **Flood susceptibility**: Check [FEMA Flood Map Service
  Center](https://msc.fema.gov/portal/) for flood zone designation. Even
  outside FEMA zones, check historical flooding records and climate change
  projections — FEMA maps are often outdated. Properties in flood zones
  require expensive flood insurance and may be uninsurable in high-risk
  areas.
- **Wetlands**: Wetlands designation (Army Corps of Engineers, state DNR)
  restricts building, clearing, and drainage. You may own the land but
  cannot use it. Wetlands delineation requires a professional survey.
- **Endangered species habitat**: Presence of endangered species can
  restrict development (federal Endangered Species Act). Check with USFWS
  and state wildlife agency.

### Access & Utilities

- **Road access**: Is the parcel landlocked (no road access)? Is the access
  road public (county-maintained) or private (you maintain it)? Paved or
  dirt? Seasonal (closed in winter)? Is there a recorded easement granting
  access? Landlocked parcels without easements are nearly worthless.
- **Water**: Municipal water, or well? If well, typical well depth in the
  area (deeper = more expensive)? Water table contaminated (agricultural
  runoff, industrial, naturally occurring arsenic/uranium)? Water rights
  restrictions (Western US — prior appropriation doctrine)? Check state
  water resources department.
- **Sewer / septic**: Municipal sewer available? If septic, is the soil
  suitable for a leach field (percolation test required)? Some parcels are
  "perc-failed" and cannot support a septic system — effectively unbuildable.
- **Power**: Grid power available? How far is the nearest connection point
  (cost per foot for line extension)? Rolling blackouts (California PSPS)?
  Off-grid solar/battery adds $20,000–$50,000+.
- **Internet**: Broadband available? Satellite (Starlink) is an option but
  check coverage. Rural areas may have no reliable internet.
- **Gas**: Natural gas available, or propane/oil delivery required?

### Legal & Title

- **HOA / CC&Rs**: Homeowners association fees, rules, and restrictions.
  CC&Rs may prohibit certain uses, fence types, paint colors, pets, rentals,
  or business operations. Read the full CC&R document, not just the summary.
  Check HOA financial health (reserve study) — an underfunded HOA means
  special assessments are coming.
- **Mineral rights**: In many Western US states, mineral rights are
  "severed" from surface rights — someone else owns the oil/gas/minerals
  under your land and can access them. Check the title for mineral rights
  ownership.
- **Conservation easements**: A conservation easement (held by a land trust
  or government agency) permanently restricts development, even for future
  owners. Read the easement terms carefully.
- **Easements**: Utility easements, access easements, drainage easements.
  These grant others the right to use part of your property. Check the title
  report and plat map.
- **Encroachments**: Neighbors' fences, driveways, or structures that cross
  the property line. Requires a survey to identify. May need resolution
  before sale or may become a permanent adverse possession claim.
- **Liens**: Tax liens, mechanic's liens, HOA liens. These must be cleared
  before or at closing. Title insurance protects against undiscovered liens.

### Toxicity & Environmental Hazards

- **Brownfield / former industrial**: Former gas stations, dry cleaners,
  factories, landfills. Soil and groundwater contamination may require
  remediation costing $10,000–$1,000,000+. Check EPA Superfund database,
  state environmental agency cleanup sites, and historical use (Sanborn fire
  insurance maps).
- **Meth lab contamination**: Properties formerly used as meth labs require
  professional remediation ($5,000–$25,000). Many states require disclosure;
  check the state's meth lab registry.
- **Radon**: Naturally occurring radioactive gas. Test before buying —
  mitigation systems cost $1,200–$2,500. Check [EPA radon zone
  map](https://www.epa.gov/radon/epa-map-radon-zones).
- **Asbestos & lead**: Pre-1980s buildings may have asbestos (insulation,
  floor tiles, siding, popcorn ceilings) and pre-1978 buildings likely have
  lead paint. Disclosure required for residential sales. Abatement is
  expensive ($1,500–$30,000+).
- **Naturally occurring hazards**: Uranium in groundwater (Southwest),
  arsenic (New England, Southwest), naturally occurring asbestos in soil
  (California, Vermont). Test well water before buying.

### Market & Financial (All Types)

- **Property tax trajectory**: Are taxes likely to rise? Check the local tax
  rate and pending ballot measures. Some areas have caps (California Prop 13)
  that reset on sale — your taxes may be much higher than the previous
  owner's.
- **Insurance availability**: Wildfire-prone areas (California) and
  hurricane-prone areas (Florida, Gulf Coast) are seeing insurers pull out.
  Check whether you can get insurance and at what cost **before** making an
  offer. An uninsurable property is effectively unfinanceable.
- **Resale liquidity**: Is the property in an area with good resale demand?
  Rural properties, unique custom homes, and properties with significant
  constraints (landlocked, off-grid, flood zone) can take years to sell.

### Auction-Specific Property Constraints

When buying property at auction (GSA Real Estate, Treasury/IRS, US Marshals,
HUD, Fannie Mae, Freddie Mac, county tax deed, foreclosure/trustee sales),
additional constraints apply beyond the standard checks above. See the
deal-intelligence skill's `references/auction-constraints.md` for the full
buildability checklist and title risk details. Key flags to surface in the
Needs Discovery Brief when the user is considering auction property:

- **Buildability (raw land)**: Before bidding on raw land at auction,
  verify: ingress (legal, physical access — landlocked parcels are nearly
  worthless), topography (slopes over 25% may be unbuildable), zoning
  (parcel zoned for intended use), lot dimensions (wide enough for legal
  building per setback requirements), airspace easements (height
  restrictions), underground easements (utility/pipeline/drainage that
  prevent building), water (municipal or well + water rights), electricity
  (grid power or off-grid budget), sewage (municipal or septic + perc
  test), trash pickup, and road access (paved/dirt/seasonal).
- **Title risks at auction**: Many auction sales (especially tax deed and
  foreclosure) do not provide title insurance. Surviving liens (IRS tax
  liens have a 120-day redemption period), occupants (eviction may be
  required), redemption rights (former owner can reclaim in some states),
  and unrecorded interests (leases, options) are all risks. Recommend a
  title search before bidding ($75–$200).
- **As-is sale**: No inspection contingencies, no financing contingencies,
  no repair credits. Inspect before bidding if possible. Budget for all
  repairs. Have cash or hard money lined up.
- **Risk level by auction type**: GSA/Treasury/USMS/HUD/Fannie/Freddie are
  moderate risk (insurable title generally available). County tax deed
  sales are high risk (no title insurance initially, possible surviving
  liens, occupants, redemption rights). Courthouse steps/trustee sales are
  very high risk (cash only, no inspection, no financing, no warranty).
- **Locale / travel**: In-person auctions (courthouse steps, some tax deed
  sales) require attending in person with a cashier's check. Ask the user
  whether they are willing to travel.

## Recommendation

For any real estate transaction, always recommend a professional inspection,
survey, title search, and soil/water testing before any purchase commitment.
Surface all identified constraints in the Needs Discovery Brief with
severity levels:

- ⚠️ caution — research further before proceeding
- ❌ deal-breaker — recommend against the purchase
- ☢️ requires expert assessment — professional inspection/testing needed

<!-- vim: set ft=markdown -->
