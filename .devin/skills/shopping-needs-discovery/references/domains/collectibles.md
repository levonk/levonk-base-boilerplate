# Collectibles — Domain Reference

Domain-specific constraints for collectibles: watches, coins, cards, comics,
art, wine, sneakers, vinyl, toys, and antiques. Referenced by
`references/constraint-attributes.md`. Load when the user is buying
collectibles. Value depends on authenticity, condition, provenance, and
market liquidity. Fraud risk is high.

## Authentication

| Category | Authentication service | What they verify |
|----------|----------------------|-----------------|
| Designer bags | Entrupy | AI-based material/hardware analysis |
| Trading cards | PSA, SGC, Beckett | Card authenticity + condition grade |
| Comics | CGC, CBCS | Authenticity + condition grade |
| Coins | PCGS, NGC | Authenticity + grade (Sheldon scale) |
| Autographs | Beckett (BAS), JSA | Signature authenticity |
| Watches | Manufacturer archive lookup | Serial + reference number match |
| Sneakers | StockX, GOAT authentication | Legitimacy check |
| Art | Independent appraiser, provenance | Attribution, provenance chain |

**Watches**: Luxury brands (Rolex, Omega, Patek) verify serial/reference
numbers against archives (sometimes for a fee). This confirms production but
not authenticity — fakes may use real serial numbers from stolen records.

## Grading

| Category | Service | Scale | Impact |
|----------|---------|-------|--------|
| Trading cards | PSA | 1–10 (10 = gem mint) | PSA 10 can be 5–10x PSA 9 |
| Comics | CGC | 0.5–10.0 | CGC 9.8 commands large premium |
| Coins | PCGS/NGC | Sheldon scale 1–70 | MS-70 vs MS-69 can double value |
| Watches | None standardized | Condition descriptors | "Mint" vs "good" affects price 20–50% |

**Graded items command 2–10x raw** for high-grade examples. Grading cost
($20–$300) is often worth it. Novices overestimate grade — factor in grading
cost and risk of a lower-than-expected grade.

## Provenance

| Provenance type | Value impact |
|----------------|-------------|
| Auction records (Sotheby's, Christie's, Heritage) | High — public, verifiable |
| Original receipts and boxes (watches) | High — "full set" adds 10–30% |
| Celebrity/historical ownership | Very high — can multiply value several times |
| Dealer records | Moderate — depends on dealer reputation |
| Verbal provenance only | Low — unverified, often fabricated |

**Demand documentation** for high-value items — a dated receipt, auction
catalog, or insurance rider, not verbal claims.

## Storage Conditions

| Category | Temperature | Humidity | Other |
|----------|------------|----------|-------|
| Wine | 55°F (constant) | 70% | Dark, vibration-free, horizontal |
| Comics/cards | 65–72°F | 40–50% | Acid-free boards/bags, UV-free |
| Watches | Room temp | 30–50% | Service history, storage position |
| Coins | Room temp | 30–50% | Acid-free holders, no PVC |
| Art | 65–75°F | 40–55% | UV-filtered glass, climate control |

**Wine is most storage-sensitive**: Temperature fluctuations damage wine.
Above 70°F, wine ages prematurely; above 77°F, it cooks. A wine fridge
($200–$2000) is essential. **Comics/cards**: UV fades ink; acid-free boards
prevent migration; Mylar bags are archival quality.

## Insurance

| Method | When to use | Requirements |
|--------|------------|--------------|
| Scheduled rider (homeowners/renters) | Most collectibles | Appraisal, itemized list |
| Specialty insurer (Collectibles Insurance Services) | High-value or large collection | Appraisal, photos, storage verification |
| Separate policy | Very high value | Professional appraisal |

## Liquidity

| Category | Liquidity | Time to sell |
|----------|----------|-------------|
| Coins (bullion) | Very high | Days |
| Trading cards (graded) | High | Days–weeks |
| Watches (Rolex, Omega) | High | Weeks |
| Sneakers (hyped) | High | Days–weeks |
| Comics/vinyl (graded) | Moderate | Weeks–months |
| Art/antiques | Low | Months–years |
| Wine | Moderate | Weeks–months (auction) |

## Market Trends

Check recent **sold** prices, not asking prices — sold prices reflect reality.

| Category | Price sources |
|----------|--------------|
| Trading cards | eBay sold listings, PWCC, 130point, CardLadder |
| Comics | eBay sold, GPA Analysis (CGC sales) |
| Coins | PCGS PriceGuide, eBay sold, Heritage auctions |
| Watches | Chrono24, WatchCharts, eBay sold |
| Art/specialty | Heritage, Sotheby's, Christie's auction results |

## Fakes & Reproductions

| Category | Counterfeit risk | Common fakes |
|----------|-----------------|--------------|
| Luxury watches | Very high | Super-clones (Rolex, Patek) — serial numbers cloned |
| Designer bags | Very high | Counterfeit hardware, leather |
| Autographs | High | Forged signatures, secretarials |
| Vintage comics | High | Reprints sold as originals, restored comics |
| Rare coins | High | Altered dates, cast counterfeits |
| Sneakers | High | "Replicas" — near-identical construction |

**Mitigation**: Buy from reputable dealers, demand authentication, factor
cost into price. For high-value items, use escrow and third-party
authentication before payment.

## Condition Sensitivity

Mint condition items can lose 50%+ of value with minor damage. A PSA 10
dropped to PSA 8 loses 70–80%. **Handle carefully**: cotton gloves for
cards/coins, watch cases, archival sleeves. Never display in direct sunlight.

<!-- vim: set ft=markdown -->
