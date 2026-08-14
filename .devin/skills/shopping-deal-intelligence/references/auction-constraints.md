# Auction Constraints — Vehicle & Property

> Constraints specific to auction-sourced vehicles and property. Loaded
> alongside `sourcing-guide.md` when any auction channel is in the candidate
> set. Covers vehicle-specific risks (smog, export-only, salvage, dealer-only
> access) and property-specific risks (buildability, zoning, utilities,
> ingress) that are more acute at auction than in retail transactions.

## How to Use This File

1. If any candidate source is an auction (type = "auction" in
   `sourcing-sources.toml`), read the applicable section below
2. For vehicle auctions → read **Vehicle Auction Constraints**
3. For real-estate auctions → read **Property Auction Constraints**
4. For any auction → read **Universal Auction Constraints** (locale, travel,
   registration gating)
5. Surface all identified constraints in the Deal Intelligence Report with
   severity levels (⚠️ caution, ❌ deal-breaker, ☢️ requires expert assessment)

---

## Universal Auction Constraints

### Locale & Travel

Auction locale determines whether a user can participate at all. Classify
every auction candidate by locale requirement:

| Locale type | Description | User action required |
|-------------|-------------|---------------------|
| **Remote bidding + shipping** | Online bidding; item ships to buyer | No travel needed; factor shipping cost |
| **Remote bidding + local pickup** | Online bidding; buyer must pick up in person | User must travel to pickup location or arrange third-party transport |
| **In-person only** | Bidding happens on-site (courthouse steps, live auction) | User must attend in person; travel required |
| **Hybrid (live + online)** | Live auction with online simulcast bidding | Remote possible but in-person often cheaper (no online buyer's premium) |

**When the user specifies a travel radius:**
- Filter out remote-bidding + local-pickup auctions where the pickup location
  exceeds the radius (unless the user explicitly says they're willing to travel
  or arrange transport)
- Include remote bidding + shipping auctions regardless of radius
- Include in-person auctions within the radius only
- Always state the pickup location and distance in the Deal Intelligence Report

**When the user does NOT specify a travel radius:**
- Ask whether they're willing to travel for pickup, and if so, how far
- Default to remote-bidding + shipping auctions only, then expand based on
  the user's answer

### Registration Gating

Some auctions restrict who can participate. Classify every auction by
registration tier:

| Tier | Description | Additional steps |
|------|-------------|-----------------|
| **Open to public** | Anyone can register and bid | Standard registration (name, address, payment method) |
| **Dealer-only** | Requires a valid dealer license | User must provide dealer license number; some platforms verify against state DMV records |
| **Reseller-only** | Requires reseller registration/tax ID | User must provide EIN or reseller certificate; e.g., B-Stock, Liquidation.com for some storefronts |
| **Export-only** | Vehicle is sold for export only; cannot be titled/registered in the US | User must sign export-only affidavit; vehicle must leave the country within a specified period |
| **Salvage-only** | Vehicle is sold as salvage; cannot be legally driven on public roads | User must rebuild/repair and pass state inspection before titling |
| **Licensed contractor** | Some government equipment auctions require proof of applicable trade license | User must provide license number |

**When an auction is dealer-only or reseller-only:**
- Flag it clearly in the Deal Intelligence Report
- Ask the user whether they have the required credential before proceeding
- If the user does not have the credential, exclude the auction from
  recommendations unless the user explicitly says they're willing to obtain it
- Document the credentialing process if the user wants to pursue it

### Buyer's Premium & Total Cost

The winning bid is rarely the final price. Always calculate the **total
acquisition cost**:

```
Total = Winning Bid + Buyer's Premium + Sales Tax + Title/Registration Fees
        + Inspection/Transport Costs + Any Required Repairs
```

- **Buyer's premium**: Ranges from 0% (GSA Auctions, Municibid) to 16.5%
  (PropertyRoom) to 10–15% (GovPlanet, Ritchie Bros.). Some are tiered
  (GovDeals: 7.5–12.5% based on sale price).
- **Sales tax**: May apply on the buyer's premium portion in some states
- **Internet buyer's fee**: Some platforms charge a separate fee for online
  bids vs. in-person bids (e.g., Ritchie Bros. capped internet buyer's fee)
- **Documentation fee**: Dealer-style doc fees at some auction platforms
- **Storage fee**: If the vehicle isn't picked up within the free period
  (typically 3–7 days), daily storage charges accrue

Always present the total acquisition cost, not just the winning bid, in the
Deal Intelligence Report.

---

## Vehicle Auction Constraints

### Smog & Emissions Compliance

**Critical for California and other strict-emissions states.** A vehicle
purchased at auction may not be certifiable for registration in the user's
state.

| Constraint | Impact | Action |
|------------|--------|--------|
| **California CARB certification** | A vehicle not certified by CARB (California Air Resources Board) cannot be registered in California, even if it passes a smog test | Check the vehicle's emissions label under the hood for "50-state" or "CARB compliant" certification. If it says "49-state" or "EPA only," it cannot be registered in California |
| **Smog test requirement** | California requires a smog certificate for most vehicle transfers. Auction vehicles are sold "as-is" and may not pass smog | Budget $200–$1,500+ for smog-related repairs (catalytic converter, O2 sensors, EGR valve). If the vehicle can't pass smog, it can't be registered |
| **Out-of-state title** | If the vehicle has an out-of-state title, California requires a VIN verification and smog check before registration | Factor in DMV fees and inspection time. Some auction vehicles have titles from states with no emissions testing |
| **Diesel emissions** | California has strict diesel emissions rules (DPF, DEF). Older diesels may not comply | Check model year against CARB diesel regulations. Pre-2010 diesels may be non-compliant in California |
| **Other strict states** | New York, Illinois (certain counties), Colorado, Nevada, Oregon (certain areas) also have emissions testing | Check the user's state DMV for emissions requirements before recommending an auction vehicle |

**When recommending an auction vehicle:**
1. Check whether the vehicle is CARB-certified (50-state emissions label)
2. If the user is in California or another strict-emissions state, flag any
   vehicle that may not pass smog
3. Recommend a pre-purchase smog inspection if the vehicle is nearby
4. For out-of-state purchases, add the cost of a VIN verification and smog
   check to the total acquisition cost

### Export-Only Vehicles

Some auction vehicles (especially at Copart and IAAI) are sold with an
**export-only restriction** — the buyer must export the vehicle outside the
US and cannot title or register it domestically.

| Flag | Meaning | User action |
|------|---------|-------------|
| **Export Only** | Vehicle must be exported; cannot be titled/registered in the US | User must sign an export-only affidavit and provide proof of export within 30–90 days. If the user wants to drive it domestically, this is a ❌ deal-breaker |
| **Export Only (Title Delayed)** | Title is held until proof of export is provided | Same as above; title will not be released until export is documented |

**When an auction vehicle is flagged export-only:**
- Clearly flag it in the Deal Intelligence Report
- Ask the user whether they are buying for export or domestic use
- If domestic use → exclude from recommendations
- If export → document the export affidavit process and timeline

### Salvage & Rebuild Titles

Auction vehicles (especially Copart, IAAI, tow yard auctions) frequently
have salvage or rebuilt titles. These have significant implications:

| Title brand | Meaning | Impact |
|-------------|---------|--------|
| **Clean title** | No major damage history | Standard registration and financing |
| **Salvage title** | Vehicle declared a total loss by an insurance company | Cannot be legally driven; must be rebuilt and pass state inspection to get a rebuilt title. Financing is very difficult. Insurance may be limited to liability only |
| **Rebuilt/Reconstructed title** | Salvage vehicle that has been repaired and passed inspection | Can be registered and driven, but financing is harder, insurance is more expensive, and resale value drops 20–40% |
| **Junk title** | Vehicle is for parts only; cannot be rebuilt or titled | Parts only; cannot be registered |
| **Certificate of destruction** | Vehicle is destroyed and cannot be rebuilt | Parts/scrap only |
| **Bill of sale only** | No title; common in tow yard/abandoned vehicle sales | User must apply for a title through their state's abandoned vehicle process, which can take months and may not succeed |

**When an auction vehicle has a salvage or branded title:**
- Flag the title brand in the Deal Intelligence Report
- Ask the user whether they are willing to repair and rebuild a salvage vehicle
- If not → exclude salvage/rebuilt title vehicles from recommendations
- If yes → add estimated repair costs to the total acquisition cost and note
  the state's rebuild inspection requirements
- Always recommend a [NICB VINCheck](https://vincheck.nicb.org/) to verify
  title status

### Damage Assessment

Auction vehicles are sold with varying levels of disclosed damage. The user
must opt into different damage levels:

| Damage level | Description | User opt-in required |
|--------------|-------------|---------------------|
| **Run & Drive** | Vehicle starts, moves, and can be driven onto a transport | Minimal repair needed; user should still get a PPI |
| **Startable** | Engine starts but vehicle may not be drivable | May need transmission, suspension, or brake work |
| **Non-runable** | Vehicle does not start; may need engine replacement or major repair | User must say they're willing to repair or part out |
| **Front end damage** | Collision damage to front | Frame damage possible; user must be willing to repair |
| **Rear end damage** | Collision damage to rear | Often less severe than front end; user must be willing to repair |
| **Side damage** | Collision damage to side | Door/panel replacement; user must be willing to repair |
| **Flood damage** | Water damage; electrical system likely compromised | ⚠️ Major concern — flood cars are notoriously unreliable; user must explicitly opt in |
| **Hail damage** | Cosmetic dents from hail | Often cosmetic only; drivable; user must be willing to accept cosmetic damage |
| **Theft recovery** | Vehicle stolen and recovered; may have damage from theft | Varies widely; user must be willing to inspect and repair |
| **Vandalism** | Intentional damage | Varies; user must be willing to repair |
| **Biohazard** | Vehicle contains biological hazards (blood, decomposition) | ☢️ Requires professional biohazard remediation; user must explicitly opt in |

**When recommending an auction vehicle:**
- State the damage level disclosed by the auction platform
- Ask the user which damage levels they're willing to accept
- For flood damage, strongly recommend against unless the user is an
  experienced mechanic or buying for parts
- Add estimated repair costs to the total acquisition cost when damage is
  disclosed

### Dealer License Requirements

Some auction platforms or specific sales within platforms require a dealer
license:

| Platform | Dealer license required? | Details |
|----------|-------------------------|---------|
| **Copart** | Some sales only | Public can register for "Public" sales; dealer-only sales require a valid dealer license. Copart also offers "Basic" and "Advanced" memberships for public buyers |
| **IAAI** | Some sales only | Similar to Copart; public buyers can participate in some sales with a public account, but many insurance sales are dealer-only |
| **ACV Auctions** | Yes (all sales) | B2B wholesale dealer auction; requires state dealer license, resale certificate, EIN, and POA. Public buyers cannot register |
| **CarMax Auctions** | Yes (all sales) | Dealer-only wholesale; CarMax must approve registration. Public buyers cannot register |
| **AutoBidMaster** | No | Broker for Copart; public can bid without dealer license; membership tiers ($35–$349/yr) |
| **SCA Auction** | No | Broker for IAAI; public can bid without dealer license; membership tiers (free–$549/yr) |
| **GSA Auctions** | No | Open to all public bidders |
| **GovDeals** | No | Open to all public bidders |
| **GovPlanet** | No | Open to all public bidders |
| **B-Stock** | Yes (reseller) | Must register as a reseller with EIN/tax ID |
| **Most state surplus** | No | Open to public |

**When an auction requires a dealer license:**
- Flag it in the Deal Intelligence Report
- Ask the user if they have a dealer license
- If not, explain the process: most states require a business premises, bond,
  insurance, and a fee. Some states offer a "wholesale dealer" license for
  auction-only purchasing without a retail lot
- Alternatively, the user can use a "dealer agent" or "broker" service that
  bids on their behalf for a fee (typically $300–$800)

---

## Property Auction Constraints

### Buildability Checklist

When buying raw land or property at auction (GSA Real Estate, Treasury,
US Marshals, county tax sales, foreclosure auctions), verify buildability
before bidding. Auction properties are sold as-is with no contingencies.

| Check | What to verify | How | Deal-breaker? |
|-------|---------------|-----|---------------|
| **Ingress / access** | Is there legal, physical access to the property? | Check the deed and plat map for recorded easements. Is the road public or private? Is the parcel landlocked? | ❌ Yes — landlocked parcels without easements are nearly worthless |
| **Topography** | Is the terrain buildable? | Check USGS topo maps, Google Earth terrain view, or a survey. Slopes over 25% may be unbuildable. Check for landslide risk (especially post-wildfire) | ❌ Yes — unbuildable slopes, cliffs, or unstable terrain |
| **Zoning** | Is the parcel zoned for the intended use? | Check the county/city zoning map and planning department. Can you build a house? An ADU? A commercial building? | ❌ Yes — wrong zoning for intended use |
| **Lot dimensions** | Is the lot wide enough for a legal building? | Check minimum lot width and setbacks in the zoning code. Some lots are too narrow to place a legally-compliant building | ❌ Yes — lots that can't meet setback requirements |
| **Airspace easements** | Are there height restrictions or airspace easements? | Check the title report for aviation easements, conservation height restrictions, or solar easements from neighbors | ⚠️ Caution — may limit building height or design |
| **Underground easements** | Are there utility, pipeline, or drainage easements that prevent building? | Check the title report and plat map for utility easements, pipeline rights-of-way, drainage easements | ⚠️ Caution — building may be restricted over easement areas |
| **Water** | Is water available? | Municipal water connection, or well (check typical well depth and water quality in the area). Western US: check water rights | ❌ Yes — no water = unbuildable (unless user wants to haul water) |
| **Electricity** | Is grid power available? | How far is the nearest connection? Cost per foot for line extension. Off-grid solar adds $20k–$50k+ | ⚠️ Caution — off-grid is possible but expensive |
| **Sewage / septic** | Is municipal sewer available, or can the soil support a septic system? | If septic: is the soil suitable (percolation test)? Some parcels are "perc-failed" and cannot support septic | ❌ Yes — no sewer + perc-failed = unbuildable |
| **Trash pickup** | Is municipal trash service available? | Check with the local waste management provider. Rural areas may require private haul or self-haul to transfer station | ⚠️ Minor — not a deal-breaker but affects livability |
| **Roads** | Is there a maintained road to the property? | Is the access road paved, dirt, or seasonal (closed in winter)? Is it county-maintained or private (you maintain it)? | ⚠️ Caution — seasonal roads make year-round access impossible |

### Title Risks at Auction

Auction properties carry unique title risks that retail purchases do not:

| Risk | Description | Mitigation |
|------|-------------|------------|
| **No title insurance** | Many auction sales (especially tax deed and foreclosure) do not provide title insurance. Hidden liens may survive the sale | Purchase a title search before bidding ($75–$200). Consider buying title insurance after the sale if possible |
| **Surviving liens** | Some liens (IRS tax liens, municipal liens, HOA liens in some states) may survive a tax deed or foreclosure sale | Research lien survival rules for the auction type in the relevant state. IRS liens have a 120-day redemption period |
| **Occupants** | The property may be occupied by the former owner or tenants. Eviction may be required | Budget for eviction costs ($3,000–$10,000+, 2–6 months). Some states require formal eviction proceedings even for foreclosure sales |
| **Redemption rights** | In some states, the former owner has a redemption period (6–12 months) during which they can reclaim the property by paying the sale price plus costs | Check state redemption laws. During the redemption period, you cannot make permanent improvements or evict in most states |
| **As-is sale** | No inspection contingencies, no financing contingencies, no repair credits | Inspect before bidding if possible. Budget for all repairs. Have cash or hard money lined up |
| **Unrecorded interests** | Leases, options, or equitable interests not recorded in the public record | A title search may not reveal unrecorded interests. Visit the property and check for occupants or lease signs |

### Property Auction Types & Risk Levels

| Auction type | Risk level | Why |
|-------------|-----------|-----|
| **GSA Real Estate Sales** | ⚠️ Moderate | Federal surplus; title is generally clean; reserve sales; online bidding |
| **Treasury/IRS seized real property** | ⚠️ Moderate | Tax forfeiture; sealed bid; title generally clean but check for surviving liens |
| **US Marshals real property** | ⚠️ Moderate | Forfeited; sold via RealLook.com and licensed brokers at fair market value; title is insurable |
| **HUD HomeStore** | ⚠️ Moderate | FHA foreclosures; must use HUD-registered agent; insurable title; Dollar Homes program |
| **Fannie Mae HomePath** | ⚠️ Low–Moderate | REO; insurable title; special financing; "HomePath Ready" program for renovated homes |
| **Freddie Mac HomeSteps** | ⚠️ Low–Moderate | REO; insurable title; 2-year home protection plan |
| **County tax deed sale** | ❌ High | No inspection, no financing, no title insurance (initially), possible surviving liens, possible occupants, redemption rights in some states |
| **County courthouse steps (trustee sale)** | ❌ Very High | Cash/cashier's check only, no inspection, no financing, no warranty, may have liens or occupants, highest risk |

**When recommending a property auction:**
1. Classify the risk level
2. For high-risk auctions (tax deed, courthouse steps), strongly recommend
   that the user consult a real estate attorney before bidding
3. Recommend a title search before bidding for all auction properties
4. For raw land, run the full buildability checklist above
5. Add the cost of title search, survey (if needed), and any required repairs
   to the total acquisition cost

<!-- vim: set ft=markdown -->
