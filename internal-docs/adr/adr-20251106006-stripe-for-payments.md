---
modeline: "vim: set ft=markdown:"
title: "ADR: Use Stripe for Payment Processing"
adr-id: 20251106006
slug: 20251106006-stripe-for-payments
url: /internal-docs/adr/adr-20251106006-stripe-for-payments.md
synopsis: Adopt Stripe as the primary payment processor for handling transactions, subscriptions, and managing tax compliance where available.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "payments", "stripe", "billing", "saas"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

The application will offer paid services, requiring a secure and reliable system to process payments, manage subscriptions, and handle complex requirements like international sales tax. We need a solution that is developer-friendly, scalable, and globally recognized.

## Constraints

- The solution must be PCI compliant.
- It must support a wide range of payment methods and currencies.
- It must provide robust APIs and webhooks for integration with our backend services.
- It must have features for managing subscriptions and recurring billing.
- It should offer tools for tax calculation and compliance.

## Decision

We will use **Stripe** as our primary payment processing platform.

## Rationale

- **Industry Standard**: Stripe is a global leader in online payments, trusted by millions of businesses. Its reliability, security, and feature set are well-established.
- **Developer Experience**: Stripe is renowned for its excellent documentation, powerful APIs, and developer-first approach, which will accelerate our implementation.
- **Comprehensive Feature Set**: Stripe offers a complete suite of products beyond simple payments, including `Stripe Billing` for subscriptions, `Stripe Tax` for automated sales tax calculation, and `Stripe Connect` for multi-party payments.
- **Scalability and Global Reach**: Stripe is built to scale and supports businesses in dozens of countries, which aligns with our long-term growth ambitions.

## Consequences

- **Positive**:
  - We offload the immense complexity and security burden of handling payment information to a trusted third party.
  - Rapid development of billing and payment features due to Stripe's excellent APIs and documentation.
  - Access to a powerful ecosystem of tools for managing revenue, fraud, and taxes.

- **Negative**:
  - We will incur transaction fees on all payments processed.
  - We are dependent on a third-party service, creating vendor lock-in. An outage at Stripe could impact our ability to collect revenue.

## Alternatives Considered

- **Polar.sh**: This platform was considered as a potential alternative for handling payments in countries where Stripe's tax features might be limited. However, Polar.sh is primarily a **funding platform for open-source projects** (facilitating sponsorships and donations) and not a general-purpose payment processor for SaaS applications. It is not a suitable alternative to Stripe for our use case.
- **Paddle**: A strong competitor to Stripe, often favored for its all-in-one approach where it acts as the merchant of record, simplifying global tax and compliance. However, Stripe's API is generally considered more flexible and powerful.
- **Braintree (a PayPal service)**: Another major player in the payment space. It offers a solid feature set but is often seen as having a less modern API and developer experience compared to Stripe.
- **Building In-House**: This is not a viable option due to the immense complexity, security risks, and regulatory burden (PCI compliance) involved in handling raw payment data.

## Rollout / Migration

1. A Stripe account will be created and configured with the necessary business information.
2. A new internal service (`@/features/billing/server`) will be created to handle all interactions with the Stripe API, including creating customers, managing subscriptions, and processing webhooks.
3. The frontend will integrate with `Stripe.js` and the backend service to create a secure payment flow.
4. Initial implementation will be done in test mode to ensure all subscription and payment logic is correct before going live.

## References

- [Stripe](https://stripe.com/)
- [Stripe Tax](https://stripe.com/tax)
- [Polar.sh](https://polar.sh/) (Alternative Considered)

<!-- vim: set ft=markdown: -->
