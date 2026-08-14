# Hybrid Constraints — Sub-Domain

Constraints specific to traditional (non-plug-in) hybrid vehicles. Load in
addition to `index.md` when the user is buying a hybrid like a Toyota Prius,
Honda Accord Hybrid, or Ford Maverick Hybrid. These vehicles have hybrid
systems (battery + electric motor + gas engine) but cannot be plugged in to
charge — the battery is charged by regenerative braking and the engine.

PHEVs (plug-in hybrids) have different constraints — see `ev-phev.md` instead.

## Battery Longevity

| Battery type | Typical life | Replacement cost | Common in |
|-------------|-------------|------------------|-----------|
| NiMH (nickel-metal hydride) | 8–15 years | $1,000–$3,000 | Older Toyota hybrids, many hybrids through ~2015 |
| Li-ion (lithium-ion) | 10–15 years | $1,500–$3,000 | Newer hybrids (2015+), most current models |

- **Battery degradation is gradual**: Unlike a sudden failure, hybrid batteries
  lose capacity slowly. Symptoms: reduced fuel economy, frequent engine
  cycling, reduced electric-only mode duration.
- **Replacement is not catastrophic**: At $1k–$3k, hybrid battery replacement
  is far cheaper than EV battery replacement ($5k–$20k). A used hybrid near
  battery end-of-life can still be a good buy if the replacement cost is
  factored into the price.
- **Refurbished packs**: Third-party refurbished battery packs cost 30–50%
  less than OEM and are a viable option for older hybrids.

## Regenerative Braking System

- **Brake fluid absorbs moisture**: Hybrid brake systems use regenerative
  braking (the motor slows the car and recovers energy), so the friction brakes
  are used less. This means brake fluid is not cycled as hard and can absorb
  moisture over time, leading to corrosion in the brake actuator/pump. Replace
  brake fluid every 2–3 years (more frequent than conventional cars).
- **Brake actuator failure**: The electronically controlled brake actuator
  (booster) is a known failure point on some Toyota hybrids. Symptoms: hard
  brake pedal, warning lights. Replacement: $1,500–$3,000. Check for recall or
  TSB coverage.
- **Rusted rotors**: Because friction brakes are used lightly, rotors can rust
  and pit from disuse, especially in humid/salt climates. Inspect during PPI.

## Inverter / Converter Failure

- **Inverter/converter**: The DC-DC converter (replaces the alternator) and
  inverter (drives the electric motor) are high-voltage components. Failure is
  expensive: $2,000–$5,000 including labor.
- **Known issues**: Some Toyota Prius models (2010–2014) had inverter coolant
  pump failures leading to inverter failure. Check for recall/TSB coverage and
  verify the pump was replaced.
- **Warranty coverage**: Hybrid system components (inverter, converter, battery)
  are typically covered under the hybrid warranty, not the powertrain warranty.

## CVT Transmission Issues

- **eCVT vs CVT**: Toyota hybrids use an eCVT (planetary gear set, no belts) —
  very reliable. Some other hybrids use a belt-driven CVT, which can have
  failure issues.
- **Toyota eCVT**: Generally trouble-free. Fluid changes recommended every
  60k miles but failures are rare.
- **Belt CVT (non-Toyota)**: Some Nissan/Hybrid CVTs have higher failure rates.
  Check model-specific reliability. CVT fluid changes are critical — neglect
  leads to failure.

## Fuel Economy

- **Real-world vs EPA**: Hybrid fuel economy is more sensitive to driving
  style than conventional cars. City driving benefits most (regenerative
  braking). Highway driving at 70+ mph reduces the hybrid advantage — the
  engine runs continuously and the hybrid system adds weight.
- **Winter fuel economy**: Drops 15–30% in cold weather (engine runs more to
  keep warm, battery less efficient, winter blend fuel).
- **EPA vs real-world gap**: Typically 5–15% lower than EPA in mixed driving.

## Hybrid System Warranty

| Coverage | Typical | CA states (CARB) |
|----------|---------|------------------|
| Hybrid battery + system | 8 yr / 100,000 mi | 10 yr / 150,000 mi |
| Powertrain (engine/trans) | 5 yr / 60,000 mi | 5 yr / 60,000 mi |

- **CARB states**: California, Colorado, Connecticut, Maine, Maryland,
  Massachusetts, New Jersey, New York, Oregon, Rhode Island, Vermont,
  Washington. The 10yr/150k mi warranty applies to new hybrids sold in these
  states.
- **Verify transferability**: Some hybrid warranties transfer to subsequent
  owners; some do not. This significantly affects used hybrid value.

## Output Format Example

```text
Hybrid Constraints:
- Battery: NiMH, 11 years old — nearing end-of-life window
  - Replacement estimate: $2,000 (OEM) / $1,200 (refurbished)
  - Factor into offer price
- Brake fluid: Last service unknown — recommend flush ($150)
- Inverter: Coolant pump recall completed (verified via VIN)
- CVT: eCVT (Toyota planetary) — low risk
- Fuel economy: EPA 50 mpg → expect 42–45 mpg real-world
- Warranty: 8yr/100k expired; no remaining hybrid coverage
⚠️ Budget $2k for battery replacement within 2–3 years
```

<!-- vim: set ft=markdown -->
