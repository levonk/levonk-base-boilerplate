# Replacement Part Identification — Reference

Detailed guidance for identifying whether the user needs a specific replacement
part versus a whole new product, and how to find the exact manufacturer part
number. Referenced by `SKILL.md` section "2.6. Replacement Part vs Full Product".

## When to Trigger Part Identification

Trigger when the user describes any of these scenarios:

- A broken or malfunctioning item they already own
- A specific component that failed (screen, battery, hinge, keyboard, motor,
  pump, board, belt, seal, filter, heating element)
- A repair need where they're deciding between "fix it" and "replace the whole
  thing"
- A request that mentions a product model + a symptom (e.g., "my Lenovo X1
  Carbon screen is cracked", "my Dyson V11 isn't charging")

Do NOT trigger when the user is shopping for a whole new product with no
existing item to repair, or when the effort tier is Quick and the item is
inexpensive enough that repair doesn't make economic sense (e.g., a $15
toaster).

## Part vs Full Product Decision

```text
| Factor | Leans toward part | Leans toward full product |
|--------|-------------------|---------------------------|
| Item age | Under 60% of expected lifespan | Near or past expected lifespan |
| Part cost vs replacement | < 40% of replacement cost | > 50% of replacement cost |
| User skill / tools | Has tools or willing to DIY | No tools, would hire out |
| Availability of part | Part is findable | Part is discontinued / NLA |
| Multiple failures | Single component failed | Several things wrong at once |
| Warranty | Item still under warranty | Out of warranty |
| Data / setup cost | High (configured laptop, calibrated tool) | Low (commodity item) |
```

When the decision leans toward **part**, proceed to the repairability check
below. When it leans toward **full product**, continue with the standard
product workflow — but still note the broken item so deal-intelligence can
check if a part would have been cheaper (useful for future reference).

## Repair Cost vs Replacement Cost Check

Even when a part is available and the component is replaceable, **repair may
not be economically viable**. Compare the total repair cost against the cost
of buying a working replacement (used or new) before recommending the part.

### Total Repair Cost Calculation

```
Total repair cost = Part price + Shipping + Tools/materials + Labor time × User's hourly value + Risk of failure
```

Where:
- **Part price + shipping**: From part-number sourcing (see
  `deal-intelligence/references/part-number-research.md`)
- **Tools/materials**: Any tools the user doesn't already own (e.g., a
  heat gun for phone screen replacement, a torque wrench for automotive
  work, adhesive strips, thermal paste)
- **Labor time × user's hourly value**: Estimate the repair time from
  iFixit guides or YouTube tutorials. Multiply by the user's
  self-reported hourly value (or a default of $25–$50/hour if not
  specified). A 3-hour repair at $40/hour is $120 of time.
- **Risk of failure**: If the repair has a meaningful chance of failing
  (damaging the device further, part doesn't work, user can't complete
  it), add the expected cost of failure. A 20% chance of bricking a $500
  device is $100 of risk.

### Comparison

```text
| Option | Cost | Time | Risk | Total (cost + time + risk) |
|--------|------|------|------|---------------------------|
| Buy part + DIY repair | $X part + $Y tools | Z hours × $W/hr | R% failure risk | $Total |
| Buy part + professional repair | $X part + $Y labor | 0 hours | Low | $Total |
| Buy working used replacement | $Z | 0 hours | Low (verify condition) | $Z |
| Buy new replacement | $N | 0 hours | Lowest | $N |
```

### When Repair Is a Bad Idea

Recommend **against** repair and toward buying a working replacement when:

- **Part + labor > working used replacement**: If the part costs $80 and
  professional installation is $100, but a working used unit costs $120 on
  eBay, buy the used unit. You get a working device faster, with less risk,
  and often a warranty.
- **Part + DIY time > working used replacement**: If the part is $40 but
  the repair takes 4 hours ($160 of time at $40/hr), and a working used
  unit is $100, the user's time makes repair more expensive than
  replacement.
- **Multiple parts failing**: If more than one component needs
  replacement, the combined cost often exceeds buying a working unit.
- **Device is near end of support life**: If the device will stop
  receiving OS/security updates within a year, spending money on repairs
  extends the life of a device that's about to become a security risk
  anyway (see `references/constraint-checklist.md` — Obsolescence &
  Lifecycle Risks). Better to put the repair budget toward a replacement
  that will be supported longer.
- **Repair has high failure risk**: If the repair has a > 25% chance of
  failing (complex microsoldering, glued glass removal, BGA reflow),
  the expected cost of failure may exceed the savings.

### Output: Repair vs Replacement Recommendation

Include in the Needs Discovery Brief:

