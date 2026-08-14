# Cameras — Domain Reference

Domain-specific constraints for cameras: DSLR, mirrorless, compact, and
action cameras. Referenced by `references/constraint-attributes.md`. Load
when the user is buying a camera or camera system. Cameras are a system
purchase — the lens ecosystem matters as much as the body. Sensor size,
mount compatibility, and repairability drive long-term value; the used
market is large but requires careful inspection.

## Camera Types

| Type | Viewfinder | Format status | Best for | Used value |
|------|-----------|---------------|----------|------------|
| DSLR | Optical (OVF) | Dying — few new models | Budget full-frame, sports | Excellent — steep depreciation |
| Mirrorless | Electronic (EVF) | Dominant new format | Most users, video, travel | Good — still depreciating |
| Compact | None or EVF | Niche — premium only | Pocketable, street, travel | Holds value if 1-inch+ sensor |
| Action | None | Active | Rugged, waterproof, sports | Poor — rapid model turnover |

**DSLR**: Optical viewfinder, mirror, large legacy lens selection. Dying
format — Canon and Sony stopped new DSLR development. Good used value.
**Mirrorless**: Dominant new format. EVF, smaller/lighter, superior video.
**Compact**: Fixed lens, pocketable. Premium compacts with 1-inch+ sensors
(Sony RX100, Ricoh GR) remain viable; low-end obsolete. **Action**: Rugged,
waterproof, wide-angle fixed (GoPro, DJI Action). Not general-purpose.

## Sensor Size

Bigger sensor = better low-light, shallower depth of field, wider dynamic
range. Trade-off: larger body, lenses, cost. **Hierarchy**: 1-inch < Micro
4/3 < APS-C < full-frame < medium format — each step roughly doubles sensor
area and low-light capability.

| Sensor | Crop factor | Typical use | Low-light |
|--------|------------|-------------|-----------|
| 1-inch | 2.7x | Compact, entry | Moderate |
| Micro 4/3 | 2.0x | Travel, video | Good |
| APS-C | 1.5–1.6x | Enthusiast, budget | Good |
| Full-frame | 1.0x | Professional, low-light | Excellent |
| Medium format | 0.64–0.79x | Studio, landscape | Exceptional |

## Lens Ecosystem

**Before committing to a mount, check available lenses and prices.** The
body is a consumable; lenses are the long-term investment.

| Mount | Brand | Lens selection | Third-party support |
|-------|-------|---------------|---------------------|
| Sony E | Sony | Excellent (FF + APS-C) | Sigma, Tamron, Tokina |
| Canon RF | Canon | Growing (RF locked down) | Limited |
| Nikon Z | Nikon | Growing | Viltrox, Tamron (increasing) |
| Fuji X | Fujifilm | Excellent (APS-C) | Sigma, Tamron, Viltrox |
| Micro 4/3 | OM System/Panasonic | Largest (shared mount) | Many third-party |
| Canon EF (DSLR) | Canon | Vast, cheap used | Sigma, Tamron, Tokina |
| Nikon F (DSLR) | Nikon | Vast, cheap used | Sigma, Tamron, Tokina |

## Used Camera Checks

| Check | What to look for | Red flags |
|-------|-----------------|-----------|
| Shutter count | DSLR rated 100k–500k actuations | >80% of rated life |
| Sensor | Dust (cleanable), scratches (permanent) | Scratches, persistent dust |
| Lens fungus | Open aperture, shine light through | Hazy, web-like growth |
| Battery health | Charge cycles, hold time | Won't hold charge, swollen |
| Firmware | Check manufacturer site for updates | Abandoned (no updates in 3+ yr) |

**Shutter count**: DSLRs have mechanical shutters rated 100k–500k. Mirrorless
uses electronic shutters more often (count less relevant). Tools:
shuttercount.com, EXIF readers.
## Weather Sealing

| Rating | Meaning | Use case |
|--------|---------|----------|
| IP rating (e.g., IP53) | Ingress protection certified | Rain, dust (limited) |
| Manufacturer claim | "Weather-resistant" / "sealed" | Light rain — not guaranteed |
| None | No sealing | Fair-weather only |

Matters for outdoor/travel/landscape. Premium bodies (Sony a7/a9, Canon
R5/R6, Nikon Z8, Olympus/OM) seal best; entry-level have none. Sealing
degrades over time — used bodies may have compromised gaskets.

## Video Specs

| Spec | What it means | Why it matters |
|------|--------------|----------------|
| Resolution | 4K / 6K / 8K | 4K standard; 6K/8K for professional |
| Frame rate | 24/30/60/120/240 fps | Slow-motion needs 60+ fps |
| Bit rate | 50–400 Mbps | Higher = less compression, better quality |
| Log profiles | S-Log, C-Log, N-Log | Flat profile for color grading (pro) |
| Rolling shutter | Sensor readout speed | Fast readout = less skew in motion |

**For video-focused buyers**: Check overheating limits (some shut down after
15–30 min of 4K), recording time limits (some capped at 29:59 for tax
reasons), and external recording support (HDMI out for raw/ProRes).

## Memory Cards

| Card type | Speed | Use case |
|-----------|-------|----------|
| SD UHS-I | 100 MB/s | Photos, basic 4K |
| SD UHS-II | 250–300 MB/s | High-res burst, 4K video |
| CFexpress Type A | 700 MB/s | Sony high-speed bodies |
| CFexpress Type B | 1000–1700 MB/s | Canon R5/R6, Nikon Z8/Z9 |
| XQD | 400–500 MB/s | Older Nikon pro bodies (legacy) |

**Fast cards are required** for high-res video (4K60+, 8K) and high-speed
burst. A slow card causes buffer jams and dropped frames. Some bodies have
dual slots (SD + CFexpress).

## Repairability

- **Manufacturer service**: Canon, Nikon, Sony have authorized service
  centers. Check if the model is still supported (parts for bodies >7 years
  old are often discontinued).
- **Third-party repair**: Independent shops can service older bodies — but
  parts availability limits what they can fix.
- **DIY**: Limited. Sensor cleaning is DIY-able; shutter replacement
  requires specialized tools. DSLRs (Canon 5D, Nikon D700) have strong parts
  availability; early mirrorless (2010s) may not.

<!-- vim: set ft=markdown -->
