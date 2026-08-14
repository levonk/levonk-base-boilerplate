# PSU, Case & Cooling — Sub-Domain Reference

Constraints specific to the power supply, case, and CPU cooling. Load when
the user is buying a PSU, case, or CPU cooler. For component power draws
and clearance requirements, also see `cpu-motherboard.md` and `gpu.md`.

A bad PSU can destroy every component in the system. A restrictive case
can starve components of air. An undersized cooler throttles the CPU.
These are the least glamorous parts but the most critical to get right.

## PSU Wattage

- Calculate total system draw + **30–50% headroom**. Headroom covers
  transient spikes and keeps the PSU in its efficient operating range.
- **Never run a PSU at >80% of rated capacity** — efficiency drops, heat
  rises, lifespan shortens.
- Use [PCPartPicker](https://pcpartpicker.com/) or
  [OuterVision](https://outervision.com/power-supply-calculator) to
  estimate system draw.

| System class | Typical draw | Recommended PSU |
|--------------|-------------|-----------------|
| Office (APU, no GPU) | 150–200 W | 400–500 W |
| Mid gaming (mid GPU) | 300–400 W | 550–650 W |
| High-end (RTX 4070/4080) | 450–600 W | 750–850 W |
| Enthusiast (RTX 4090) | 600–800 W | 1000 W |

## PSU Efficiency & Quality

| Rating | Efficiency @ 50% load | Recommendation |
|--------|----------------------|----------------|
| 80 Plus Bronze | ~85% | Minimum acceptable |
| 80 Plus Gold | ~90% | Recommended for most builds |
| 80 Plus Platinum | ~92% | High-end / always-on systems |
| 80 Plus Titanium | ~94% | Server / extreme efficiency |

Efficiency saves on electricity over years of use. A Gold PSU running 8
hours/day pays back the premium over a Bronze unit in 2–3 years.

- Use the **Cultists PSU Tier List** (community-maintained) to verify
  build quality and OEM origin.
- **Never buy unbranded or ultra-cheap PSUs** — a bad PSU can destroy every
  component. The PSU is the last place to cut corners.
- Japanese capacitors and full protection suite (see below) are markers of
  quality. Reviews from Gamers Nexus, TechPowerUp, and Tom's Hardware test
  these properly.

## Modular vs Non-Modular

| Type | Fixed cables | Use case |
|------|-------------|----------|
| Fully modular | None — all detachable | Best cable management; only connect what's needed |
| Semi-modular | CPU 8-pin + 24-pin fixed | Good balance; GPU/peripheral cables detachable |
| Non-modular | All fixed | Cheapest; messy cable management, fits poorly in small cases |

## PSU Protections & ATX Standard

Look for these protections in the spec sheet — quality units list all:

| Protection | What it does |
|-----------|--------------|
| OVP / UVP | Over/under-voltage protection |
| OCP / OPP | Over-current / over-power protection |
| SCP / OTP | Short-circuit / over-temperature protection |

A PSU missing any of these is a red flag.

- **ATX 3.0/3.1** supports the **12VHPWR connector** natively for RTX
  40-series and handles transient spikes better.
- Older **ATX 2.x** PSUs need an adapter (often bundled with the GPU) —
  works but adds cable bulk.

## Case Airflow & Clearance

- **Front intake + rear/top exhaust** is the standard airflow path.
- **Mesh front panels** breathe better than solid glass — a mesh front can
  drop component temps by 5–10°C vs a solid front.
- Check the **included fan count** — some cases ship with 2–3 fans, others
  with none. Budget for additional fans if needed.

Verify the case fits every component:

- **GPU length** — the #1 fit issue (see `gpu.md`)
- **CPU cooler height** — air cooler max height (mm)
- **Radiator support** — top/front, 240/280/360mm; check thickness limit
- **PSU length** — some cases limit PSU to 160mm; high-wattage units are
  often longer
- **Cable management space** — behind the motherboard tray; tight spaces
  make building painful

## Case Fan Configuration

| Pressure | Setup | Effect |
|----------|-------|--------|
| Positive | More intake than exhaust | Less dust buildup (air escapes through gaps) |
| Negative | More exhaust than intake | Better thermals but draws dust through gaps |
| Balanced | Equal intake/exhaust | Good all-around |

A typical setup is **2–3 intake + 1–2 exhaust**. Dust filters on intake
fans reduce maintenance.

## CPU Cooling & Thermal Paste

| Cooler type | Price | Lifespan | Notes |
|-------------|-------|----------|-------|
| Stock cooler | Included | — | Fine for 65W; loud under load |
| Air cooler | $20–100 | 5+ years | Reliable; quiet with good model; fan is only moving part |
| AIO liquid | $60–200 | 3–5 years | Better cooling; pump failure risk; check radiator fit |
| Custom loop | $300+ | Varies | Enthusiast only; highest maintenance |

- For AIOs, verify the **radiator fits the case** (see Case Airflow & Clearance).
- Air coolers are the reliability choice — a $10 fan replacement extends life
  indefinitely; an AIO pump failure requires full replacement.
- **Thermal paste**: pre-applied on stock and most air coolers. Aftermarket
  paste ($5–15) gives 2–5°C improvement; reapply every 2–3 years or when
  temps rise unexpectedly.

<!-- vim: set ft=markdown -->
