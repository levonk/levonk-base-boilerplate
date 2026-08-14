# EV & PHEV Constraints — Sub-Domain

Constraints specific to battery-electric vehicles (BEVs) and plug-in hybrid
vehicles (PHEVs). Load in addition to `index.md` when the user is buying an EV
or PHEV. These vehicles have unique infrastructure, battery, and incentive
considerations that gasoline vehicles do not.

## Charging Infrastructure

| Charger type | Power | Range added / hour | Install cost | Where |
|-------------|-------|-------------------|--------------|-------|
| Level 1 (120V) | 1.4–1.9 kW | 3–5 mi | $0 (standard outlet) | Home |
| Level 2 (240V) | 3.3–19.2 kW | 12–60 mi | $500–$2,000 (install) | Home / public |
| DC fast charge | 50–350 kW | 100–300 mi / 20–40 min | N/A (public only) | Public |

- **Home charger install**: Level 2 requires a 240V circuit (like a dryer
  outlet). Cost $500–$2,000 depending on panel distance and wiring. Get an
  electrician quote before buying the vehicle.
- **Home electrical panel capacity**: Verify the panel has spare amperage for a
  40–60 amp circuit. Older homes with 100A panels may need a panel upgrade
  ($1,500–$4,000) or a load-shedding charger.
- **Public charging cost**: 3–5× more expensive per kWh than home charging.
  Relying on public charging erodes the fuel-cost savings that justify an EV.
- **Connector types**:

  | Connector | Use | Notes |
  |-----------|-----|-------|
  | J1772 | Level 1/2 | Universal for all EVs/PHEVs |
  | CCS | DC fast charge | Standard for most non-Tesla EVs |
  | NACS (Tesla) | Level 2 + DC fast charge | Becoming the US standard; adapters available |

## Battery Health

- **State of Health (SOH)**: The key metric for used EV battery condition.
  Measure via OBD2 scanner (e.g., Car Scanner, LeafSpy) or manufacturer
  service mode. SOH below 70% indicates significant degradation.
- **Replacement threshold**: Replace battery below ~70% SOH. Below this, range
  is severely compromised and resale value drops.
- **Battery replacement cost**: $5,000–$20,000 depending on vehicle. For a used
  EV near warranty expiry, this is the single largest financial risk.
- **Battery warranty**: Federal minimum is 8 years / 100,000 miles (covers
  manufacturing defects and significant capacity loss, typically below 70%
  capacity). Verify the warranty is transferable to subsequent owners — some
  are, some aren't.

## Range

- **User-stated range is a floor, not a target**: When the user says "I need
  ~90 miles of range," that means *at least* enough to cover their daily
  driving at a good price. A 200+ mile EV priced below a rare short-range
  model is the better recommendation — more range at equal or lower cost is a
  benefit, not a mismatch. Treat range as a ceiling only if the user explicitly
  caps it ("only ~90 mi", "no more than 100 mi", "keep it under 120"). See
  SKILL.md §2.7 for the full floors-vs-ceilings rule.
- **Real-world vs EPA**: EPA range is a best-case estimate. Real-world range is
  typically 10–25% lower due to driving style, climate, speed, and accessory
  use (AC, heating).
- **Cold weather reduction**: 20–40% range loss in cold weather (below 32°F).
  Battery chemistry is less efficient in cold; cabin heating draws significant
  power. This is the most common source of buyer dissatisfaction.
- **Recommend realistic range**: For daily commute + buffer, use 70% of EPA
  rating as the planning number.

## Tax Credits & Incentives

- **Federal tax credit**: Up to $7,500 for qualifying new EVs. Eligibility
  rules: vehicle must be assembled in North America, battery components/sourcing
  thresholds apply, buyer income limits ($300k MFJ / $150k single), MSRP caps
  ($55k sedan / $80k SUV/truck/van). Used EVs qualify for up to $4,000 (income
  limits $75k single / $150k MFJ, price cap $25k).
- **State incentives**: Vary widely — rebates, tax credits, reduced
  registration fees, HOV lane access. Check the state's clean vehicle program.
- **Lease loophole**: Leased EVs qualify for the full $7,500 commercial credit
  regardless of sourcing/income rules, often passed to the lessee as a
  capitalized cost reduction.

## Software & Update Horizon

- **Software update support**: Manufacturers support OTA updates for a limited
  period. Tesla: 5–7 years. Most others: 3–5 years. After support ends, the
  infotainment/charging systems become frozen and may lose compatibility with
  new charging networks or apps.
- **Connected services**: Subscription fees for navigation, remote climate,
  charging network access may apply after a free trial period.

## Output Format Example

```text
EV/PHEV Constraints:
- Charging: Level 2 install $1,200 est (panel has 60A spare)
- Battery SOH: 92% (OBD2 scan) — healthy, above 70% threshold
- Range: EPA 258 mi → plan on ~180 mi (70% for cold weather)
- Warranty: 8yr/100k mi battery — transferable, expires 03/2027
- Federal credit: Not eligible (assembled outside N. America)
- State incentive: $2,500 rebate (income-qualified)
- Software support: OTA through ~2028 (manufacturer estimate)
⚠️ Verify panel capacity with electrician before purchase
```

<!-- vim: set ft=markdown -->
