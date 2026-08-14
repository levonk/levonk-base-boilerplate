# Exotic & Sports Car Constraints — Sub-Domain

Constraints specific to exotic cars, supercars, and high-end sports cars. Load
in addition to `index.md` when the user is buying a Ferrari, Lamborghini,
Porsche 911/GT cars, McLaren, Aston Martin, Lotus, or similar. These vehicles
have maintenance, parts, insurance, and ownership dynamics that differ
dramatically from mass-market cars.

## Mechanic & Service

- **Specialist required**: General mechanics cannot service exotics. Use the
  dealership or an independent specialist (e.g., for Porsche: a shop like
  Rennsport or similar marque specialist). Labor rates: $150–$300/hour.
- **PPI by specialist**: A standard $100–$300 PPI is insufficient. A specialist
  PPI costs $300–$800 and includes compression/leak-down tests, clutch
  measurement, ECU scan for over-revs, and suspension/brake inspection. Never
  skip this on an exotic.
- **ECU data**: For high-performance cars (especially Porsche GT cars,
  Ferraris), pull ECU data to check for over-rev events. Excessive over-revs
  indicate abuse and can void warranty / indicate engine damage risk.

## Parts Availability

| Situation | Impact | Mitigation |
|-----------|--------|------------|
| Parts in stock | Normal timeline | — |
| Special order | 4–12 weeks lead time | Plan downtime; negotiate price with lead time |
| Discontinued (NLA) | Custom fabrication required | Budget $2k–$10k+ for one-off parts |

- **Discontinued parts**: For older exotics (15+ years), some parts are no
  longer available from the manufacturer. Solutions: aftermarket reproductions,
  used parts from salvage, or custom fabrication. This can make a "cheap"
  exotic very expensive to maintain.
- **Body panels and trim**: Often the most expensive and hardest-to-source
  parts. A minor fender-bender can cost $10k–$30k+.

## Maintenance Costs

| Service type | Typical cost | Frequency |
|-------------|-------------|-----------|
| Annual / minor service | $3,000–$15,000 | Every 1 year or 7,500–10,000 mi |
| Major service (belt, clutch, valves) | $5,000–$25,000 | Every 3–5 years or 15k–30k mi |
| Brake job (rotors + pads) | $3,000–$10,000 | Every 20k–40k mi |
| Clutch replacement | $3,000–$15,000 | Every 15k–40k mi (depends on driving) |

- **Clutch replacement**: Exotic clutches (especially dual-clutch
  transmissions) are expensive. Ferrari F1/DCF clutches: $5k–$12k. Porsche PDK
  clutch: $4k–$8k. Manual clutches: $3k–$6k. Check clutch wear during PPI.
- **Tires**: Exotic tires (e.g., Michelin Pilot Sport Cup 2) cost $400–$800
  each and last 10k–20k miles. Budget $2k–$4k per set.

## Insurance

- **Specialty insurers**: Use Hagerty, Grundy, or similar — not standard auto
  insurers. They understand exotics and offer better terms.
- **Agreed value vs stated value**:

  | Policy type | Payout | Use when |
  |-------------|--------|----------|
  | Agreed value | Full agreed amount, no depreciation | Always preferred for exotics |
  | Stated value | Up to stated amount, subject to adjustment | Less desirable; insurer can pay less |

- **Mileage limits**: Specialty policies often cap annual mileage (e.g., 2,500–
  5,000 mi/year). Unlimited mileage policies cost more. Verify the limit fits
  the user's intended use.
- **Track day exclusion**: Most policies exclude track use. Separate track
  insurance is available but expensive.

## Depreciation

- **Most exotics depreciate 40–70% over 10 years**, similar to luxury cars but
  on a larger absolute scale.
- **Appreciation exceptions**: Limited-production models (e.g., Porsche 911 R,
  GT3 RS, certain Ferraris) can appreciate. These are the exception, not the
  rule. Do not assume appreciation.
- **Salvage title impact**: A salvage/rebuilt title on an exotic destroys
  50–70% of the value and makes the car nearly impossible to insure with
  specialty carriers. Avoid salvage-title exotics unless the user is an expert
  willing to accept the risk.

## Storage

- **Climate-controlled storage**: Exotics require climate-controlled storage
  (50–70°F, 30–50% humidity) to preserve interior materials, prevent rubber
  degradation, and protect electronics. Cost: $100–$400/month.
- **Battery tender**: Exotics drain batteries quickly when sitting. A battery
  tender/maintainer is mandatory for any car that sits more than 2 weeks.
- **Rodent protection**: Long-term storage requires rodent prevention —
  rodents damage wiring (soy-based insulation).

## Output Format Example

```text
Exotic Constraints:
- PPI: Specialist inspection required ($500 est) — includes leak-down + over-rev scan
- Maintenance: Annual $4k, major service due in 8k mi ($8k est)
- Clutch: 60% remaining (PPI measurement) — budget $6k replacement in ~20k mi
- Tires: 40% remaining — budget $3k set in ~10k mi
- Insurance: Hagerty agreed value, $1,800/yr, 3,500 mi limit
- Parts: All current; no NLA concerns for this model year
- Storage: Climate-controlled $200/mo + battery tender
- Depreciation: Expect 50% loss over 10 years (non-limited model)
⚠️ Salvage title = avoid (50–70% value loss, uninsurable with specialty carriers)
```

<!-- vim: set ft=markdown -->
