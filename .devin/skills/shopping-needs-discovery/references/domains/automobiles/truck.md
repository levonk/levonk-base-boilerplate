# Truck Constraints — Sub-Domain

Constraints specific to pickup trucks. Load in addition to `index.md` when the
user is buying a truck (Ford F-150, Ram 1500, Chevy Silverado, Toyota Tacoma,
etc.) and intends to use it for payload, towing, or work. Trucks have capacity
ratings, drivetrain options, and configurations that passenger cars do not.

## Payload Capacity

- **Payload = GVWR − curb weight**. The payload rating is the maximum weight
  the truck can carry in the bed and cabin (passengers + cargo). Check the
  Tire and Loading sticker on the driver's door jamb — this is the
  authoritative number, not the brochure.
- **GVWR (Gross Vehicle Weight Rating)**: The maximum the truck can weigh
  fully loaded, including the truck itself, passengers, cargo, fuel, and
  tongue weight from a trailer.
- **Payload is often the limiting factor**, not towing capacity. A "half-ton"
  truck often has only 1,000–1,800 lbs of payload. Add a driver, passenger,
  and a bed full of gravel and you may exceed payload before filling the bed.

## Towing Capacity

- **GCWR (Gross Combined Weight Rating)**: The maximum total weight of truck +
  trailer + everything in both. Towing capacity = GCWR − curb weight (truck).
- **Tongue weight**: Should be 10–15% of the loaded trailer weight for a
  conventional trailer. Too little tongue weight causes trailer sway; too much
  overloads the rear axle and reduces front steering/braking.
- **Weight-distribution hitch**: Required above ~5,000 lbs trailer weight.
  Distributes tongue weight across front and rear axles. Without it, the rear
  squats and the front lifts, reducing steering and braking control.
- **Trailer brake controller**: Required for trailers with electric brakes
  (most trailers over 3,000 lbs GVWR). Integrated controllers are available on
  some trucks; aftermarket units cost $200–$400 installed.

| Rating | What it means | Where to find it |
|--------|--------------|-----------------|
| GVWR | Max loaded truck weight | Door jamb sticker |
| GCWR | Max truck + trailer combined | Owner's manual / towing guide |
| Payload | Max cargo in bed + cabin | Door jamb sticker |
| Tow rating | Max trailer weight | Owner's manual / towing guide |
| Axle ratings (GAWR) | Max weight per axle | Door jamb sticker |

## Diesel vs Gas

| Factor | Gas | Diesel |
|--------|-----|--------|
| Upfront premium | — | $8,000–$12,000 |
| Fuel economy (towing) | Lower | 20–40% better |
| Fuel economy (empty) | Similar or better | Better on highway |
| Maintenance | Standard | DEF fluid, DPF cleaning, more frequent oil changes |
| Longevity | 150k–250k mi typical | 300k–500k mi typical |
| Major failure cost | Lower | Fuel injector failure: $4,000–$8,000 |

- **DEF (Diesel Exhaust Fluid)**: Required for all modern diesels. Must be
  refilled periodically (every 3k–10k mi depending on driving). Running out
  triggers limp mode.
- **DPF (Diesel Particulate Filter)**: Requires periodic regeneration (highway
  driving). Short-trip-only driving clogs the DPF — expensive cleaning or
  replacement ($2k–$4k).
- **Diesel makes sense when**: towing frequently, high annual mileage
  (20k+/yr), or keeping the truck 10+ years. Otherwise the premium doesn't
  pay back.

## Bed Length & Configuration

| Bed length | Typical use | Notes |
|-----------|-------------|-------|
| Short (5.5 ft) | Daily driving, light cargo | Most common on crew cabs; limits sheet goods |
| Standard (6.5 ft) | General use | Fits most needs; can carry plywood flat |
| Long (8 ft) | Work, construction | Full sheet goods flat; less common on crew cabs |

- **Sheet goods**: Plywood/drywall is 4×8 ft. Only a 6.5+ ft bed with tailgate
  down or an 8 ft bed carries them flat.

## Cab Configurations

| Cab type | Seating | Wheelbase | Notes |
|----------|---------|-----------|-------|
| Regular (2-door) | 2–3 | Shortest | Best payload/bed length; rare in market |
| Extended | 4–5 (small rear) | Medium | Occasional rear seat use |
| Crew | 5–6 (full rear) | Longest | Most popular; reduces bed length options |

## Payload vs Towing Trade-off

- **You cannot max both simultaneously.** Towing capacity assumes the truck is
  empty except for a driver (~150 lbs). Every pound of payload (passengers,
  cargo, hitch) reduces available towing capacity by the same amount.
- **Tongue weight counts against payload.** A 10,000 lb trailer at 12% tongue
  weight = 1,200 lbs of payload consumed. If payload is 1,500 lbs, only 300 lbs
  remains for passengers and cargo.

## Output Format Example

```text
Truck Constraints:
- Payload: 1,520 lbs (door jamb sticker)
  - Driver + 1 passenger: 350 lbs
  - Available for cargo/tongue: 1,170 lbs
- Tow rating: 11,300 lbs (GCWR 17,000 lbs)
  - With 2 passengers + gear (500 lbs payload): effective tow ~10,800 lbs
  - Weight-distribution hitch required above 5,000 lbs
- Trailer brake controller: Integrated (factory)
- Engine: 5.0L gas — no DEF/DPF maintenance
- Bed: 6.5 ft standard — carries plywood flat (tailgate down)
- Cab: Crew — 5-passenger, wheelbase 145"
⚠️ Verify payload meets needs — payload is the limiting factor, not tow rating
```

<!-- vim: set ft=markdown -->
