# Stock Monitoring & Rare Opportunity Alerts — Reference

Detailed tooling, alert classification, and output formats for monitoring out-of-stock, limited-edition, or scarce items. Referenced by `SKILL.md` section "2. Stock Monitoring & Rare Opportunity Alerts".

## Monitoring Setup

| Tool | Use Case | Alert Speed |
|------|----------|-------------|
| [NowInStock](https://www.nowinstock.net/) | Consoles, GPUs, high-demand electronics | Near real-time |
| [HotStock](https://www.hotstock.io/) | App-based restock alerts | Push notifications |
| [CamelCamelCamel](https://camelcamelcamel.com/) | Amazon price drop alerts | Email/push |
| [Distill.io](https://distill.io/) | Any webpage change monitoring | Configurable (seconds to hours) |
| Store-specific wishlists | Retailer restock notifications | Email |
| eBay saved searches | Used/auction availability | Email digest |
| Reddit / Discord communities | Niche product drops | Community-driven |

## Alert Classification

| Priority | Condition | Action |
|----------|-----------|--------|
| 🔴 **Critical** | Item at or below target price + in stock + essential deadline approaching | Auto-buy if authorized; otherwise immediate notification |
| 🟡 **High** | Item restocked but above target price | Notify user with price comparison |
| 🟢 **Informational** | Similar item available; price trend change | Include in weekly digest |

## Monitoring Output Format

```markdown
## Stock Alert: [Product Name]

- 🔴 Priority: CRITICAL
- Source: [Retailer / Platform]
- Price: $X.XX (target was $Y.XX — Z% below target)
- Condition: [New / Refurbished / Used - Excellent]
- Stock level: [X units remaining / Unknown]
- Link: [URL]
- Estimated sell-out: [time estimate based on demand signals]

### Recommended Action
→ [BUY NOW — within auto-buy parameters] or [NOTIFY USER]
```

<!-- vim: set ft=markdown -->
