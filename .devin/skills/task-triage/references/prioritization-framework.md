# Prioritization Framework Reference

Detailed reference for the Agent Organization 26-tier prioritization framework, including tier listings, adjustment tables, decision matrices, and escalation rules.

## The 26-Tier Framework

### Tier 1: Security (Immediate Action Required)

1. **Security - Incidents** — Isolate from network to prevent data leakage and investigate
2. **Security - Immediate High Risks** — Exposure to new major exploit

### Tier 2: Critical System Issues

3. **Unplanned Outage / Reduction in Service** — Core systems down
4. **Critical Current Clients: Keep** — Revenue-critical relationships at risk
5. **Functionality Issues: Urgent & Important** — Core features broken

### Tier 3: Scheduled Critical Work

6. **Scheduled Tasks: Urgent & Important** — Time-sensitive commitments

### Tier 4: Important Maintenance

7. **Non-Critical Current Clients: Keep** — Standard relationship maintenance
8. **Scheduled Tasks: Not Urgent & Important** — Planned improvements
9. **Functionality Issues: Not Urgent & Important** — Non-critical bug fixes

### Tier 5: Revenue & Growth Opportunities

10. **Guaranteed Profit Opportunities** — Near-certain revenue
11. **Unblock Internal Teams** — Enable other revenue-generating work

### Tier 6: Lower-Priority Scheduled Work

12. **Scheduled Tasks: Urgent & Not Important** — Time-sensitive but low value
13. **Scheduled Tasks: Not Urgent & Important** — Important but flexible timing

### Tier 7: Client Expansion

14. **Current Clients: Upsell** — Expand existing relationships

### Tier 8: New Client Acquisition

15. **Acquire Clients: Recurring Revenue** — New ongoing revenue streams
16. **Acquire Clients: Flat Revenue** — One-time revenue opportunities

### Tier 9: Strategic Investment

17. **High EBITDA Tech Debt** — ROI-positive infrastructure work
18. **Planned R&D** — Scheduled innovation investment

### Tier 10: Lower Priority Technical Debt

19. **Tech Debt: Urgent & Important** (routine)
20. **Speculative R&D** — Experimental, unproven

### Tier 11: Backlog & Low Priority

21. **Tech Debt: Not Urgent & Important**
22. **Tech Debt: Urgent & Not Important**
23. **Functionality Issues: Urgent & Not Important**
24. **Functionality Issues: Not Urgent & Not Important**
25. **Tech Debt: Not Urgent & Not Important**

## Requestor Priority Adjustments

The entity making the request modifies the effective priority:

| Requestor Level | Adjustment |
|-----------------|------------|
| **Principal / Chief of Staff** | +3 tiers (max Tier 1) |
| **Established Business (Critical)** | +2 tiers |
| **Established Business (Standard)** | No adjustment |
| **Venture Studio Pod (Active)** | -1 tier |
| **Venture Studio Pod (Experimental)** | -3 tiers |
| **External / Unknown** | Case by case; typically defer |

## Cost/Capacity Constraints

The Shared Services team evaluates capacity impact:

| Cost Level | Action |
|------------|--------|
| **Low Cost (< 2 hours)** | Accept within tier bounds |
| **Medium Cost (2-8 hours)** | Accept if tier ≤ 10 |
| **High Cost (8-40 hours)** | Accept if tier ≤ 7 |
| **Very High Cost (> 40 hours)** | Accept only if tier ≤ 3; otherwise escalate to CoS |

## Decision Matrix

| Effective Tier | Low Cost | Medium Cost | High Cost | Very High Cost |
|----------------|----------|-------------|-----------|----------------|
| **1-3** | Auto-accept | Auto-accept | Auto-accept | Escalate to CoS |
| **4-7** | Auto-accept | Auto-accept | Accept | Defer/Reject |
| **8-10** | Auto-accept | Accept | Defer/Reject | Reject |
| **11-15** | Accept | Defer | Reject | Reject |
| **16-20** | Defer | Reject | Reject | Reject |
| **21-26** | Reject | Reject | Reject | Reject |

## Cross-Cutting Priority Adjustments

Additional dimensions that modify base tier:

| Trigger | Adjustment |
|---------|------------|
| Regulatory deadline < 48 hours | +5 tiers |
| Active litigation | +4 tiers |
| Viral negative PR coverage | +3 tiers |
| >$100,000 revenue at risk | +3 tiers |
| Security incident | Override to Tier 1 |

## Escalation Rules

Escalate to Chief of Staff when:

- Tier conflict (same-priority requests competing for same resources)
- Cross-function coordination required
- Governance boundary unclear
- Requestor disputes priority assignment
- Very high cost request (> 40 hours)
- Security incident requiring principal notification

## Eisenhower Matrix Application

The 26-tier framework maps to Eisenhower quadrants:

### DO FIRST (Urgent & Important) — Tiers 1-8

- Security incidents, legal emergencies, system outages
- Critical client escalations, regulatory deadlines
- PR crises, safety incidents

### SCHEDULE (Not Urgent & Important) — Tiers 9-16

- Planned security hardening, contract negotiations
- Strategic communications, high-ROI tech debt
- Client upsell planning, financial planning

### DELEGATE (Urgent & Not Important) — Tiers 17-22

- Routine maintenance, low-priority client work
- Scheduled low-value tasks, urgent tech debt
- Minor functionality issues

### ELIMINATE (Not Urgent & Not Important) — Tiers 23-26

- Backlog tech debt, low-priority functionality issues
- Non-urgent tech debt, speculative work

## Example Triage Conversations

### Example 1: Security Incident

**User**: "We detected a data leak in the customer database."

**Triage**:

- Base Tier: 1 (Security - Incidents)
- Cross-Cutting: Security incident → Override to Tier 1
- Requestor: Venture Pod B → Tier 1 (cannot go lower)
- Cost: High (forensics + remediation)
- Decision: **EXECUTE IMMEDIATELY** — Security incidents bypass all cost limits

### Example 2: Feature Request

**User**: "Can you add a new dashboard widget for the sales team?"

**Triage**:

- Base Tier: 9 (Functionality Issues: Not Urgent & Important)
- Cross-Cutting: None
- Requestor: Established Business A (Critical Client) → +2 tiers
- Effective Tier: 7 (9 - 2 = 7)
- Cost: Medium (4 hours)
- Decision: **ACCEPT** — Within tier 7 bounds for medium cost

### Example 3: Tech Debt

**User**: "We need to refactor the legacy authentication module."

**Triage**:

- Base Tier: 22 (Tech Debt: Not Urgent & Important)
- Cross-Cutting: None
- Requestor: Venture Pod C (Experimental) → -3 tiers
- Effective Tier: 25 (22 - 3 = 25)
- Cost: Very High (60 hours)
- Decision: **DEFER / REJECT** — Below threshold; low priority queue suggests pod handles internally or uses contingent workforce
