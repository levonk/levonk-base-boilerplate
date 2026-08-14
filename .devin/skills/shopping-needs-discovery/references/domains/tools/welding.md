# Welding Tools — Constraints

What's unique to welding equipment purchases. For generic power/battery/safety guidance, see `index.md`.

## Process Selection

| Process | Price | Difficulty | Best For |
|---|---|---|---|
| MIG (GMAW) | $300-2000 | Easiest | Steel, aluminum, stainless — fastest deposition |
| TIG (GTAW) | $500-3000 | Hardest | All metals — highest quality, precise |
| Stick (SMAW) | $200-1000 | Moderate | Steel, cast iron — outdoor-tolerant, dirty metal OK |
| Flux-cored (FCAW) | $300-1500 | Easy | Outdoors, dirty metal — no gas needed |

## Duty Cycle

Percentage of a 10-minute period the welder can run at rated amperage.

- **60% @ 200A** = 6 min welding, 4 min cooling
- Higher duty cycle = more expensive but can weld longer without stopping
- Critical for production; less important for occasional repair

## Input Power

| Power | Max Output | Material | Notes |
|---|---|---|---|
| 120V | ~140A | 1/4" steel max | Household outlet — check circuit (15A/20A) |
| 240V | 180-300A+ | Thicker material | Needs dedicated circuit — confirm user has 240V available |

- Dual-voltage machines (120/240V) offer flexibility — confirm before recommending

## Gas Requirements

MIG and TIG need shielding gas — ongoing cost.

| Metal | Gas Mix | Notes |
|---|---|---|
| Steel | 75/25 Ar/CO2 | Most common MIG mix |
| Aluminum | Pure Ar | TIG and MIG |

- Tank rental: $50-100/yr + gas $30-80 per fill
- Tank size: 40-80 cf for hobby, 125+ cf for production

## Aluminum Welding

- MIG aluminum needs a **spool gun** ($100-300) — prevents wire birdnesting in long feed
- TIG aluminum requires **AC, not DC** — confirm machine supports AC/DC
- Aluminum dissipates heat fast — needs more amperage than steel of same thickness

## Safety

- **Auto-darkening helmet** $50-300 — check lens reaction time (1/10000 to 1/30000 sec), number of sensors (3-4 ideal)
- Leather gloves, jacket, apron — UV burns exposed skin ("arc flash" is like sunburn)
- Welding fumes toxic — **ventilation or fume extraction ($100-500) mandatory for indoor welding**
- Fire risk — remove flammables within 35 ft, fire extinguisher required and accessible

## Used Welder Checks

- Duty cycle performance (does it trip thermal overload as rated?)
- Wire feed smoothness (MIG) — check feed roller condition, no skipping
- HF start (TIG) — should start arc without touching tungsten
- Gas solenoid operation — should open/close cleanly, no leaks
- Foot pedal function (TIG) — smooth amperage ramp

## Output Format Example

```
PROCESS: MIG (easiest to learn, fastest for your steel projects)
POWER: 240V required — you confirmed dedicated circuit available
DUTY CYCLE: 60% @ 180A (sufficient for 3/8" steel, hobby use)
GAS: 75/25 Ar/CO2, 80 cf tank — $75/yr rental + $40/fill
SAFETY: auto-darkening helmet ($120, 1/20000 sec), leather jacket ($60)
USED OPTION: Hobart 190, $600 vs $900 new — wire feed smooth, solenoid OK
```

<!-- vim: set ft=markdown -->
