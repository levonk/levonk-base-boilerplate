# Purchase Optimization Reference

## Optimization Stack Steps

Step-by-step layering of savings mechanisms to minimize total out-of-pocket cost. Referenced by `SKILL.md` section "4. Purchase Optimization Stack".

1. **Gift card discounts**: Buy discounted gift cards from [Raise](https://www.raise.com/), [CardCookie](https://www.cardcookie.com/), or credit card portal gift card offers (e.g., Chase Ultimate Rewards, Amex Offers) — typically 3–15% off
2. **Affiliate cashback portals**: Route purchase through [Rakuten](https://www.rakuten.com/), [TopCashback](https://www.topcashback.com/), [BeFrugal](https://www.befrugal.com/), [Bing Shopping cashback](https://www.bing.com/shop), [Capital One Shopping](https://capitaloneshopping.com/), or [Chase Offers](https://www.chase.com/personal/chase-offers) — typically 1–15% back
3. **Credit card category bonuses**: Use the card with the highest multiplier for the merchant category (e.g., 5x on rotating categories, 3x on online shopping)
4. **Credit card benefits**: Extended warranty (most cards add 1–2 years), purchase protection (120 days), price protection (60–90 days), return protection
5. **Coupon stacking**: Browser extensions ([Honey](https://www.joinhoney.com/), Capital One Shopping), retailer coupons, manufacturer coupons, promo codes from deal sites
6. **Price matching**: Target, Best Buy, and others price match Amazon and competitors

## Savings Stack Output Format

```text
## Savings Stack

| Layer | Source | Savings | Details |
|-------|--------|---------|---------|
| Base price | [Retailer] | — | $X.XX |
| Gift card | [Source] @ Y% off | -$X.XX | Buy $100 card for $92 |
| Cashback | [Portal] @ Z% | -$X.XX | Route through Rakuten |
| Card bonus | [Card] @ Nx points | ~$X.XX value | Category bonus |
| Coupon | [Code] | -$X.XX | Stacks with sale |
| **Net cost** | | | **$X.XX** |
| **Total saved** | | | **$X.XX (Y%)** |

### Bonus Benefits
- Extended warranty: +2 years via [Card]
- Purchase protection: 120 days via [Card]
- Price protection: If price drops within 60 days, [Card] refunds difference
```

## Card Selection From `payment_methods`

When the user has provided `payment_methods` in their request, use that data to select the optimal card:

1. Match the retailer's merchant category to each card's `categories_bonus`
2. Pick the card with the highest multiplier for this category
3. Check if that card has active portal offers (Chase Offers, Amex Offers) for additional stacking
4. Apply any available gift card balances first (reduces the amount charged to credit card)
5. Factor in card benefits (extended warranty, purchase protection) as tie-breakers

## Cashback Portal Comparison

| Portal | Typical Rates | Best For | Notes |
|--------|--------------|----------|-------|
| [Rakuten](https://www.rakuten.com/) | 1–15% | Broad retailer coverage | Quarterly bonus events; pays via PayPal or check |
| [TopCashback](https://www.topcashback.com/) | 1–20% | Highest rates per-store | Slower payout; "Elevated" rates beat Rakuten frequently |
| [BeFrugal](https://www.befrugal.com/) | 1–15% | Rate matching guarantee | Will match any competitor's higher rate |
| [Capital One Shopping](https://capitaloneshopping.com/) | 1–10% (credits) | Auto-coupon + cashback combo | No Capital One card required; browser extension |
| [Bing Shopping](https://www.bing.com/shop) | 1–10% (Microsoft Rewards) | Microsoft Rewards ecosystem | Points convert to gift cards |
| [Chase Offers](https://www.chase.com/personal/chase-offers) | 5–15% (statement credit) | Targeted per-card offers | Limited time; activate before purchase |
| [Amex Offers](https://www.americanexpress.com/en-us/benefits/offers/) | 5–20% (statement credit) | High-value targeted offers | Add to card before purchasing |
| [PayPal Cashback](https://www.paypal.com/us/webapps/mpp/cashback) | 1–5% | PayPal checkout | Automatic with eligible purchases |
| [Ibotta](https://home.ibotta.com/) | Varies | Groceries, retail | Receipt scanning + online cashback |
| [RetailMeNot](https://www.retailmenot.com/) | 1–10% | Coupon + cashback combo | Browser extension available |

**Rule**: Always compare rates across at least 3 portals before purchasing. Rates change daily.

**Stacking order**: Gift card discount → cashback portal → credit card bonus category → coupon code

## Credit Card Category Bonuses (Common Structures)

### Rotating 5x Categories (Quarterly)
- **Chase Freedom Flex**: Amazon, grocery, gas, restaurants, PayPal, Walmart (varies by quarter)
- **Discover it**: Same categories as Chase, doubled first year (effectively 10%)
- **Citi Custom Cash**: 5% on your top spend category each month (automatic)

### Fixed High-Rate Categories
- **Amex Blue Cash Preferred**: 6% grocery (up to $6k/yr), 6% streaming, 3% transit
- **Chase Sapphire Reserve**: 3x dining + travel (effectively 4.5% via portal)
- **Amex Gold**: 4x restaurants + grocery (up to $25k/yr)
- **Capital One SavorOne**: 3% dining, entertainment, grocery, streaming
- **US Bank Altitude Go**: 4x dining, 2x grocery/streaming/gas

### Online Shopping Cards
- **Amex Blue Cash Everyday**: 3% online retail (up to $6k/yr)
- **PayPal Cashback Mastercard**: 3% PayPal purchases, 2% everywhere
- **Amazon Visa (Prime)**: 5% Amazon + Whole Foods
- **Target RedCard**: 5% Target (debit or credit)
- **Walmart+ credit card**: 5% Walmart.com, 2% in-store

## Extended Warranty Stacking

Most credit cards add 1–2 years of extended warranty beyond manufacturer warranty:

| Card Tier | Extension | Max Benefit | Coverage |
|-----------|-----------|-------------|----------|
| Chase Sapphire Reserve | +1 year | $10,000/claim | Up to 3 years original warranty |
| Amex Platinum | +2 years | $10,000/claim | Up to 5 years original warranty |
| Chase Freedom Flex | +1 year | $10,000/claim | Up to 3 years original warranty |
| Citi Double Cash | +2 years | $10,000/claim | Up to 5 years original warranty |
| Capital One Venture X | +1 year | $10,000/claim | Up to 3 years original warranty |

**Strategy**: For expensive electronics, use a card with +2 year warranty extension to get a total of 3+ years coverage at no cost.

## Gift Card Discount Sources

| Source | Discount Range | Notes |
|--------|---------------|-------|
| [Raise](https://www.raise.com/) | 2–15% | Largest marketplace; verified sellers |
| [CardCookie](https://www.cardcookie.com/) | 2–12% | Aggregates prices across resellers |
| Chase Ultimate Rewards Portal | 20–25% (via points) | If you have Chase points, gift cards are redeemed at 1.25–1.5 cpp |
| Costco | 10–20% | Bundled gift card packs (restaurants, entertainment) |
| Sam's Club | 10–20% | Similar to Costco |
| Target Circle offers | 5–10% | Periodic gift card promotions |
| Amex Membership Rewards | Varies | Targeted gift card offers through portal |

## Purchase Protection Quick Reference

| Protection | What it covers | Typical term | Best cards |
|-----------|---------------|-------------|------------|
| **Price protection** | Refunds price drops after purchase | 60–120 days | Citi (via Citi Price Rewind), some Amex |
| **Purchase protection** | Theft or damage to new purchases | 90–120 days | Chase Sapphire, Amex Platinum |
| **Return protection** | Retailer won't accept return; card reimburses | 90 days | Amex (up to $300/item) |
| **Extended warranty** | Extends manufacturer warranty | +1–2 years | See table above |
| **Cell phone protection** | Cracked screen, theft | Ongoing (pay phone bill with card) | Wells Fargo Active Cash, Chase Ink |

## Optimization Checklist

Before every purchase over $50:

- [ ] Check CamelCamelCamel / price history for current price vs all-time low
- [ ] Compare at least 3 cashback portals for best rate
- [ ] Check for discounted gift cards at Raise/CardCookie
- [ ] Activate any Chase Offers / Amex Offers for the retailer
- [ ] Search for coupon codes on Slickdeals, RetailMeNot, Honey
- [ ] Select credit card with highest multiplier for merchant category
- [ ] Confirm card provides extended warranty or purchase protection if needed
- [ ] Check if retailer price-matches (Best Buy, Target, etc.)
- [ ] Verify cashback portal tracks the purchase (screenshot confirmation page)

<!-- vim: set ft=markdown -->
