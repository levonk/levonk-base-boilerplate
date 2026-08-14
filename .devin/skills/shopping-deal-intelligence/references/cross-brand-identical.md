# Cross-Brand Identical Products — Reference

Detailed guidance for identifying when differently-branded products are the
same OEM product, and how to use that knowledge for cheaper sourcing.
Referenced by `SKILL.md` section "2.5. Cross-Brand Identical Products".

## The Brand Tax Problem

Many products are not manufactured by the brand on the label. The brand buys
the product (or a complete unit) from an OEM and rebrands it with their own
name, model number, and packaging — sometimes with cosmetic differences
(different bezel color, different included accessories) but the same internal
components, performance, and reliability. The price difference between the
OEM-branded version and the rebranded version can be 20–100% for the same
physical product.

**Examples:**

| OEM product | Also sold as | Same internals? | Typical price gap |
|-------------|-------------|-----------------|-------------------|
| NVIDIA DGX Spark | Acer GB10 AI Mini PC | Yes — same NVIDIA GB10 Grace Blackwell SoC, same reference design | Varies by channel |
| Whirlpool washing machine | Kenmore (Sears brand) | Yes — Kenmore is a rebrand; model number prefix reveals the OEM (110.x = Whirlpool, 665.x = KitchenAid/Whirlpool, 790.x = Frigidaire) | 10–30% |
| LG washing machine | Kenmore (799.x prefix) | Yes | 10–25% |
| Frigidaire refrigerator | Kenmore (253.x prefix) | Yes | 10–30% |
| Foxconn motherboard | Many pre-built PCs | Yes — OEM motherboard with brand-specific BIOS | Varies |
| Quanta laptop chassis | Many laptop brands (HP, Dell, Lenovo entry-level) | Often — same chassis, different branding | 15–40% |
| Pegatron router | Many consumer routers | Sometimes — same hardware, different firmware | 10–30% |
| Chinese OEM Android phones | Many regional brands (BLU, Umidigi, Doogee rebrands) | Yes — same board, different shell | 30–70% |

## How to Identify Cross-Brand Identical Products

### 1. Model Number Prefix Decoding (Appliances)

Many rebrand brands encode the OEM in the model number prefix:

| Brand | Prefix | OEM |
|-------|--------|-----|
| Kenmore | 110.x, 665.x, 110.x | Whirlpool |
| Kenmore | 790.x, 791.x | Frigidaire |
| Kenmore | 253.x | Frigidaire |
| Kenmore | 799.x | LG |
| Kenmore | 106.x | Whirlpool |
| Kenmore Elite | 720.x | LG |
| Kenmore | 417.x | Frigidaire |

Search `<brand> model number prefix decoder` or `<brand> who makes it` to
find the OEM for a specific model.

### 2. Reference Design Matching (Electronics)

Many electronics are built on a reference design provided by the chip
manufacturer. The NVIDIA DGX Spark and Acer GB10 are both built on NVIDIA's
GB10 Grace Blackwell reference design. Products built on the same reference
design share:

- Same SoC / processor
- Same PCB layout (often identical)
- Same memory configuration options
- Same I/O ports
- Same thermal design (sometimes different heatsink/fan cosmetics)

**How to find reference design matches:**
- Search the chip/SoC name + "reference design" or "partners"
- Check the chip manufacturer's partner announcements (NVIDIA, AMD, Intel,
  Qualcomm all announce launch partners for reference designs)
- Compare spec sheets — if two products have identical specs down to the
  port layout and thermal envelope, they're likely the same reference design

### 3. FCC ID Matching (All Electronics)

The FCC ID is required for all devices that emit RF. The FCC ID's first 3
characters are the grantee code (the company that submitted the device for
certification). If two differently-branded products share the same FCC ID
(or the same grantee code + similar product code), they're the same physical
device.