```markdown
### Repair vs Replacement Analysis
- Part cost: $X (from [supplier])
- Tools needed: [list, $Y if not already owned]
- Labor: [Z hours DIY / $W professional]
- Risk of failure: [Low / Medium / High — R%]
- Total repair cost: $Total
- Working used replacement: $Z ([condition, source])
- New replacement: $N
- Recommendation: [Repair / Buy used replacement / Buy new replacement]
- Reason: [e.g., "Part + labor ($180) exceeds working used unit ($120)"]
```

## Repairability & Replaceability Check

**Before researching a part number**, verify that the failed component is
actually user-replaceable. Some modern devices have components that are
soldered, glued, cryptographically paired, or software-locked to the original
unit — buying the part is wasted money because it cannot be installed or will
not function.

### Components That Are Often Not User-Replaceable

| Category | Examples | Why it's locked |
|----------|----------|-----------------|
| **Soldered RAM** | Apple silicon Macs (M1/M2/M3/M4 — all RAM is unified memory on the SoC), most ultrabooks (Dell XPS 13, Surface Laptop, many Chromebooks) | RAM is soldered to the logic board or integrated into the SoC |
| **Soldered SSDs** | Apple silicon Macs (M1/M2/M3/M4 — SSD is on-package or soldered), Surface Pro, some Dell XPS | Storage is soldered; no M.2/NVMe slot |
| **Cryptographic pairing** | Apple silicon Macs (Touch ID, Face ID, display assembly, logic board, battery, trackpad, keyboard, top case) | Components are cryptographically paired to the SoC at the factory; swapping a genuine part from another unit causes a boot loop or disabled functionality unless re-paired via Apple's proprietary Service Configuration tool |
| **Glued batteries** | Many modern laptops, phones, tablets | Battery is glued in; removal risks damaging the chassis or other components |
| **Riveted keyboards** | MacBook Pro (2016–2019 butterfly, some post-2020) | Keyboard is riveted into the top case assembly; replacing the keyboard means replacing the entire top case (display, trackpad, battery often bundled) |
| **Software-locked components** | Some printers (cartridge DRM), some laptops (BIOS whitelist for Wi-Fi cards), John Deere tractors (ECU pairing) | Manufacturer firmware refuses to recognize non-paired replacement parts |
| **Paired display assemblies** | iPhone 13+ (Face ID + display paired), Samsung Galaxy (fingerprint sensor + display paired) | Display swap disables biometric authentication without manufacturer re-calibration |

### How to Check Repairability

1. **Search iFixit** for the device model — iFixit assigns a repairability
   score (1–10) and lists which components are replaceable and which are not.
   Their teardown guides note soldered, glued, or paired components.
2. **Search the manufacturer's service manual** — if the manual shows a
   removal procedure for the component, it's replaceable. If the component
   only appears as part of a larger assembly (e.g., "logic board assembly"
   that includes RAM and SSD), it's not independently replaceable.
3. **Check for cryptographic pairing warnings** — search
   `<model> <component> pairing OR locked OR serialized` on Google and
   Reddit. Apple's components, in particular, are widely documented.
