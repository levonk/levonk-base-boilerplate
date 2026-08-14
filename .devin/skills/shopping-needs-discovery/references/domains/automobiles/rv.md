# RV & Motorhome Constraints — Sub-Domain

Constraints specific to recreational vehicles — motorized (motorhomes) and
towable (travel trailers, fifth wheels). Load in addition to `index.md` when
the user is buying an RV. RVs combine vehicle and dwelling systems, creating
unique maintenance, storage, and depreciation dynamics.

## Motorhome Classes

| Class | Style | Price range | Pros | Cons |
|-------|-------|-------------|------|------|
| **Class A** | Bus-style, custom chassis | $100k–$1M+ | Most space/luxury; residential amenities | Most expensive; hardest to drive/park; highest maintenance |
| **Class B** | Camper van (Sprinter/ProMaster/Transit) | $50k–$150k | Easiest to drive/park; can be daily driver; best fuel economy | Least space; expensive per sq ft |
| **Class C** | Cab-over (truck chassis with house) | $50k–$200k | Good balance of space/driveability; sleeps 6+ | Cab-over bed access; narrower than Class A |

## Motorized vs Towable

| Factor | Motorized (Class A/B/C) | Towable (travel trailer, 5th wheel) |
|--------|------------------------|-------------------------------------|
| Upfront cost | Higher | Lower |
| Engine to maintain | Yes | No (tow vehicle is separate) |
| Need a tow vehicle | No (but may tow a car ("toad")) | Yes (must match tow capacity) |
| Setup at camp | Level + hookups | Level + hookups + unhitch |
| Driving experience | Drives like a vehicle | Towing dynamics; requires skill |
| Depreciation | Similar (30–50% in 5 yr) | Similar |

- **Towable advantage**: No engine/drivetrain to maintain. The tow vehicle can
  be used independently. Lower total cost for occasional users.
- **Motorized advantage**: Self-contained; no setup/unhitch at each stop. Better
  for frequent movers and full-timers.

## Systems

| System | Component | Maintenance concern |
|--------|-----------|---------------------|
| Water | Fresh water tank + pump | Sanitize tank annually; check for leaks |
| Waste | Grey tank (sink/shower), black tank (toilet) | Dump regularly; black tank needs proper treatment |
| Propane | Tank(s) + regulator + lines | Leak test; regulator replacement every 10–15 yr |
| Electrical (12V) | House batteries + converter | Battery replacement every 3–6 yr; check converter output |
| Electrical (120V) | Shore power + breaker panel | GFCI test; check for corrosion at shore power inlet |
| Generator | Onboard (gas/propane/diesel) | Run monthly under load; annual service ($200–$500) |
| Climate | Roof AC + furnace | AC recharge/clean coils; furnace annual inspection (propane) |

- **Dump station requirements**: Grey/black tanks must be emptied at a dump
  station (RV park, truck stop, municipal facility). Plan routes around dump
  availability if boondocking.

## Winterization

- **Cold climates**: Water systems must be winterized to prevent freeze damage
  (cracked pipes, pump, water heater). Cost: $200–$400 (professional) or DIY
  ($20–$50 in antifreeze + labor).
- **Method**: Drain all water, blow out lines with compressed air, pump RV
  antifreeze through the system. Some owners use air-only (no antifreeze) —
  riskier but simpler.
- **De-winterization**: Spring startup requires flushing antifreeze and
  sanitizing the fresh water system.

## Storage

| Storage type | Cost / month | When needed |
|-------------|-------------|------------|
| Indoor (climate-controlled) | $200–$400 | Exotics, full-timer rigs, cold climates |
| Indoor (non-climate) | $100–$250 | Most RVs, year-round |
| Outdoor (covered) | $75–$150 | Mild climates |
| Outdoor (uncovered) | $50–$150 | Budget; accelerates weathering |

- **Storage is a significant ongoing cost** often overlooked. An RV stored
  outdoors in sun/snow degrades faster (roof, seals, decals, interior).

## Depreciation

- **RVs depreciate 30–50% in 5 years** — faster than cars. They are not
  investments. A $100k Class C is worth $50k–$70k after 5 years.
- **Driving off the lot**: New RVs lose 10–20% immediately, similar to cars.
- **Used RVs (3–5 years old)** offer the best value — previous owner absorbed
  the steepest depreciation, and most mechanical issues have surfaced.

## Roof Maintenance

| Roof type | Lifespan | Maintenance |
|-----------|----------|-------------|
| Rubber (EPDM/TPO) | 10–15 years | Inspect + coat annually; $300–$600/yr |
| Fiberglass | 20+ years | Inspect seams; less maintenance |

- **Roof leaks = structural damage**: Water intrusion rots the wood framing
  and delaminates the walls. A small leak ignored for months can cause
  thousands in damage. Inspect roof seams and sealant every 6 months.
- **PPI for RVs**: Inspect for water damage using a moisture meter around
  windows, seams, and corners. This is the #1 RV PPI finding.

## Tires

- **Replace at 7 years regardless of tread.** RV tires age out before they wear
  out. The DOT date code (4 digits on sidewall: WWYY) tells the week and year
  of manufacture. Tires older than 7 years are at risk of blowouts.
- **Blowout risk**: RV blowouts cause severe damage (side-of-road body damage,
  loss of control). Tire pressure monitoring system (TPMS) is strongly
  recommended ($200–$400).
- **Load range**: Verify tires match the RV's weight rating. Under-rated tires
  are a common cause of blowouts.

## Infrastructure

- **RV parks**: Full hookups (water, sewer, electric 30/50A). Cost $30–$80/night.
  Reserve ahead in peak season.
- **Boondocking (dry camping)**: No hookups. Requires sufficient battery/solar
  capacity, fresh water, and waste tank capacity. Plan dump/fill stops.
- **Solar + battery upgrade**: $1,000–$5,000 for a boondocking-capable system.

## Output Format Example

```text
RV Constraints:
- Class: C (cab-over), 2019, $65k asking
- Depreciation: 5 yr old, ~45% off MSRP — reasonable
- Roof: Rubber (EPDM), 5 yr old — inspect + recoat ($400)
  - Moisture scan: No active leaks (PPI)
- Tires: DOT code 2118 (week 21, 2018) — 6 yr old
  - Replace within 1 year ($1,200 for 6 tires + TPMS $300)
- Systems: Generator 200 hrs, AC x2 functional, furnace functional
- Storage: Indoor $180/mo (user has access)
- Winterization: Required (user in CO) — $300/yr or DIY
- Towable vs motorized: Motorized — no separate tow vehicle needed
⚠️ Tires at 6 years — budget replacement within 12 months
⚠️ Roof inspection every 6 months — leaks cause structural damage
```

<!-- vim: set ft=markdown -->