**How to check:**
1. Find the FCC ID on the product label or in the user manual
2. Look it up on [FCCID.io](https://fccid.io/)
3. Search the FCC ID — if multiple brand names appear, they're rebrands of
   the same device
4. Search the grantee code alone — all products from that grantee are
   manufactured by the same company

### 4. ODM / Contract Manufacturer Databases

Some products are designed and manufactured by an ODM (Original Design
Manufacturer) and sold under many brand names. Common ODMs:

| ODM | Makes products for | Product types |
|-----|-------------------|---------------|
| Foxconn | Apple, HP, Dell, Cisco, Microsoft | Laptops, phones, servers |
| Quanta | HP, Dell, Lenovo, Acer, Google | Laptops, tablets, servers |
| Compal | Acer, HP, Dell, Lenovo | Laptops, wearables |
| Pegatron | ASUS, Apple, HP, Google | Laptops, routers, phones |
| Wistron | Acer, Dell, HP, Lenovo | Laptops, IoT devices |

For ODM-built products, the internal hardware is often identical across
brands — the differences are in the case, BIOS/UEFI branding, and included
software. Search `<model> ODM` or `<model> contract manufacturer` to find
the ODM.

### 5. Community Knowledge

Forums and communities often document rebrand relationships:

- Reddit: `r/BIFL`, `r/Appliances`, `r/laptops`, `r/hardware`
- [iFixit](https://www.ifixit.com/) — teardowns reveal identical internals
  across brands
- Wikipedia — many brand articles list the OEM relationship
- Search `<brand> who makes it` or `<brand> rebrand` or `<brand> OEM`

## Cross-Brand Comparison Table Format

When cross-brand identical products are identified, present them so the user
can see they're buying the same product under different labels:

```text
## Cross-Brand Identical Products

### OEM Relationship
- OEM / Reference design: [e.g., NVIDIA GB10 Grace Blackwell reference design]
- Identified via: [FCC ID match / spec sheet comparison / model prefix / community]
- Confidence: [High (FCC ID match) / Medium (spec match) / Low (community report)]

### Comparison
| Brand | Model | Price | Differences | Warranty | Notes |
|-------|-------|-------|-------------|----------|-------|
| NVIDIA | DGX Spark | $X | Reference design, NVIDIA branding | [terms] | Official |
| Acer | GB10 AI Mini PC | $Y | Same SoC/board, Acer branding, [cosmetic diff] | [terms] | [Y% cheaper] |

### Recommendation
→ The [brand] model is the same product as [brand] at [Z%] lower cost.
→ Differences: [list any real differences — warranty, included accessories,
  firmware, support channel]
→ If differences don't matter to you, buy [cheaper brand].
```

## When Cross-Brand Differences DO Matter

Cross-brand identical doesn't always mean "buy the cheaper one." Real
differences that can justify the brand tax:

| Difference | Why it matters | Example |
|-----------|---------------|---------|
| **Warranty** | The OEM brand may offer longer or better warranty terms | NVIDIA offers 3-year warranty on DGX Spark; Acer may offer 1-year on GB10 |
| **Firmware / BIOS** | The OEM brand may get firmware updates first or exclusively | NVIDIA may release driver updates before Acer |
| **Support channel** | The OEM brand has direct manufacturer support; rebrand routes through the rebrand's support (often worse) | NVIDIA direct support vs Acer tier-1 support |
| **Included accessories** | Different packaging may include different cables, adapters, or software licenses | DGX Spark may include NVIDIA software stack; Acer may not |
| **Cosmetic / form factor** | Different chassis, color, or size — matters if it needs to fit a specific space | Acer GB10 may have different dimensions |
| **Certification / compliance** | One brand may have certifications the other lacks (MIL-STD, specific industry compliance) | Matters for enterprise/government purchases |
| **Resale value** | The OEM brand may hold resale value better due to brand recognition | NVIDIA-branded may resell higher than Acer-branded |

Always list these differences in the comparison table so the user can decide
if the savings are worth the trade-offs. See
`references/warranty-comparison.md` for the warranty dimension.

## Brand Premium Assessment (Luxury & Status Goods)

Cross-brand identical research focuses on the *same* product under different
labels. **Brand premium assessment** covers a related but distinct case:
different products of **similar quality** where one commands a significantly
higher price primarily due to brand cachet, not superior materials or
craftsmanship.

### When Brand Premium Is Not Justified by Quality

| Category | Premium brand | Comparable quality alternative | Typical premium |
|----------|--------------|-------------------------------|-----------------|
| Watches | Rolex ($10k–$50k) | Grand Seiko ($3k–$8k), Tudor ($2k–$5k), Omega ($4k–$8k) | 2–5x for the name |
| Watches | Patek Philippe ($20k+) | ALS (A. Lange & Söhne), Vacheron — comparable or better finishing | 2–3x for brand recognition |
| Handbags | Louis Vuitton ($1.5k–$5k) | Comparable quality leather from independent makers ($300–$800) | 3–10x for the monogram |
| Knives | Shun ($150–$300) | Tojiro DP ($60–$100), MAC ($80–$150) — same VG-MAX/AUS-10 steel | 2–4x for the brand |
| Cookware | Le Creuset ($200–$400) | Lodge enameled cast iron ($50–$100) — comparable for most cooking | 3–5x for the name |
| Audio cables | "Audiophile" brands ($100–$1,000) | Monoprice or Blue Jeans Cable ($10–$30) — no audible difference | 10–50x for snake oil |
| Sunglasses | Ray-Ban ($150–$300) | Comparable quality from Warby Parker, Sunski ($50–$100) | 2–4x for the logo |
| Fountain pens | Montblanc ($300–$1,000) | Pilot Custom 823 ($250), TWSBI ($60–$100) — comparable writing experience | 3–10x for the star |

### How to Assess Brand Premium

1. **Identify the core quality attributes** that matter for the product
   category (e.g., for watches: movement accuracy, finishing quality,
   water resistance, power reserve; for cookware: heat distribution,
   enamel durability, oven-safe temperature).
2. **Find alternatives with comparable or identical specifications** on
   those attributes. For watches, compare movement (in-house vs ETA,
   accuracy rating), finishing (sprung-bezel vs pressed, hand-polishing),
   and certification (COSC chronometer, Geneva Seal).
3. **Calculate the premium**: `Premium = (Brand price - Alternative price) / Alternative price`
4. **Determine what the premium buys**: Is it resale value? Social
   signaling? Warranty? Heritage? After-sales service? Or is it purely
   the logo?
5. **Present the comparison** so the user can decide if the premium is
   worth it for their use case.

### When Brand Premium IS Justified

The premium isn't always wasted money. It can buy real value:

| Justification | Why it's real | Example |
|---------------|---------------|---------|
| **Resale value** | Premium brands hold value better; the total cost of ownership may be lower | Rolex Submariner retains 70–90% of value over 10 years; Grand Seiko retains 40–60% |
| **After-sales service** | Premium brands offer better long-term service, parts availability, and repair | Montblanc lifetime warranty + repair service; Pilot does not |
| **Heritage / collectibility** | Some premium items are collectible and may appreciate | Patek Philippe, certain Rolex references, Hermès Birkin |
| **Social signaling** | If the user needs the brand for professional/social context, the premium buys that signal | A lawyer wearing a Rolex to client meetings |
| **Superior materials/specs** | Sometimes the premium brand genuinely uses better materials | Rolex 904L steel vs industry-standard 316L (more corrosion-resistant) |
| **Warranty** | Premium brands may offer longer or better warranty terms | See `references/warranty-comparison.md` |

### Brand Premium Comparison Table Format

```text
## Brand Premium Assessment

### Quality Comparison
| Attribute | Premium brand ([Brand]) | Alternative ([Brand]) | Difference |
|-----------|------------------------|----------------------|------------|
| [Core spec 1] | [value] | [value] | [Same / Premium better / Alt better] |
| [Core spec 2] | [value] | [value] | [Same / Premium better / Alt better] |
| ... | ... | ... | ... |

### Price Comparison
- Premium brand ([Brand] [model]): $X
- Alternative ([Brand] [model]): $Y
- Brand premium: $X - $Y = $Z (N% more)

### What the Premium Buys
- [Resale value: X% retention vs Y%]
- [Warranty: X years vs Y years]
- [Service: description]
- [Social signaling: yes/no — user's context]
- [Materials: difference if any]

### Recommendation
→ If [attributes that matter to the user] are comparable, the alternative
  saves $Z (N%).
→ The premium buys [list of justifications]. Worth it if [conditions].
→ Not worth it if [conditions].
```

## When to Trigger Cross-Brand Research

Run cross-brand identical research when:

- The user names a specific branded product (check if a cheaper rebrand or
  OEM-direct version exists)
- The product category is known for heavy rebranding (appliances, laptops,
  routers, Android phones, power tools)
- The effort tier is Standard or above (the research takes time; not worth it
  for Quick-tier commodity items)
- The price difference potential is significant (cross-brand savings of
  < $10 on a $100 item aren't worth the research time)

Do NOT trigger when:

- The product is a unique design with no rebrands (most phones, most
  purpose-built tools)
- The effort tier is Quick and the item is inexpensive
- The user explicitly says "I want [brand]" and brand loyalty is the priority

<!-- vim: set ft=markdown -->
