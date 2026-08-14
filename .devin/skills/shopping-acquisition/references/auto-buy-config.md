# Auto-Buy Configuration & Execution — Reference

Detailed configuration schema, execution steps, and safeguards for pre-authorized automatic purchases. Referenced by `SKILL.md` section "3. Auto-Buy Execution".

## Required Parameters

Auto-buy requires ALL of these user-provided parameters:

```yaml
auto_buy:
  enabled: true
  product: "exact product identifier or match criteria"
  max_price: 500.00          # will not buy above this
  condition: "new|refurbished|used-like-new"  # minimum acceptable condition
  preferred_retailers:        # ordered list
    - amazon
    - bestbuy
    - walmart
  payment_priority:            # ordered list from payment_methods
    - "gift_card:Amazon"       # use gift card balance first
    - "credit_card:4321"       # then Chase Sapphire Reserve
    - "credit_card:9876"       # fallback to Amex BCP
  optimization_required: true  # must route through cashback portal
  shipping:
    max_days: 5
    max_cost: 0               # free shipping only
  notification: "always"      # always | on_failure | never
```

## Execution Steps

1. **Validate** all conditions are met (price ≤ max, condition ≥ minimum, retailer in list)
2. **Select payment** from `payment_priority` — apply gift card balances first, then charge remainder to best credit card
3. **Optimize** purchase path (gift card + portal + card — per deal-intelligence stack)
4. **Execute** purchase through preferred retailer
5. **Confirm** order number, payment method used, and delivery estimate
6. **Notify** user with purchase receipt, card used, and optimization breakdown

## Safeguards

- Never exceed `max_price` under any circumstance
- Never buy from a retailer not on `preferred_retailers` list
- Never charge a card not in the user's `payment_methods`
- Apply gift card balances before credit card charges
- Always apply optimization stack if `optimization_required` is true
- Log every auto-buy decision with full reasoning for audit (including card selection rationale)

<!-- vim: set ft=markdown -->
