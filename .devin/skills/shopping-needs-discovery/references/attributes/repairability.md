# Repairability — Attribute Reference

Constraint attribute: applies when the item has components that could fail
and need repair or replacement. Referenced by
`references/constraint-attributes.md`.

This is a **pre-purchase consideration** — "when this breaks, can it be
fixed?" — distinct from `references/part-identification.md`, which covers
identifying a specific part for a specific repair already in progress.

## Why Repairability Matters at Purchase Time

A product that can't be repaired has a shorter effective lifespan and higher
total cost of ownership. A $1,500 laptop that can't be repaired when the
battery degrades in 3 years has a higher lifetime cost than a $1,800 laptop
that can be repaired for $100.

## How to Assess Repairability

1. **Check [iFixit](https://www.ifixit.com/)** for a repairability score
   (1–10) and teardown guide. The score considers: ease of opening, type of
   fasteners (screws vs adhesive), modularity of components, availability of
   replacement parts, and service manual availability.
2. **Check parts availability** — are replacement parts available from the
   manufacturer, third-party resellers, or eBay? A repairable device with no
   available parts is effectively unrepairable.
3. **Check service network** — does the manufacturer have authorized service
   centers in the user's area? Can independent shops repair it? Some
   manufacturers restrict parts to authorized servicers only.
4. **Check for parts pairing** — see the table below. Devices with paired
   components can only be repaired by authorized servicers with proprietary
   tools.

## Components That Are Often Not User-Replaceable

| Category | Examples | Why it's locked |
|----------|----------|-----------------|
| **Soldered RAM** | Apple silicon Macs (M1–M4), most ultrabooks (Dell XPS 13, Surface Laptop, many Chromebooks) | RAM is soldered or integrated into the SoC |
| **Soldered SSDs** | Apple silicon Macs, Surface Pro, some Dell XPS | Storage is soldered; no M.2/NVMe slot |
| **Cryptographic pairing** | Apple silicon Macs (Touch ID, Face ID, display, logic board, battery, trackpad, keyboard) | Components are paired to the SoC; swapping causes boot loop without Apple's Service Configuration tool |
| **Glued batteries** | Many modern laptops, phones, tablets | Battery is glued; removal risks damage |
| **Riveted keyboards** | MacBook Pro (2016–2019 butterfly, some post-2020) | Keyboard is riveted into top case; replacing keyboard = replacing entire top case |
| **Software-locked components** | Some printers (cartridge DRM), some laptops (BIOS whitelist for Wi-Fi cards), John Deere tractors | Firmware refuses non-paired parts |
| **Paired display assemblies** | iPhone 13+ (Face ID + display), Samsung Galaxy (fingerprint + display) | Display swap disables biometrics without re-calibration |

## Repairability Tiers

| Tier | iFixit score | Examples | Implication |
|------|-------------|----------|-------------|
| **Excellent** | 8–10 | Framework Laptop, Fairphone, ThinkPad X-series (pre-soldered RAM), desktop PCs | User can replace most components with a screwdriver |
| **Good** | 6–7 | Most ThinkPads, HP EliteBook, Dell Latitude | RAM, SSD, battery replaceable; some components require more effort |
| **Moderate** | 4–5 | MacBook Air (M-series), most phones | Battery and screen replaceable but require adhesive cutting and specialized tools |
| **Poor** | 1–3 | MacBook Pro (M-series), Surface Pro, most ultrabooks | Most components soldered or paired; professional repair only |
| **Unrepairable** | N/A | Apple silicon Macs (RAM/SSD), sealed devices | Components cannot be replaced at all |

## When Repairability Matters Most

- **Expected ownership > 3 years**: The longer you keep it, the more likely
  something fails
- **High item cost**: A $2,000 laptop repair bill hurts more than a $200 one
- **No local service center**: If the nearest authorized repair is 100+
  miles away, user-repairability is critical
- **Harsh environment**: Drops, spills, dust, temperature extremes increase
  failure probability
- **Battery-powered devices**: Batteries degrade; if the battery isn't
  replaceable, the device has a hard end-of-life

## When Repairability Matters Less

- **Expected ownership < 2 years**: Most things won't break in that window
- **Low item cost**: A $50 device isn't worth repairing
- **Commodity items**: Standard parts, cheap replacements, easy to swap
- **Manufacturer provides free replacement**: Some products have
  no-questions-asked replacement policies

## Cross-References

- For identifying a specific replacement part: see
  `references/part-identification.md`
- For obsolescence risks (software support horizon): see
  `attributes/obsolescence.md`
- For total cost of ownership (repair costs over time): see
  `attributes/total-cost-of-ownership.md`

<!-- vim: set ft=markdown -->
