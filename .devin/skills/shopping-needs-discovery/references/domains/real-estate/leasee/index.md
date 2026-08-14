# Leasee (Tenant) — Sub-Domain Index

Constraints specific to leasing or renting property as a tenant. Referenced
by `domains/real-estate/index.md`. Load when the user is the tenant, not
the owner.

This is fundamentally different from buying — the user is not purchasing an
asset, they're entering a contractual obligation. The constraints are about
lease terms, not property characteristics (though property condition still
matters).

## How to Use This Index

1. Read the generic tenant constraints below (apply to all rentals)
2. Identify the rental type and load the matching sub-domain file
3. Surface all identified constraints in the Needs Discovery Brief

## Sub-Domain Files

| Sub-domain | When to load | Reference |
|------------|-------------|-----------|
| **Home rental** | User is renting a house, townhouse, or condo (single unit, private owner or small landlord) | `home.md` |
| **Apartment rental** | User is renting an apartment in a multi-unit building (managed by property management company) | `apartment.md` |
| **Commercial lease** | User is leasing commercial space (retail, office, industrial) | `commercial.md` |

## Generic Tenant Constraints (All Rental Types)

### Lease Term Types

| Term type | Typical duration | Notes |
|-----------|-----------------|-------|
| **Fixed-term** | 12 months | Most common; rent locked for term |
| **Month-to-month** | Indefinite | Flexibility for tenant and landlord; rent can increase with notice |
| **Short-term** | 3–6 months | Higher rent; useful for transitional periods |

### Rent Escalation

| Escalation type | How it works | Risk to tenant |
|----------------|-------------|----------------|
| **Flat** | Same rent for entire term | No risk; landlord absorbs inflation |
| **Fixed increases** | $X increase per year (e.g., 3%) | Predictable; budgetable |
| **CPI-linked** | Increases with Consumer Price Index | Variable; can spike with inflation |
| **Stepped** | Specific increases at specific dates | Predictable but can be large jumps |

**Negotiation tip**: For multi-year leases, negotiate a cap on CPI increases
(e.g., max 4%/year) to protect against inflation spikes.

### Key Lease Provisions (All Types)

| Provision | What to check | Red flag |
|-----------|-------------|----------|
| **Security deposit** | Amount, return timeline (varies by state) | Non-refundable deposits (illegal in many states) |
| **Late fees** | Amount and grace period | Excessive fees (> 10% of rent) |
| **Maintenance responsibility** | Who fixes what — landlord or tenant? | Tenant responsible for all repairs |
| **Subletting** | Allowed? Under what conditions? | No subletting clause with no exception |
| **Early termination** | Penalties, notice required | No early termination option at all |
| **Pet policy** | Allowed? Deposit? Breed/size limits? | "No pets" with no ESA exception (violates FHA) |
| **Rent increase notice** | How much notice before increase | Less than state minimum |
| **Entry notice** | Landlord entry notice period | Less than 24 hours (illegal in most states) |
| **Utilities** | Who pays which utilities | Tenant pays water/trash (unusual for apartments) |
| **Parking** | Included? Assigned? Cost? Guest parking? | No parking included in area where parking is essential |

### Hidden Costs (All Types)

- **Application fees**: $30–$75 per adult (non-refundable)
- **Move-in fees**: $200–$500 (non-refundable, vs deposit which is refundable)
- **Pet rent**: $25–$50/month per pet (in addition to pet deposit)
- **Parking**: $50–$300/month in urban areas (if not included)
- **Storage**: $50–$150/month for additional storage
- **Utilities**: Ask for 12 months of utility bills to estimate monthly cost
- **Renter's insurance**: $15–$30/month (often required by lease)

### Tenant Rights

Research the specific jurisdiction — tenant rights vary dramatically:

- **Just-cause eviction**: Some cities require landlords to have a valid
  reason to evict (non-payment, lease violation, owner move-in). Without
  just-cause protections, a landlord can refuse to renew for any reason.
- **Rent control/ stabilization**: Limits rent increases (see
  `../rental.md` for details by state)
- **Right to repair and deduct**: Some states allow tenants to pay for
  repairs and deduct from rent if landlord doesn't fix within a reasonable
  time
- **Warranty of habitability**: Landlord must maintain the property in a
  habitable condition (working heat, hot water, no infestations, no
  structural hazards)
- **Security deposit return**: Timeline and itemization requirements vary
  by state (14–30 days typical; some states require interest on deposit)

### Negotiation Leverage (All Types)

- **Off-season leasing** (Nov–Feb): Lower rents, more landlord concessions
- **Longer lease term**: Offer to sign 18–24 months for lower monthly rent
- **Strong application**: High credit score, verifiable income, good rental
  history — use as leverage to negotiate rent or fees

<!-- vim: set ft=markdown -->
