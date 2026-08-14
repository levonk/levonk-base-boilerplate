# Market Timing Calendar & Signal Interpretation

## Timing Signal Summary

Quick-reference table of signals and the action each suggests. Referenced by `SKILL.md` section "3. Market Timing Analysis".

| Signal | Indicator | Action |
|--------|-----------|--------|
| **Seasonality** | Post-holiday clearance, end-of-model-year | Buy after season peaks (e.g., grills in Sept, snow blowers in March) |
| **Upcoming weather** | Hurricane, tornado, wildfire season | Buy before demand spikes for generators, plywood, etc. |
| **Economic cycle** | Fed rate decisions, recession indicators | Large purchases (homes, cars) may benefit from rate drops |
| **Search traffic** | Google Trends rising for the product | Rising interest = rising prices; buy before the spike |
| **Ad cost signals** | CPM/CPC increases in the product's category | Sellers spending more on ads = demand is growing = buy now |
| **Product lifecycle** | New model announced, predecessor being cleared | Wait for clearance pricing on outgoing models |
| **Retail calendar** | Prime Day, Black Friday, Presidents Day, Memorial Day | Time purchase to known sale events if timeline allows |
| **Regulatory** | New tariffs, import restrictions, bans | Buy before regulation reduces supply |
| **Inventory signals** | "Only X left in stock", warehouse clearance | Low inventory with no restock = buy now; clearance = wait for deeper cuts |
| **Government fiscal calendar** | Federal fiscal year ends Sept 30; agencies clear surplus before year-end | Sept surge in GSA Auctions and DLA listings as agencies dispose of excess property |
| **Police auction hold periods** | Seized/found property held 30–90 days before auction (varies by state) | New police auction inventory appears continuously; check PropertyRoom and GovDeals weekly |
| **Estate sale schedule** | Estate sales run Fri–Sun; day 1 full price, day 2 25–50% off, day 3 half-price/make offer | Best prices on Sunday afternoon; best selection Friday morning |
| **Repo cycles** | Repossessions spike after holiday season (Jan–Feb) and mid-summer (July–Aug) when loan delinquencies peak | More repo inventory at credit unions and Copart/IAAI during these windows |

## Timing Recommendation Output Format

```text
## Timing Recommendation

- Best time to buy: [date range]
- Reason: [explanation referencing signals above]
- Risk of waiting: [what happens if user waits past essential date]
- Current price vs expected best price: $X now → ~$Y at optimal time
- Recommendation: [BUY NOW | WAIT UNTIL <date> | SET ALERT]
```

## Monthly Buying Calendar

| Month | Best categories to buy | Why |
|-------|----------------------|-----|
| **January** | Fitness equipment, bedding, winter clothing, Christmas decor | New Year clearance, post-holiday excess |
| **February** | TVs, furniture (Presidents Day), winter gear | Super Bowl TV deals, Presidents Day sales |
| **March** | Frozen food, luggage, winter sports gear | National Frozen Food Month, end-of-season |
| **April** | Vacuums, cookware, sneakers | Spring cleaning promos |
| **May** | Mattresses, appliances (Memorial Day), refrigerators | Memorial Day sales, pre-summer |
| **June** | Tools, gym memberships, lingerie, menswear | Father's Day, semi-annual sales |
| **July** | Furniture, clothing, electronics (Prime Day) | Amazon Prime Day ripple, summer clearance start |
| **August** | Back-to-school electronics, laptops, school supplies, outdoor furniture | Back-to-school, patio clearance |
| **September** | Grills, outdoor gear, bikes, cars, iPhones (outgoing model), **government surplus** | End of summer, new model year cars, new iPhone launch, **federal fiscal year-end Sept 30 — agencies surge surplus listings** |
| **October** | Jeans, patio furniture, prior-gen electronics | Pre-holiday positioning, Prime Big Deal Days |
| **November** | Everything (Black Friday/Cyber Monday), TVs, toys, laptops | Biggest sale event of the year |
| **December** | Gift cards, toys (clearance after 12/25), holiday decor (12/26+) | Post-Christmas clearance starts 12/26 |

## Signal Interpretation Guide

### Bullish Signals (Buy Soon)

| Signal | Interpretation | Source |
|--------|---------------|--------|
| Google Trends rising sharply | Demand increasing → prices will follow | [Google Trends](https://trends.google.com/) |
| Manufacturer announces supply constraints | Shortage incoming → buy before stockout | Industry news, earnings calls |
| New tariffs announced | Import costs rise → retail prices rise in 30–90 days | [USTR](https://ustr.gov/), trade news |
| Hurricane/tornado/wildfire forecast | Generators, plywood, water — buy immediately | [NHC](https://www.nhc.noaa.gov/), [SPC](https://www.spc.noaa.gov/) |
| Competitor exits market | Remaining options lose price competition | Industry news |
| Raw material cost spike | Manufactured goods prices lag by 60–120 days | Commodity indices |

### Bearish Signals (Wait / Prices Dropping)

| Signal | Interpretation | Source |
|--------|---------------|--------|
| New model announced | Current model enters clearance cycle | Manufacturer press releases |
| Retailer inventory surplus | Deeper discounts coming | Earnings calls, warehouse sale announcements |
| Post-season | Seasonal items drop 30–60% | Retail calendar above |
| Fed rate cut | Big-ticket financing gets cheaper | [Fed Reserve](https://www.federalreserve.gov/) |
| Recession indicators | Discretionary spending drops → sellers discount | [NBER](https://www.nber.org/research/data/us-business-cycle-expansions-and-contractions) |
| Search traffic declining | Demand softening → sellers may cut prices | Google Trends |
| CPC/CPM dropping in category | Advertisers pulling back → demand cooling | Industry ad benchmarks |

### Neutral / Watch Signals

| Signal | Interpretation |
|--------|---------------|
| Price stable for 90+ days | Fair market value established; deal unlikely without catalyst |
| Mixed reviews on new model | Wait 60–90 days for firmware/revision fixes before buying new |
| Trade show upcoming (CES, MWC, IFA) | New announcements may obsolete current picks; wait if timeline allows |

## Product Lifecycle Timing

```
[Announcement] → [Pre-order Premium +10-20%] → [Launch MSRP] → [3-month Settling -5%]
→ [6-month First Sales -10-15%] → [12-month Established -15-25%]
→ [Next Gen Announced → Clearance -25-40%] → [Discontinued → Scarcity +10%]
```

**Key insight**: The sweet spot for most electronics is 3–6 months after launch or immediately after the successor is announced.

## Macro-Economic Timing

- **Rising interest rates**: Bad time for large financed purchases (cars, homes); sellers may discount to compensate
- **Falling interest rates**: Good time for financed purchases; asset prices may rise so buy before the rush
- **High unemployment**: Sellers of discretionary goods discount aggressively; good time for furniture, electronics, vehicles
- **Supply chain disruption**: Buy early or buy used; new inventory gets expensive and scarce
- **Strong dollar**: Imported goods are cheaper; good time for electronics, European luxury goods
- **Weak dollar**: Domestic goods are relatively cheaper; avoid import-heavy categories

<!-- vim: set ft=markdown -->