4. **Check manufacturer self-service programs** — Apple, Samsung, Google, and
   Valve now offer self-service repair programs with official parts and
   manuals. If a part is available through the official program, it's
   replaceable (though some still require a pairing/re-calibration step via
   the manufacturer's software tool).

### When the Part Is Not Replaceable

If the repairability check reveals the component cannot be user-replaced:

1. **Warn the user explicitly** — do not proceed with part-number research.
   Deliver the warning in the Needs Discovery Brief (format below).
2. **Present alternatives**:
   - **Authorized repair** — manufacturer or authorized service provider can
     replace the part (they have the pairing tools). Note the typical cost.
   - **Independent repair** — some independent shops have access to pairing
     tools (e.g., Apple's Independent Repair Provider Program). Note that
     not all independent shops can re-pair all components.
   - **Full device replacement** — if repair cost approaches replacement
     cost, recommend replacing the whole device.
   - **Right-to-repair workarounds** — for some paired components,
     community-developed tools exist (e.g., ASTROFP for Apple display
     re-pairing). Note these as "advanced, may void warranty, may not work
     on all firmware versions" — do not recommend them as primary options.

### Repairability Warning Output Format

When a part is not user-replaceable, include this in the Needs Discovery
Brief instead of the `Replacement Part` section:

```markdown
### Repairability Warning
- Device: [exact model number]
- Failed component: [e.g., SSD, RAM, display assembly]
- Replaceable: No — [reason: soldered / cryptographic pairing / glued / software-locked]
- Source: [iFixit teardown, service manual, forum report]
- Authorized repair cost estimate: $X–$Y
- Independent repair options: [if available, with caveats]
- Full device replacement cost: $Z
- Recommendation: [Authorized repair / Replace device / Community workaround (advanced)]
- ⚠️ Note: Buying the part separately will not work — the component is
  [soldered / paired / locked] and cannot be installed or will not function
  without manufacturer re-pairing tools.
```

## Finding the Manufacturer Part Number

The part number is the key to cheaper sourcing. Searching "laptop model XYZ
screen replacement" surfaces pre-packaged repair kits and model-specific
listings with a convenience markup. Searching the actual panel part number
(e.g., `LP140QH1-SPB1`) surfaces the raw OEM panel from multiple suppliers at
a fraction of the cost.

### Part Number Sources (ranked by reliability)

| Source | What it provides | How to use |
|--------|-----------------|------------|
| Manufacturer service manual | Exploded diagrams with part numbers | Search `<brand> <model> service manual PDF`; often free on manufacturer support sites |
| [iFixit](https://www.ifixit.com/) | Teardown guides with part identification | Search the device model; guides name the specific part and sometimes the part number |
| Manufacturer parts store | Official part numbers and diagrams | Apple, Dell, HP, Lenovo, Samsung, Whirlpool, GE all have parts portals |
| Parts diagram / parts list sites | Exploded views with numbered callouts | [PartSelect](https://www.partselect.com/) (appliances), [eReplacementParts](https://www.ereplacementparts.com/) (power tools), [Sears PartsDirect](https://www.searspartsdirect.com/) (many brands) |
| Device label / engraving | Part number printed on the component itself | Open the device and read the label on the actual part — most reliable for screens, batteries, boards, motors |
| FCC ID lookup | Internal component IDs for electronics | [FCCID.io](https://fccid.io/) — search the device's FCC ID, internal photos often show component labels |
| Forum / Reddit communities | Crowd-sourced part numbers | Search `<model> <component> part number` on Reddit, Badcaps, NotebookReview forums |

### Part Number Identification Workflow

0. **Run the repairability check above.** If the component is not
   user-replaceable, stop — deliver the repairability warning and do not
   proceed with part-number research.
1. **Get the exact device model number** — not the marketing name. "MacBook
   Pro 14" is the marketing name; `A2442` or `MDXG3LL/A` is the model number.
   Find it on the device label, in system settings, or on the original
   receipt.
2. **Find the service manual or parts diagram** for that model number.
3. **Identify the specific component** in the diagram and read its part
   number. If no diagram is available, search for teardown guides (iFixit,
   YouTube) that show the component and its label.
4. **Verify the part number** by cross-referencing it against at least one
   other source (manufacturer parts store, parts reseller, forum post).
5. **Note cross-brand equivalents** — the same OEM part is often sold under
   multiple brand labels at different prices. See
   `deal-intelligence/references/part-number-research.md` for the cross-brand
   equivalence research that happens during pricing.

### Common Part Number Formats

| Category | Format example | Where to look |
|----------|---------------|---------------|
| Laptop screens | `LP140QH1-SPB1`, `B140HAN05.7` | Label on back of panel (requires opening bezel) |
| Laptop batteries | `BQ20Z45`, `L16M2PF2` | Label on battery cell |
| Phone screens | `661-NNNN` (Apple), `GH97-NNNNN` (Samsung) | Service manual or parts store |
| Appliance parts | `W10856621`, `PS11741425` (Whirlpool) | Parts diagram on PartSelect / Sears PartsDirect |
| Power tool parts | `N074465`, `1619P08961` | eReplacementParts diagram |
| Automotive parts | OEM: `31206-PLC-005`; aftermarket: `APT-1234` | Dealer parts dept, [RockAuto](https://www.rockauto.com/), [Partsouq](https://www.partsouq.com/) |

## Output: Part Number in the Needs Discovery Brief

When part identification succeeds, add a `Replacement Part` section to the
Needs Discovery Brief so deal-intelligence can search by part number instead
of model number:

```markdown
### Replacement Part
- Device model: [exact model number, e.g., Lenovo ThinkPad X1 Carbon Gen 9 — 20XWCTO1WW]
- Failed component: [e.g., display panel]
- Manufacturer part number: [e.g., LP140QH1-SPB1]
- Part number verified via: [source, e.g., iFixit teardown + label on panel]
- Cross-brand equivalents to investigate: [if known, e.g., "same panel rebranded as Innolux N140HCG-GQ2"]
- Part-only cost estimate: $X–$Y
- Full replacement cost estimate: $Z
- Repair recommendation: [Part is economically viable / Replace whole device instead]
```

When part identification fails (part is NLA, can't find the number, or part
cost is too close to replacement), omit this section and proceed with the
standard product workflow.

<!-- vim: set ft=markdown -->
